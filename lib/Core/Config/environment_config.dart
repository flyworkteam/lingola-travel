/// Environment Configuration
/// Handles different environments (development, staging, production)
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;

  /// Get current environment
  static Environment get currentEnvironment => _currentEnvironment;

  /// Set environment (call this in main.dart)
  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  /// Get base URL based on environment
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000/api';
      case Environment.staging:
        // TODO: Update with your staging backend URL
        return 'https://staging-api.lingolatravel.com/api';
      case Environment.production:
        // TODO: Update with your production backend URL
        return 'https://api.lingolatravel.com/api';
    }
  }

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
  static bool get enableDebugLogging => !isProduction;
  static bool get enableDetailedErrors => isDevelopment;
}
