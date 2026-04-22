// lib/core/app_config.dart
//
// Compile-time configuration via --dart-define.
// NEVER ship plaintext secrets in assets.
//
// Build usage:
//   flutter run  --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=eyJ...
//   flutter build apk --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=eyJ...
//
// The values are baked into the binary at compile-time and are NOT readable
// as plaintext files from the APK/IPA bundle.

class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL/SUPABASE_ANON_KEY. Build with --dart-define.',
      );
    }
  }

  /// App display name used in analytics and notifications.
  static const appName = 'رسالة الإسلام';

  /// Play Store / App Store package identifier.
  /// Used for rating and sharing. Update below when published.
  static const playStoreId = 'com.alghaya.islamicmessage';
}
