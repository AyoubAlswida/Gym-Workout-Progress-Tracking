import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'exercise_seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workout_tracker.db');
    return _database!;
  }

  /// Clears the cached connection so tests can re-open against a fresh
  /// (in-memory) database factory.
  static Future<void> resetForTest() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE workout_sessions (
        id $idType,
        date $textType,
        duration $integerType,
        routineName $textType,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id $idType,
        name $textType,
        category $textType,
        muscleGroup TEXT NOT NULL DEFAULT '',
        equipment TEXT NOT NULL DEFAULT '',
        isCustom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sets (
        id $idType,
        sessionId $integerType,
        exerciseId $integerType,
        weight $realType,
        reps $integerType,
        isCompleted $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE body_measurements (
        id $idType,
        date $textType,
        bodyWeight $realType,
        bodyFatPercentage $realType
      )
    ''');

    await _createV2Tables(db);
    await _seedData(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          "ALTER TABLE exercises ADD COLUMN muscleGroup TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE exercises ADD COLUMN equipment TEXT NOT NULL DEFAULT ''");
      await db.execute(
          'ALTER TABLE exercises ADD COLUMN isCustom INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE workout_sessions ADD COLUMN notes TEXT');
      await _createV2Tables(db);
      await _seedData(db);
    }
  }

  Future _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isPreset INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS routine_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routineId INTEGER NOT NULL,
        exerciseId INTEGER NOT NULL,
        targetSets INTEGER NOT NULL,
        targetReps INTEGER NOT NULL,
        orderIndex INTEGER NOT NULL
      )
    ''');
  }

  /// Idempotent: inserts catalog exercises and preset routines only when
  /// missing (matched by name), and never deletes or re-ids existing rows —
  /// user data references them.
  Future _seedData(Database db) async {
    for (final exercise in exerciseSeedData) {
      final existing = await db.query(
        'exercises',
        columns: ['id'],
        where: 'name = ?',
        whereArgs: [exercise['name']],
      );
      if (existing.isEmpty) {
        await db.insert('exercises', {...exercise, 'isCustom': 0});
      } else {
        // Backfill the new v2 columns on rows seeded by v1.
        await db.update(
          'exercises',
          {
            'muscleGroup': exercise['muscleGroup'],
            'equipment': exercise['equipment'],
          },
          where: "id = ? AND muscleGroup = ''",
          whereArgs: [existing.first['id']],
        );
      }
    }

    for (final routine in routineSeedData) {
      final existing = await db.query(
        'routines',
        columns: ['id'],
        where: 'name = ? AND isPreset = 1',
        whereArgs: [routine['name']],
      );
      if (existing.isNotEmpty) continue;

      final routineId = await db.insert('routines', {
        'name': routine['name'],
        'isPreset': 1,
      });
      final exercises = routine['exercises'] as List;
      for (var i = 0; i < exercises.length; i++) {
        final item = exercises[i] as Map;
        final exerciseRows = await db.query(
          'exercises',
          columns: ['id'],
          where: 'name = ?',
          whereArgs: [item['name']],
        );
        if (exerciseRows.isEmpty) continue;
        await db.insert('routine_exercises', {
          'routineId': routineId,
          'exerciseId': exerciseRows.first['id'],
          'targetSets': item['sets'],
          'targetReps': item['reps'],
          'orderIndex': i,
        });
      }
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
