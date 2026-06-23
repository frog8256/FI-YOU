import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  const AppConfig._();

  static const appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://fi-you.vercel.app/privacy',
  );
  static const termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://fi-you.vercel.app/terms',
  );
  static const dataDeletionUrl = String.fromEnvironment(
    'DATA_DELETION_URL',
    defaultValue: 'https://fi-you.vercel.app/data-deletion',
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static bool get useSupabase => hasSupabaseConfig;

  static bool get useDebugMockFallback => !kReleaseMode && !hasSupabaseConfig;

  static void validateLaunchConfiguration() {
    if (kReleaseMode && !hasSupabaseConfig) {
      throw StateError(
        'Supabase configuration is required for release builds. '
        'Pass --dart-define=SUPABASE_URL=... and '
        '--dart-define=SUPABASE_PUBLISHABLE_KEY=...',
      );
    }
  }

  static Future<SupabaseClient?> initializeSupabaseIfConfigured() async {
    validateLaunchConfiguration();
    if (!hasSupabaseConfig) {
      return null;
    }
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
    return Supabase.instance.client;
  }
}
