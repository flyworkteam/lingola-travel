/// App configuration constants
class AppConfig {
  AppConfig._(); // Private constructor

  // App Info
  static const String appName = 'Lingola Travel';
  static const String appVersion = '1.0.0';

  // API Configuration
  // TODO: Replace with actual backend URL before deployment
  static const String baseUrl = 'http://localhost:3000/api';
  static const String apiVersion = 'v1';
  static const String apiTimeout = '30'; // seconds

  // ScreenUtil Design Size (from Figma)
  static const double designWidth = 393;
  static const double designHeight = 852;

  // OneSignal Configuration
  // TODO: Add OneSignal App ID after setup
  static const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';

  // Social Auth Configuration
  // TODO: Add credentials after obtaining from respective platforms
  static const String googleClientIdIOS = 'YOUR_GOOGLE_CLIENT_ID_IOS';
  static const String googleClientIdAndroid = 'YOUR_GOOGLE_CLIENT_ID_ANDROID';
  static const String googleClientIdWeb = 'YOUR_GOOGLE_CLIENT_ID_WEB';

  static const String appleTeamId = 'YOUR_APPLE_TEAM_ID';
  static const String appleClientId = 'YOUR_APPLE_CLIENT_ID';
  static const String appleRedirectUri = 'YOUR_APPLE_REDIRECT_URI';

  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';
  static const String facebookClientToken = 'YOUR_FACEBOOK_CLIENT_TOKEN';

  // RevenueCat Configuration (for future use)
  // TODO: Add RevenueCat API keys after store approval
  static const String revenueCatApiKeyIOS = 'YOUR_REVENUECAT_IOS_KEY';
  static const String revenueCatApiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_KEY';

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
  static const bool enableRevenueCat = false; // Enable after store approval
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
