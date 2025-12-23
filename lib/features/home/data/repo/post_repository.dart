import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/post_models.dart';
import '../../../../features/auth/register/data/models/media_upload_response.dart';

class PostRepository {
  final ApiService _apiService;

  PostRepository(this._apiService);

  Future<PostResponse> getPosts({int page = 1}) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.postIndexPublic,
        queryParameters: {'page': page},
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
      throw Exception('Failed to load posts: ${e.toString()}');
    }
  }

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

      if (response.statusCode != null && response.statusCode! < 400) {
        return MediaUploadResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to upload media: ${e.toString()}');
    }
  }

  Future<CreatePostResponse> createPost(CreatePostRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        '/api/post',
        data: request.toJson(),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return CreatePostResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
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

  Future<CreateCommentResponse> createComment(
    CreateCommentRequest request,
  ) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.createComment,
        data: request.toJson(),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return CreateCommentResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to create comment: ${e.toString()}');
    }
  }

  Future<void> likePost(int postId, LikePostRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.likePost(postId),
        data: request.toJson(),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return;
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to like post: ${e.toString()}');
    }
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
