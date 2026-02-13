import '../Models/api_response.dart';
import '../Models/course_model.dart';
import '../Services/api_client.dart';
import 'base_repository.dart';

/// Lesson Repository - Handles all lesson-related API calls
class LessonRepository extends BaseRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get lesson by ID
  Future<ApiResponse<LessonModel>> getLessonById(int lessonId) async {
    try {
      final response = await _apiClient.get('/lessons/$lessonId');

      if (response.success && response.data != null) {
        final lesson = LessonModel.fromJson(
          response.data['lesson'] as Map<String, dynamic>,
        );

        return ApiResponse(success: true, data: lesson);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get lesson vocabulary
  Future<ApiResponse<List<LessonVocabularyModel>>> getLessonVocabulary(
    int lessonId,
  ) async {
    try {
      final response = await _apiClient.get('/lessons/$lessonId/vocabulary');

      if (response.success && response.data != null) {
        final List<dynamic> vocabJson = response.data['vocabulary'] ?? [];
        final vocabulary = vocabJson
            .map(
              (json) =>
                  LessonVocabularyModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return ApiResponse(success: true, data: vocabulary);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Mark lesson as completed
  Future<ApiResponse<bool>> completLesson({
    required int lessonId,
    int? timeSpent,
    int? wordsLearned,
  }) async {
    try {
      final response = await _apiClient.post(
        '/lessons/$lessonId/complete',
        data: {
          if (timeSpent != null) 'time_spent': timeSpent,
          if (wordsLearned != null) 'words_learned': wordsLearned,
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

  /// Get user's lesson progress
  Future<ApiResponse<Map<String, dynamic>>> getUserLessonProgress(
    int lessonId,
  ) async {
    try {
      final response = await _apiClient.get('/lessons/$lessonId/progress');

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
}
