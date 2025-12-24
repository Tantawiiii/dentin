import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/conversations_response.dart';
import '../models/messages_response.dart';
import '../models/send_message_request.dart';
import '../models/send_message_response.dart';
import '../models/mark_as_read_request.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository(this._apiService);

  Future<ConversationsResponse> getConversations(int receiverId) async {
    try {
      final response = await _apiService.dio.request<dynamic>(
        ApiConstants.conversations,
        data: {'receiver_id': receiverId},
        options: Options(method: 'GET'),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        final jsonData = response.data as Map<String, dynamic>;
        if (jsonData['result'] == 'Error') {
          throw Exception(
            jsonData['message'] ?? 'Failed to load conversations',
          );
        }
        return ConversationsResponse.fromJson(jsonData);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load conversations: ${e.toString()}');
    }
  }

  Future<MessagesResponse> getMessages(int receiverId) async {
    try {
      final response = await _apiService.dio.request<dynamic>(
        ApiConstants.chatMessages,
        data: {'receiver_id': receiverId},
        options: Options(method: 'GET'),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        final jsonData = response.data as Map<String, dynamic>;
        if (jsonData['result'] == 'Error') {
          throw Exception(jsonData['message'] ?? 'Failed to load messages');
        }
        return MessagesResponse.fromJson(jsonData);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to load messages: ${e.toString()}');
    }
  }

  Future<SendMessageResponse> sendMessage(SendMessageRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.sendMessage,
        data: request.toJson(),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        final jsonData = response.data as Map<String, dynamic>;
        if (jsonData['result'] == 'Error') {
          throw Exception(jsonData['message'] ?? 'Failed to send message');
        }
        return SendMessageResponse.fromJson(jsonData);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  Future<void> markAsRead(MarkAsReadRequest request) async {
    try {
      final response = await _apiService.post<dynamic>(
        ApiConstants.markAsRead,
        data: request.toJson(),
      );

      if (response.statusCode != null && response.statusCode! < 400) {
        final jsonData = response.data as Map<String, dynamic>;
        if (jsonData['result'] == 'Error') {
          throw Exception(
            jsonData['message'] ?? 'Failed to mark messages as read',
          );
        }
        return;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessageFromDioException(e));
    } catch (e) {
      throw Exception('Failed to mark as read: ${e.toString()}');
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
