import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/storage_service.dart';
import '../data/repo/chat_repository.dart';
import '../data/models/send_message_request.dart';
import '../data/models/mark_as_read_request.dart';
import '../data/models/conversation_model.dart';
import '../data/models/chat_message_model.dart';
import '../data/models/chat_user_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final FirebaseService _firebaseService;
  final StorageService _storageService;

  ChatCubit(this._repository, this._firebaseService, this._storageService)
    : super(ChatInitial());

  List<Conversation> _conversations = [];
  List<ChatMessage> _messages = [];
  int? _currentReceiverId;
  int? _currentUserId;
  StreamSubscription<DatabaseEvent>? _messagesSubscription;
  StreamSubscription<DatabaseEvent>? _typingSubscription;
  bool _isTyping = false;

  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  int? get currentReceiverId => _currentReceiverId;
  bool get isTyping => _isTyping;

  Future<void> loadConversations(int currentUserId) async {
    _currentUserId = currentUserId;
    emit(ConversationsLoading());

    try {
      final response = await _repository.getConversations(currentUserId);
      final apiConversations = response.data;
      final firebaseConversations = await _loadFirebaseConversations(
        currentUserId,
      );
      _conversations = _mergeConversations(
        apiConversations,
        firebaseConversations,
      );
      emit(ConversationsLoaded(_conversations));
    } catch (e) {
      emit(ConversationsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMessages(int receiverId, {bool forceRefresh = false}) async {
    // Only skip if messages are already loaded and not forcing refresh
    if (!forceRefresh &&
        _currentReceiverId == receiverId &&
        _messages.isNotEmpty) {
      // Messages already loaded for this receiver
      return;
    }

    emit(MessagesLoading(_conversations));

    try {
      // Stop old listener if exists
      await _stopRealtimeListener();

      _currentReceiverId = receiverId;
      _currentUserId = _storageService.getUserData()?.id;

      if (_currentUserId != null) {
        // Setup Firebase realtime listener
        await _setupRealtimeListener(receiverId);

        // Mark messages as read
        await _repository.markAsRead(MarkAsReadRequest(receiverId: receiverId));
      } else {
        // Fallback to API if no user ID
        final response = await _repository.getMessages(receiverId);
        _messages = response.data;
        emit(
          MessagesLoaded(
            conversations: _conversations,
            messages: _messages,
            receiverId: receiverId,
          ),
        );
      }
    } catch (e) {
      emit(
        MessagesError(
          conversations: _conversations,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _setupRealtimeListener(int receiverId) async {
    if (_currentUserId == null) return;

    final roomId = _firebaseService.generateRoomId(_currentUserId!, receiverId);

    final messagesRef = _firebaseService.getMessagesRef(roomId);

    // Listen to messages
    _messagesSubscription = messagesRef.onValue.listen((event) {
      if (!event.snapshot.exists) {
        _messages = [];
        emit(
          MessagesLoaded(
            conversations: _conversations,
            messages: _messages,
            receiverId: receiverId,
          ),
        );
        return;
      }

      final firebaseMessages = <ChatMessage>[];
      final processedIds = <String>{};

      for (var child in event.snapshot.children) {
        if (child.value == null) continue;

        if (child.value is! Map) {
          continue;
        }

        final messageData = Map<String, dynamic>.from(
          child.value as Map<Object?, Object?>,
        );
        final messageId = messageData['id']?.toString() ?? child.key ?? '';

        if (messageId.isNotEmpty && !processedIds.contains(messageId)) {
          processedIds.add(messageId);

          final userData = _storageService.getUserData();
          if (userData != null) {
            final senderId = messageData['sender_id'] ?? 0;
            final receiverIdFromMsg = messageData['receiver_id'] ?? 0;

            final sender = ChatUser(
              id: senderId is int
                  ? senderId
                  : int.tryParse(senderId.toString()) ?? 0,
              userName: messageData['sender_name'] ?? 'User',
              profileImage: messageData['sender_image'],
              createdAt: '',
              updatedAt: '',
            );

            final receiver = ChatUser(
              id: receiverIdFromMsg is int
                  ? receiverIdFromMsg
                  : int.tryParse(receiverIdFromMsg.toString()) ?? 0,
              userName: '',
              profileImage: null,
              createdAt: '',
              updatedAt: '',
            );

            final message = ChatMessage(
              id: int.tryParse(messageId) ?? messageId.hashCode.abs(),
              body: messageData['body'] ?? '',
              createdAt:
                  messageData['created_at'] ?? DateTime.now().toIso8601String(),
              sender: sender,
              receiver: receiver,
              isRead:
                  messageData['is_read'] ??
                  messageData['isRead'] ??
                  messageData['read'] ??
                  false,
              type: messageData['type'] == 'image'
                  ? MessageType.image
                  : messageData['type'] == 'file'
                  ? MessageType.file
                  : messageData['type'] == 'product'
                  ? MessageType.product
                  : MessageType.text,
              fileUrl: messageData['file_url'],
              fileName: messageData['file_name'],
              fileSize: messageData['file_size'],
              productInfo: messageData['product_info'] != null
                  ? Map<String, dynamic>.from(
                      messageData['product_info'] is Map
                          ? (messageData['product_info'] as Map).map(
                              (key, value) => MapEntry(key.toString(), value),
                            )
                          : {},
                    )
                  : null,
              timestamp: messageData['timestamp'] is int
                  ? messageData['timestamp']
                  : int.tryParse(messageData['timestamp']?.toString() ?? ''),
            );

            firebaseMessages.add(message);
          }
        }
      }

      // Sort messages by timestamp
      firebaseMessages.sort((a, b) {
        final timeA =
            a.timestamp ?? DateTime.parse(a.createdAt).millisecondsSinceEpoch;
        final timeB =
            b.timestamp ?? DateTime.parse(b.createdAt).millisecondsSinceEpoch;
        return timeA.compareTo(timeB);
      });

      _messages = firebaseMessages;
      _markIncomingMessagesAsRead(
        roomId: roomId,
        receiverId: receiverId,
        snapshot: event.snapshot,
      );

      // Update conversations if needed (async without await in listener)
      if (_currentUserId != null && _conversations.isEmpty) {
        _repository
            .getConversations(_currentUserId!)
            .then((response) {
              _conversations = response.data;
            })
            .catchError((e) {
              // Ignore error, keep existing conversations
            });
      }

      emit(
        MessagesLoaded(
          conversations: _conversations,
          messages: _messages,
          receiverId: receiverId,
        ),
      );
    });

    // Listen to typing indicators
    final typingRef = _firebaseService.databaseRef.child(
      'chats/$roomId/typing',
    );
    _typingSubscription = typingRef.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        // Check if value is a Map
        if (event.snapshot.value is Map) {
          try {
            final typingData = Map<String, dynamic>.from(
              event.snapshot.value as Map<Object?, Object?>,
            );
            _isTyping = typingData[receiverId.toString()] == true;
          } catch (e) {
            _isTyping = false;
          }
        } else {
          _isTyping = false;
        }
      } else {
        _isTyping = false;
      }
    });
  }

  Future<void> _stopRealtimeListener() async {
    await _messagesSubscription?.cancel();
    await _typingSubscription?.cancel();
    _messagesSubscription = null;
    _typingSubscription = null;
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
      _currentUserId = _storageService.getUserData()?.id;
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final userData = _storageService.getUserData()!;
      // Send to Laravel API
      final request = SendMessageRequest(
        body: body.trim(),
        receiverId: receiverId,
      );
      final sendResponse = await _repository.sendMessage(request);

      final roomId = _firebaseService.generateRoomId(_currentUserId!, receiverId);
      final messagesRef = _firebaseService.getMessagesRef(roomId);
      final newMessageRef = messagesRef.push();
      final messageId =
          newMessageRef.key ??
          'msg_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';

      final messageData = {
        'id': messageId,
        'body': body.trim(),
        'sender_id': _currentUserId,
        'receiver_id': receiverId,
        'sender_name': userData.userName,
        'sender_image': userData.profileImage ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().toIso8601String(),
        'type': 'text',
        'is_read': false,
        'read': false,
      };

      var syncedToFirebase = false;
      try {
        await newMessageRef.set(messageData);
        syncedToFirebase = true;
      } catch (e) {
        // Keep chat usable even if Firebase write fails.
        print('Firebase message sync failed: $e');
      }

      try {
        await _firebaseService.sendNotification(
          receiverId: receiverId,
          type: 'new_message',
          title: 'New Message',
          message: 'New message from ${userData.userName}: ${body.trim()}',
          senderId: _currentUserId!,
          senderName: userData.userName,
          senderImage: userData.profileImage,
          data: {'message_id': messageId, 'room_id': roomId},
        );
      } catch (e) {
        print('Notification send failed: $e');
      }

      // Stop typing indicator
      await sendTypingIndicator(receiverId, false);

      // Fallback to API response when realtime sync is unavailable.
      if (!syncedToFirebase &&
          !_messages.any((message) => message.id == sendResponse.data.id)) {
        _messages = [..._messages, sendResponse.data];
        emit(
          MessageSent(
            conversations: _conversations,
            messages: _messages,
            receiverId: receiverId,
          ),
        );
      }

      // Reload conversations to update last message
      if (_currentUserId != null) {
        final response = await _repository.getConversations(_currentUserId!);
        final apiConversations = response.data;
        final firebaseConversations = await _loadFirebaseConversations(
          _currentUserId!,
        );
        _conversations = _mergeConversations(
          apiConversations,
          firebaseConversations,
        );
      }

      if (!syncedToFirebase) {
        emit(
          MessagesLoaded(
            conversations: _conversations,
            messages: _messages,
            receiverId: receiverId,
          ),
        );
      }
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

  Future<void> sendFile({
    required String filePath,
    required int receiverId,
    required String fileName,
    required int fileSize,
    required bool isImage,
  }) async {
    try {
      _currentUserId = _storageService.getUserData()?.id;
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final userData = _storageService.getUserData()!;

      // Upload file to backend
      final fileData = await _repository.uploadFile(
        filePath: filePath,
        receiverId: receiverId,
      );

      final roomId = _firebaseService.generateRoomId(
        _currentUserId!,
        receiverId,
      );
      final messagesRef = _firebaseService.getMessagesRef(roomId);
      final newMessageRef = messagesRef.push();
      final messageId =
          newMessageRef.key ??
          'file_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';

      final messageData = {
        'id': messageId,
        'body': fileData['file_name'] ?? fileName,
        'sender_id': _currentUserId,
        'receiver_id': receiverId,
        'sender_name': userData.userName,
        'sender_image': userData.profileImage ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().toIso8601String(),
        'type': isImage ? 'image' : 'file',
        'file_url': fileData['file_url'],
        'file_name': fileData['file_name'] ?? fileName,
        'file_size': fileData['file_size'] ?? fileSize,
        'is_read': false,
        'read': false,
      };

      // Send to Firebase
      await newMessageRef.set(messageData);

      // Send notification
      await _firebaseService.sendNotification(
        receiverId: receiverId,
        type: 'new_message',
        title: 'New Message',
        message: '${userData.userName} shared a ${isImage ? 'photo' : 'file'}',
        senderId: _currentUserId!,
        senderName: userData.userName,
        senderImage: userData.profileImage,
        data: {'message_id': messageId, 'room_id': roomId},
      );

      // Reload conversations (without changing current messages state)
      if (_currentUserId != null) {
        final response = await _repository.getConversations(_currentUserId!);
        _conversations = response.data;
      }

      // Don't emit state - let Firebase listener update the messages
      // The Firebase listener will automatically update _messages and emit MessagesLoaded
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

  Future<void> sendTypingIndicator(int receiverId, bool isTyping) async {
    if (_currentUserId == null) return;

    final roomId = _firebaseService.generateRoomId(_currentUserId!, receiverId);
    await _firebaseService.sendTypingIndicator(
      roomId: roomId,
      userId: _currentUserId!,
      isTyping: isTyping,
    );
  }

  void clearMessages() {
    _messages = [];
    _currentReceiverId = null;
    _stopRealtimeListener();
  }

  Future<void> refreshConversations(int currentUserId) async {
    await loadConversations(currentUserId);
  }

  Future<void> refreshMessages(int receiverId) async {
    await loadMessages(receiverId, forceRefresh: true);
  }

  @override
  Future<void> close() {
    _stopRealtimeListener();
    return super.close();
  }

  Future<List<Conversation>> _loadFirebaseConversations(int userId) async {
    final conversationMap = <int, Conversation>{};

    final friendshipsSnapshot = await _firebaseService.getFriendshipsRef().get();
    if (friendshipsSnapshot.exists) {
      for (final child in friendshipsSnapshot.children) {
        final key = child.key;
        final value = child.value;
        if (key == null || value is! Map) continue;

        final friendship = Map<String, dynamic>.from(
          value as Map<Object?, Object?>,
        );
        if (_asString(friendship['status']) != 'friends') continue;

        final ids = key.split('_').map((part) => int.tryParse(part)).toList();
        if (ids.length != 2 || !ids.contains(userId)) continue;

        final otherUserId = ids.first == userId ? ids[1] : ids[0];
        if (otherUserId == null) continue;

        final isOtherUser1 = _asInt(friendship['user1_id']) == otherUserId;
        final fallbackName = isOtherUser1
            ? _asString(friendship['user1_name'])
            : _asString(friendship['user2_name']);
        final fallbackImage = isOtherUser1
            ? _asNullableString(friendship['user1_image'])
            : _asNullableString(friendship['user2_image']);

        final user = await _fetchFirebaseUserDetails(
          otherUserId,
          fallbackName: fallbackName,
          fallbackImage: fallbackImage,
        );

        conversationMap[otherUserId] = Conversation(
          user: user,
          unreadCount: 0,
          lastMessage: null,
        );
      }
    }

    final chatsSnapshot = await _firebaseService.databaseRef.child('chats').get();
    if (chatsSnapshot.exists) {
      for (final chatChild in chatsSnapshot.children) {
        final roomId = chatChild.key;
        if (roomId == null) continue;

        final ids = roomId.split('_').map((part) => int.tryParse(part)).toList();
        if (ids.length != 2 || !ids.contains(userId)) continue;

        final otherUserId = ids.first == userId ? ids[1] : ids[0];
        if (otherUserId == null || conversationMap.containsKey(otherUserId)) {
          continue;
        }

        final user = await _fetchFirebaseUserDetails(otherUserId);
        conversationMap[otherUserId] = Conversation(
          user: user,
          unreadCount: 0,
          lastMessage: null,
        );
      }
    }

    return conversationMap.values.toList();
  }

  List<Conversation> _mergeConversations(
    List<Conversation> apiConversations,
    List<Conversation> firebaseConversations,
  ) {
    final merged = <int, Conversation>{};
    for (final conversation in apiConversations) {
      merged[conversation.user.id] = conversation;
    }
    for (final conversation in firebaseConversations) {
      merged.putIfAbsent(conversation.user.id, () => conversation);
    }
    return merged.values.toList();
  }

  Future<ChatUser> _fetchFirebaseUserDetails(
    int userId, {
    String? fallbackName,
    String? fallbackImage,
  }) async {
    try {
      final snapshot = await _firebaseService.databaseRef.child('users/$userId').get();
      if (snapshot.exists && snapshot.value is Map) {
        final userData = Map<String, dynamic>.from(
          snapshot.value as Map<Object?, Object?>,
        );

        final userName = _asString(userData['user_name']).isNotEmpty
            ? _asString(userData['user_name'])
            : (_asString(userData['name']).isNotEmpty
                  ? _asString(userData['name'])
                  : (fallbackName ?? 'User $userId'));

        return ChatUser(
          id: userId,
          userName: userName,
          profileImage:
              _asNullableString(userData['profile_image']) ??
              _asNullableString(userData['avatar']) ??
              fallbackImage,
          createdAt: _asString(userData['created_at']),
          updatedAt: _asString(userData['updated_at']),
        );
      }
    } catch (_) {}

    return ChatUser(
      id: userId,
      userName:
          (fallbackName != null && fallbackName.isNotEmpty)
          ? fallbackName
          : 'User $userId',
      profileImage: fallbackImage,
      createdAt: '',
      updatedAt: '',
    );
  }

  void _markIncomingMessagesAsRead({
    required String roomId,
    required int receiverId,
    required DataSnapshot snapshot,
  }) {
    if (_currentUserId == null || !snapshot.exists) return;

    final updates = <String, Object?>{};
    for (final child in snapshot.children) {
      if (child.key == null || child.value is! Map) continue;

      final messageData = Map<String, dynamic>.from(
        child.value as Map<Object?, Object?>,
      );
      final senderId = _asInt(messageData['sender_id']);
      final alreadyRead =
          _asBool(messageData['is_read']) || _asBool(messageData['read']);

      if (senderId == receiverId && !alreadyRead) {
        updates['chats/$roomId/messages/${child.key}/is_read'] = true;
        updates['chats/$roomId/messages/${child.key}/read'] = true;
      }
    }

    if (updates.isNotEmpty) {
      _firebaseService.databaseRef.update(updates);
    }
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  String _asString(dynamic value) => value?.toString() ?? '';

  String? _asNullableString(dynamic value) {
    final str = value?.toString();
    if (str == null || str.isEmpty) return null;
    return str;
  }
}
