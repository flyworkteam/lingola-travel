import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/course_model.dart';
import '../../Models/api_response.dart';
import '../../Repositories/course_repository.dart';

/// Home View Model - Page state for Home screen
class HomeViewModel {
  final bool isLoading;
  final String? errorMessage;
  final List<CourseModel> courses;
  final bool isPremium;
  final String userName;

  const HomeViewModel({
    this.isLoading = false,
    this.errorMessage,
    this.courses = const [],
    this.isPremium = false,
    this.userName = 'User',
  });

  HomeViewModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CourseModel>? courses,
    bool? isPremium,
    String? userName,
  }) {
    return HomeViewModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      courses: courses ?? this.courses,
      isPremium: isPremium ?? this.isPremium,
      userName: userName ?? this.userName,
    );
  }
}

/// Home View Controller - Manages home screen state and actions
class HomeViewController extends StateNotifier<HomeViewModel> {
  final CourseRepository _courseRepository = CourseRepository();

  HomeViewController() : super(const HomeViewModel());

  /// Initialize home screen - load courses
  Future<void> init() async {
    print('🚀 HomeViewController.init() başladı');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await loadCourses();
      print('✅ HomeViewController.init() tamamlandı');
    } catch (e) {
      print('❌ HomeViewController.init() HATA: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize home screen',
      );
    }
  }

  /// Load all courses from API
  Future<void> loadCourses() async {
    print('📚 loadCourses() başladı');
    try {
      final ApiResponse<List<CourseModel>> response = await _courseRepository
          .getCourses();

      print(
        '📡 API Response: success=${response.success}, data length=${response.data?.length ?? 0}',
      );

      if (response.success && response.data != null) {
        print('✅ Kurslar yüklendi: ${response.data!.length} adet');
        for (var course in response.data!) {
          print('   - ${course.title} (${course.totalLessons} lessons)');
        }
        state = state.copyWith(
          isLoading: false,
          courses: response.data!,
          errorMessage: null,
        );
      } else {
        print('❌ API başarısız: ${response.error?.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.error?.message ?? 'Failed to load courses',
        );
      }
    } catch (e) {
      print('❌ loadCourses() HATA: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Refresh courses
  Future<void> refresh() async {
    await loadCourses();
  }

  /// Update premium status (from user provider or auth)
  void updatePremiumStatus(bool isPremium) {
    state = state.copyWith(isPremium: isPremium);
  }

  /// Update user name
  void updateUserName(String name) {
    state = state.copyWith(userName: name);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for HomeViewController
final homeViewControllerProvider =
    StateNotifierProvider<HomeViewController, HomeViewModel>(
      (ref) => HomeViewController(),
    );
