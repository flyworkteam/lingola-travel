import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/course_model.dart';
import '../../Repositories/course_repository.dart';

/// Course Controller State
class CourseControllerState {
  final List<CourseModel> courses;
  final bool isLoading;
  final String? errorMessage;
  final String targetLanguage;

  const CourseControllerState({
    this.courses = const [],
    this.isLoading = false,
    this.errorMessage,
    this.targetLanguage = 'en',
  });

  CourseControllerState copyWith({
    List<CourseModel>? courses,
    bool? isLoading,
    String? errorMessage,
    String? targetLanguage,
  }) {
    return CourseControllerState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}

/// Course Controller
class CourseController extends StateNotifier<CourseControllerState> {
  final CourseRepository _repository;

  CourseController(this._repository) : super(const CourseControllerState());

  /// Initialize and load courses
  Future<void> init({String? targetLanguage}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final response = await _repository.getCourses(
        targetLanguage: targetLanguage ?? state.targetLanguage,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          courses: response.data!,
          isLoading: false,
          targetLanguage: targetLanguage ?? state.targetLanguage,
        );
        print(
          '✅ Loaded ${response.data!.length} courses for ${state.targetLanguage}',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.error?.toString() ?? 'Failed to load courses',
        );
        print('❌ Failed to load courses: ${response.error}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      print('❌ Error loading courses: $e');
    }
  }

  /// Refresh courses
  Future<void> refresh() async {
    await init(targetLanguage: state.targetLanguage);
  }

  /// Change target language and reload courses
  Future<void> changeLanguage(String language) async {
    await init(targetLanguage: language);
  }

  /// Get lessons for a specific course
  Future<List<LessonModel>> getCourseLessons(String courseId) async {
    try {
      final response = await _repository.getLessonsByCourse(courseId);

      if (response.success && response.data != null) {
        print('✅ Loaded ${response.data!.length} lessons for course $courseId');
        return response.data!;
      } else {
        print('❌ Failed to load lessons: ${response.error}');
        return [];
      }
    } catch (e) {
      print('❌ Error loading lessons: $e');
      return [];
    }
  }

  /// Update course progress
  Future<void> updateProgress(
    String courseId,
    int lessonsCompleted,
    int progressPercentage,
  ) async {
    // Update local state
    final updatedCourses = state.courses.map((course) {
      if (course.id == courseId) {
        return CourseModel(
          id: course.id,
          category: course.category,
          title: course.title,
          description: course.description,
          imageUrl: course.imageUrl,
          totalLessons: course.totalLessons,
          isFree: course.isFree,
          displayOrder: course.displayOrder,
          lessonsCompleted: lessonsCompleted,
          progressPercentage: progressPercentage,
        );
      }
      return course;
    }).toList();

    state = state.copyWith(courses: updatedCourses);
  }
}

/// Course Controller Provider
final courseControllerProvider =
    StateNotifierProvider<CourseController, CourseControllerState>((ref) {
      return CourseController(CourseRepository());
    });
