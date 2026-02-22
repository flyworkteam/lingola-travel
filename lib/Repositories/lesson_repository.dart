import '../Models/api_response.dart';
import '../Models/course_model.dart';
import '../Services/api_client.dart';
import 'base_repository.dart';

/// Lesson Repository - Handles all lesson-related API calls
class LessonRepository extends BaseRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get lesson by ID
  Future<ApiResponse<LessonModel>> getLessonById(String lessonId) async {
    try {
      print('🔍 Fetching lesson: $lessonId');
      final response = await _apiClient.get('/lessons/$lessonId');
      print('📡 API Response success: ${response.success}');
      print('📦 Response data: ${response.data}');

      if (response.success && response.data != null) {
        print('✅ Response data is not null');
        print('🔑 Response keys: ${response.data.keys.toList()}');

        final lessonData = response.data['lesson'];
        print('📄 Lesson data type: ${lessonData.runtimeType}');
        print('📄 Lesson data: $lessonData');

        final lesson = LessonModel.fromJson(lessonData as Map<String, dynamic>);

        print('✅ Lesson parsed successfully: ${lesson.title}');
        return ApiResponse(success: true, data: lesson);
      }

      print('❌ Response not successful or data is null');
      return ApiResponse(success: false, error: response.error);
    } catch (e, stackTrace) {
      print('❌ Exception in getLessonById: $e');
      print('📚 Stack trace: $stackTrace');
      return handleError(e);
    }
  }

  /// Get lesson vocabulary
  Future<ApiResponse<List<LessonVocabularyModel>>> getLessonVocabulary(
    String lessonId,
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
  Future<ApiResponse<bool>> completeLesson({
    required String lessonId,
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
    String lessonId,
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

  /// Update lesson progress
  Future<ApiResponse<bool>> updateLessonProgress({
    required String lessonId,
    int? currentStep,
    int? progressPercentage,
    int? timeSpentSeconds,
    bool? completed,
    int? score,
  }) async {
    try {
      final response = await _apiClient.post(
        '/lessons/$lessonId/progress',
        data: {
          if (currentStep != null) 'current_step': currentStep,
          if (progressPercentage != null)
            'progress_percentage': progressPercentage,
          if (timeSpentSeconds != null) 'time_spent_seconds': timeSpentSeconds,
          if (completed != null) 'completed': completed ? 1 : 0,
          if (score != null) 'score': score,
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

  /// Get next lesson after current lesson
  Future<ApiResponse<Map<String, dynamic>?>> getNextLesson(
    String lessonId,
  ) async {
    try {
      print('🔍 Fetching next lesson after: $lessonId');
      final response = await _apiClient.get('/lessons/$lessonId/next');

      if (response.success && response.data != null) {
        final nextLessonData = response.data['nextLesson'];

        if (nextLessonData == null) {
          // No more lessons
          print('✅ No more lessons - All completed!');
          return ApiResponse(success: true, data: null);
        }

        print('✅ Next lesson found: ${nextLessonData['id']}');
        return ApiResponse(success: true, data: nextLessonData);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      print('❌ Exception in getNextLesson: $e');
      return handleError(e);
    }
  }
}
