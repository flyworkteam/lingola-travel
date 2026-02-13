import '../Services/api_client.dart';
import '../Models/api_response.dart';

/// Base Repository class
/// Provides common methods for all repositories
abstract class BaseRepository {
  final ApiClient _apiClient = ApiClient();

  ApiClient get apiClient => _apiClient;

  /// Handle repository-level errors and convert to ApiResponse
  ApiResponse<T> handleError<T>(Object error) {
    String errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
    String errorCode = 'UNKNOWN_ERROR';

    if (error is ApiError) {
      errorCode = error.code;
      errorMessage = _getLocalizedErrorMessage(error);
    } else if (error is Exception) {
      errorMessage = error.toString();
    }

    return ApiResponse<T>(
      success: false,
      data: null,
      error: ApiError(code: errorCode, message: errorMessage),
    );
  }

  /// Map error codes to user-friendly messages
  String _getLocalizedErrorMessage(ApiError error) {
    switch (error.code) {
      case 'TIMEOUT':
        return 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
      case 'NO_CONNECTION':
        return 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
      case 'UNAUTHORIZED':
        return 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.';
      case 'FORBIDDEN':
        return 'Bu işlem için yetkiniz yok.';
      case 'NOT_FOUND':
        return 'İstenen kaynak bulunamadı.';
      case 'VALIDATION_ERROR':
        return 'Geçersiz veri. Lütfen bilgilerinizi kontrol edin.';
      case 'SERVER_ERROR':
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
      default:
        return error.message;
    }
  }
}
