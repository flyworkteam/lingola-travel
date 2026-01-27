import 'base_repository.dart';
import '../Models/user_model.dart';

/// Authentication Repository
/// Handles all authentication-related API calls
class AuthRepository extends BaseRepository {
  /// Login with email and password
  Future<AuthResult> loginWithEmail(String email, String password) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        return AuthResult(
          success: true,
          user: UserModel.fromJson(response.data!['user']),
          accessToken: response.data!['accessToken'],
          refreshToken: response.data!['refreshToken'],
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: handleError(response.error!),
        );
      }
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'Bir hata oluştu: $e');
    }
  }

  /// Login with Google
  Future<AuthResult> loginWithGoogle(String idToken) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'idToken': idToken},
      );

      if (response.success && response.data != null) {
        return AuthResult(
          success: true,
          user: UserModel.fromJson(response.data!['user']),
          accessToken: response.data!['accessToken'],
          refreshToken: response.data!['refreshToken'],
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: handleError(response.error!),
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Google girişi başarısız: $e',
      );
    }
  }

  /// Login with Apple
  Future<AuthResult> loginWithApple(String identityToken) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/apple',
        data: {'identityToken': identityToken},
      );

      if (response.success && response.data != null) {
        return AuthResult(
          success: true,
          user: UserModel.fromJson(response.data!['user']),
          accessToken: response.data!['accessToken'],
          refreshToken: response.data!['refreshToken'],
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: handleError(response.error!),
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Apple girişi başarısız: $e',
      );
    }
  }

  /// Login with Facebook
  Future<AuthResult> loginWithFacebook(String accessToken) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/facebook',
        data: {'accessToken': accessToken},
      );

      if (response.success && response.data != null) {
        return AuthResult(
          success: true,
          user: UserModel.fromJson(response.data!['user']),
          accessToken: response.data!['accessToken'],
          refreshToken: response.data!['refreshToken'],
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: handleError(response.error!),
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Facebook girişi başarısız: $e',
      );
    }
  }

  /// Anonymous login
  Future<AuthResult> loginAnonymously(String deviceId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/anonymous',
        data: {'deviceId': deviceId},
      );

      if (response.success && response.data != null) {
        return AuthResult(
          success: true,
          user: UserModel.fromJson(response.data!['user']),
          accessToken: response.data!['accessToken'],
          refreshToken: response.data!['refreshToken'],
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: handleError(response.error!),
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Anonim giriş başarısız: $e',
      );
    }
  }

  /// Refresh access token
  Future<AuthResult> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.success && response.data != null) {
        return AuthResult(
          success: true,
          accessToken: response.data!['accessToken'],
          refreshToken: response.data!['refreshToken'],
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: handleError(response.error!),
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Token yenileme başarısız: $e',
      );
    }
  }

  /// Logout
  Future<bool> logout(String refreshToken) async {
    try {
      final response = await apiClient.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Submit onboarding answers
  Future<bool> submitOnboarding(Map<String, dynamic> answers) async {
    try {
      final response = await apiClient.post('/user/onboarding', data: answers);

      return response.success;
    } catch (e) {
      return false;
    }
  }
}

/// Auth Result Model
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });
}
