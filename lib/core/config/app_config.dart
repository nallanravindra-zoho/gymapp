/// Build-time settings for the backend. They are passed with
/// `--dart-define-from-file=env.json` (see `env.example.json`), so they live
/// outside the source code. All three are public client identifiers, not
/// secrets: row-level security on the server is what protects the data.
class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// The publishable key (`sb_publishable_...`). The older name
  /// `SUPABASE_ANON_KEY` is also accepted.
  static const _publishable = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const _anon = String.fromEnvironment('SUPABASE_ANON_KEY');
  static String get supabaseKey =>
      _publishable.isNotEmpty ? _publishable : _anon;

  /// OAuth client id of type "Web application" from Google Cloud.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  /// False in builds made without the settings: the app still works fully
  /// offline and simply does not offer sign-in.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseKey.isNotEmpty &&
      googleWebClientId.isNotEmpty;
}
