import 'conversation_model.dart';

class ConversationsResponse {
  final String result;
  final String message;
  final List<Conversation> data;
  final int status;

  ConversationsResponse({
    required this.result,
    required this.message,
    required this.data,
    required this.status,
  });

  factory ConversationsResponse.fromJson(Map<String, dynamic> json) {
    List<Conversation> conversations = [];

    if (json['data'] != null) {
      if (json['data'] is List) {
        // Handle array format
        conversations = (json['data'] as List<dynamic>)
            .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (json['data'] is Map) {
        // Handle object format with numeric keys (e.g., {"0": {...}, "2": {...}})
        final dataMap = json['data'] as Map<String, dynamic>;
        conversations = dataMap.values
            .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return ConversationsResponse(
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      data: conversations,
      status: json['status'] ?? 0,
    );
  }
}
