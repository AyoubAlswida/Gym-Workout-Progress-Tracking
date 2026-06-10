/// Minimal app-side user, so viewmodels never depend on supabase types.
class AuthUser {
  final String id;
  final String? email;
  const AuthUser({required this.id, this.email});
}

/// Auth seam. The concrete implementation wraps supabase_flutter; tests use a
/// fake.
abstract class AuthApi {
  /// Emits the current user (or null) and every subsequent change.
  Stream<AuthUser?> get authState;

  AuthUser? get currentUser;

  Future<void> signUp(String email, String password);
  Future<void> signInWithPassword(String email, String password);
  Future<void> signOut();
}
