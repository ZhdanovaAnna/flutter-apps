/// Supabase connection settings.
///
/// The publishable/anon key is intended for use in a client application.
/// Never put a Supabase secret/service-role key here.
class SupabaseConfig {
  static const String url = 'https://ryxzwmmyevhrcdxfubje.supabase.co';
  static const String publishableKey =
      'sb_publishable_cvCSoEqf1q4AKMoOoqSHqQ_JC38ts86';

  static bool get isConfigured =>
      url.startsWith('http') &&
      !url.contains('PASTE_YOUR') &&
      publishableKey.isNotEmpty &&
      !publishableKey.contains('PASTE_YOUR');
}
