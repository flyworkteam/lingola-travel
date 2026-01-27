import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Core/Config/app_config.dart';

/// API Client using Dio
/// Handles all HTTP requests with interceptors for auth, logging, and error handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${AppConfig.baseUrl}/${AppConfig.apiVersion}',
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

          // Log request
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response
          print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
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
  Future<ApiResponse<T>> get<T>(
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
      return ApiResponse<T>.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST Request
  Future<ApiResponse<T>> post<T>(
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
      return ApiResponse<T>.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT Request
  Future<ApiResponse<T>> put<T>(
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
      return ApiResponse<T>.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE Request
  Future<ApiResponse<T>> delete<T>(
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
      return ApiResponse<T>.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // Error Handler
  ApiResponse<T> _handleError<T>(DioException error) {
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

    return ApiResponse<T>(
      success: false,
      data: null,
      error: ApiError(code: errorCode, message: errorMessage),
    );
  }
}

/// Standard API Response Model
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;

  ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] as T?,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data, 'error': error?.toJson()};
  }
}

/// API Error Model
class ApiError {
  final String code;
  final String message;

  ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN',
      message: json['message'] ?? 'An error occurred',
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message};
  }
}
