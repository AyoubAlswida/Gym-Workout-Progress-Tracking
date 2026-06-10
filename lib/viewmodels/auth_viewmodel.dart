import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/auth_api.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthApi _auth;

  /// Invoked after a sign-in transition so the app can kick off an initial
  /// sync. Wired in main.dart to SyncViewModel.syncNow().
  final Future<void> Function()? onSignedIn;

  StreamSubscription<AuthUser?>? _sub;

  AuthViewModel({required AuthApi auth, this.onSignedIn}) : _auth = auth {
    _user = _auth.currentUser;
    _sub = _auth.authState.listen(_onAuthChanged);
  }

  AuthUser? _user;
  AuthUser? get user => _user;
  bool get isSignedIn => _user != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void _onAuthChanged(AuthUser? user) {
    final wasSignedOut = _user == null;
    _user = user;
    notifyListeners();
    if (wasSignedOut && user != null) {
      onSignedIn?.call();
    }
  }

  Future<bool> signIn(String email, String password) =>
      _run(() => _auth.signInWithPassword(email, password));

  Future<bool> signUp(String email, String password) =>
      _run(() => _auth.signUp(email, password));

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Runs an auth call with loading/error bookkeeping; returns success.
  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
