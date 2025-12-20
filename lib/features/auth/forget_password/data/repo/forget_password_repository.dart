import 'package:dio/dio.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';
import '../models/verify_otp_request.dart';
import '../models/verify_otp_response.dart';
import '../models/reset_password_request.dart';
import '../models/reset_password_response.dart';

class ForgetPasswordRepository {
  final ApiService _apiService;

  static const String _defaultErrorMessage = 'An error occurred. Please try again.';

  ForgetPasswordRepository(this._apiService);

  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.sendOtp,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = _convertToMap(response.data);
        if (jsonData == null) {
          throw Exception('Invalid response format');
        }

        return SendOtpResponse.fromJson(jsonData);
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

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.verifyOtp,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = _convertToMap(response.data);
        if (jsonData == null) {
          throw Exception('Invalid response format');
        }

        final message = jsonData['message'] ?? '';
        if (message == 'Invalid OTP') {
          return VerifyOtpResponse(message: message, success: false);
        }

        return VerifyOtpResponse(message: message, success: true);
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

  Future<ResetPasswordResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.resetPassword,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = _convertToMap(response.data);
        if (jsonData == null) {
          throw Exception('Invalid response format');
        }

        return ResetPasswordResponse.fromJson(jsonData);
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
    return 'Network error: ${exception.message ?? "Unknown error"}';
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

