import 'chat_message_model.dart';

class MessagesResponse {
  final String result;
  final String message;
  final List<ChatMessage> data;
  final int status;

  MessagesResponse({
    required this.result,
    required this.message,
    required this.data,
    required this.status,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    List<ChatMessage> messages = [];

    if (json['data'] != null) {
      if (json['data'] is List) {
        // Handle array format
        messages = (json['data'] as List<dynamic>)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (json['data'] is Map) {
        final dataMap = json['data'] as Map<String, dynamic>;
        messages = dataMap.values
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return MessagesResponse(
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      data: messages,
      status: json['status'] ?? 0,
    );
  }
}
