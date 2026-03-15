import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';

import '../routing/app_routes.dart';
import '../../shared/widgets/app_toast.dart' show navigatorKey;
import 'storage_service.dart';
import 'firebase_service.dart';

/// Channel used for high-importance push notifications on Android.
const String _kChannelId = 'dentin_notifications';
const String _kChannelName = 'Dentin Notifications';
const String _kChannelDesc = 'Social interactions – likes, comments, replies';

class FCMService {
  Map<String, dynamic> get _serviceAccount => {
    "type": "service_account",
    "project_id": dotenv.env['FCM_PROJECT_ID'],
    "private_key_id": dotenv.env['FCM_PRIVATE_KEY_ID'],
    "private_key": dotenv.env['FCM_PRIVATE_KEY']?.replaceAll(r'\n', '\n'),
    "client_email": dotenv.env['FCM_CLIENT_EMAIL'],
    "client_id": dotenv.env['FCM_CLIENT_ID'],
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": dotenv.env['FCM_CLIENT_X509_CERT_URL'],
    "universe_domain": "googleapis.com"
  };

  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Dio _dio = Dio();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  AccessCredentials? _credentials;

  // ─── Token Management ──────────────────────────────────────────────────────

  Future<String?> _getAccessToken() async {
    try {
      // Check if existing token is still valid (expire in 5 mins buffer)
      if (_credentials != null &&
          _credentials!.accessToken.expiry.isAfter(
            DateTime.now().toUtc().add(const Duration(minutes: 5)),
          )) {
        return _credentials!.accessToken.data;
      }

      final accountCredentials = ServiceAccountCredentials.fromJson(_serviceAccount);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await clientViaServiceAccount(accountCredentials, scopes);
      _credentials = client.credentials;
      return _credentials!.accessToken.data;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting FCM Access Token: $e');
      return null;
    }
  }

  // ─── Initialisation ────────────────────────────────────────────────────────

  Future<void> initialize(StorageService storageService) async {
    try {
      await _initLocalNotifications();

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('📱 FCM Permission: ${settings.authorizationStatus}');
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _getAndSaveFCMToken(storageService);

        // Subscribe to global topics for promotions and announcements
        await subscribeToTopic('announcements');
        await subscribeToTopic('promotions');

        // Re-save token whenever Firebase rotates it
        _messaging.onTokenRefresh.listen((newToken) async {
          _fcmToken = newToken;
          await storageService.saveFCMToken(newToken);
          final userData = storageService.getUserData();
          if (userData != null) {
            await FirebaseService().saveUserFCMToken(userData.id, newToken);
          }
          if (kDebugMode) print('🔄 FCM Token refreshed');
        });

        // Show banner while app is in the foreground
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // App opened via a notification tap (background → foreground)
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // App was terminated; opened via notification tap
        final initial = await _messaging.getInitialMessage();
        if (initial != null) _handleNotificationTap(initial);
      }
    } catch (e) {
      if (kDebugMode) print('❌ FCM initialization error: $e');
    }
  }

  // ─── Save token for a specific user (called after login) ───────────────────

  Future<void> saveTokenForUser(int userId) async {
    try {
      final token = _fcmToken ?? await _messaging.getToken();
      if (token != null) {
        _fcmToken = token;
        await FirebaseService().saveUserFCMToken(userId, token);
        if (kDebugMode) print('✅ FCM token saved for user $userId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error saving FCM token for user: $e');
    }
  }

  // ─── Local Notifications setup ─────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // already handled by firebase_messaging
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create the Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _kChannelId,
        _kChannelName,
        description: _kChannelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print('🔔 Local notification tapped: ${response.payload}');
    }
    // Navigate to the notifications screen when user taps a local banner
    navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
  }

  // ─── Show a local notification banner (foreground) ─────────────────────────

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  // ─── Message handlers ───────────────────────────────────────────────────────

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📨 Foreground message: ${message.notification?.title}');
    }

    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    if (title.isNotEmpty || body.isNotEmpty) {
      await _showLocalNotification(
        title: title,
        body: body,
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('🔔 Notification tapped: ${message.data}');
    }

    final data = message.data;
    final type = data['type'] ?? '';
    final context = navigatorKey.currentContext;
    if (context == null) return;


    switch (type) {
      case 'post_like':
      case 'post_comment':
      case 'comment_like':
      case 'comment_reply':
      case 'reply_like':
        navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
        break;

      case 'friend_request':
      case 'friend_accept':
        navigatorKey.currentState?.pushNamed(AppRoutes.friendRequests);
        break;

      default:
       
        navigatorKey.currentState?.pushNamed(AppRoutes.home);
    }
  }

  // ─── FCM Token helpers ──────────────────────────────────────────────────────

  Future<void> _getAndSaveFCMToken(StorageService storageService) async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        await storageService.saveFCMToken(_fcmToken!);
        final userData = storageService.getUserData();
        if (userData != null) {
          await FirebaseService().saveUserFCMToken(userData.id, _fcmToken!);
        }
        if (kDebugMode) print('✅ FCM Token obtained');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error getting FCM token: $e');
    }
  }

  // ─── Topic subscriptions ────────────────────────────────────────────────────

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) print('✅ Subscribed to topic: $topic');
    } catch (e) {
      if (kDebugMode) print('❌ Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      if (kDebugMode) print('❌ Error unsubscribing from topic: $e');
    }
  }

  // ─── Push Notification Diagnostics ─────────────────────────────────────────

  /// Returns a map with all diagnostic info about the FCM setup on this device.
  /// Keys: platform, permission, has_token, token_preview, token_in_db, error
  Future<Map<String, String>> checkNotificationStatus(
    StorageService storageService,
  ) async {
    final result = <String, String>{};

    // Platform
    result['platform'] = Platform.isIOS ? 'iOS' : 'Android';

    // Permission
    try {
      final settings = await _messaging.getNotificationSettings();
      result['permission'] = settings.authorizationStatus.name;
    } catch (e) {
      result['permission'] = 'error: $e';
    }

    // Token
    try {
      final token = _fcmToken ?? await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        result['has_token'] = 'true';
        result['token_preview'] =
            '${token.substring(0, 20)}...${token.substring(token.length - 10)}';
      } else {
        result['has_token'] = 'false';
        result['token_preview'] = 'none';
      }
    } catch (e) {
      result['has_token'] = 'error';
      result['token_preview'] = 'error: $e';
    }

    // Token saved in Firebase DB?
    try {
      final userData = storageService.getUserData();
      if (userData != null) {
        final snap = await FirebaseService()
            .getUserFCMTokensRef(userData.id)
            .once();
        if (snap.snapshot.exists) {
          final data = snap.snapshot.value as Map<dynamic, dynamic>?;
          result['token_in_db'] = 'true (${data?.length ?? 0} device(s))';
        } else {
          result['token_in_db'] = 'false – token not saved yet';
        }
      } else {
        result['token_in_db'] = 'n/a – no logged-in user';
      }
    } catch (e) {
      result['token_in_db'] = 'error: $e';
    }

    if (kDebugMode) {
      print('═══════════════════ FCM Diagnostics ═══════════════════');
      result.forEach((k, v) => print('  $k: $v'));
      print('═══════════════════════════════════════════════════════');
    }

    return result;
  }

  Future<bool> sendSelfTestNotification(StorageService storageService) async {
    try {
      final userData = storageService.getUserData();
      if (userData == null) return false;

      final token = _fcmToken ?? await _messaging.getToken();
      if (token == null) return false;

      // Ensure token is saved before writing the test notification
      await FirebaseService().saveUserFCMToken(userData.id, token);

      final notifId =
          'test_${DateTime.now().millisecondsSinceEpoch}';

      // Use direct push since Cloud Functions aren't available on free plan
      await sendPushDirectly(
        receiverId: userData.id,
        title: '✅ Direct Push Works (V1)!',
        body: 'Notification sent directly from app at ${DateTime.now().toString().substring(11, 16)}',
        data: {
          'type': 'test',
          'id': notifId,
        },
      );

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Self-test failed: $e');
      return false;
    }
  }

  // ─── Direct Push Sender (V1 API) ───────────────────────────────────────────

  /// Sends a push notification directly to another user by:
  /// 1. Fetching their FCM tokens from the Database
  /// 2. Calling the modern FCM HTTP v1 API using OAuth2 credentials
  Future<void> sendPushDirectly({
    required int receiverId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // 1. Get OAuth2 Access Token
      final accessToken = await _getAccessToken();
      if (accessToken == null) return;

      // 2. Get receiver's tokens from Database
      final snap = await FirebaseService().getUserFCMTokensRef(receiverId).get();
      if (!snap.exists) {
        if (kDebugMode) print('⚠️ No tokens found for user $receiverId');
        return;
      }

      final tokensMap = snap.value as Map<dynamic, dynamic>;
      final List<String> tokens = tokensMap.values
          .map((v) => (v as Map)['token'] as String)
          .toList();

      if (kDebugMode) {
        print('📨 Attempting to send push to ${tokens.length} device(s) via V1 API');
      }

      // 3. Send to each token
      final projectId = _serviceAccount['project_id'];
      final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      for (final targetToken in tokens) {
        try {
          // Prepare V1 payload
          final payload = {
            'message': {
              'token': targetToken,
              'notification': {
                'title': title,
                'body': body,
              },
              'data': (data ?? {}).map((k, v) => MapEntry(k, v.toString())),
              'android': {
                'priority': 'high',
                'notification': {
                  'channel_id': _kChannelId,
                  'sound': 'default',
                },
              },
              'apns': {
                'payload': {
                  'aps': {
                    'sound': 'default',
                    'badge': 1,
                  },
                },
              },
            },
          };

          await _dio.post(
            url,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
            ),
            data: payload,
          );
        } catch (e) {
          if (kDebugMode) print('❌ Failed to send to token $targetToken: $e');
        }
      }
      if (kDebugMode) print('✅ Direct push sent via FCM V1 API');
    } catch (e) {
      if (kDebugMode) print('❌ Error sending direct push: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is guaranteed to be initialized before this function is called.
  if (kDebugMode) {
    print('📨 BGHandler: ${message.notification?.title ?? message.data['title']}');
  }

  if (message.notification != null) return;

  final title = message.data['title'] ?? '';
  final body = message.data['body'] ?? message.data['message'] ?? '';
  if (title.isEmpty && body.isEmpty) return;

  const channelId = 'dentin_notifications';
  const channelName = 'Dentin Notifications';
  const channelDesc = 'Social interactions – likes, comments, replies';

  final plugin = FlutterLocalNotificationsPlugin();

  const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
  const iosInit = DarwinInitializationSettings();
  const initSettings =
      InitializationSettings(android: androidInit, iOS: iosInit);
  await plugin.initialize(settings: initSettings);

  // Ensure the Android channel exists (idempotent call)
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

  await plugin.show(
    id: message.hashCode,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/launcher_icon',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: message.data.toString(),
  );
}
