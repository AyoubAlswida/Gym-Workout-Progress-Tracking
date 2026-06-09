import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gym_workout_tracking/core/database/db_helper.dart';

import '../test_db_helper.dart';

/// Recreates the exact v1 schema with user data, then opens it through
/// DatabaseHelper (v2) and verifies the migration preserved everything.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await setupTestDatabase();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  Future<void> createV1Database() async {
    final path = p.join(tempDir.path, 'workout_tracker.db');
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE workout_sessions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              duration INTEGER NOT NULL,
              routineName TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE exercises (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              category TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE workout_sets (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              sessionId INTEGER NOT NULL,
              exerciseId INTEGER NOT NULL,
              weight REAL NOT NULL,
              reps INTEGER NOT NULL,
              isCompleted INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE body_measurements (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              bodyWeight REAL NOT NULL,
              bodyFatPercentage REAL NOT NULL
            )
          ''');
          await db.insert('exercises', {'name': 'Bench Press', 'category': 'Chest'});
          await db.insert('exercises', {'name': 'Squat', 'category': 'Legs'});
          await db.insert('exercises', {'name': 'Deadlift', 'category': 'Back'});
          await db.insert('exercises', {'name': 'Pull Up', 'category': 'Back'});
          await db.insert('exercises', {'name': 'Overhead Press', 'category': 'Shoulders'});
          // User data referencing seeded exercise ids.
          await db.insert('workout_sessions', {
            'id': 1,
            'date': '2026-06-01T10:00:00.000',
            'duration': 0,
            'routineName': 'Push Day',
          });
          await db.insert('workout_sets', {
            'sessionId': 1,
            'exerciseId': 1,
            'weight': 80.0,
            'reps': 8,
            'isCompleted': 1,
          });
          await db.insert('body_measurements', {
            'date': '2026-06-01T10:00:00.000',
            'bodyWeight': 75.0,
            'bodyFatPercentage': 15.0,
          });
        },
      ),
    );
    await db.close();
  }

  Future<void> createV2Database() async {
    final path = p.join(tempDir.path, 'workout_tracker.db');
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE workout_sessions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              duration INTEGER NOT NULL,
              routineName TEXT NOT NULL,
              notes TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE exercises (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              category TEXT NOT NULL,
              muscleGroup TEXT NOT NULL DEFAULT '',
              equipment TEXT NOT NULL DEFAULT '',
              isCustom INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE workout_sets (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              sessionId INTEGER NOT NULL,
              exerciseId INTEGER NOT NULL,
              weight REAL NOT NULL,
              reps INTEGER NOT NULL,
              isCompleted INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE body_measurements (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              bodyWeight REAL NOT NULL,
              bodyFatPercentage REAL NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE routines (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              isPreset INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE routine_exercises (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              routineId INTEGER NOT NULL,
              exerciseId INTEGER NOT NULL,
              targetSets INTEGER NOT NULL,
              targetReps INTEGER NOT NULL,
              orderIndex INTEGER NOT NULL
            )
          ''');
          await db.insert('exercises', {
            'name': 'Bench Press',
            'category': 'Chest',
            'muscleGroup': 'Chest',
            'equipment': 'Barbell',
          });
          await db.insert('workout_sessions', {
            'id': 1,
            'date': '2026-06-01T10:00:00.000',
            'duration': 3600,
            'routineName': 'Push Day',
          });
          await db.insert('workout_sets', {
            'sessionId': 1,
            'exerciseId': 1,
            'weight': 80.0,
            'reps': 8,
            'isCompleted': 1,
          });
          await db.insert('body_measurements', {
            'date': '2026-06-01T10:00:00.000',
            'bodyWeight': 75.0,
            'bodyFatPercentage': 15.0,
          });
        },
      ),
    );
    await db.close();
  }

  test('v1 database upgrades to v3 with data intact', () async {
    await createV1Database();

    final db = await DatabaseHelper.instance.database;
    expect(await db.getVersion(), 3);

    // Original exercises kept their ids and got the new columns backfilled.
    final bench = await db.query('exercises', where: 'name = ?', whereArgs: ['Bench Press']);
    expect(bench.length, 1, reason: 'seeding must not duplicate v1 exercises');
    expect(bench.first['id'], 1);
    expect(bench.first['muscleGroup'], 'Chest');
    expect(bench.first['equipment'], 'Barbell');
    expect(bench.first['isCustom'], 0);

    // Catalog expanded well beyond the original five.
    final exerciseCount = (await db.rawQuery('SELECT COUNT(*) AS c FROM exercises')).first['c'] as int;
    expect(exerciseCount, greaterThan(40));

    // User data survived.
    final sets = await db.query('workout_sets');
    expect(sets.length, 1);
    expect(sets.first['weight'], 80.0);
    final sessions = await db.query('workout_sessions');
    expect(sessions.length, 1);
    expect(sessions.first['notes'], isNull);
    final measurements = await db.query('body_measurements');
    expect(measurements.length, 1);

    // Preset routines seeded with resolvable exercise references.
    final routines = await db.query('routines', where: 'isPreset = 1');
    expect(routines.length, 4);
    final orphans = await db.rawQuery('''
      SELECT COUNT(*) AS c FROM routine_exercises re
      LEFT JOIN exercises e ON re.exerciseId = e.id
      WHERE e.id IS NULL
    ''');
    expect(orphans.first['c'], 0);
  });

  test('v2 database upgrades to v3 with data intact', () async {
    await createV2Database();

    final db = await DatabaseHelper.instance.database;
    expect(await db.getVersion(), 3);

    // Legacy rows readable; new columns are null.
    final sets = await db.query('workout_sets');
    expect(sets.length, 1);
    expect(sets.first['weight'], 80.0);
    expect(sets.first['durationSeconds'], isNull);
    expect(sets.first['distanceMeters'], isNull);

    final measurements = await db.query('body_measurements');
    expect(measurements.length, 1);
    expect(measurements.first['waist'], isNull);
    expect(measurements.first['thighs'], isNull);

    // New columns are writable.
    await db.insert('workout_sets', {
      'sessionId': 1,
      'exerciseId': 1,
      'weight': 0.0,
      'reps': 0,
      'isCompleted': 1,
      'durationSeconds': 1800,
      'distanceMeters': 5000.0,
    });
    final cardio = await db.query('workout_sets',
        where: 'durationSeconds IS NOT NULL');
    expect(cardio.length, 1);
    expect(cardio.first['distanceMeters'], 5000.0);

    // progress_photos table exists and is usable.
    await db.insert('progress_photos', {
      'date': '2026-06-10T08:00:00.000',
      'filePath': '/photos/1.jpg',
    });
    expect((await db.query('progress_photos')).length, 1);

    // Cardio exercises got seeded by the upgrade.
    final cardioExercises =
        await db.query('exercises', where: "category = 'Cardio'");
    expect(cardioExercises.length, 8);
  });

  test('upgrade is idempotent across reopen', () async {
    await createV1Database();
    await DatabaseHelper.instance.database;
    await DatabaseHelper.resetForTest();

    final db = await DatabaseHelper.instance.database;
    final bench = await db.query('exercises', where: 'name = ?', whereArgs: ['Bench Press']);
    expect(bench.length, 1);
    final routines = await db.query('routines', where: 'isPreset = 1');
    expect(routines.length, 4);
    final cardioExercises =
        await db.query('exercises', where: "category = 'Cardio'");
    expect(cardioExercises.length, 8,
        reason: 'cardio seeding must not duplicate on reopen');
  });

  test('fresh install creates v3 schema with seeds', () async {
    final db = await DatabaseHelper.instance.database;
    expect(await db.getVersion(), 3);

    final exerciseCount = (await db.rawQuery('SELECT COUNT(*) AS c FROM exercises')).first['c'] as int;
    expect(exerciseCount, greaterThan(40));
    final routines = await db.query('routines');
    expect(routines.length, 4);
    final routineExercises = await db.query('routine_exercises');
    expect(routineExercises, isNotEmpty);
    final cardioExercises =
        await db.query('exercises', where: "category = 'Cardio'");
    expect(cardioExercises.length, 8);
    // v3 tables/columns present on fresh install too.
    await db.insert('progress_photos', {
      'date': '2026-06-10T08:00:00.000',
      'filePath': '/photos/1.jpg',
      'note': 'front',
    });
    expect((await db.query('progress_photos')).length, 1);
  });
}
