import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workout_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
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
        routineName $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id $idType,
        name $textType,
        category $textType
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
    
    // Insert some default exercises for the MVP
    await db.insert('exercises', {'name': 'Bench Press', 'category': 'Chest'});
    await db.insert('exercises', {'name': 'Squat', 'category': 'Legs'});
    await db.insert('exercises', {'name': 'Deadlift', 'category': 'Back'});
    await db.insert('exercises', {'name': 'Pull Up', 'category': 'Back'});
    await db.insert('exercises', {'name': 'Overhead Press', 'category': 'Shoulders'});
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
