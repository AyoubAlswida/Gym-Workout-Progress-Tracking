import 'package:sqflite/sqflite.dart';
import '../core/database/db_helper.dart';
import '../core/sync/sync_clock.dart';
import '../core/sync/sync_ids.dart';
import '../models/routine.dart';
import '../models/routine_exercise.dart';

class RoutineRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Routine>> getRoutines() async {
    final db = await dbHelper.database;
    final maps = await db.query('routines',
        where: 'isDeleted = 0', orderBy: 'isPreset DESC, name ASC');
    return List.generate(maps.length, (i) => Routine.fromMap(maps[i]));
  }

  Future<List<RoutineExercise>> getRoutineExercises(int routineId) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT re.*, e.name AS exerciseName
      FROM routine_exercises re
      JOIN exercises e ON re.exerciseId = e.id
      WHERE re.routineId = ? AND re.isDeleted = 0
      ORDER BY re.orderIndex ASC
      ''',
      [routineId],
    );
    return List.generate(maps.length, (i) => RoutineExercise.fromMap(maps[i]));
  }

  Future<Map<int, int>> getExerciseCounts() async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      'SELECT routineId, COUNT(*) AS count FROM routine_exercises '
      'WHERE isDeleted = 0 GROUP BY routineId',
    );
    return {
      for (final map in maps) map['routineId'] as int: map['count'] as int
    };
  }

  Future<String?> _exerciseUuid(DatabaseExecutor txn, int exerciseId) async {
    final rows = await txn.query('exercises',
        columns: ['uuid'], where: 'id = ?', whereArgs: [exerciseId]);
    return rows.isEmpty ? null : rows.first['uuid'] as String?;
  }

  Future<int> insertRoutine(Routine routine, List<RoutineExercise> items) async {
    final db = await dbHelper.database;
    final now = nowUtcIso();
    final routineUuid = routine.uuid ?? newUuid();
    return await db.transaction((txn) async {
      final routineId = await txn.insert('routines', {
        ...routine.toMap(),
        'uuid': routineUuid,
        'updatedAt': now,
        'isDirty': 1,
      });
      for (var i = 0; i < items.length; i++) {
        await txn.insert('routine_exercises', {
          ...items[i].toMap(),
          'id': null,
          'routineId': routineId,
          'orderIndex': i,
          'uuid': newUuid(),
          'routineUuid': routineUuid,
          'exerciseUuid': await _exerciseUuid(txn, items[i].exerciseId),
          'updatedAt': now,
          'isDirty': 1,
        });
      }
      return routineId;
    });
  }

  /// Diffs the new exercise list against the stored one by exercise:
  /// kept rows are updated in place (uuid preserved → remote row updates),
  /// removed rows are tombstoned (deletion propagates), new rows are inserted.
  /// This replaces the old delete-all/re-insert, which would have orphaned
  /// remote rows and lost their identity.
  Future<void> updateRoutine(Routine routine, List<RoutineExercise> items) async {
    final db = await dbHelper.database;
    final now = nowUtcIso();
    await db.transaction((txn) async {
      final existingRoutine = await txn.query('routines',
          columns: ['uuid'], where: 'id = ?', whereArgs: [routine.id]);
      final routineUuid = (existingRoutine.isNotEmpty
              ? existingRoutine.first['uuid'] as String?
              : null) ??
          routine.uuid ??
          newUuid();

      await txn.update(
        'routines',
        {
          ...routine.toMap(),
          'uuid': routineUuid,
          'updatedAt': now,
          'isDirty': 1,
        },
        where: 'id = ?',
        whereArgs: [routine.id],
      );

      final existing = await txn.query(
        'routine_exercises',
        columns: ['id', 'exerciseId'],
        where: 'routineId = ? AND isDeleted = 0',
        whereArgs: [routine.id],
      );
      // Each exercise appears at most once per routine.
      final byExerciseId = {
        for (final row in existing) row['exerciseId'] as int: row['id'] as int
      };
      final seen = <int>{};

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final existingId = byExerciseId[item.exerciseId];
        if (existingId != null) {
          // Kept: update in place, preserve uuid/routineUuid/exerciseUuid.
          await txn.update(
            'routine_exercises',
            {
              'targetSets': item.targetSets,
              'targetReps': item.targetReps,
              'orderIndex': i,
              'isDeleted': 0,
              'isDirty': 1,
              'updatedAt': now,
            },
            where: 'id = ?',
            whereArgs: [existingId],
          );
          seen.add(existingId);
        } else {
          await txn.insert('routine_exercises', {
            ...item.toMap(),
            'id': null,
            'routineId': routine.id,
            'orderIndex': i,
            'uuid': newUuid(),
            'routineUuid': routineUuid,
            'exerciseUuid': await _exerciseUuid(txn, item.exerciseId),
            'updatedAt': now,
            'isDirty': 1,
          });
        }
      }

      // Removed: tombstone the rows that are no longer present.
      for (final row in existing) {
        final id = row['id'] as int;
        if (!seen.contains(id)) {
          await txn.update(
            'routine_exercises',
            {'isDeleted': 1, 'isDirty': 1, 'updatedAt': now},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
    });
  }

  Future<void> deleteRoutine(int routineId) async {
    final db = await dbHelper.database;
    final now = nowUtcIso();
    final tombstone = {'isDeleted': 1, 'isDirty': 1, 'updatedAt': now};
    await db.transaction((txn) async {
      await txn.update('routine_exercises', tombstone,
          where: 'routineId = ?', whereArgs: [routineId]);
      await txn.update('routines', tombstone,
          where: 'id = ?', whereArgs: [routineId]);
    });
  }
}
