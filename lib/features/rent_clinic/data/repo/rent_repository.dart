import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/rent_models.dart';

class RentRepository {
  final ApiService _apiService;

  RentRepository(this._apiService);

  Future<RentListResponse> getRents({int page = 1}) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.rentIndex,
        data: {'page': page},
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = response.data as Map<String, dynamic>;
        if (jsonData['result'] == 'Error') {
          throw Exception(jsonData['message'] ?? 'Failed to load rents');
        }
        return RentListResponse.fromJson(jsonData);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load rents: ${e.toString()}');
    }
  }

  Future<RentDetailsResponse> getRentDetails(int id) async {
    try {
      final response = await _apiService.get<dynamic>(
        ApiConstants.rentDetails(id),
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = response.data as Map<String, dynamic>;
        if (jsonData['result'] == 'Error') {
          throw Exception(jsonData['message'] ?? 'Failed to load rent details');
        }
        return RentDetailsResponse.fromJson(jsonData);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load rent details: ${e.toString()}');
    }
  }

  Future<CreateRentResponse> createRent(CreateRentRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.rentCreate,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = response.data as Map<String, dynamic>;
        if (jsonData['result'] == 'Error') {
          throw Exception(jsonData['message'] ?? 'Failed to create rent');
        }
        return CreateRentResponse.fromJson(jsonData);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to create rent: ${e.toString()}');
    }
  }

  Future<void> contactSeller(ContactSellerRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.contactSeller,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = response.data as Map<String, dynamic>;
        if (jsonData['result'] == 'Error') {
          throw Exception(jsonData['message'] ?? 'Failed to send message');
        }
        return;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  String _extractErrorMessage(Response<dynamic> response) {
    if (response.data != null) {
      final errorData = response.data;
      if (errorData is Map<String, dynamic>) {
        return errorData['message'] ?? 'An error occurred';
      }
    }
    return response.statusMessage ?? 'An error occurred';
  }

  String _extractErrorMessageFromDioException(DioException exception) {
    final responseData = exception.response?.data;
    if (responseData != null && responseData is Map) {
      final errorData = responseData as Map<String, dynamic>;
      return errorData['message'] ?? 'Network error occurred';
    }
    return 'Network error: ${exception.message ?? "Unknown error"}';
  }
}
