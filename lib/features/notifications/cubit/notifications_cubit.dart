import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/storage_service.dart';
import '../data/models/notification_model.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final FirebaseService _firebaseService;
  final StorageService _storageService;

  StreamSubscription<DatabaseEvent>? _notificationsSubscription;
  int? _currentUserId;

  List<NotificationModel> _notifications = [];

  NotificationsCubit(this._firebaseService, this._storageService)
    : super(NotificationsInitial());

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> loadNotifications() async {
    _currentUserId = _storageService.getUserData()?.id;
    if (_currentUserId == null) {
      emit(NotificationsError('User not authenticated'));
      return;
    }

    emit(NotificationsLoading());

    try {
      await _setupRealtimeListener();
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _setupRealtimeListener() async {
    if (_currentUserId == null) return;

    final notificationsRef = _firebaseService.getNotificationsRef(
      _currentUserId!,
    );

    // Use orderByChild and limitToLast like in React code
    final notificationsQuery = notificationsRef
        .orderByChild('timestamp')
        .limitToLast(10); // Get last 10 notifications

    _notificationsSubscription = notificationsQuery.onValue.listen((event) {
      if (!event.snapshot.exists) {
        _notifications = [];
        emit(
          NotificationsLoaded(notifications: _notifications, unreadCount: 0),
        );
        return;
      }

      _notifications = [];

      for (var child in event.snapshot.children) {
        final notificationId = child.key ?? '';
        final notificationData = Map<String, dynamic>.from(
          child.value as Map<Object?, Object?>,
        );

        try {
          final notification = NotificationModel.fromFirebase(
            notificationId,
            notificationData,
          );
          _notifications.add(notification);
        } catch (e) {
          print('Error parsing notification: $e');
        }
      }

      // Sort by timestamp (newest first) - already sorted by Firebase but ensure it
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final unreadCount = _notifications.where((n) => !n.read).length;

      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    });
  }

  Future<void> markAsRead(String notificationId) async {
    if (_currentUserId == null) return;

    final currentState = state;
    if (currentState is NotificationsLoaded) {
      emit(
        NotificationActionLoading(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    }

    try {
      final notificationRef = _firebaseService
          .getNotificationsRef(_currentUserId!)
          .child(notificationId);

      await notificationRef.update({'read': true});

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
      }

      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationsError('Failed to mark notification as read: $e'));
    }
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    final currentState = state;
    if (currentState is NotificationsLoaded) {
      emit(
        NotificationActionLoading(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    }

    try {
      final updates = <String, dynamic>{};
      for (final notification in _notifications) {
        if (!notification.read) {
          updates['notifications/$_currentUserId/${notification.id}/read'] =
              true;
        }
      }

      if (updates.isNotEmpty) {
        await _firebaseService.databaseRef.update(updates);

        // Update local state
        _notifications = _notifications
            .map((n) => n.copyWith(read: true))
            .toList();

        emit(
          NotificationsLoaded(notifications: _notifications, unreadCount: 0),
        );
      }
    } catch (e) {
      emit(NotificationsError('Failed to mark all as read: $e'));
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    if (_currentUserId == null) return;

    final currentState = state;
    if (currentState is NotificationsLoaded) {
      emit(
        NotificationActionLoading(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    }

    try {
      final notificationRef = _firebaseService
          .getNotificationsRef(_currentUserId!)
          .child(notificationId);

      await notificationRef.remove();

      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);

      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationsError('Failed to delete notification: $e'));
    }
  }

  Future<void> clearAllNotifications() async {
    if (_currentUserId == null) return;

    final currentState = state;
    if (currentState is NotificationsLoaded) {
      emit(
        NotificationActionLoading(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    }

    try {
      final notificationsRef = _firebaseService.getNotificationsRef(
        _currentUserId!,
      );
      await notificationsRef.remove();

      _notifications = [];

      emit(NotificationsLoaded(notifications: _notifications, unreadCount: 0));
    } catch (e) {
      emit(NotificationsError('Failed to clear all notifications: $e'));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
