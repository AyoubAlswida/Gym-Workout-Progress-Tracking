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

  Future<void> updateSessionOnFinish(int sessionId, int duration, String? notes) async {
    final db = await dbHelper.database;
    await db.update(
      'workout_sessions',
      {'duration': duration, 'notes': notes},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Removes an abandoned session and any sets logged under it.
  Future<void> deleteSession(int sessionId) async {
    final db = await dbHelper.database;
    await db.delete('workout_sets', where: 'sessionId = ?', whereArgs: [sessionId]);
    await db.delete('workout_sessions', where: 'id = ?', whereArgs: [sessionId]);
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

  /// Most recent completed set for an exercise, excluding the session in
  /// progress — used as the "last time" hint.
  Future<WorkoutSet?> getLastSetForExercise(int exerciseId, {int? excludeSessionId}) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT ws.* FROM workout_sets ws
      JOIN workout_sessions s ON ws.sessionId = s.id
      WHERE ws.exerciseId = ? AND ws.isCompleted = 1
        AND (? IS NULL OR ws.sessionId != ?)
      ORDER BY s.date DESC, ws.id DESC
      LIMIT 1
      ''',
      [exerciseId, excludeSessionId, excludeSessionId],
    );
    if (maps.isEmpty) return null;
    return WorkoutSet.fromMap(maps.first);
  }

  /// All-time heaviest completed set, excluding the session in progress —
  /// the baseline for PR detection.
  Future<double?> getMaxWeightForExercise(int exerciseId, {int? excludeSessionId}) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT MAX(weight) AS maxWeight FROM workout_sets
      WHERE exerciseId = ? AND isCompleted = 1
        AND (? IS NULL OR sessionId != ?)
      ''',
      [exerciseId, excludeSessionId, excludeSessionId],
    );
    return maps.first['maxWeight'] as double?;
  }

  // Analytics

  /// Best completed set per session for one exercise, ordered by date.
  /// Rows: date (ISO string), maxWeight, reps (of the max-weight set).
  Future<List<Map<String, dynamic>>> getExerciseProgress(int exerciseId) async {
    final db = await dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT s.date AS date, MAX(ws.weight) AS maxWeight, ws.reps AS reps
      FROM workout_sets ws
      JOIN workout_sessions s ON ws.sessionId = s.id
      WHERE ws.exerciseId = ? AND ws.isCompleted = 1
      GROUP BY ws.sessionId
      ORDER BY s.date ASC
      ''',
      [exerciseId],
    );
  }

  /// All completed sets with their session date; the viewmodel groups them
  /// into weeks (simpler than sqlite date arithmetic).
  Future<List<Map<String, dynamic>>> getCompletedSetVolumes() async {
    final db = await dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT s.date AS date, ws.weight * ws.reps AS volume
      FROM workout_sets ws
      JOIN workout_sessions s ON ws.sessionId = s.id
      WHERE ws.isCompleted = 1
      ORDER BY s.date ASC
      ''',
    );
  }

  /// Heaviest completed set per exercise.
  /// Rows: exerciseId, exerciseName, weight, reps, date.
  Future<List<Map<String, dynamic>>> getPersonalRecords() async {
    final db = await dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT ws.exerciseId AS exerciseId, e.name AS exerciseName,
             MAX(ws.weight) AS weight, ws.reps AS reps, s.date AS date
      FROM workout_sets ws
      JOIN workout_sessions s ON ws.sessionId = s.id
      JOIN exercises e ON ws.exerciseId = e.id
      WHERE ws.isCompleted = 1
      GROUP BY ws.exerciseId
      ORDER BY weight DESC
      ''',
    );
  }

  /// Exercises that have at least one completed set — the analytics dropdown.
  Future<List<Exercise>> getExercisesWithData() async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT DISTINCT e.* FROM exercises e
      JOIN workout_sets ws ON ws.exerciseId = e.id
      WHERE ws.isCompleted = 1
      ORDER BY e.name ASC
      ''',
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }
}
