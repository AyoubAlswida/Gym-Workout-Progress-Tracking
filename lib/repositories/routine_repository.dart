import '../core/database/db_helper.dart';
import '../models/routine.dart';
import '../models/routine_exercise.dart';

class RoutineRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Routine>> getRoutines() async {
    final db = await dbHelper.database;
    final maps =
        await db.query('routines', orderBy: 'isPreset DESC, name ASC');
    return List.generate(maps.length, (i) => Routine.fromMap(maps[i]));
  }

  Future<List<RoutineExercise>> getRoutineExercises(int routineId) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT re.*, e.name AS exerciseName
      FROM routine_exercises re
      JOIN exercises e ON re.exerciseId = e.id
      WHERE re.routineId = ?
      ORDER BY re.orderIndex ASC
      ''',
      [routineId],
    );
    return List.generate(maps.length, (i) => RoutineExercise.fromMap(maps[i]));
  }

  Future<Map<int, int>> getExerciseCounts() async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      'SELECT routineId, COUNT(*) AS count FROM routine_exercises GROUP BY routineId',
    );
    return {
      for (final map in maps) map['routineId'] as int: map['count'] as int
    };
  }

  Future<int> insertRoutine(Routine routine, List<RoutineExercise> items) async {
    final db = await dbHelper.database;
    return await db.transaction((txn) async {
      final routineId = await txn.insert('routines', routine.toMap());
      for (var i = 0; i < items.length; i++) {
        await txn.insert('routine_exercises', {
          ...items[i].toMap(),
          'id': null,
          'routineId': routineId,
          'orderIndex': i,
        });
      }
      return routineId;
    });
  }

  /// Replaces the routine row and its exercise list atomically.
  Future<void> updateRoutine(Routine routine, List<RoutineExercise> items) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'routines',
        routine.toMap(),
        where: 'id = ?',
        whereArgs: [routine.id],
      );
      await txn.delete(
        'routine_exercises',
        where: 'routineId = ?',
        whereArgs: [routine.id],
      );
      for (var i = 0; i < items.length; i++) {
        await txn.insert('routine_exercises', {
          ...items[i].toMap(),
          'id': null,
          'routineId': routine.id,
          'orderIndex': i,
        });
      }
    });
  }

  Future<void> deleteRoutine(int routineId) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'routine_exercises',
        where: 'routineId = ?',
        whereArgs: [routineId],
      );
      await txn.delete('routines', where: 'id = ?', whereArgs: [routineId]);
    });
  }
}
