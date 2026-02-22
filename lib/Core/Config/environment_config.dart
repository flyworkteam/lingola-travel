import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment Configuration
/// Handles different environments (development, staging, production)
/// Now reads from .env file
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;

  /// Initialize environment config (call in main.dart)
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  /// Get current environment
  static Environment get currentEnvironment => _currentEnvironment;

  /// Set environment (call this in main.dart)
  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  /// Get base URL from .env or fallback to default
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // Fallback based on environment
    switch (_currentEnvironment) {
      case Environment.development:
        // Real device: use local network IP (without /api suffix, ApiClient adds it)
        return 'http://10.252.15.1122:3000';
      case Environment.staging:
        return 'https://staging-api.lingolatravel.com';
      case Environment.production:
        return 'https://api.lingolatravel.com';
    }
  }

  /// Get API version
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'api/v1';

  /// Get API timeout
  static String get apiTimeout => dotenv.env['API_TIMEOUT'] ?? '60';

  /// Check if we're in production
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// Check if we're in development
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  /// Check if we're in staging
  static bool get isStaging => _currentEnvironment == Environment.staging;

  /// Get environment name
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  /// Enable/Disable features based on environment
  static bool get enableDebugLogging =>
      dotenv.env['ENABLE_DEBUG_LOGGING']?.toLowerCase() == 'true' ||
      isDevelopment;
  static bool get enableDetailedErrors => isDevelopment;

  /// Get OneSignal App ID
  static String get oneSignalAppId =>
      dotenv.env['ONESIGNAL_APP_ID'] ?? 'YOUR_ONESIGNAL_APP_ID';
}
