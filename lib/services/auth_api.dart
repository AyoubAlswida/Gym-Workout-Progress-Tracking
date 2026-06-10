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

/// Permanently signed-out auth used when Supabase isn't configured, so the
/// app runs fully offline with the account UI hidden.
class OfflineAuthApi implements AuthApi {
  @override
  Stream<AuthUser?> get authState => const Stream.empty();

  @override
  AuthUser? get currentUser => null;

  @override
  Future<void> signUp(String email, String password) async {}

  @override
  Future<void> signInWithPassword(String email, String password) async {}

  @override
  Future<void> signOut() async {}
}
