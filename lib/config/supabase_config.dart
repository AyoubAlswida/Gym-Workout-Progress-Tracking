/// Supabase connection settings. Replace the placeholders with your project's
/// values (Project Settings → API) to enable cloud sync. While they remain
/// placeholders, [isConfigured] is false and the app runs fully offline with
/// the account/sync UI hidden — exactly as before Phase 3.
///
/// See docs/SUPABASE_SETUP.md for the full setup walkthrough.
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';

  static bool get isConfigured =>
      !url.startsWith('YOUR_') && !anonKey.startsWith('YOUR_');
}
