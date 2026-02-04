import 'package:flutter/material.dart';
import '../../View/SplashView/splash_view.dart';
import '../../View/SplashView/splash_page_view.dart';
import '../../View/OnboardingView/sign_in_view.dart';
import '../../View/OnboardingView/language_selection_view.dart';
import '../../View/OnboardingView/profession_selection_view.dart';
import '../../View/OnboardingView/english_level_selection_view.dart';
import '../../View/OnboardingView/daily_goal_selection_view.dart';
import '../../View/OnboardingView/creating_plan_view.dart';
import '../../View/HomeView/home_view.dart'; // Free version with CustomBottomNavBar

/// App Routes - Named route definitions
class AppRoutes {
  AppRoutes._(); // Private constructor

  // Route Names
  static const String splash = '/';
  static const String splashPages = '/splash-pages';
  static const String onboarding = '/onboarding';
  static const String languageSelection = '/language-selection';
  static const String professionSelection = '/profession-selection';
  static const String englishLevelSelection = '/english-level-selection';
  static const String dailyGoalSelection = '/daily-goal-selection';
  static const String creatingPlan = '/creating-plan';
  static const String login = '/login';
  static const String home = '/home';
  static const String premium = '/premium';

  // Main Navigation Routes
  static const String travelVocabulary = '/travel-vocabulary';
  static const String dictionary = '/dictionary';
  static const String courses = '/courses';
  static const String quiz = '/quiz';
  static const String library = '/library';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Travel Vocabulary Routes
  static const String vocabCategory = '/vocab-category';
  static const String vocabDetail = '/vocab-detail';

  // Dictionary Routes
  static const String dictionarySearch = '/dictionary-search';
  static const String dictionaryCategory = '/dictionary-category';
  static const String dictionaryDetail = '/dictionary-detail';

  // Quiz Routes
  static const String quizCategory = '/quiz-category';
  static const String quizStart = '/quiz-start';
  static const String quizResult = '/quiz-result';

  // Course Routes
  static const String courseDetail = '/course-detail';
  static const String lessonDetail = '/lesson-detail';

  // Profile Routes
  static const String profileEdit = '/profile-edit';
  static const String settings = '/settings';
  static const String subscriptionManagement = '/subscription-management';
  static const String progress = '/progress';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // TODO: Implement actual route generation with proper widgets
    // For now, return a placeholder
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text('Route not implemented: ${settings.name}')),
      ),
    );
  }

  // Routes Map (will be populated as we build views)
  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashView(),
      splashPages: (context) => const SplashPageView(),
      onboarding: (context) => const SignInView(),
      languageSelection: (context) => const LanguageSelectionView(),
      professionSelection: (context) => const ProfessionSelectionView(),
      englishLevelSelection: (context) => const EnglishLevelSelectionView(),
      dailyGoalSelection: (context) => const DailyGoalSelectionView(),
      creatingPlan: (context) => const CreatingPlanView(),
      home: (context) => const HomeView(), // Free version with new bottom nav
      // TODO: Add more routes as views are created
      // etc.
    };
  }
}
