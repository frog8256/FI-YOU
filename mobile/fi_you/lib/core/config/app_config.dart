import 'package:flutter/foundation.dart';

class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'production');
  static const privacyPolicyUrl = 'https://fi-you.vercel.app/privacy';

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static bool get canUseMockRepository =>
      !kReleaseMode && (appEnv == 'local' || appEnv == 'development' || appEnv == 'test');
}
