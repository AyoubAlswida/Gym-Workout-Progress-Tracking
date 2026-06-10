import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../sync/sync_clock.dart';
import '../sync/sync_ids.dart';
import 'exercise_seed_data.dart';

/// Sync-metadata columns shared by every syncable table.
const String _syncColumns =
    'uuid TEXT, updatedAt TEXT, isDirty INTEGER NOT NULL DEFAULT 0, '
    'isDeleted INTEGER NOT NULL DEFAULT 0';

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
      version: 4,
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
        notes TEXT,
        $_syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id $idType,
        name $textType,
        category $textType,
        muscleGroup TEXT NOT NULL DEFAULT '',
        equipment TEXT NOT NULL DEFAULT '',
        isCustom INTEGER NOT NULL DEFAULT 0,
        $_syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sets (
        id $idType,
        sessionId $integerType,
        exerciseId $integerType,
        weight $realType,
        reps $integerType,
        isCompleted $integerType,
        durationSeconds INTEGER,
        distanceMeters REAL,
        sessionUuid TEXT,
        exerciseUuid TEXT,
        $_syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE body_measurements (
        id $idType,
        date $textType,
        bodyWeight $realType,
        bodyFatPercentage $realType,
        waist REAL,
        chest REAL,
        arms REAL,
        hips REAL,
        thighs REAL,
        $_syncColumns
      )
    ''');

    await _createV2Tables(db);
    await _createV3Tables(db);
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
      // Seeding runs once at the end of the upgrade chain.
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE workout_sets ADD COLUMN durationSeconds INTEGER');
      await db
          .execute('ALTER TABLE workout_sets ADD COLUMN distanceMeters REAL');
      await db.execute('ALTER TABLE body_measurements ADD COLUMN waist REAL');
      await db.execute('ALTER TABLE body_measurements ADD COLUMN chest REAL');
      await db.execute('ALTER TABLE body_measurements ADD COLUMN arms REAL');
      await db.execute('ALTER TABLE body_measurements ADD COLUMN hips REAL');
      await db.execute('ALTER TABLE body_measurements ADD COLUMN thighs REAL');
      await _createV3Tables(db);
    }
    if (oldVersion < 4) {
      await _addSyncColumns(db);
      await _backfillSyncMetadata(db);
    }
    // Idempotent — picks up any catalog additions (e.g. v3 cardio exercises).
    await _seedData(db);
  }

  /// Adds the four sync columns (+ parent-uuid columns) to every table, but
  /// only where missing — a v1→v4 jump may have created some tables with the
  /// columns already (via _createV2/V3Tables), so we can't blindly ALTER.
  Future _addSyncColumns(Database db) async {
    const base = ['uuid TEXT', 'updatedAt TEXT'];
    const flags = [
      'isDirty INTEGER NOT NULL DEFAULT 0',
      'isDeleted INTEGER NOT NULL DEFAULT 0',
    ];
    final perTable = <String, List<String>>{
      'workout_sessions': [...base, ...flags],
      'exercises': [...base, ...flags],
      'workout_sets': [...base, ...flags, 'sessionUuid TEXT', 'exerciseUuid TEXT'],
      'body_measurements': [...base, ...flags],
      'routines': [...base, ...flags],
      'routine_exercises': [
        ...base,
        ...flags,
        'routineUuid TEXT',
        'exerciseUuid TEXT',
      ],
      'progress_photos': [...base, ...flags],
    };
    for (final entry in perTable.entries) {
      final existing = (await db.rawQuery('PRAGMA table_info(${entry.key})'))
          .map((r) => r['name'] as String)
          .toSet();
      for (final colDef in entry.value) {
        final colName = colDef.split(' ').first;
        if (!existing.contains(colName)) {
          await db.execute('ALTER TABLE ${entry.key} ADD COLUMN $colDef');
        }
      }
    }
  }

  /// Assigns a uuid + updatedAt to every existing row. Presets get a
  /// deterministic name-based uuid (identical across devices); user rows get
  /// a random v4. Parents are processed before children so the child
  /// parent-uuid subqueries resolve.
  Future _backfillSyncMetadata(Database db) async {
    final now = nowUtcIso();

    Future<void> backfillSimple(String table) async {
      final rows = await db.query(table, columns: ['id'], where: 'uuid IS NULL');
      for (final row in rows) {
        await db.update(table, {'uuid': newUuid(), 'updatedAt': now},
            where: 'id = ?', whereArgs: [row['id']]);
      }
    }

    // Parents first.
    final exercises = await db.query('exercises',
        columns: ['id', 'name', 'isCustom'], where: 'uuid IS NULL');
    for (final row in exercises) {
      final uuid = (row['isCustom'] == 1)
          ? newUuid()
          : presetExerciseUuid(row['name'] as String);
      await db.update('exercises', {'uuid': uuid, 'updatedAt': now},
          where: 'id = ?', whereArgs: [row['id']]);
    }

    final routines = await db.query('routines',
        columns: ['id', 'name', 'isPreset'], where: 'uuid IS NULL');
    for (final row in routines) {
      final uuid = (row['isPreset'] == 1)
          ? presetRoutineUuid(row['name'] as String)
          : newUuid();
      await db.update('routines', {'uuid': uuid, 'updatedAt': now},
          where: 'id = ?', whereArgs: [row['id']]);
    }

    await backfillSimple('workout_sessions');
    await backfillSimple('body_measurements');
    await backfillSimple('progress_photos');
    await backfillSimple('workout_sets');
    await backfillSimple('routine_exercises');

    // Children: resolve parent uuids now that parents have them.
    await db.execute('''
      UPDATE workout_sets SET
        sessionUuid = (SELECT uuid FROM workout_sessions WHERE workout_sessions.id = workout_sets.sessionId),
        exerciseUuid = (SELECT uuid FROM exercises WHERE exercises.id = workout_sets.exerciseId)
      WHERE sessionUuid IS NULL OR exerciseUuid IS NULL
    ''');
    await db.execute('''
      UPDATE routine_exercises SET
        routineUuid = (SELECT uuid FROM routines WHERE routines.id = routine_exercises.routineId),
        exerciseUuid = (SELECT uuid FROM exercises WHERE exercises.id = routine_exercises.exerciseId)
      WHERE routineUuid IS NULL OR exerciseUuid IS NULL
    ''');
  }

  Future _createV3Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS progress_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        filePath TEXT NOT NULL,
        note TEXT,
        $_syncColumns
      )
    ''');
  }

  Future _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isPreset INTEGER NOT NULL DEFAULT 0,
        $_syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS routine_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routineId INTEGER NOT NULL,
        exerciseId INTEGER NOT NULL,
        targetSets INTEGER NOT NULL,
        targetReps INTEGER NOT NULL,
        orderIndex INTEGER NOT NULL,
        routineUuid TEXT,
        exerciseUuid TEXT,
        $_syncColumns
      )
    ''');
  }

  /// Idempotent: inserts catalog exercises and preset routines only when
  /// missing (matched by name), and never deletes or re-ids existing rows —
  /// user data references them.
  Future _seedData(Database db) async {
    final now = nowUtcIso();

    for (final exercise in exerciseSeedData) {
      final name = exercise['name'] as String;
      final existing = await db.query(
        'exercises',
        columns: ['id', 'uuid'],
        where: 'name = ?',
        whereArgs: [name],
      );
      if (existing.isEmpty) {
        await db.insert('exercises', {
          ...exercise,
          'isCustom': 0,
          'uuid': presetExerciseUuid(name),
          'updatedAt': now,
        });
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
        // Ensure the deterministic uuid is present on legacy preset rows.
        if (existing.first['uuid'] == null) {
          await db.update(
            'exercises',
            {'uuid': presetExerciseUuid(name), 'updatedAt': now},
            where: 'id = ?',
            whereArgs: [existing.first['id']],
          );
        }
      }
    }

    for (final routine in routineSeedData) {
      final routineName = routine['name'] as String;
      final existing = await db.query(
        'routines',
        columns: ['id'],
        where: 'name = ? AND isPreset = 1',
        whereArgs: [routineName],
      );
      if (existing.isNotEmpty) continue;

      final routineUuid = presetRoutineUuid(routineName);
      final routineId = await db.insert('routines', {
        'name': routineName,
        'isPreset': 1,
        'uuid': routineUuid,
        'updatedAt': now,
      });
      final exercises = routine['exercises'] as List;
      for (var i = 0; i < exercises.length; i++) {
        final item = exercises[i] as Map;
        final exerciseName = item['name'] as String;
        final exerciseRows = await db.query(
          'exercises',
          columns: ['id'],
          where: 'name = ?',
          whereArgs: [exerciseName],
        );
        if (exerciseRows.isEmpty) continue;
        await db.insert('routine_exercises', {
          'routineId': routineId,
          'exerciseId': exerciseRows.first['id'],
          'targetSets': item['sets'],
          'targetReps': item['reps'],
          'orderIndex': i,
          'uuid': newUuid(),
          'routineUuid': routineUuid,
          'exerciseUuid': presetExerciseUuid(exerciseName),
          'updatedAt': now,
        });
      }
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
