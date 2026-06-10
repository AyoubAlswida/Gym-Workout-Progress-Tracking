import 'package:supabase_flutter/supabase_flutter.dart';

import 'remote_data_source.dart';

/// Concrete [RemoteDataSource] backed by Supabase Postgres. Translates between
/// the canonical local shape (camelCase keys, ints for booleans) and the
/// remote schema (snake_case columns, real booleans). Verified manually on a
/// device — not unit-tested.
class SupabaseRemoteDataSource implements RemoteDataSource {
  final SupabaseClient _client;
  final String userId;

  SupabaseRemoteDataSource({required this.userId, SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // Columns stored as booleans remotely but as 0/1 ints locally.
  static const _boolColumns = {
    'isDeleted',
    'isCompleted',
    'isCustom',
    'isPreset',
  };

  static String _toSnake(String s) =>
      s.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

  static String _toCamel(String s) =>
      s.replaceAllMapped(RegExp(r'_([a-z])'), (m) => m[1]!.toUpperCase());

  Map<String, dynamic> _toRemote(Map<String, dynamic> row) {
    final out = <String, dynamic>{};
    row.forEach((key, value) {
      final remoteKey = _toSnake(key);
      out[remoteKey] = _boolColumns.contains(key) ? value == 1 : value;
    });
    return out;
  }

  Map<String, dynamic> _toLocal(Map<String, dynamic> row) {
    final out = <String, dynamic>{};
    row.forEach((key, value) {
      final localKey = _toCamel(key);
      out[localKey] =
          (_boolColumns.contains(localKey) && value is bool) ? (value ? 1 : 0) : value;
    });
    return out;
  }

  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    final payload = rows.map(_toRemote).toList();
    await _client.from(table).upsert(payload, onConflict: 'uuid');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
      String table, String? sinceUpdatedAt) async {
    var query = _client.from(table).select().eq('user_id', userId);
    if (sinceUpdatedAt != null) {
      query = query.gt('updated_at', sinceUpdatedAt);
    }
    final rows = await query.order('updated_at', ascending: true);
    return rows
        .map((r) => _toLocal(Map<String, dynamic>.from(r)))
        .toList();
  }
}
