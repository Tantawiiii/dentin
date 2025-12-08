import 'package:dio/dio.dart';

import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class LoginRepository {
  final ApiService _apiService;

  LoginRepository(this._apiService);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return LoginResponse.fromJson(response.data!);
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ??
            errorData['error'] ??
            'Login failed. Please try again.';
        throw Exception(errorMessage);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}

