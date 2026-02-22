import 'package:dio/dio.dart';
import '../Core/Config/app_config.dart';
import '../Models/api_response.dart';
import 'secure_storage_service.dart';

/// API Client using Dio
/// Handles all HTTP requests with interceptors for auth, logging, and error handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService();

  ApiClient._internal() {
    final baseUrl = AppConfig.apiVersion.isEmpty
        ? AppConfig.baseUrl
        : '${AppConfig.baseUrl}/${AppConfig.apiVersion}';
    print('🌐 API Client initialized with base URL: $baseUrl');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: int.parse(AppConfig.apiTimeout)),
        receiveTimeout: Duration(seconds: int.parse(AppConfig.apiTimeout)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token = await _secureStorage.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔑 Token added to request: ${token.substring(0, 20)}...');
          } else {
            print('⚠️ No access token found!');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - refresh token
          if (error.response?.statusCode == 401) {
            try {
              // Try to refresh token
              final refreshToken = await _secureStorage.getRefreshToken();

              if (refreshToken != null) {
                final refreshed = await _refreshAccessToken(refreshToken);

                if (refreshed) {
                  // Retry original request with new token
                  final newToken = await _secureStorage.getAccessToken();

                  if (newToken != null) {
                    error.requestOptions.headers['Authorization'] =
                        'Bearer $newToken';

                    final response = await _dio.fetch(error.requestOptions);
                    return handler.resolve(response);
                  }
                } else {
                  // Refresh failed, logout user
                  await _clearTokens();
                }
              } else {
                // No refresh token, logout user
                await _clearTokens();
              }
            } catch (e) {
              print('Token refresh error: $e');
              await _clearTokens();
            }
          }

          // Log error
          print(
            'ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  /// Refresh access token using refresh token
  Future<bool> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await Dio().post(
        '${AppConfig.baseUrl}/${AppConfig.apiVersion}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['data']['accessToken'];
        final newRefreshToken = response.data['data']['refreshToken'];

        // Save new tokens
        await _secureStorage.saveAccessToken(newAccessToken);
        await _secureStorage.saveRefreshToken(newRefreshToken);

        print('Token refreshed successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  }

  /// Clear all tokens (logout)
  Future<void> _clearTokens() async {
    await _secureStorage.deleteTokens();
    print('Tokens cleared - User logged out');
  }

  // GET Request
  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullUrl = _dio.options.baseUrl + path;
    print('🌐 API GET Request - Path: $path');
    print('🌐 Base URL: ${_dio.options.baseUrl}');
    print('🌐 Full URL: $fullUrl');

    try {
      print('🌐 API GET Request - Path: $path');
      print('🌐 Base URL: ${_dio.options.baseUrl}');
      print('🌐 Full URL: ${_dio.options.baseUrl}$path');

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      print('🌐 API Response Status: ${response.statusCode}');
      print('🌐 API Response Data Keys: ${response.data?.keys}');

      return ApiResponse<dynamic>(
        success: response.data['success'] ?? true,
        data: response.data['data'],
        error: response.data['error'] != null
            ? ApiError.fromJson(response.data['error'] as Map<String, dynamic>)
            : null,
      );
    } on DioException catch (e) {
      print('💥 API GET Error: ${e.type} - ${e.message}');
      if (e.response?.data != null) {
        print('💥 Error Response: ${e.response?.data}');
      }
      return _handleError(e);
    }
  }

  // POST Request
  Future<ApiResponse<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<dynamic>(
        success: response.data['success'] ?? true,
        data: response.data['data'],
        error: response.data['error'] != null
            ? ApiError.fromJson(response.data['error'] as Map<String, dynamic>)
            : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // PUT Request
  Future<ApiResponse<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<dynamic>(
        success: response.data['success'] ?? true,
        data: response.data['data'],
        error: response.data['error'] != null
            ? ApiError.fromJson(response.data['error'] as Map<String, dynamic>)
            : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // PATCH Request
  Future<ApiResponse<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<dynamic>(
        success: response.data['success'] ?? true,
        data: response.data['data'],
        error: response.data['error'] != null
            ? ApiError.fromJson(response.data['error'] as Map<String, dynamic>)
            : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // DELETE Request
  Future<ApiResponse<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<dynamic>(
        success: response.data['success'] ?? true,
        data: response.data['data'],
        error: response.data['error'] != null
            ? ApiError.fromJson(response.data['error'] as Map<String, dynamic>)
            : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Error Handler
  ApiResponse<dynamic> _handleError(DioException error) {
    String errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
    String errorCode = 'UNKNOWN_ERROR';

    print('💥 DioException Details:');
    print('   Type: ${error.type}');
    print('   Message: ${error.message}');
    print('   Status Code: ${error.response?.statusCode}');

    if (error.response != null) {
      // Server error
      final data = error.response!.data;
      print('   Response Data: $data');

      if (data is Map<String, dynamic>) {
        errorMessage = data['error']?['message'] ?? errorMessage;
        errorCode = data['error']?['code'] ?? errorCode;
      }
    } else {
      // Network error
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Bağlantı zaman aşımına uğradı';
        errorCode = 'TIMEOUT';
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = 'İnternet bağlantısı yok';
        errorCode = 'NO_CONNECTION';
      }
    }

    print('   Final Error: $errorCode - $errorMessage');

    return ApiResponse<dynamic>(
      success: false,
      data: null,
      error: ApiError(code: errorCode, message: errorMessage),
    );
  }
}
