import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'firebase_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize(StorageService storageService) async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('📱 FCM Permission status: ${settings.authorizationStatus}');
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _getFCMToken(storageService);

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) async {
          _fcmToken = newToken;
          await _saveFCMToken(newToken, storageService);
          
          // Update FCM token in Firebase Realtime Database
          final userData = storageService.getUserData();
          if (userData != null) {
            final firebaseService = FirebaseService();
            await firebaseService.saveUserFCMToken(userData.id, newToken);
          }
          
          if (kDebugMode) {
            print('🔄 FCM Token refreshed: $newToken');
          }
        });

        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleBackgroundMessage(initialMessage);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FCM initialization error: $e');
      }
    }
  }

  Future<void> _getFCMToken(StorageService storageService) async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        await _saveFCMToken(_fcmToken!, storageService);
        
        // Save FCM token to Firebase Realtime Database for Cloud Functions
        final userData = storageService.getUserData();
        if (userData != null) {
          final firebaseService = FirebaseService();
          await firebaseService.saveUserFCMToken(userData.id, _fcmToken!);
        }
        
        if (kDebugMode) {
          print('✅ FCM Token: $_fcmToken');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting FCM token: $e');
      }
    }
  }

  Future<void> _saveFCMToken(
    String token,
    StorageService storageService,
  ) async {
    try {
      await storageService.saveFCMToken(token);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving FCM token: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📨 Foreground message received:');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');
    }

    // Show local notification or update UI
    // You can use flutter_local_notifications package here
  }

  /// Handle background messages (when app is in background/terminated)
  void _handleBackgroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📨 Background message received:');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subscribing to topic: $e');
      }
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unsubscribing from topic: $e');
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📨 Background message handler: ${message.messageId}');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');
  }
}
