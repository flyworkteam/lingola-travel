import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'SplashViewController/splash_view_controller.dart';

/// Global controller providers registry
/// All StateNotifierProviders for controllers are defined here
class AllControllers {
  AllControllers._(); // Private constructor

  // Splash Controller
  static final splash =
      StateNotifierProvider<SplashViewController, SplashViewModel>(
        (ref) => SplashViewController(ref),
      );

  // TODO: Add more controller providers as they are created
  //   (ref) => OnboardingViewController(ref),
  // );
}
