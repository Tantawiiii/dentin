import 'chat_user_model.dart';

class ChatMessage {
  final int id;
  final String body;
  final String createdAt;
  final ChatUser sender;
  final ChatUser receiver;
  final bool? isRead;

  ChatMessage({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.sender,
    required this.receiver,
    this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      createdAt: json['created_at'] ?? '',
      sender: ChatUser.fromJson(json['sender'] as Map<String, dynamic>),
      receiver: ChatUser.fromJson(json['receiver'] as Map<String, dynamic>),
      isRead: json['is_read'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'created_at': createdAt,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'is_read': isRead,
    };
  }
}
