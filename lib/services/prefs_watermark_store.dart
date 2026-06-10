import 'package:shared_preferences/shared_preferences.dart';

import 'remote_data_source.dart';

/// Persists per-table pull watermarks in shared_preferences.
class PrefsWatermarkStore implements SyncWatermarkStore {
  static const _prefix = 'sync_wm_';

  @override
  Future<String?> get(String table) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$table');
  }

  @override
  Future<void> set(String table, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$table', value);
  }
}
