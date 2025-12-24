import '../data/models/conversation_model.dart';
import '../data/models/chat_message_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

// Conversations states
class ConversationsLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;

  ConversationsLoaded(this.conversations);
}

class ConversationsError extends ChatState {
  final String message;

  ConversationsError(this.message);
}

// Messages states
class MessagesLoading extends ChatState {
  final List<Conversation> conversations;

  MessagesLoading(this.conversations);
}

class MessagesLoaded extends ChatState {
  final List<Conversation> conversations;
  final List<ChatMessage> messages;
  final int receiverId;

  MessagesLoaded({
    required this.conversations,
    required this.messages,
    required this.receiverId,
  });
}

class MessagesError extends ChatState {
  final List<Conversation> conversations;
  final String message;

  MessagesError({required this.conversations, required this.message});
}

// Send message states
class MessageSending extends ChatState {
  final List<Conversation> conversations;
  final List<ChatMessage> messages;
  final int receiverId;

  MessageSending({
    required this.conversations,
    required this.messages,
    required this.receiverId,
  });
}

class MessageSent extends ChatState {
  final List<Conversation> conversations;
  final List<ChatMessage> messages;
  final int receiverId;

  MessageSent({
    required this.conversations,
    required this.messages,
    required this.receiverId,
  });
}

class MessageSendError extends ChatState {
  final List<Conversation> conversations;
  final List<ChatMessage> messages;
  final int receiverId;
  final String message;

  MessageSendError({
    required this.conversations,
    required this.messages,
    required this.receiverId,
    required this.message,
  });
}
