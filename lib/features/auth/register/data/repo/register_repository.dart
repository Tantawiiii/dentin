import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/media_upload_response.dart';

class RegisterRepository {
  final ApiService _apiService;

  static const String _defaultErrorMessage =
      'Registration failed. Please try again.';
  static const String _invalidResponseFormat = 'Invalid response format';
  static const String _networkErrorPrefix = 'Network error: ';

  RegisterRepository(this._apiService);

  Future<MediaUploadResponse> uploadMedia(
    File file, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });

      final response = await _apiService.post<dynamic>(
        ApiConstants.media,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (_isSuccessResponse(response)) {
        return _handleMediaSuccessResponse(response);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.register,
        data: request.toJson(),
      );

      if (_isSuccessResponse(response)) {
        return _handleRegisterSuccessResponse(response);
      } else {
        throw Exception(_extractRegisterErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  bool _isSuccessResponse(Response<dynamic> response) {
    return response.statusCode != null &&
        response.statusCode! < 400 &&
        response.data != null;
  }

  MediaUploadResponse _handleMediaSuccessResponse(Response<dynamic> response) {
    final jsonData = _convertToMap(response.data);
    if (jsonData == null) {
      throw Exception(_invalidResponseFormat);
    }
    return MediaUploadResponse.fromJson(jsonData);
  }

  RegisterResponse _handleRegisterSuccessResponse(Response<dynamic> response) {
    final jsonData = _convertToMap(response.data);
    if (jsonData == null) {
      throw Exception(_invalidResponseFormat);
    }
    return RegisterResponse.fromJson(jsonData);
  }

  String _extractErrorMessage(Response<dynamic> response) {
    if (response.data != null) {
      final errorData = _convertToMap(response.data);
      if (errorData != null) {
        return errorData['message'] ??
            errorData['error'] ??
            response.statusMessage ??
            _defaultErrorMessage;
      }
    }
    return response.statusMessage ?? _defaultErrorMessage;
  }

  String _extractRegisterErrorMessage(Response<dynamic> response) {
    if (response.data != null) {
      final errorData = _convertToMap(response.data);
      if (errorData != null) {
        // Try to parse as RegisterErrorResponse
        try {
          final errorResponse = RegisterErrorResponse.fromJson(errorData);
          return errorResponse.getFormattedErrors();
        } catch (e) {
          return errorData['message'] ??
              errorData['error'] ??
              response.statusMessage ??
              _defaultErrorMessage;
        }
      }
    }
    return response.statusMessage ?? _defaultErrorMessage;
  }

  String _extractErrorMessageFromDioException(DioException exception) {
    final responseData = exception.response?.data;
    if (responseData != null && responseData is Map) {
      final errorData = _convertToMap(responseData);
      if (errorData != null) {
        // Try to parse as RegisterErrorResponse
        try {
          final errorResponse = RegisterErrorResponse.fromJson(errorData);
          return errorResponse.getFormattedErrors();
        } catch (e) {
          return errorData['message'] ??
              errorData['error'] ??
              _defaultErrorMessage;
        }
      }
    }
    return '$_networkErrorPrefix${exception.message ?? "Unknown error"}';
  }

  Map<String, dynamic>? _convertToMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
