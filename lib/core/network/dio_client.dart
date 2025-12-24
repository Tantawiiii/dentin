import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_constants.dart';
import '../../shared/widgets/unauthenticated_dialog.dart';
import '../services/storage_service.dart';

class DioClient {
  DioClient({required StorageService storageService})
    : _storageService = storageService {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    _setupInterceptors();
  }

  late final Dio _dio;
  final StorageService _storageService;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          try {
            if (response.data != null) {
              final data = response.data;
              String? message;

              // Handle different response formats
              if (data is Map<String, dynamic>) {
                message = data['message']?.toString();
              } else if (data is String) {
                try {
                  final parsed = data;
                  if (parsed.contains('"message"') &&
                      parsed.contains('Unauthenticated')) {
                    message = 'Unauthenticated.';
                  }
                } catch (_) {
                  if (data.contains('Unauthenticated')) {
                    message = 'Unauthenticated.';
                  }
                }
              }

              if (message != null &&
                  message.toLowerCase().contains('unauthenticated')) {
                // Clear token and show dialog
                clearAuthToken();
                _storageService.removeToken();
                UnauthenticatedDialog.show();
              }
            }
          } catch (e) {
            // If error parsing response, continue normally
          }

          handler.next(response);
        },
        onError: (error, handler) {
          if (error.response != null) {
            try {
              final data = error.response?.data;
              String? message;

              if (data is Map<String, dynamic>) {
                message = data['message']?.toString();
              } else if (data is String) {
                if (data.contains('Unauthenticated')) {
                  message = 'Unauthenticated.';
                }
              }

              if (message != null &&
                  message.toLowerCase().contains('unauthenticated')) {
                // Clear token and show dialog
                clearAuthToken();
                _storageService.removeToken();
                UnauthenticatedDialog.show();
              }
            } catch (e) {
              // If error parsing response, continue normally
            }
          }

          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  Dio get dio => _dio;

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Update base URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
}
