import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../features/auth/login/data/models/login_response.dart';

class FirebaseComment {
  final String id;
  final int postId;
  final UserData user;
  final String content;
  final String? reaction;
  final String createdAt;
  final int likesCount;
  final int repliesCount;
  final bool userHasLiked;
  final String? firebaseKey;

  FirebaseComment({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    this.reaction,
    required this.createdAt,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.userHasLiked = false,
    this.firebaseKey,
  });
}

class FirebaseReply {
  final String id;
  final String commentId;
  final UserData user;
  final String content;
  final String createdAt;
  final int likesCount;
  final bool userHasLiked;
  final String? firebaseKey;

  FirebaseReply({
    required this.id,
    required this.commentId,
    required this.user,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.userHasLiked = false,
    this.firebaseKey,
  });
}

class FirebaseCommentsService {
  final FirebaseService _firebaseService;

  FirebaseCommentsService({required FirebaseService firebaseService})
    : _firebaseService = firebaseService;

  // Get comments reference for a post
  DatabaseReference _getCommentsRef(int postId) {
    return _firebaseService.databaseRef.child('posts/$postId/comments');
  }

  // Get comment likes reference
  DatabaseReference _getCommentLikesRef(int postId, String commentId) {
    return _firebaseService.databaseRef.child(
      'posts/$postId/comments/$commentId/likes',
    );
  }

  // Get comment replies reference
  DatabaseReference _getCommentRepliesRef(int postId, String commentId) {
    return _firebaseService.databaseRef.child(
      'posts/$postId/comments/$commentId/replies',
    );
  }

  // Get reply likes reference
  DatabaseReference _getReplyLikesRef(
    int postId,
    String commentId,
    String replyId,
  ) {
    return _firebaseService.databaseRef.child(
      'posts/$postId/comments/$commentId/replies/$replyId/likes',
    );
  }

  // Add comment
  Future<String> addComment({
    required int postId,
    required String content,
    required UserData user,
    String?
    commentId, // Optional: use this ID if provided (for backend comments)
  }) async {
    try {
      final commentsRef = _getCommentsRef(postId);
      final newCommentKey = commentId ?? commentsRef.push().key;

      if (newCommentKey == null) {
        throw Exception('Failed to generate comment key');
      }

      final commentData = {
        'id': newCommentKey,
        'post_id': postId,
        'user': {
          'id': user.id,
          'user_name': user.userName,
          'profile_image': user.profileImage ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        'content': content,
        'reaction': null,
        'created_at': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await commentsRef.child(newCommentKey).set(commentData);
      return newCommentKey;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding comment: $e');
      }
      rethrow;
    }
  }

  // Like/Unlike comment
  Future<void> toggleCommentLike({
    required int postId,
    required String commentId,
    required int userId,
    required UserData user,
  }) async {
    try {
      final likesRef = _getCommentLikesRef(postId, commentId);
      final query = likesRef.orderByChild('user_id').equalTo(userId);
      final snapshot = await query.get();

      if (snapshot.exists) {
        // Unlike - remove the like
        final likesData = snapshot.value as Map<dynamic, dynamic>;
        final likeKey = likesData.keys.first;
        await likesRef.child(likeKey.toString()).remove();
      } else {
        // Like - add new like
        final newLikeKey = likesRef.push().key;
        if (newLikeKey != null) {
          await likesRef.child(newLikeKey).set({
            'user_id': userId,
            'user_name': user.userName,
            'user_avatar': user.profileImage ?? '',
            'created_at': DateTime.now().toIso8601String(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling comment like: $e');
      }
      rethrow;
    }
  }

  // Add reply to comment
  Future<String> addReply({
    required int postId,
    required String commentId,
    required String content,
    required UserData user,
  }) async {
    try {
      final repliesRef = _getCommentRepliesRef(postId, commentId);
      final newReplyKey = repliesRef.push().key;

      if (newReplyKey == null) {
        throw Exception('Failed to generate reply key');
      }

      final replyData = {
        'id': newReplyKey,
        'comment_id': commentId,
        'user': {
          'id': user.id,
          'user_name': user.userName,
          'profile_image': user.profileImage ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await repliesRef.child(newReplyKey).set(replyData);
      return newReplyKey;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding reply: $e');
      }
      rethrow;
    }
  }

  // Like/Unlike reply
  Future<void> toggleReplyLike({
    required int postId,
    required String commentId,
    required String replyId,
    required int userId,
    required UserData user,
  }) async {
    try {
      final likesRef = _getReplyLikesRef(postId, commentId, replyId);
      final query = likesRef.orderByChild('user_id').equalTo(userId);
      final snapshot = await query.get();

      if (snapshot.exists) {
        // Unlike - remove the like
        final likesData = snapshot.value as Map<dynamic, dynamic>;
        final likeKey = likesData.keys.first;
        await likesRef.child(likeKey.toString()).remove();
      } else {
        // Like - add new like
        final newLikeKey = likesRef.push().key;
        if (newLikeKey != null) {
          await likesRef.child(newLikeKey).set({
            'user_id': userId,
            'user_name': user.userName,
            'user_avatar': user.profileImage ?? '',
            'created_at': DateTime.now().toIso8601String(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling reply like: $e');
      }
      rethrow;
    }
  }

  Stream<List<FirebaseComment>> listenToComments({
    required int postId,
    required int currentUserId,
  }) {
    final commentsRef = _getCommentsRef(postId);
    final controller = StreamController<List<FirebaseComment>>();
    final Map<String, FirebaseComment> commentsMap = {};
    final Map<String, StreamSubscription> likesSubscriptions = {};
    final Map<String, StreamSubscription> repliesSubscriptions = {};
    bool isDisposed = false;

    // Helper function to emit updated comments
    Future<void> emitComments() async {
      if (isDisposed || controller.isClosed) return;

      // Reload stats for all comments
      for (final key in commentsMap.keys.toList()) {
        await _updateCommentStats(key, postId, currentUserId, commentsMap);
      }

      if (!controller.isClosed && !isDisposed) {
        final sortedComments = _sortComments(commentsMap.values.toList());
        controller.add(sortedComments);
      }
    }

    // Listen to comments changes
    final commentsSubscription = commentsRef.onValue.listen((event) async {
      if (isDisposed || controller.isClosed) return;

      if (!event.snapshot.exists) {
        commentsMap.clear();
        if (!controller.isClosed) {
          controller.add([]);
        }
        return;
      }

      final commentsData = event.snapshot.value as Map<dynamic, dynamic>?;
      if (commentsData == null) {
        commentsMap.clear();
        if (!controller.isClosed) {
          controller.add([]);
        }
        return;
      }

      // Cancel old subscriptions
      for (final sub in likesSubscriptions.values) {
        sub.cancel();
      }
      for (final sub in repliesSubscriptions.values) {
        sub.cancel();
      }
      likesSubscriptions.clear();
      repliesSubscriptions.clear();

      // Load all comments with stats
      await _loadCommentsWithStats(
        commentsData,
        postId,
        currentUserId,
        commentsMap,
      );

      // Set up real-time listeners for likes and replies
      for (final key in commentsMap.keys) {
        // Listen to likes changes
        final likesRef = _getCommentLikesRef(postId, key);
        likesSubscriptions[key] = likesRef.onValue.listen((likesEvent) {
          if (isDisposed || controller.isClosed) return;
          emitComments();
        });

        // Listen to replies changes
        final repliesRef = _getCommentRepliesRef(postId, key);
        repliesSubscriptions[key] = repliesRef.onValue.listen((repliesEvent) {
          if (isDisposed || controller.isClosed) return;
          emitComments();
        });
      }

      await emitComments();
    });

    // Cleanup on stream close
    controller.onCancel = () {
      isDisposed = true;
      commentsSubscription.cancel();
      for (final sub in likesSubscriptions.values) {
        sub.cancel();
      }
      for (final sub in repliesSubscriptions.values) {
        sub.cancel();
      }
      likesSubscriptions.clear();
      repliesSubscriptions.clear();
    };

    return controller.stream;
  }

  Future<void> _loadCommentsWithStats(
    Map<dynamic, dynamic> commentsData,
    int postId,
    int currentUserId,
    Map<String, FirebaseComment> commentsMap,
  ) async {
    for (final entry in commentsData.entries) {
      final key = entry.key.toString();
      final commentData = entry.value as Map<dynamic, dynamic>;

      await _loadSingleCommentWithStats(
        key,
        commentData,
        postId,
        currentUserId,
        commentsMap,
      );
    }
  }

  Future<void> _loadSingleCommentWithStats(
    String key,
    Map<dynamic, dynamic> commentData,
    int postId,
    int currentUserId,
    Map<String, FirebaseComment> commentsMap,
  ) async {
    int likesCount = 0;
    bool userHasLiked = false;
    int repliesCount = 0;

    try {
      final likesSnapshot = await _getCommentLikesRef(postId, key).get();
      if (likesSnapshot.exists) {
        final likes = likesSnapshot.value as Map<dynamic, dynamic>;
        likesCount = likes.length;
        userHasLiked = likes.values.any(
          (like) => (like as Map<dynamic, dynamic>)['user_id'] == currentUserId,
        );
      }

      final repliesSnapshot = await _getCommentRepliesRef(postId, key).get();
      if (repliesSnapshot.exists) {
        final replies = repliesSnapshot.value as Map<dynamic, dynamic>;
        repliesCount = replies.length;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting comment stats: $e');
      }
    }

    final userData = commentData['user'] as Map<dynamic, dynamic>?;
    if (userData != null) {
      final comment = FirebaseComment(
        id: key,
        postId: postId,
        user: UserData.fromJson(Map<String, dynamic>.from(userData)),
        content: commentData['content']?.toString() ?? '',
        reaction: commentData['reaction']?.toString(),
        createdAt: commentData['created_at']?.toString() ?? '',
        likesCount: likesCount,
        repliesCount: repliesCount,
        userHasLiked: userHasLiked,
        firebaseKey: key,
      );

      commentsMap[key] = comment;
    }
  }

  Future<void> _updateCommentStats(
    String key,
    int postId,
    int currentUserId,
    Map<String, FirebaseComment> commentsMap,
  ) async {
    if (!commentsMap.containsKey(key)) return;

    final comment = commentsMap[key]!;
    int likesCount = 0;
    bool userHasLiked = false;
    int repliesCount = 0;

    try {
      final likesSnapshot = await _getCommentLikesRef(postId, key).get();
      if (likesSnapshot.exists) {
        final likes = likesSnapshot.value as Map<dynamic, dynamic>;
        likesCount = likes.length;
        userHasLiked = likes.values.any(
          (like) => (like as Map<dynamic, dynamic>)['user_id'] == currentUserId,
        );
      }

      final repliesSnapshot = await _getCommentRepliesRef(postId, key).get();
      if (repliesSnapshot.exists) {
        final replies = repliesSnapshot.value as Map<dynamic, dynamic>;
        repliesCount = replies.length;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating comment stats: $e');
      }
    }

    commentsMap[key] = FirebaseComment(
      id: comment.id,
      postId: comment.postId,
      user: comment.user,
      content: comment.content,
      reaction: comment.reaction,
      createdAt: comment.createdAt,
      likesCount: likesCount,
      repliesCount: repliesCount,
      userHasLiked: userHasLiked,
      firebaseKey: comment.firebaseKey,
    );
  }

  List<FirebaseComment> _sortComments(List<FirebaseComment> comments) {
    comments.sort((a, b) {
      try {
        return DateTime.parse(
          b.createdAt,
        ).compareTo(DateTime.parse(a.createdAt));
      } catch (e) {
        return 0;
      }
    });
    return comments;
  }

  // Listen to replies for a comment
  Stream<List<FirebaseReply>> listenToReplies({
    required int postId,
    required String commentId,
    required int currentUserId,
  }) {
    final repliesRef = _getCommentRepliesRef(postId, commentId);

    return repliesRef.onValue.asyncMap((event) async {
      if (!event.snapshot.exists) {
        return <FirebaseReply>[];
      }

      final repliesData = event.snapshot.value as Map<dynamic, dynamic>?;
      if (repliesData == null) {
        return <FirebaseReply>[];
      }

      final List<FirebaseReply> replies = [];

      for (final entry in repliesData.entries) {
        final key = entry.key.toString();
        final replyData = entry.value as Map<dynamic, dynamic>;

        int likesCount = 0;
        bool userHasLiked = false;

        try {
          final likesSnapshot = await _getReplyLikesRef(
            postId,
            commentId,
            key,
          ).get();
          if (likesSnapshot.exists) {
            final likes = likesSnapshot.value as Map<dynamic, dynamic>;
            likesCount = likes.length;
            userHasLiked = likes.values.any(
              (like) =>
                  (like as Map<dynamic, dynamic>)['user_id'] == currentUserId,
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error getting reply stats: $e');
          }
        }

        final userData = replyData['user'] as Map<dynamic, dynamic>?;
        if (userData != null) {
          replies.add(
            FirebaseReply(
              id: key,
              commentId: commentId,
              user: UserData.fromJson(Map<String, dynamic>.from(userData)),
              content: replyData['content']?.toString() ?? '',
              createdAt: replyData['created_at']?.toString() ?? '',
              likesCount: likesCount,
              userHasLiked: userHasLiked,
              firebaseKey: key,
            ),
          );
        }
      }

      replies.sort(
        (a, b) =>
            DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)),
      );

      return replies;
    });
  }

  Future<void> sendNotification({
    required int receiverId,
    required String type,
    required String title,
    required String message,
    required int senderId,
    required String senderName,
    String? senderImage,
    int? postId,
    String? commentId,
    String? replyId,
    String? postContent,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (receiverId == senderId) {
        return;
      }


      final notificationId =
          'notif_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
      final notificationRef = _firebaseService
          .getNotificationsRef(receiverId)
          .child(notificationId);

      final notificationData = <String, dynamic>{
        'id': notificationId,
        'type': type,
        'title': title,
        'message': message,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_image': senderImage ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'read': false,
        'sender_type': 'user',
      };

      // Add optional fields
      if (postId != null) {
        notificationData['post_id'] = postId;
      }
      if (commentId != null) {
        notificationData['comment_id'] = commentId;
      }
      if (replyId != null) {
        notificationData['reply_id'] = replyId;
      }
      if (postContent != null) {
        notificationData['post_content'] = postContent;
      }

      if (additionalData != null) {
        notificationData.addAll(additionalData);
      }

      await notificationRef.set(notificationData);
      await FCMService().sendPushDirectly(
        receiverId: receiverId,
        title: title,
        body: message,
        data: notificationData,
      );

      if (kDebugMode) {
        print('✅ Notification saved to Firebase for user: $receiverId');
        print('   Type: $type, Title: $title');
        print('   Path: notifications/$receiverId/$notificationId');
        print(
          '   📱 Cloud Functions will send push notification automatically',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending notification: $e');
      }
    }
  }
}
