import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/core/database/db_helper.dart';
import 'package:gym_workout_tracking/models/body_measurement.dart';
import 'package:gym_workout_tracking/models/workout_session.dart';
import 'package:gym_workout_tracking/models/workout_set.dart';
import 'package:gym_workout_tracking/repositories/measurement_repository.dart';
import 'package:gym_workout_tracking/repositories/workout_repository.dart';
import 'package:gym_workout_tracking/services/backup_service.dart';

import '../test_db_helper.dart';

void main() {
  late Directory tempDir;
  late BackupService service;
  late WorkoutRepository workoutRepo;

  setUp(() async {
    tempDir = await setupTestDatabase();
    service = BackupService();
    workoutRepo = WorkoutRepository();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  Future<({int sessionId, int benchId, int runningId})> seedData() async {
    final exercises = await workoutRepo.getExercises();
    final bench = exercises.firstWhere((e) => e.name == 'Bench Press');
    final running =
        exercises.firstWhere((e) => e.name == 'Running (Treadmill)');

    final sessionId = await workoutRepo.insertSession(WorkoutSession(
        date: '2026-06-01T10:00:00.000',
        duration: 3600,
        routineName: 'Push Day'));
    final setId = await workoutRepo.insertSet(WorkoutSet(
        sessionId: sessionId, exerciseId: bench.id!, weight: 80, reps: 8));
    await workoutRepo.updateSetCompletion(setId, true);
    final cardioId = await workoutRepo.insertSet(WorkoutSet(
        sessionId: sessionId,
        exerciseId: running.id!,
        weight: 0,
        reps: 0,
        durationSeconds: 1800,
        distanceMeters: 5000));
    await workoutRepo.updateSetCompletion(cardioId, true);
    await MeasurementRepository().insertMeasurement(BodyMeasurement(
        date: '2026-06-01T09:00:00.000',
        bodyWeight: 75,
        bodyFatPercentage: 15,
        waist: 82));
    return (sessionId: sessionId, benchId: bench.id!, runningId: running.id!);
  }

  test('JSON backup round-trips with identical ids and cardio fields',
      () async {
    final seeded = await seedData();
    final backup = await service.exportJsonBackup();

    // Wipe everything by importing an empty (but valid) backup.
    await service.importJsonBackup(jsonEncode({
      'schemaVersion': 3,
      'tables': <String, dynamic>{},
    }));
    expect(await workoutRepo.getSessions(), isEmpty);
    expect(await workoutRepo.getExercises(), isEmpty);

    // Restore the original.
    await service.importJsonBackup(backup);

    final sessions = await workoutRepo.getSessions();
    expect(sessions.single.id, seeded.sessionId);
    expect(sessions.single.duration, 3600);

    final sets = await workoutRepo.getSetsForSession(seeded.sessionId);
    expect(sets.length, 2);
    final cardio = sets.firstWhere((s) => s.durationSeconds != null);
    expect(cardio.exerciseId, seeded.runningId);
    expect(cardio.durationSeconds, 1800);
    expect(cardio.distanceMeters, 5000);

    final exercises = await workoutRepo.getExercises();
    expect(exercises.firstWhere((e) => e.name == 'Bench Press').id,
        seeded.benchId);

    final measurement =
        (await MeasurementRepository().getMeasurements()).single;
    expect(measurement.waist, 82);
  });

  test('CSV export escapes commas/quotes and keeps Arabic text', () async {
    final db = await DatabaseHelper.instance.database;
    final exerciseId = await db.insert('exercises', {
      'name': 'تمرين, "خاص"',
      'category': 'Chest',
      'muscleGroup': 'Chest',
      'equipment': 'Other',
      'isCustom': 1,
    });
    final sessionId = await workoutRepo.insertSession(WorkoutSession(
        date: '2026-06-01T10:00:00.000', duration: 0, routineName: 'Q'));
    await workoutRepo.insertSet(WorkoutSet(
        sessionId: sessionId, exerciseId: exerciseId, weight: 50, reps: 10));

    final csv = await service.exportWorkoutCsv();

    expect(csv.startsWith('﻿'), isTrue, reason: 'BOM for Excel');
    final lines = csv.trim().split('\n').map((l) => l.trim()).toList();
    expect(lines.first.replaceFirst('﻿', ''),
        'date,routineName,exerciseName,category,weight,reps,durationSeconds,distanceMeters,isCompleted');
    expect(lines[1], contains('"تمرين, ""خاص"""'));
    expect(lines[1], contains('50.0,10'));
  });

  test('malformed JSON throws and leaves data untouched', () async {
    await seedData();
    await expectLater(
      service.importJsonBackup('{not valid json'),
      throwsA(isA<BackupException>()),
    );
    await expectLater(
      service.importJsonBackup(jsonEncode({'tables': []})),
      throwsA(isA<BackupException>()),
    );
    // Data still present.
    expect(await workoutRepo.getSessions(), hasLength(1));
    expect((await workoutRepo.getExercises()), isNotEmpty);
  });

  test('backup from a newer schema version is rejected', () async {
    await expectLater(
      service.importJsonBackup(jsonEncode({
        'schemaVersion': 99,
        'tables': <String, dynamic>{},
      })),
      throwsA(predicate(
          (e) => e is BackupException && e.reason == 'newerVersion')),
    );
  });
}
