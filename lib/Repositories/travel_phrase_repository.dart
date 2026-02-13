import '../Models/api_response.dart';
import '../Models/travel_phrase_model.dart';
import '../Services/api_client.dart';
import 'base_repository.dart';

class TravelPhraseRepository extends BaseRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get travel phrases by category
  Future<ApiResponse<List<TravelPhraseModel>>> getPhrasesByCategory(
    String? category,
  ) async {
    try {
      final queryParams = category != null ? {'category': category} : null;

      final response = await _apiClient.get(
        '/dictionary/phrases',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final phrasesJson = response.data['phrases'] as List;
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

  /// Get all travel phrases
  Future<ApiResponse<List<TravelPhraseModel>>> getAllPhrases() async {
    return getPhrasesByCategory(null);
  }
}
