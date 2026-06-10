/// The seam between the sync engine and the cloud backend. Rows are passed in
/// the same canonical shape as the local `toMap()` output (camelCase keys,
/// ints for booleans) plus a `user_id`. The concrete Supabase implementation
/// translates to/from Postgres (snake_case, real booleans, timestamptz); the
/// in-memory fake used in tests echoes the canonical shape directly.
abstract class RemoteDataSource {
  /// Upserts rows for [table], keyed on `uuid` (one user's data).
  Future<void> upsert(String table, List<Map<String, dynamic>> rows);

  /// Rows for [table] whose `updatedAt` is strictly greater than
  /// [sinceUpdatedAt] (or all rows when null), including tombstones
  /// (`isDeleted = 1`), ordered by `updatedAt` ascending.
  Future<List<Map<String, dynamic>>> fetchSince(
      String table, String? sinceUpdatedAt);
}

/// Persists per-table pull watermarks (the max `updatedAt` already pulled).
abstract class SyncWatermarkStore {
  Future<String?> get(String table);
  Future<void> set(String table, String value);
}
