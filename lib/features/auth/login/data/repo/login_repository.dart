import 'package:dio/dio.dart';

import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class LoginRepository {
  final ApiService _apiService;

  static const String _defaultErrorMessage = 'Login failed. Please try again.';
  static const String _invalidResponseFormat = 'Invalid response format';
  static const String _networkErrorPrefix = 'Network error: ';

  LoginRepository(this._apiService);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = _convertToMap(response.data);
        if (jsonData == null) {
          throw Exception(_invalidResponseFormat);
        }

        final status = jsonData['status'];
        if (status == false || status == null) {
          final errorMessage = jsonData['message'] ?? _defaultErrorMessage;
          throw Exception(errorMessage);
        }

        return LoginResponse.fromJson(jsonData);
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

  String _extractErrorMessageFromDioException(DioException exception) {
    final responseData = exception.response?.data;
    if (responseData != null && responseData is Map) {
      final errorData = _convertToMap(responseData);
      if (errorData != null) {
        return errorData['message'] ??
            errorData['error'] ??
            _defaultErrorMessage;
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
