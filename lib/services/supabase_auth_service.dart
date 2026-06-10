import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'auth_api.dart';

/// Concrete [AuthApi] over supabase_flutter email/password auth. Verified
/// manually on a device — not unit-tested.
class SupabaseAuthService implements AuthApi {
  final SupabaseClient _client;

  SupabaseAuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  AuthUser? _fromSupabase(User? user) =>
      user == null ? null : AuthUser(id: user.id, email: user.email);

  @override
  Stream<AuthUser?> get authState => _client.auth.onAuthStateChange
      .map((state) => _fromSupabase(state.session?.user));

  @override
  AuthUser? get currentUser => _fromSupabase(_client.auth.currentUser);

  @override
  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signInWithPassword(String email, String password) async {
    await _client.auth
        .signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
