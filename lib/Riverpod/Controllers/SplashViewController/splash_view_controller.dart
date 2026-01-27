import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// Splash View Model - Page state for Splash screen
class SplashViewModel {
  final int currentSlideIndex;
  final bool isAutoPlaying;
  final bool isLoading;

  SplashViewModel({
    this.currentSlideIndex = 0,
    this.isAutoPlaying = true,
    this.isLoading = false,
  });

  SplashViewModel copyWith({
    int? currentSlideIndex,
    bool? isAutoPlaying,
    bool? isLoading,
  }) {
    return SplashViewModel(
      currentSlideIndex: currentSlideIndex ?? this.currentSlideIndex,
      isAutoPlaying: isAutoPlaying ?? this.isAutoPlaying,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Splash View Controller
class SplashViewController extends StateNotifier<SplashViewModel> {
  final Ref ref;
  Timer? _autoPlayTimer;

  // Total number of intro slides
  static const int totalSlides = 3;

  SplashViewController(this.ref) : super(SplashViewModel()) {
    _startAutoPlay();
  }

  /// Start auto-play timer
  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(
      const Duration(milliseconds: 5000), // Auto slide every 5 seconds
      (timer) {
        if (state.isAutoPlaying && state.currentSlideIndex < totalSlides - 1) {
          nextSlide();
        } else {
          timer.cancel();
        }
      },
    );
  }

  /// Stop auto-play (when user manually swipes)
  void stopAutoPlay() {
    _autoPlayTimer?.cancel();
    state = state.copyWith(isAutoPlaying: false);
  }

  /// Go to next slide
  void nextSlide() {
    if (state.currentSlideIndex < totalSlides - 1) {
      state = state.copyWith(currentSlideIndex: state.currentSlideIndex + 1);
    }
  }

  /// Go to previous slide
  void previousSlide() {
    if (state.currentSlideIndex > 0) {
      stopAutoPlay();
      state = state.copyWith(currentSlideIndex: state.currentSlideIndex - 1);
    }
  }

  /// Set specific slide index
  void setSlideIndex(int index) {
    stopAutoPlay();
    state = state.copyWith(currentSlideIndex: index);
  }

  /// Navigate to onboarding (called after last slide or skip button)
  void navigateToOnboarding() {
    // TODO: Navigate to onboarding when implemented
    print('Navigate to Onboarding');
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }
}
