import 'package:sqflite/sqflite.dart';

import '../core/database/db_helper.dart';
import 'remote_data_source.dart';

/// Describes how one table participates in sync.
class _SyncTable {
  final String name;

  /// Extra WHERE applied on push so seeded/preset rows never upload.
  final String? pushFilter;

  /// Parent-uuid columns that must be resolved to local ids on pull.
  final List<_ParentLink> parents;

  const _SyncTable(this.name, {this.pushFilter, this.parents = const []});
}

class _ParentLink {
  final String uuidColumn; // e.g. 'sessionUuid'
  final String parentTable; // e.g. 'workout_sessions'
  final String localFkColumn; // e.g. 'sessionId'
  const _ParentLink(this.uuidColumn, this.parentTable, this.localFkColumn);
}

/// Offline-first bidirectional sync: push local changes, then pull remote
/// ones. Parents are processed before children in both directions so
/// parent-uuid references always resolve. Conflicts are resolved
/// last-write-wins by `updatedAt`.
class SyncService {
  final DatabaseHelper _dbHelper;
  final RemoteDataSource _remote;
  final SyncWatermarkStore _watermarks;
  final String userId;

  SyncService({
    required this.userId,
    required RemoteDataSource remote,
    required SyncWatermarkStore watermarks,
    DatabaseHelper? dbHelper,
  })  : _remote = remote,
        _watermarks = watermarks,
        _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // Parents before children.
  static const List<_SyncTable> _tables = [
    _SyncTable('exercises', pushFilter: 'isCustom = 1'),
    _SyncTable('routines', pushFilter: 'isPreset = 0'),
    _SyncTable('workout_sessions'),
    _SyncTable('body_measurements'),
    _SyncTable('progress_photos'),
    _SyncTable('workout_sets', parents: [
      _ParentLink('sessionUuid', 'workout_sessions', 'sessionId'),
      _ParentLink('exerciseUuid', 'exercises', 'exerciseId'),
    ]),
    _SyncTable('routine_exercises', parents: [
      _ParentLink('routineUuid', 'routines', 'routineId'),
      _ParentLink('exerciseUuid', 'exercises', 'exerciseId'),
    ]),
  ];

  bool _running = false;

  /// Push then pull. Serialized: overlapping calls are ignored.
  Future<void> sync() async {
    if (_running) return;
    _running = true;
    try {
      await _pushAll();
      await _pullAll();
    } finally {
      _running = false;
    }
  }

  Future<void> _pushAll() async {
    final db = await _dbHelper.database;
    for (final table in _tables) {
      final where = StringBuffer('isDirty = 1');
      if (table.pushFilter != null) where.write(' AND ${table.pushFilter}');
      final rows = await db.query(table.name, where: where.toString());
      if (rows.isEmpty) continue;

      final payload = rows.map((row) {
        final out = Map<String, dynamic>.from(row)
          ..remove('id')
          ..remove('isDirty')
          ..['user_id'] = userId;
        return out;
      }).toList();

      await _remote.upsert(table.name, payload);

      // Clear dirty on the rows we just pushed.
      final uuids = rows.map((r) => r['uuid']).whereType<String>().toList();
      if (uuids.isNotEmpty) {
        final placeholders = List.filled(uuids.length, '?').join(',');
        await db.rawUpdate(
          'UPDATE ${table.name} SET isDirty = 0 WHERE uuid IN ($placeholders)',
          uuids,
        );
      }
    }
  }

  Future<void> _pullAll() async {
    final db = await _dbHelper.database;
    for (final table in _tables) {
      final since = await _watermarks.get(table.name);
      final incoming = await _remote.fetchSince(table.name, since);
      if (incoming.isEmpty) continue;

      String? maxWatermark = since;
      final deferred = <Map<String, dynamic>>[];

      for (final row in incoming) {
        final applied = await _applyIncoming(db, table, row);
        if (!applied) deferred.add(row);
        final updatedAt = row['updatedAt'] as String?;
        if (updatedAt != null &&
            (maxWatermark == null || updatedAt.compareTo(maxWatermark) > 0)) {
          maxWatermark = updatedAt;
        }
      }

      // Second pass for children whose parent arrived later in the same batch.
      for (final row in deferred) {
        await _applyIncoming(db, table, row);
      }

      if (maxWatermark != null) {
        await _watermarks.set(table.name, maxWatermark);
      }
    }
  }

  /// Returns false if a required parent uuid could not be resolved (caller
  /// should defer and retry in a second pass).
  Future<bool> _applyIncoming(
      Database db, _SyncTable table, Map<String, dynamic> row) async {
    final uuid = row['uuid'] as String?;
    if (uuid == null) return true; // nothing usable; treat as handled

    final local = Map<String, dynamic>.from(row)
      ..remove('user_id')
      ..remove('id')
      ..['isDirty'] = 0;

    // Resolve parent uuids -> local ids.
    for (final parent in table.parents) {
      final parentUuid = row[parent.uuidColumn] as String?;
      if (parentUuid != null) {
        final id = await _localId(db, parent.parentTable, parentUuid);
        if (id == null) return false; // parent missing -> defer
        local[parent.localFkColumn] = id;
      }
    }

    final existing = await db.query(table.name,
        columns: ['id', 'updatedAt'], where: 'uuid = ?', whereArgs: [uuid]);
    final incomingUpdatedAt = row['updatedAt'] as String? ?? '';

    if (existing.isEmpty) {
      // Don't materialize a tombstone we've never seen.
      if (_isDeleted(row)) return true;
      await db.insert(table.name, local);
    } else {
      final localUpdatedAt = existing.first['updatedAt'] as String? ?? '';
      // Last-write-wins; ties keep local (already applied).
      if (incomingUpdatedAt.compareTo(localUpdatedAt) > 0) {
        await db.update(table.name, local,
            where: 'uuid = ?', whereArgs: [uuid]);
      }
    }
    return true;
  }

  bool _isDeleted(Map<String, dynamic> row) =>
      row['isDeleted'] == 1 || row['isDeleted'] == true;

  Future<int?> _localId(Database db, String table, String uuid) async {
    final rows = await db.query(table,
        columns: ['id'], where: 'uuid = ?', whereArgs: [uuid]);
    return rows.isEmpty ? null : rows.first['id'] as int?;
  }
}
