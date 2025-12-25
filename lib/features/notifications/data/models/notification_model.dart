enum NotificationType {
  friendRequest,
  friendAccepted,
  newMessage,
  postLike,
  postComment,
  postShare,
  unknown,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final int senderId;
  final String senderName;
  final String? senderImage;
  final int timestamp;
  final bool read;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.timestamp,
    required this.read,
    this.data,
  });

  String get typeString {
    switch (type) {
      case NotificationType.friendRequest:
        return 'friend_request';
      case NotificationType.friendAccepted:
        return 'friend_accepted';
      case NotificationType.newMessage:
        return 'new_message';
      case NotificationType.postLike:
        return 'post_like';
      case NotificationType.postComment:
        return 'post_comment';
      case NotificationType.postShare:
        return 'post_share';
      default:
        return 'unknown';
    }
  }

  factory NotificationModel.fromFirebase(String id, Map<dynamic, dynamic> data) {
    // Parse notification type
    NotificationType parseType(String? typeString) {
      switch (typeString) {
        case 'friend_request':
          return NotificationType.friendRequest;
        case 'friend_accepted':
          return NotificationType.friendAccepted;
        case 'new_message':
          return NotificationType.newMessage;
        case 'post_like':
          return NotificationType.postLike;
        case 'post_comment':
          return NotificationType.postComment;
        case 'post_share':
          return NotificationType.postShare;
        default:
          return NotificationType.unknown;
      }
    }

    return NotificationModel(
      id: id,
      type: parseType(data['type']?.toString()),
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      senderId: data['sender_id'] is int
          ? data['sender_id']
          : int.tryParse(data['sender_id']?.toString() ?? '0') ?? 0,
      senderName: data['sender_name']?.toString() ?? '',
      senderImage: data['sender_image']?.toString(),
      timestamp: data['timestamp'] is int
          ? data['timestamp']
          : int.tryParse(data['timestamp']?.toString() ?? '0') ?? 0,
      read: data['read'] == true || data['read'] == 'true',
      data: data['data'] != null
          ? Map<String, dynamic>.from(data['data'] as Map)
          : null,
    );
  }

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    int? senderId,
    String? senderName,
    String? senderImage,
    int? timestamp,
    bool? read,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      data: data ?? this.data,
    );
  }
}

