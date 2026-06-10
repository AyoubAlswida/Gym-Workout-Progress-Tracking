/// Supabase connection settings. Replace the placeholders with your project's
/// values (Project Settings → API) to enable cloud sync. While they remain
/// placeholders, [isConfigured] is false and the app runs fully offline with
/// the account/sync UI hidden — exactly as before Phase 3.
///
/// See docs/SUPABASE_SETUP.md for the full setup walkthrough.
class SupabaseConfig {
  static const String url = 'https://hpwoggdyrolyeaxgkfma.supabase.co';
  static const String anonKey =
      'sb_publishable_9CzYd_CpSui8EauqulMhHQ_UgGMAWRM';

  static bool get isConfigured =>
      !url.startsWith('YOUR_') && !anonKey.startsWith('YOUR_');
}
