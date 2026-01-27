import '../Services/api_client.dart';

/// Base Repository class
/// Provides common methods for all repositories
abstract class BaseRepository {
  final ApiClient _apiClient = ApiClient();

  ApiClient get apiClient => _apiClient;

  /// Handle repository-level errors
  String handleError(ApiError error) {
    // Map error codes to user-friendly messages
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
