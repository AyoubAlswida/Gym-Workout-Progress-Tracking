import 'dart:async';

import 'package:gym_workout_tracking/services/auth_api.dart';

/// In-memory auth for tests. [failNext] makes the next call throw.
class FakeAuthApi implements AuthApi {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;
  bool failNext = false;

  @override
  Stream<AuthUser?> get authState => _controller.stream;

  @override
  AuthUser? get currentUser => _current;

  void _maybeFail() {
    if (failNext) {
      failNext = false;
      throw Exception('auth failed');
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    _maybeFail();
    _setUser(AuthUser(id: 'fake-id', email: email));
  }

  @override
  Future<void> signInWithPassword(String email, String password) async {
    _maybeFail();
    _setUser(AuthUser(id: 'fake-id', email: email));
  }

  @override
  Future<void> signOut() async {
    _setUser(null);
  }

  void _setUser(AuthUser? user) {
    _current = user;
    _controller.add(user);
  }

  void dispose() => _controller.close();
}
