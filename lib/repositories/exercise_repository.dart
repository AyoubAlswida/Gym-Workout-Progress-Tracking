import '../core/database/db_helper.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Exercise>> getExercises({String? search, String? muscleGroup}) async {
    final db = await dbHelper.database;
    final where = <String>[];
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
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<int> insertExercise(Exercise exercise) async {
    final db = await dbHelper.database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await dbHelper.database;
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  /// Returns true if deleted. Refuses when the exercise has logged sets or
  /// belongs to a routine — history must keep resolving its name.
  Future<bool> deleteExercise(int id) async {
    final db = await dbHelper.database;
    final inUse = await db.rawQuery(
      '''
      SELECT (SELECT COUNT(*) FROM workout_sets WHERE exerciseId = ?) +
             (SELECT COUNT(*) FROM routine_exercises WHERE exerciseId = ?) AS refs
      ''',
      [id, id],
    );
    if ((inUse.first['refs'] as int) > 0) return false;
    await db.delete(
      'exercises',
      where: 'id = ? AND isCustom = 1',
      whereArgs: [id],
    );
    return true;
  }
}
