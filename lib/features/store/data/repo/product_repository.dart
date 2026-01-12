import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/product_models.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  Future<ProductResponse> getProducts({
    int page = 1,
    String? search,
    String? type,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'filters': <String, dynamic>{'active': 1},
      };

      if (type != null && type.isNotEmpty && type != 'all') {
        (requestBody['filters'] as Map<String, dynamic>)['type'] = type;
      }

      final queryParams = <String, dynamic>{'page': page};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.post<dynamic>(
        ApiConstants.productIndex,
        data: requestBody,
        queryParameters: queryParams,
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return ProductResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load products: ${e.toString()}');
    }
  }

  Future<CreateProductResponse> createProduct(
    CreateProductRequest request,
  ) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.productCreate,
        data: request.toJson(),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return CreateProductResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  Future<ProductDetailsResponse> getProductDetails(int id) async {
    try {
      final response = await _apiService.get<dynamic>(
        ApiConstants.productDetails(id),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return ProductDetailsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load product details: ${e.toString()}');
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
