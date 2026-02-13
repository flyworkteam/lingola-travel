import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Core/Config/app_config.dart';
import '../Models/api_response.dart';

/// API Client using Dio
/// Handles all HTTP requests with interceptors for auth, logging, and error handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  ApiClient._internal() {
    final baseUrl = '${AppConfig.baseUrl}/${AppConfig.apiVersion}';

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
          final token = await _secureStorage.read(
            key: AppConfig.keyAccessToken,
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - refresh token
          if (error.response?.statusCode == 401) {
            // TODO: Implement token refresh logic
            print('TOKEN EXPIRED - Need to refresh');
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

  // GET Request
  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
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
    String errorMessage = 'An error occurred';
    String errorCode = 'UNKNOWN_ERROR';

    if (error.response != null) {
      // Server error
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        errorMessage = data['error']?['message'] ?? errorMessage;
        errorCode = data['error']?['code'] ?? errorCode;
      }
    } else {
      // Network error
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout';
        errorCode = 'TIMEOUT';
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
        errorCode = 'NO_CONNECTION';
      }
    }

    return ApiResponse<dynamic>(
      success: false,
      data: null,
      error: ApiError(code: errorCode, message: errorMessage),
    );
  }
}
