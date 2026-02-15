import 'base_repository.dart';
import '../Models/api_response.dart';

/// Profile Repository
/// Handles user profile and onboarding-related API calls
class ProfileRepository extends BaseRepository {
  /// Get user profile
  Future<ApiResponse<dynamic>> getProfile() async {
    try {
      return await apiClient.get('/profile');
    } catch (e) {
      return handleError(e);
    }
  }

  /// Update user profile
  Future<ApiResponse<dynamic>> updateProfile({
    String? name,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (photoUrl != null) data['photo_url'] = photoUrl;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;

      return await apiClient.patch('/profile', data: data);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get user statistics
  Future<ApiResponse<dynamic>> getStats() async {
    try {
      return await apiClient.get('/profile/stats');
    } catch (e) {
      return handleError(e);
    }
  }

  /// Save onboarding preferences
  Future<ApiResponse<dynamic>> saveOnboarding({
    required String targetLanguage,
    String? profession,
    String? englishLevel,
    String? dailyGoal,
    int? dailyGoalMinutes,
  }) async {
    try {
      final Map<String, dynamic> data = {'target_language': targetLanguage};

      if (profession != null) data['profession'] = profession;
      if (englishLevel != null) data['english_level'] = englishLevel;
      if (dailyGoal != null) data['daily_goal'] = dailyGoal;
      if (dailyGoalMinutes != null)
        data['daily_goal_minutes'] = dailyGoalMinutes;

      return await apiClient.put('/profile/onboarding', data: data);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Change password
  Future<ApiResponse<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await apiClient.post(
        '/profile/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      return handleError(e);
    }
  }
}
