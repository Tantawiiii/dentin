import 'chat_message_model.dart';

class SendMessageResponse {
  final String result;
  final String message;
  final ChatMessage data;
  final int status;

  SendMessageResponse({
    required this.result,
    required this.message,
    required this.data,
    required this.status,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      data: ChatMessage.fromJson(json['data'] as Map<String, dynamic>),
      status: json['status'] ?? 0,
    );
  }
}
