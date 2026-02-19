import '../Models/api_response.dart';
import '../Models/policy_model.dart';
import 'base_repository.dart';

/// Policy Repository - Handles all policy-related API calls
class PolicyRepository extends BaseRepository {
  /// Get Privacy Policy
  Future<ApiResponse<PolicyModel>> getPrivacyPolicy() async {
    try {
      final response = await apiClient.get('/policies/privacy');
      print(
        '🔍 Privacy Policy Response: success=${response.success}, data=${response.data}',
      );

      if (response.success && response.data != null) {
        final policy = PolicyModel.fromJson(response.data);
        return ApiResponse(success: true, data: policy);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get Terms of Service
  Future<ApiResponse<PolicyModel>> getTermsOfService() async {
    try {
      final response = await apiClient.get('/policies/terms');
      print(
        '🔍 Terms Response: success=${response.success}, data=${response.data}',
      );

      if (response.success && response.data != null) {
        final policy = PolicyModel.fromJson(response.data);
        return ApiResponse(success: true, data: policy);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get Cookies Policy
  Future<ApiResponse<PolicyModel>> getCookiesPolicy() async {
    try {
      final response = await apiClient.get('/policies/cookies');
      print(
        '🔍 Cookies Policy Response: success=${response.success}, data=${response.data}',
      );

      if (response.success && response.data != null) {
        final policy = PolicyModel.fromJson(response.data);
        return ApiResponse(success: true, data: policy);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }
}
