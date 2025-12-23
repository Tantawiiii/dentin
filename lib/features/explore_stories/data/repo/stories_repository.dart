import 'package:dio/dio.dart';

import '../../../../core/network/api_service.dart';
import '../../../home/data/models/post_models.dart';

class StoriesRepository {
  final ApiService _apiService;

  StoriesRepository(this._apiService);

  Future<PostResponse> getStoriesWithVideo() async {
    try {
      final response = await _apiService.get<dynamic>(
        '/api/posts/with-video',
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return PostResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load stories: ${e.toString()}');
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

