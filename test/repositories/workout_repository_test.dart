import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/models/workout_session.dart';
import 'package:gym_workout_tracking/models/workout_set.dart';
import 'package:gym_workout_tracking/repositories/workout_repository.dart';

import '../test_db_helper.dart';

void main() {
  late Directory tempDir;
  late WorkoutRepository repository;

  setUp(() async {
    tempDir = await setupTestDatabase();
    repository = WorkoutRepository();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  Future<int> insertSessionWithSet({
    required String date,
    required int exerciseId,
    required double weight,
    required int reps,
    bool completed = true,
  }) async {
    final sessionId = await repository.insertSession(WorkoutSession(
      date: date,
      duration: 0,
      routineName: 'Test',
    ));
    final setId = await repository.insertSet(WorkoutSet(
      sessionId: sessionId,
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
    ));
    if (completed) await repository.updateSetCompletion(setId, true);
    return sessionId;
  }

  test('updateSessionOnFinish persists duration and notes', () async {
    final sessionId = await repository.insertSession(WorkoutSession(
      date: DateTime.now().toIso8601String(),
      duration: 0,
      routineName: 'Push Day',
    ));
    await repository.updateSessionOnFinish(sessionId, 1800, 'Felt strong');

    final sessions = await repository.getSessions();
    final session = sessions.firstWhere((s) => s.id == sessionId);
    expect(session.duration, 1800);
    expect(session.notes, 'Felt strong');
  });

  test('deleteSession removes session and its sets', () async {
    final sessionId = await insertSessionWithSet(
        date: '2026-06-01T10:00:00.000', exerciseId: 1, weight: 60, reps: 10);
    await repository.deleteSession(sessionId);

    expect(await repository.getSetsForSession(sessionId), isEmpty);
    expect((await repository.getSessions()).where((s) => s.id == sessionId),
        isEmpty);
  });

  test('getLastSetForExercise returns most recent completed set excluding current session', () async {
    await insertSessionWithSet(
        date: '2026-05-01T10:00:00.000', exerciseId: 1, weight: 60, reps: 10);
    await insertSessionWithSet(
        date: '2026-06-01T10:00:00.000', exerciseId: 1, weight: 70, reps: 8);
    final currentId = await insertSessionWithSet(
        date: '2026-06-09T10:00:00.000', exerciseId: 1, weight: 80, reps: 5);

    final lastSet = await repository.getLastSetForExercise(1,
        excludeSessionId: currentId);
    expect(lastSet, isNotNull);
    expect(lastSet!.weight, 70);
    expect(lastSet.reps, 8);
  });

  test('getMaxWeightForExercise ignores incomplete sets and current session', () async {
    await insertSessionWithSet(
        date: '2026-05-01T10:00:00.000', exerciseId: 1, weight: 90, reps: 3,
        completed: false);
    await insertSessionWithSet(
        date: '2026-05-10T10:00:00.000', exerciseId: 1, weight: 75, reps: 5);
    final currentId = await insertSessionWithSet(
        date: '2026-06-09T10:00:00.000', exerciseId: 1, weight: 100, reps: 1);

    final max = await repository.getMaxWeightForExercise(1,
        excludeSessionId: currentId);
    expect(max, 75);
  });

  test('getExerciseProgress returns best set per session in date order', () async {
    await insertSessionWithSet(
        date: '2026-06-05T10:00:00.000', exerciseId: 2, weight: 100, reps: 5);
    await insertSessionWithSet(
        date: '2026-05-01T10:00:00.000', exerciseId: 2, weight: 90, reps: 5);

    final progress = await repository.getExerciseProgress(2);
    expect(progress.length, 2);
    expect(progress.first['maxWeight'], 90);
    expect(progress.last['maxWeight'], 100);
  });

  test('getPersonalRecords returns max per exercise', () async {
    await insertSessionWithSet(
        date: '2026-05-01T10:00:00.000', exerciseId: 1, weight: 80, reps: 8);
    await insertSessionWithSet(
        date: '2026-06-01T10:00:00.000', exerciseId: 1, weight: 85, reps: 5);
    await insertSessionWithSet(
        date: '2026-06-01T10:00:00.000', exerciseId: 2, weight: 120, reps: 5);

    final records = await repository.getPersonalRecords();
    expect(records.length, 2);
    final benchPr = records.firstWhere((r) => r['exerciseId'] == 1);
    expect(benchPr['weight'], 85);
    expect(benchPr['exerciseName'], 'Bench Press');
  });

  test('getExercisesWithData only lists exercises with completed sets', () async {
    final deadlift = (await repository.getExercises())
        .firstWhere((e) => e.name == 'Deadlift');
    await insertSessionWithSet(
        date: '2026-06-01T10:00:00.000',
        exerciseId: deadlift.id!,
        weight: 140,
        reps: 3);

    final exercises = await repository.getExercisesWithData();
    expect(exercises.length, 1);
    expect(exercises.first.name, 'Deadlift');
  });
}
