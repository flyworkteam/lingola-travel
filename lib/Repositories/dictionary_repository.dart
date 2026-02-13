import '../Models/api_response.dart';
import '../Models/dictionary_model.dart';
import '../Models/travel_phrase_model.dart';
import '../Services/api_client.dart';
import 'base_repository.dart';

/// Dictionary Repository - Handles all dictionary-related API calls
class DictionaryRepository extends BaseRepository {
  /// Get all dictionary categories
  Future<ApiResponse<List<DictionaryCategoryModel>>> getCategories() async {
    try {
      final response = await apiClient.get('/dictionary/categories');

      if (response.success && response.data != null) {
        final List<dynamic> categoriesJson = response.data['categories'] ?? [];
        final categories = categoriesJson
            .map(
              (json) => DictionaryCategoryModel.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();

        return ApiResponse(success: true, data: categories);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get words by category
  Future<ApiResponse<List<DictionaryWordModel>>> getWordsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.get(
        '/dictionary/categories/$categoryId/words',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.success && response.data != null) {
        final List<dynamic> wordsJson = response.data['words'] ?? [];
        final words = wordsJson
            .map(
              (json) =>
                  DictionaryWordModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return ApiResponse(success: true, data: words);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Search words
  Future<ApiResponse<List<DictionaryWordModel>>> searchWords({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/dictionary/search',
        queryParameters: {'q': query, 'page': page, 'limit': limit},
      );

      if (response.success && response.data != null) {
        final List<dynamic> wordsJson = response.data['words'] ?? [];
        final words = wordsJson
            .map(
              (json) =>
                  DictionaryWordModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return ApiResponse(success: true, data: words);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get word by ID
  Future<ApiResponse<DictionaryWordModel>> getWordById(int wordId) async {
    try {
      final response = await apiClient.get('/dictionary/words/$wordId');

      if (response.success && response.data != null) {
        final word = DictionaryWordModel.fromJson(
          response.data['word'] as Map<String, dynamic>,
        );

        return ApiResponse(success: true, data: word);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get travel phrases by category
  Future<ApiResponse<List<TravelPhraseModel>>> getTravelPhrases({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/dictionary/phrases',
        queryParameters: {
          if (category != null) 'category': category,
          'page': page,
          'limit': limit,
        },
      );

      if (response.success && response.data != null) {
        final List<dynamic> phrasesJson = response.data['phrases'] ?? [];
        final phrases = phrasesJson
            .map(
              (json) =>
                  TravelPhraseModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return ApiResponse(success: true, data: phrases);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get recent searches
  Future<ApiResponse<List<String>>> getRecentSearches({int limit = 10}) async {
    try {
      final response = await apiClient.get(
        '/dictionary/recent-searches',
        queryParameters: {'limit': limit},
      );

      if (response.success && response.data != null) {
        final List<dynamic> searchesJson = response.data['searches'] ?? [];
        final searches = searchesJson
            .map((item) => (item as Map<String, dynamic>)['query'] as String)
            .toList();

        return ApiResponse(success: true, data: searches);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Save search query
  Future<ApiResponse<bool>> saveSearchQuery(String query) async {
    try {
      final response = await apiClient.post(
        '/dictionary/recent-searches',
        data: {'query': query},
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

  /// Clear recent searches
  Future<ApiResponse<bool>> clearRecentSearches() async {
    try {
      final response = await apiClient.delete('/dictionary/recent-searches');

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
