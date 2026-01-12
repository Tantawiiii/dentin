import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static DatabaseReference? _databaseRef;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Firebase should already be initialized by main.dart
      // Just get the database reference
      if (Firebase.apps.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Firebase not initialized yet. Please initialize Firebase in main.dart first.');
        }
        return;
      }

      _databaseRef = FirebaseDatabase.instance.ref();
      _initialized = true;

      if (kDebugMode) {
        print('✅ FirebaseService initialized successfully');
        print('📊 Database URL: ${FirebaseDatabase.instance.databaseURL}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FirebaseService initialization error: $e');
      }
      // Don't rethrow - let the app continue
      // Firebase features will fail gracefully when used
    }
  }

  DatabaseReference get databaseRef =>
      _databaseRef ?? FirebaseDatabase.instance.ref();

  // Generate room ID from two user IDs
  String generateRoomId(int userId1, int userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Get messages reference for a chat room
  DatabaseReference getMessagesRef(String roomId) {
    return databaseRef.child('chats/$roomId/messages');
  }

  // Get typing indicator reference
  DatabaseReference getTypingRef(String roomId, int userId) {
    return databaseRef.child('chats/$roomId/typing/$userId');
  }

  // Get notifications reference
  DatabaseReference getNotificationsRef(int userId) {
    return databaseRef.child('notifications/$userId');
  }

  // Get user FCM tokens reference (to store FCM tokens for push notifications)
  DatabaseReference getUserFCMTokensRef(int userId) {
    return databaseRef.child('users/$userId/fcm_tokens');
  }

  // Save FCM token for a user (to be used by Cloud Functions for push notifications)
  Future<void> saveUserFCMToken(int userId, String fcmToken) async {
    try {
      final tokenRef = getUserFCMTokensRef(userId).child(fcmToken);
      await tokenRef.set({
        'token': fcmToken,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'platform': 'flutter',
      });
      if (kDebugMode) {
        print('✅ FCM token saved for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving FCM token: $e');
      }
    }
  }

  // Send notification to Realtime Database
  // Note: This only saves to database, doesn't send push notification
  // For push notifications, use FCMService or send to backend API
  Future<void> sendNotification({
    required int receiverId,
    required String type,
    required String title,
    required String message,
    required int senderId,
    required String senderName,
    String? senderImage,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId =
          'notif_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
      final notificationRef = getNotificationsRef(
        receiverId,
      ).child(notificationId);

      await notificationRef.set({
        'id': notificationId,
        'type': type,
        'title': title,
        'message': message,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_image': senderImage ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'read': false,
        if (data != null) ...data,
      });

      // Note: To send push notification, you need to:
      // 1. Get receiver's FCM token from your backend
      // 2. Send push notification via FCM Admin SDK (backend) or
      // 3. Use Cloud Functions to trigger on database write
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Send typing indicator
  Future<void> sendTypingIndicator({
    required String roomId,
    required int userId,
    required bool isTyping,
  }) async {
    try {
      final typingRef = getTypingRef(roomId, userId);
      if (isTyping) {
        await typingRef.set(true);
      } else {
        await typingRef.remove();
      }
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  // Generate friendship ID from two user IDs
  String generateFriendshipId(int userId1, int userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Get friendships reference
  DatabaseReference getFriendshipsRef() {
    return databaseRef.child('friendships');
  }

  // Get specific friendship reference
  DatabaseReference getFriendshipRef(String friendshipId) {
    return databaseRef.child('friendships/$friendshipId');
  }

  // Send friend request
  Future<void> sendFriendRequest({
    required int userId1,
    required String userName1,
    String? userImage1,
    required int userId2,
    required String userName2,
    String? userImage2,
  }) async {
    try {
      final friendshipId = generateFriendshipId(userId1, userId2);
      final friendshipRef = getFriendshipRef(friendshipId);

      await friendshipRef.set({
        'user1_id': userId1,
        'user1_name': userName1,
        'user1_image': userImage1 ?? '',
        'user2_id': userId2,
        'user2_name': userName2,
        'user2_image': userImage2 ?? '',
        'status': 'pending',
        'requested_by': userId1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      final friendshipRef = getFriendshipRef(friendshipId);
      await friendshipRef.update({
        'status': 'friends',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'accepted_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error accepting friend request: $e');
      rethrow;
    }
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String friendshipId) async {
    try {
      final friendshipRef = getFriendshipRef(friendshipId);
      await friendshipRef.update({
        'status': 'rejected',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'rejected_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error rejecting friend request: $e');
      rethrow;
    }
  }

  // Cancel friend request
  Future<void> cancelFriendRequest(String friendshipId) async {
    try {
      final friendshipRef = getFriendshipRef(friendshipId);
      await friendshipRef.remove();
    } catch (e) {
      print('Error cancelling friend request: $e');
      rethrow;
    }
  }

  // Remove friend
  Future<void> removeFriend(String friendshipId) async {
    try {
      final friendshipRef = getFriendshipRef(friendshipId);
      await friendshipRef.remove();
    } catch (e) {
      print('Error removing friend: $e');
      rethrow;
    }
  }
}
