import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/event_models.dart';

class EventRepository {
  final ApiService _apiService;

  EventRepository(this._apiService);

  Future<EventResponse> getEvents({int page = 1, int? perPage}) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.eventIndex,
        queryParameters: {
          'page': page,
          if (perPage != null) 'per_page': perPage,
        },
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return EventResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load events: ${e.toString()}');
    }
  }

  Future<EventDetailsResponse> getEventDetails(int eventId) async {
    try {
      final response = await _apiService.get<dynamic>(
        ApiConstants.eventDetails(eventId),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        return EventDetailsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load event details: ${e.toString()}');
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
