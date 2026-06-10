import 'package:gym_workout_tracking/services/remote_data_source.dart';

/// In-memory stand-in for the cloud backend. Stores rows per table keyed by
/// uuid, applying last-write-wins on upsert so it mirrors the server's
/// conflict behavior.
class FakeRemoteDataSource implements RemoteDataSource {
  final Map<String, Map<String, Map<String, dynamic>>> tables = {};

  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    final store = tables.putIfAbsent(table, () => {});
    for (final row in rows) {
      final uuid = row['uuid'] as String;
      final existing = store[uuid];
      final incomingAt = row['updatedAt'] as String? ?? '';
      final existingAt = existing?['updatedAt'] as String? ?? '';
      if (existing == null || incomingAt.compareTo(existingAt) >= 0) {
        store[uuid] = Map<String, dynamic>.from(row);
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
      String table, String? sinceUpdatedAt) async {
    final store = tables[table];
    if (store == null) return [];
    final rows = store.values.where((r) {
      if (sinceUpdatedAt == null) return true;
      final at = r['updatedAt'] as String? ?? '';
      return at.compareTo(sinceUpdatedAt) > 0;
    }).map((r) => Map<String, dynamic>.from(r)).toList()
      ..sort((a, b) => (a['updatedAt'] as String)
          .compareTo(b['updatedAt'] as String));
    return rows;
  }

  /// Test helper: seed a row as though another device had pushed it.
  void seed(String table, Map<String, dynamic> row) {
    tables.putIfAbsent(table, () => {})[row['uuid'] as String] =
        Map<String, dynamic>.from(row);
  }
}

/// In-memory watermark store for tests.
class FakeWatermarkStore implements SyncWatermarkStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> get(String table) async => _values[table];

  @override
  Future<void> set(String table, String value) async => _values[table] = value;
}
