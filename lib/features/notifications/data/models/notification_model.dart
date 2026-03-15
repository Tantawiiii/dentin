enum NotificationType {
  friendRequest,
  friendAccepted,
  newMessage,
  postLike,
  postComment,
  postShare,
  commentLike,
  commentReply,
  replyLike,
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

  // Optional contextual fields for deep linking
  final int? postId;
  final String? commentId;
  final String? replyId;

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
    this.postId,
    this.commentId,
    this.replyId,
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
      case NotificationType.commentLike:
        return 'comment_like';
      case NotificationType.commentReply:
        return 'comment_reply';
      case NotificationType.replyLike:
        return 'reply_like';
      default:
        return 'unknown';
    }
  }

  /// Human-readable icon name for each notification type
  String get iconName {
    switch (type) {
      case NotificationType.postLike:
        return 'favorite';
      case NotificationType.commentLike:
      case NotificationType.replyLike:
        return 'favorite';
      case NotificationType.postComment:
      case NotificationType.commentReply:
        return 'comment';
      case NotificationType.friendRequest:
        return 'person_add';
      case NotificationType.friendAccepted:
        return 'people';
      case NotificationType.newMessage:
        return 'message';
      default:
        return 'notifications';
    }
  }

  static NotificationType parseType(String? typeString) {
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
      case 'comment_like':
        return NotificationType.commentLike;
      case 'comment_reply':
        return NotificationType.commentReply;
      case 'reply_like':
        return NotificationType.replyLike;
      default:
        return NotificationType.unknown;
    }
  }

  factory NotificationModel.fromFirebase(
    String id,
    Map<dynamic, dynamic> data,
  ) {
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
      postId: data['post_id'] is int
          ? data['post_id']
          : int.tryParse(data['post_id']?.toString() ?? ''),
      commentId: data['comment_id']?.toString(),
      replyId: data['reply_id']?.toString(),
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
    int? postId,
    String? commentId,
    String? replyId,
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
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      replyId: replyId ?? this.replyId,
    );
  }
}
