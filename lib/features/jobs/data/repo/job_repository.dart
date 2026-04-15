import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../auth/register/data/models/media_upload_response.dart';
import '../models/job_models.dart';

class JobRepository {
  final ApiService _apiService;

  JobRepository(this._apiService);

  Future<JobResponse> getJobs({
    int page = 1,
    String? search,
    String? location,
    String? type,
    String? specialization,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (type != null && type.isNotEmpty && type != 'All Jobs') {
        queryParams['type'] = type;
      }

      final filters = <String, dynamic>{
        'active': 1,
      };
      if (specialization != null && specialization.isNotEmpty && specialization != 'All') {
        filters['specialization'] = specialization;
      }

      final response = await _apiService.post<dynamic>(
        ApiConstants.jobIndex,
        queryParameters: queryParams,
        data: {'filters': filters},
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return JobResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load jobs: ${e.toString()}');
    }
  }

  Future<JobResponse> getOwnerJobs({
    int page = 1,
    String? search,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      final filters = <String, dynamic>{};

      if (search != null && search.trim().isNotEmpty) {
        filters['search'] = search.trim();
      }
      if (type != null && type.trim().isNotEmpty && type != 'All Jobs') {
        filters['type'] = type.trim();
      }

      final response = await _apiService.post<dynamic>(
        ApiConstants.jobOwnerIndex,
        queryParameters: queryParams,
        data: {'filters': filters},
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return JobResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load applied dentists jobs: ${e.toString()}');
    }
  }

  Future<JobApplicantsResponse> getJobApplicants(int jobId) async {
    try {
      final response = await _apiService.get<dynamic>(
        ApiConstants.jobApplicants(jobId),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return JobApplicantsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load job applicants: ${e.toString()}');
    }
  }

  Future<JobDetailsResponse> getJobDetails(int id) async {
    try {
      final response = await _apiService.get<dynamic>(
        ApiConstants.jobDetails(id),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return JobDetailsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load job details: ${e.toString()}');
    }
  }

  Future<ApplyJobResponse> applyToJob({
    required int jobId,
    required String coverLetter,
  }) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.applyJob(jobId),
        data: {'cover_letter': coverLetter},
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return ApplyJobResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to apply for job: ${e.toString()}');
    }
  }

  String _extractErrorMessage(Response<dynamic> response) {
    if (response.data != null) {
      final errorData = response.data;
      if (errorData is Map<String, dynamic>) {
        return errorData['message']?.toString() ?? 'An error occurred';
      }
    }
    return response.statusMessage ?? 'An error occurred';
  }

  Future<MediaUploadResponse> uploadMedia(File file) async {
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

  Future<CreateJobResponse> createJob(CreateJobRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.jobCreate,
        data: request.toJson(),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return CreateJobResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to create job: ${e.toString()}');
    }
  }

  String _extractErrorMessageFromDioException(DioException exception) {
    final responseData = exception.response?.data;
    if (responseData != null && responseData is Map) {
      final errorData = responseData as Map<String, dynamic>;
      return errorData['message']?.toString() ?? 'Network error occurred';
    }
    return 'Network error: ${exception.message ?? "Unknown error"}';
  }
}
