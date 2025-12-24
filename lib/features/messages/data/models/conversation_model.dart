import 'chat_user_model.dart';
import 'chat_message_model.dart';

class Conversation {
  final ChatUser user;
  final ChatMessage? lastMessage;
  final int unreadCount;

  Conversation({
    required this.user,
    this.lastMessage,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      user: ChatUser.fromJson(json['user'] as Map<String, dynamic>),
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
    };
  }
}
