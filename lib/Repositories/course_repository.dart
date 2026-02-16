import '../Models/api_response.dart';
import '../Models/course_model.dart';
import '../Services/api_client.dart';
import 'base_repository.dart';

/// Course Repository - Handles all course-related API calls
class CourseRepository extends BaseRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get all courses
  Future<ApiResponse<List<CourseModel>>> getCourses({
    String? targetLanguage,
  }) async {
    try {
      final queryParams = targetLanguage != null
          ? '?language=$targetLanguage'
          : '';
      final response = await _apiClient.get('/courses$queryParams');

      if (response.success && response.data != null) {
        final List<dynamic> coursesJson = response.data['courses'] ?? [];
        final courses = coursesJson
            .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return ApiResponse(success: true, data: courses);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get course by ID
  Future<ApiResponse<CourseModel>> getCourseById(String courseId) async {
    try {
      final response = await _apiClient.get('/courses/$courseId');

      if (response.success && response.data != null) {
        final course = CourseModel.fromJson(
          response.data['course'] as Map<String, dynamic>,
        );

        return ApiResponse(success: true, data: course);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get lessons for a specific course
  Future<ApiResponse<List<LessonModel>>> getLessonsByCourse(
    String courseId,
  ) async {
    try {
      print('📡 CourseRepository.getLessonsByCourse - courseId: $courseId');
      final response = await _apiClient.get('/courses/$courseId/lessons');

      print('📡 Raw response - success: ${response.success}');
      print('📡 Raw response - data: ${response.data}');
      print('📡 Raw response - error: ${response.error}');

      if (response.success && response.data != null) {
        final List<dynamic> lessonsJson = response.data['lessons'] ?? [];
        print('📡 Lessons JSON count: ${lessonsJson.length}');

        final lessons = lessonsJson
            .map((json) => LessonModel.fromJson(json as Map<String, dynamic>))
            .toList();

        print('📡 Parsed lessons count: ${lessons.length}');
        return ApiResponse(success: true, data: lessons);
      }

      print('❌ Response not successful or data is null');
      return ApiResponse(success: false, error: response.error);
    } catch (e, stackTrace) {
      print('💥 Exception in getLessonsByCourse: $e');
      print('Stack trace: $stackTrace');
      return handleError(e);
    }
  }

  /// Get user's course progress
  Future<ApiResponse<Map<String, dynamic>>> getUserCourseProgress(
    int courseId,
  ) async {
    try {
      final response = await _apiClient.get('/courses/$courseId/progress');

      if (response.success && response.data != null) {
        return ApiResponse(
          success: true,
          data: response.data as Map<String, dynamic>,
        );
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Update course progress
  Future<ApiResponse<bool>> updateCourseProgress({
    required int courseId,
    required int lessonsCompleted,
    int? currentLessonId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/courses/$courseId/progress',
        data: {
          'lessons_completed': lessonsCompleted,
          if (currentLessonId != null) 'current_lesson_id': currentLessonId,
        },
      );

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }
}
