import 'dart:convert';

import '../core/database/db_helper.dart';

/// Thrown when a backup file can't be restored; [reason] maps to an l10n key
/// decision in the UI ('invalid' vs 'newerVersion').
class BackupException implements Exception {
  final String reason;
  BackupException(this.reason);

  @override
  String toString() => 'BackupException($reason)';
}

/// Serializes the database to/from portable strings. File I/O lives in
/// BackupFileService so this layer stays unit-testable.
class BackupService {
  static const int schemaVersion = 4;

  static const List<String> _tables = [
    'exercises',
    'routines',
    'routine_exercises',
    'workout_sessions',
    'workout_sets',
    'body_measurements',
    'progress_photos',
  ];

  final DatabaseHelper _dbHelper;

  BackupService({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Full-database JSON backup. Photo rows carry file paths only — the
  /// image files themselves are not embedded.
  Future<String> exportJsonBackup() async {
    final db = await _dbHelper.database;
    final tables = <String, List<Map<String, dynamic>>>{};
    for (final table in _tables) {
      tables[table] = await db.query(table);
    }
    return const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': tables,
    });
  }

  /// Workout history as CSV, one row per set. Starts with a UTF-8 BOM so
  /// Excel detects the encoding (Arabic exercise names otherwise garble).
  Future<String> exportWorkoutCsv() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT s.date AS date, s.routineName AS routineName,
             e.name AS exerciseName, e.category AS category,
             ws.weight AS weight, ws.reps AS reps,
             ws.durationSeconds AS durationSeconds,
             ws.distanceMeters AS distanceMeters,
             ws.isCompleted AS isCompleted
      FROM workout_sets ws
      JOIN workout_sessions s ON ws.sessionId = s.id
      JOIN exercises e ON ws.exerciseId = e.id
      ORDER BY s.date ASC, ws.id ASC
    ''');

    final buffer = StringBuffer('﻿');
    const header = [
      'date',
      'routineName',
      'exerciseName',
      'category',
      'weight',
      'reps',
      'durationSeconds',
      'distanceMeters',
      'isCompleted',
    ];
    buffer.writeln(header.join(','));
    for (final row in rows) {
      buffer.writeln(header.map((col) => _csvField(row[col])).join(','));
    }
    return buffer.toString();
  }

  static String _csvField(Object? value) {
    final text = value?.toString() ?? '';
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  /// Wipe-and-replace restore. Original row ids are preserved so cross-table
  /// references (sessionId, exerciseId, routineId) stay intact. Validates
  /// fully before deleting anything; the whole swap runs in one transaction.
  Future<void> importJsonBackup(String jsonString) async {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } on FormatException {
      throw BackupException('invalid');
    } on TypeError {
      throw BackupException('invalid');
    }

    final version = data['schemaVersion'];
    if (version is! int) throw BackupException('invalid');
    if (version > schemaVersion) throw BackupException('newerVersion');

    final tablesRaw = data['tables'];
    if (tablesRaw is! Map<String, dynamic>) throw BackupException('invalid');
    final tables = <String, List<Map<String, dynamic>>>{};
    for (final table in _tables) {
      final rows = tablesRaw[table];
      // Older backups may legitimately lack newer tables.
      if (rows == null) {
        tables[table] = [];
        continue;
      }
      if (rows is! List) throw BackupException('invalid');
      tables[table] = rows.map((row) {
        if (row is! Map<String, dynamic>) throw BackupException('invalid');
        return row;
      }).toList();
    }

    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (final table in _tables) {
        await txn.delete(table);
      }
      for (final table in _tables) {
        for (final row in tables[table]!) {
          await txn.insert(table, row);
        }
      }
    });
  }
}
