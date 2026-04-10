import '../core/database/db_helper.dart';
import '../models/workout_session.dart';
import '../models/exercise.dart';
import '../models/workout_set.dart';

class WorkoutRepository {
  final dbHelper = DatabaseHelper.instance;

  // Exercises
  Future<List<Exercise>> getExercises() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  // Sessions
  Future<int> insertSession(WorkoutSession session) async {
    final db = await dbHelper.database;
    return await db.insert('workout_sessions', session.toMap());
  }

  Future<List<WorkoutSession>> getSessions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('workout_sessions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => WorkoutSession.fromMap(maps[i]));
  }

  // Sets
  Future<int> insertSet(WorkoutSet workoutSet) async {
    final db = await dbHelper.database;
    return await db.insert('workout_sets', workoutSet.toMap());
  }

  Future<List<WorkoutSet>> getSetsForSession(int sessionId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('workout_sets', where: 'sessionId = ?', whereArgs: [sessionId]);
    return List.generate(maps.length, (i) => WorkoutSet.fromMap(maps[i]));
  }

  Future<void> updateSetCompletion(int setId, bool isCompleted) async {
    final db = await dbHelper.database;
    await db.update(
      'workout_sets',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [setId],
    );
  }
}
