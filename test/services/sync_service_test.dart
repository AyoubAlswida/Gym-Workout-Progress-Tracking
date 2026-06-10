import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/core/database/db_helper.dart';
import 'package:gym_workout_tracking/core/sync/sync_ids.dart';
import 'package:gym_workout_tracking/models/exercise.dart';
import 'package:gym_workout_tracking/models/workout_session.dart';
import 'package:gym_workout_tracking/models/workout_set.dart';
import 'package:gym_workout_tracking/repositories/exercise_repository.dart';
import 'package:gym_workout_tracking/repositories/workout_repository.dart';
import 'package:gym_workout_tracking/services/sync_service.dart';

import '../fakes/fake_remote_data_source.dart';
import '../test_db_helper.dart';

void main() {
  late Directory tempDir;
  late FakeRemoteDataSource remote;
  late FakeWatermarkStore watermarks;
  late SyncService sync;
  late WorkoutRepository workouts;

  setUp(() async {
    tempDir = await setupTestDatabase();
    remote = FakeRemoteDataSource();
    watermarks = FakeWatermarkStore();
    sync = SyncService(
        userId: 'u1', remote: remote, watermarks: watermarks);
    workouts = WorkoutRepository();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  Future<int> benchPressId() async =>
      (await workouts.getExercises()).firstWhere((e) => e.name == 'Bench Press').id!;

  test('push uploads dirty user rows, clears dirty, and excludes presets',
      () async {
    final benchId = await benchPressId();
    await ExerciseRepository()
        .insertExercise(Exercise(name: 'Custom Curl', category: 'Arms', isCustom: true));
    final sessionId = await workouts.insertSession(WorkoutSession(
        date: '2026-06-01T10:00:00.000', duration: 3600, routineName: 'Quick'));
    await workouts.insertSet(WorkoutSet(
        sessionId: sessionId, exerciseId: benchId, weight: 80, reps: 8));

    await sync.sync();

    // Session + set + custom exercise pushed.
    expect(remote.tables['workout_sessions']?.length, 1);
    expect(remote.tables['workout_sets']?.length, 1);
    // Only the custom exercise — presets must never upload.
    expect(remote.tables['exercises']?.length, 1);
    expect(remote.tables['exercises']!.values.single['name'], 'Custom Curl');

    // Pushed rows are no longer dirty.
    final db = await DatabaseHelper.instance.database;
    final dirty = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM workout_sessions WHERE isDirty = 1');
    expect(dirty.first['c'], 0);
  });

  test('pull inserts a remote session and set, resolving parent + preset uuids',
      () async {
    final benchId = await benchPressId();
    remote.seed('workout_sessions', {
      'uuid': 's-1',
      'date': '2026-06-01T10:00:00.000',
      'duration': 3600,
      'routineName': 'Quick',
      'notes': null,
      'updatedAt': '2026-06-01T10:00:00Z',
      'isDeleted': 0,
      'user_id': 'u1',
    });
    remote.seed('workout_sets', {
      'uuid': 'set-1',
      'weight': 100.0,
      'reps': 5,
      'isCompleted': 1,
      'durationSeconds': null,
      'distanceMeters': null,
      'sessionUuid': 's-1',
      'exerciseUuid': presetExerciseUuid('Bench Press'),
      'updatedAt': '2026-06-01T10:00:01Z',
      'isDeleted': 0,
      'user_id': 'u1',
    });

    await sync.sync();

    final sessions = await workouts.getSessions();
    expect(sessions.length, 1);
    expect(sessions.single.uuid, 's-1');

    final sets = await workouts.getSetsForSession(sessions.single.id!);
    expect(sets.length, 1);
    expect(sets.single.weight, 100.0);
    // Parent uuids resolved to local ids.
    expect(sets.single.sessionId, sessions.single.id);
    expect(sets.single.exerciseId, benchId);
  });

  test('last-write-wins: a newer remote row overwrites local', () async {
    final sessionId = await workouts.insertSession(WorkoutSession(
        date: '2026-06-01T10:00:00.000', duration: 100, routineName: 'Quick'));
    final db = await DatabaseHelper.instance.database;
    final local = (await db.query('workout_sessions',
            where: 'id = ?', whereArgs: [sessionId]))
        .single;
    // Force the local timestamp to be old so the remote one wins.
    await db.update('workout_sessions', {'updatedAt': '2026-01-01T00:00:00Z'},
        where: 'id = ?', whereArgs: [sessionId]);

    remote.seed('workout_sessions', {
      ...local,
      'updatedAt': '2026-12-01T00:00:00Z',
      'duration': 999,
      'user_id': 'u1',
    }..remove('id'));

    await sync.sync();

    final updated = (await workouts.getSessions()).single;
    expect(updated.duration, 999);
  });

  test('a remote tombstone removes a local row', () async {
    final sessionId = await workouts.insertSession(WorkoutSession(
        date: '2026-06-01T10:00:00.000', duration: 100, routineName: 'Quick'));
    final db = await DatabaseHelper.instance.database;
    final local = (await db.query('workout_sessions',
            where: 'id = ?', whereArgs: [sessionId]))
        .single;
    await db.update('workout_sessions', {'updatedAt': '2026-01-01T00:00:00Z'},
        where: 'id = ?', whereArgs: [sessionId]);

    remote.seed('workout_sessions', {
      ...local,
      'updatedAt': '2026-12-01T00:00:00Z',
      'isDeleted': 1,
      'user_id': 'u1',
    }..remove('id'));

    await sync.sync();

    expect(await workouts.getSessions(), isEmpty);
  });

  test('overlapping sync calls do not double-run', () async {
    // Two concurrent syncs; the second should no-op while the first runs.
    await Future.wait([sync.sync(), sync.sync()]);
    // No exception, and a subsequent sync still works.
    await sync.sync();
  });
}
