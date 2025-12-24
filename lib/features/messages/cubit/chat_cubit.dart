import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repo/chat_repository.dart';
import '../data/models/send_message_request.dart';
import '../data/models/mark_as_read_request.dart';
import '../data/models/conversation_model.dart';
import '../data/models/chat_message_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository) : super(ChatInitial());

  List<Conversation> _conversations = [];
  List<ChatMessage> _messages = [];
  int? _currentReceiverId;
  int? _currentUserId;

  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  int? get currentReceiverId => _currentReceiverId;

  Future<void> loadConversations(int currentUserId) async {
    _currentUserId = currentUserId;
    emit(ConversationsLoading());

    try {
      final response = await _repository.getConversations(currentUserId);
      _conversations = response.data;
      emit(ConversationsLoaded(_conversations));
    } catch (e) {
      emit(ConversationsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMessages(int receiverId) async {
    if (_messages.isNotEmpty && _currentReceiverId == receiverId) {
      // Messages already loaded for this receiver
      return;
    }

    emit(MessagesLoading(_conversations));

    try {
      final response = await _repository.getMessages(receiverId);
      _messages = response.data;
      _currentReceiverId = receiverId;

      // Mark messages as read
      await _repository.markAsRead(MarkAsReadRequest(receiverId: receiverId));

      emit(
        MessagesLoaded(
          conversations: _conversations,
          messages: _messages,
          receiverId: receiverId,
        ),
      );
    } catch (e) {
      emit(
        MessagesError(
          conversations: _conversations,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> sendMessage(String body, int receiverId) async {
    if (body.trim().isEmpty) return;

    final currentState = state;
    if (currentState is MessagesLoaded ||
        currentState is MessageSent ||
        currentState is MessageSending ||
        currentState is MessageSendError) {
      emit(
        MessageSending(
          conversations: _conversations,
          messages: _messages,
          receiverId: receiverId,
        ),
      );
    }

    try {
      final request = SendMessageRequest(
        body: body.trim(),
        receiverId: receiverId,
      );
      final response = await _repository.sendMessage(request);

      // Add the new message to the list
      _messages.add(response.data);
      _currentReceiverId = receiverId;

      // Reload conversations to update last message if we have current user ID
      if (_currentUserId != null) {
        await loadConversations(_currentUserId!);
      }

      emit(
        MessageSent(
          conversations: _conversations,
          messages: _messages,
          receiverId: receiverId,
        ),
      );
    } catch (e) {
      emit(
        MessageSendError(
          conversations: _conversations,
          messages: _messages,
          receiverId: receiverId,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void clearMessages() {
    _messages = [];
    _currentReceiverId = null;
  }

  Future<void> refreshConversations(int currentUserId) async {
    await loadConversations(currentUserId);
  }
}
