import 'package:flutter/foundation.dart';

/// Drives manual/triggered sync with loading + error state. The actual work
/// (building a SyncService for the current user and running push/pull) and the
/// gating (signed in + configured + online) are injected, keeping this
/// viewmodel pure and testable.
class SyncViewModel extends ChangeNotifier {
  final Future<void> Function() _runSync;
  final bool Function() _canSync;

  SyncViewModel({
    required Future<void> Function() runSync,
    required bool Function() canSync,
  })  : _runSync = runSync,
        _canSync = canSync;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  DateTime? _lastSyncedAt;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  String? _lastError;
  String? get lastError => _lastError;

  bool get canSync => _canSync();

  Future<void> syncNow() async {
    if (_isSyncing || !_canSync()) return;
    _isSyncing = true;
    _lastError = null;
    notifyListeners();
    try {
      await _runSync();
      _lastSyncedAt = DateTime.now();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
