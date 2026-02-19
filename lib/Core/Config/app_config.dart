import 'environment_config.dart';

/// App configuration constants
class AppConfig {
  AppConfig._(); // Private constructor

  // App Info
  static const String appName = 'Lingola Travel';
  static const String appVersion = '1.0.0';

  // API Configuration
  // Backend URL is now managed by EnvironmentConfig
  static String get baseUrl => EnvironmentConfig.baseUrl;
  static const String apiVersion = 'v1';
  static const String apiTimeout = '30'; // seconds

  // ScreenUtil Design Size (from Figma)
  static const double designWidth = 393;
  static const double designHeight = 852;

  // OneSignal Configuration
  static const String oneSignalAppId =
      'os_v2_app_md3igryoz5eafffspayjs3g6g656yuqjafeusv56fnnfuldca3vknyeldhcjvfqfj34gfwgttpp2thv7gra22mmmlhcd2wzpjjmjzpi';

  // Social Auth Configuration
  // ✅ Keys from backend .env
  static const String googleClientIdIOS =
      '1029036878125-jfifd1h29ksjqrj7itof3rprkendhfbg.apps.googleusercontent.com';
  static const String googleClientIdAndroid =
      '1029036878125-4tk01breq1fk6773de1q33sb3od28oqa.apps.googleusercontent.com';
  static const String googleClientIdWeb =
      '1029036878125-ve1subf0p13cg2tfnktpqqo1ij7gvlfj.apps.googleusercontent.com';

  static const String appleTeamId = 'JK42R39DT5';
  static const String appleClientId = 'com.flywork.lingolatravel';
  static const String appleRedirectUri =
      'https://lingola-travel-api.com/auth/apple/callback';

  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';
  static const String facebookClientToken = 'YOUR_FACEBOOK_CLIENT_TOKEN';

  // RevenueCat Configuration
  static const String revenueCatApiKeyIOS = 'appl_kNUfZQftWCZOoUHTEUfeLNjZgBH';
  static const String revenueCatApiKeyAndroid =
      'goog_FilzbVoUQKqbEJvgOlGAaBZIShS';

  // Premium Trial Configuration
  static const int premiumTrialDays = 1;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration (in hours)
  static const int cacheDuration = 24;

  // Audio Configuration
  static const double defaultAudioVolume = 1.0;
  static const double defaultPlaybackSpeed = 1.0;

  // Feature Flags
  static const bool enableFacebookLogin = false; // Enable after store approval
  static const bool enableRevenueCat = true; // ✅ RevenueCat entegrasyonu aktif
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserProfile = 'user_profile';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyLanguageCode = 'language_code';
  static const String keyThemeMode = 'theme_mode';

  // Animation Durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
  static const int splashDuration = 3000;
  static const int autoSlideInterval = 5000;

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'tr', 'es', 'fr', 'de'];

  // Quiz Configuration
  static const int questionsPerQuiz = 10;
  static const int quizTimeLimit = 300; // seconds

  // Daily Goal Options (in minutes)
  static const List<int> dailyGoalOptions = [5, 10, 15, 20, 30];
}
