import '../core/database/db_helper.dart';
import '../core/sync/sync_clock.dart';
import '../core/sync/sync_ids.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Exercise>> getExercises({String? search, String? muscleGroup}) async {
    final db = await dbHelper.database;
    final where = <String>['isDeleted = 0'];
    final args = <Object>[];
    if (search != null && search.isNotEmpty) {
      where.add('name LIKE ?');
      args.add('%$search%');
    }
    if (muscleGroup != null && muscleGroup.isNotEmpty) {
      where.add('muscleGroup = ?');
      args.add(muscleGroup);
    }
    final maps = await db.query(
      'exercises',
      where: where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<int> insertExercise(Exercise exercise) async {
    final db = await dbHelper.database;
    final map = exercise.toMap()
      ..['uuid'] = exercise.uuid ?? newUuid()
      ..['updatedAt'] = nowUtcIso()
      ..['isDirty'] = 1;
    return await db.insert('exercises', map);
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await dbHelper.database;
    final map = exercise.toMap()
      ..['updatedAt'] = nowUtcIso()
      ..['isDirty'] = 1;
    await db.update(
      'exercises',
      map,
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  /// Returns true if deleted. Refuses when the exercise has logged sets or
  /// belongs to a routine — history must keep resolving its name. Custom
  /// exercises are soft-deleted so the deletion propagates on sync.
  Future<bool> deleteExercise(int id) async {
    final db = await dbHelper.database;
    final inUse = await db.rawQuery(
      '''
      SELECT (SELECT COUNT(*) FROM workout_sets
                WHERE exerciseId = ? AND isDeleted = 0) +
             (SELECT COUNT(*) FROM routine_exercises
                WHERE exerciseId = ? AND isDeleted = 0) AS refs
      ''',
      [id, id],
    );
    if ((inUse.first['refs'] as int) > 0) return false;
    final count = await db.update(
      'exercises',
      {'isDeleted': 1, 'isDirty': 1, 'updatedAt': nowUtcIso()},
      where: 'id = ? AND isCustom = 1',
      whereArgs: [id],
    );
    return count > 0;
  }
}
