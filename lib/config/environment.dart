/// Environment configuration for PrivatPDF
///
/// Provides centralized configuration for different environments
/// (development, staging, production) and feature flags.
class Environment {
  /// Current environment
  static const String current = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Whether the app is running in production
  static bool get isProduction => current == 'production';

  /// Whether the app is running in development
  static bool get isDevelopment => current == 'development';

  /// Whether the app is running in staging
  static bool get isStaging => current == 'staging';

  /// App version
  static const String version = '0.1.0';

  /// Maximum file size for free tier (in bytes)
  static const int maxFileSizeFree = 5 * 1024 * 1024; // 5MB

  /// Maximum file size for pro tier (in bytes)
  static const int maxFileSizePro = 100 * 1024 * 1024; // 100MB

  /// Maximum number of files for merge (free tier)
  static const int maxMergeFilesFree = 10;

  /// Maximum number of files for merge (pro tier)
  static const int maxMergeFilesPro = 50;

  /// Minimum password length
  static const int minPasswordLength = 6;

  /// Maximum password length
  static const int maxPasswordLength = 128;

  /// Minimum files required for merge
  static const int minMergeFiles = 2;

  /// Minimum pages required for split
  static const int minSplitPages = 2;

  /// Analytics storage key
  static const String analyticsStorageKey = 'privatpdf_analytics';

  /// Maximum analytics events to store in localStorage
  static const int maxStoredAnalyticsEvents = 1000;

  /// Enable analytics (can be disabled via compile-time constant)
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );

  /// Enable network verification
  static const bool enableNetworkVerification = bool.fromEnvironment(
    'ENABLE_NETWORK_VERIFICATION',
    defaultValue: true,
  );

  /// Enable debug logging
  static bool get enableDebugLogging => isDevelopment;

  /// Auto-reset success state after this duration
  static const Duration successStateResetDuration = Duration(seconds: 3);

  /// Memory cleanup delay after download
  static const Duration memoryCleanupDelay = Duration(milliseconds: 500);

  /// Operation queue processing delay
  static const Duration queueProcessingDelay = Duration(milliseconds: 500);

  /// Download URL cleanup delay
  static const Duration downloadUrlCleanupDelay = Duration(milliseconds: 100);

  /// Whitelisted domains for network verification
  static const List<String> whitelistedDomains = [
    // CDN providers
    'cdn.skypack.dev',
    'cdn.jsdelivr.net',
    'unpkg.com',
    'esm.sh',

    // Google Fonts
    'fonts.googleapis.com',
    'fonts.gstatic.com',

    // Vercel platform
    'vercel.com',
    'vercel.app',

    // CanvasKit (Flutter Web)
    'www.gstatic.com',
  ];

  /// Get configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': current,
      'version': version,
      'isProduction': isProduction,
      'isDevelopment': isDevelopment,
      'maxFileSizeFree': '$maxFileSizeFree bytes (${maxFileSizeFree ~/ 1024 ~/ 1024} MB)',
      'maxFileSizePro': '$maxFileSizePro bytes (${maxFileSizePro ~/ 1024 ~/ 1024} MB)',
      'enableAnalytics': enableAnalytics,
      'enableNetworkVerification': enableNetworkVerification,
      'enableDebugLogging': enableDebugLogging,
    };
  }

  /// Print configuration summary to console
  static void printConfig() {
    if (enableDebugLogging) {
      print('=== PrivatPDF Environment Configuration ===');
      getConfigSummary().forEach((key, value) {
        print('  $key: $value');
      });
      print('==========================================');
    }
  }
}
