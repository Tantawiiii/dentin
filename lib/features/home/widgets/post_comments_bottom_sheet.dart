import 'dart:async';
import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../../../features/auth/login/data/models/login_response.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../data/models/post_models.dart';
import '../data/repo/post_repository.dart';
import '../services/firebase_comments_service.dart';

class PostCommentsBottomSheet extends StatefulWidget {
  final Post post;
  final VoidCallback onAddComment;

  const PostCommentsBottomSheet({
    super.key,
    required this.post,
    required this.onAddComment,
  });

  @override
  State<PostCommentsBottomSheet> createState() =>
      _PostCommentsBottomSheetState();
}

class _PostCommentsBottomSheetState extends State<PostCommentsBottomSheet> {
  final FirebaseCommentsService _commentsService = di
      .sl<FirebaseCommentsService>();
  final PostRepository _postRepository = di.sl<PostRepository>();
  final StorageService _storageService = di.sl<StorageService>();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<FirebaseComment> _comments = [];
  List<Comment> _backendComments = [];
  String? _replyingToCommentId;
  final Map<String, List<FirebaseReply>> _replies = {};
  final Map<String, bool> _expandedReplies = {};
  final Map<String, StreamSubscription<List<FirebaseReply>>> _repliesSubscriptions =
      {};
  bool _isLoading = true;
  bool _isAddingComment = false;
  bool _isAddingReply = false;
  final Map<String, bool> _isLikingComment = {};
  StreamSubscription<List<FirebaseComment>>? _commentsSubscription;

  UserData? _currentUser;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBackendComments();
    _setupCommentsListener();
  }

  void _loadUserData() {
    final userData = _storageService.getUserData();
    setState(() {
      _currentUser = userData;
      _currentUserId = userData?.id;
    });
  }

  Future<void> _loadBackendComments() async {
    // Load comments from backend first
    setState(() {
      _backendComments = widget.post.comments;
      _isLoading = false;
    });
  }

  void _setupCommentsListener() {
    if (_currentUserId == null) return;

    _commentsSubscription = _commentsService
        .listenToComments(
          postId: widget.post.id,
          currentUserId: _currentUserId!,
        )
        .listen((firebaseComments) {
          if (mounted) {
            setState(() {
              _comments = firebaseComments;
            });

            // Load replies for all comments that have replies immediately
            for (final comment in firebaseComments) {
              if (comment.repliesCount > 0 &&
                  !_repliesSubscriptions.containsKey(comment.id)) {
                // Load replies immediately when comments are loaded
                _loadRepliesInBackground(comment.id);
              }
            }
          }
        });
  }

  Future<void> _loadRepliesInBackground(String commentId) async {
    if (_currentUserId == null) return;
    if (_repliesSubscriptions.containsKey(commentId)) return; // Already loaded

    try {
      final repliesStream = _commentsService.listenToReplies(
        postId: widget.post.id,
        commentId: commentId,
        currentUserId: _currentUserId!,
      );

      final subscription = repliesStream.listen((replies) {
        if (mounted) {
          setState(() {
            _replies[commentId] = replies;
            // Auto-expand if replies are loaded and not already expanded
            if (replies.isNotEmpty && _expandedReplies[commentId] != true) {
              _expandedReplies[commentId] = true;
            }
          });
        }
      });

      _repliesSubscriptions[commentId] = subscription;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading replies in background: $e');
      }
    }
  }

  // Convert PostUser to UserData
  UserData _convertPostUserToUserData(PostUser postUser) {
    return UserData(
      id: postUser.id,
      userName: postUser.userName,
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      birthDate: null,
      graduationYear: null,
      university: null,
      graduationGrade: null,
      postgraduateDegree: null,
      specialization: null,
      experienceYears: null,
      description: null,
      experience: null,
      whereDidYouWork: null,
      address: null,
      availableTimes: null,
      skills: null,
      fields: null,
      profileImage: postUser.profileImage,
      coverImage: null,
      graduationCertificateImage: null,
      cv: null,
      courseCertificatesImage: null,
      isWorkAssistantUniversity: null,
      assistantUniversity: null,
      tools: null,
      active: null,
      hasClinic: null,
      clinicName: null,
      clinicAddress: null,
      createdAt: postUser.createdAt,
      updatedAt: postUser.updatedAt,
    );
  }

  // Convert backend Comment to FirebaseComment format for display
  List<FirebaseComment> _getAllComments() {
    final allComments = <FirebaseComment>[];
    final backendIds = _backendComments.map((c) => c.id.toString()).toSet();

    for (final backendComment in _backendComments) {
      final commentId = backendComment.id.toString();
      final firebaseComment = _comments.firstWhere(
        (c) => c.id == commentId,
        orElse: () => FirebaseComment(
          id: commentId,
          postId: backendComment.postId,
          user: _convertPostUserToUserData(backendComment.user),
          content: backendComment.content,
          reaction: backendComment.reaction,
          createdAt: backendComment.createdAt,
          likesCount: 0,
          repliesCount: 0,
          userHasLiked: false,
        ),
      );
      allComments.add(firebaseComment);
    }

    for (final firebaseComment in _comments) {
      if (!backendIds.contains(firebaseComment.id)) {
        allComments.add(firebaseComment);
      }
    }

    allComments.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.createdAt);
        final dateB = DateTime.parse(b.createdAt);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return allComments;
  }

  @override
  void dispose() {
    _commentsSubscription?.cancel();
    for (final subscription in _repliesSubscriptions.values) {
      subscription.cancel();
    }
    _repliesSubscriptions.clear();
    _commentController.dispose();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_currentUser == null || _currentUserId == null) {
      AppToast.showError('Please login to comment', context: context);
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty || _isAddingComment) return;

    setState(() {
      _isAddingComment = true;
    });

    try {
      // Add comment to backend first
      final request = CreateCommentRequest(
        postId: widget.post.id,
        content: content,
        reaction: 'like',
      );

      final response = await _postRepository.createComment(request);

      setState(() {
        _backendComments = List<Comment>.from(_backendComments)
          ..add(response.data);
      });
      try {
        await _commentsService.addComment(
          postId: widget.post.id,
          content: content,
          user: _currentUser!,
        );
      } catch (e) {
        // If Firebase fails, continue anyway
        if (mounted) {
          print('Firebase comment sync failed: $e');
        }
      }

      // Send notification to post owner
      if (widget.post.user.id != _currentUserId) {
        await _commentsService.sendNotification(
          receiverId: widget.post.user.id,
          type: 'post_comment',
          title: 'New Comment',
          message:
              '${_currentUser!.userName} commented on your post: "${content.substring(0, content.length > 50 ? 50 : content.length)}${content.length > 50 ? '...' : ''}"',
          senderId: _currentUserId!,
          senderName: _currentUser!.userName,
          senderImage: _currentUser!.profileImage,
          postId: widget.post.id,
          commentId: response.data.id.toString(),
          postContent: widget.post.content != null
              ? (widget.post.content!.length > 100
                    ? '${widget.post.content!.substring(0, 100)}...'
                    : widget.post.content!)
              : '',
          additionalData: {'comment_content': content},
        );
      }

      _commentController.clear();
      AppToast.showSuccess('Comment added!', context: context);
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          'Failed to add comment: ${e.toString()}',
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingComment = false;
        });
      }
    }
  }

  Future<void> _toggleCommentLike(String commentId) async {
    if (_currentUser == null || _currentUserId == null) {
      AppToast.showError('Please login to like comments', context: context);
      return;
    }

    if (_isLikingComment[commentId] == true) return;

    setState(() {
      _isLikingComment[commentId] = true;
    });

    try {
      final allComments = _getAllComments();
      final comment = allComments.firstWhere(
        (c) => c.id == commentId,
        orElse: () => throw Exception('Comment not found'),
      );

      // If comment is from backend, add it to Firebase first using backend ID
      if (!_comments.any((c) => c.id == commentId)) {
        try {
          await _commentsService.addComment(
            postId: widget.post.id,
            content: comment.content,
            user: comment.user,
            commentId: commentId, // Use backend comment ID
          );
        } catch (e) {
          // Continue anyway - might already exist
        }
      }

      // Check if user already liked before toggling
      final wasLiked = comment.userHasLiked;

      // Toggle like
      await _commentsService.toggleCommentLike(
        postId: widget.post.id,
        commentId: commentId,
        userId: _currentUserId!,
        user: _currentUser!,
      );

      // Send notification only if user liked (was not liked before, now is liked)
      if (!wasLiked && comment.user.id != _currentUserId) {
        await _commentsService.sendNotification(
          receiverId: comment.user.id,
          type: 'comment_like',
          title: 'Comment Liked',
          message:
              '${_currentUser!.userName} liked your comment: "${comment.content.substring(0, comment.content.length > 50 ? 50 : comment.content.length)}${comment.content.length > 50 ? '...' : ''}"',
          senderId: _currentUserId!,
          senderName: _currentUser!.userName,
          senderImage: _currentUser!.profileImage,
          postId: widget.post.id,
          commentId: commentId,
          postContent: widget.post.content != null
              ? (widget.post.content!.length > 100
                    ? '${widget.post.content!.substring(0, 100)}...'
                    : widget.post.content!)
              : '',
        );
      }

      AppToast.showSuccess(
        comment.userHasLiked ? 'Comment unliked!' : 'Comment liked!',
        context: context,
      );

      // Force refresh comments to show updated likes
      if (mounted) {
        // The stream will automatically update, but we can trigger a refresh
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          'Failed to like comment: ${e.toString()}',
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLikingComment[commentId] = false;
        });
      }
    }
  }

  Future<void> _addReply(String commentId) async {
    if (_currentUser == null || _currentUserId == null) {
      AppToast.showError('Please login to reply', context: context);
      return;
    }

    final content = _replyController.text.trim();
    if (content.isEmpty || _isAddingReply) return;

    setState(() {
      _isAddingReply = true;
    });

    try {
      final allComments = _getAllComments();
      final comment = allComments.firstWhere(
        (c) => c.id == commentId,
        orElse: () => throw Exception('Comment not found'),
      );

      // If comment is from backend, add it to Firebase first using backend ID
      if (!_comments.any((c) => c.id == commentId)) {
        try {
          await _commentsService.addComment(
            postId: widget.post.id,
            content: comment.content,
            user: comment.user,
            commentId: commentId, // Use backend comment ID
          );
        } catch (e) {
          // Continue anyway - reply will still work
        }
      }

      await _commentsService.addReply(
        postId: widget.post.id,
        commentId: commentId,
        content: content,
        user: _currentUser!,
      );

      // Send notification to comment owner
      if (comment.user.id != _currentUserId) {
        await _commentsService.sendNotification(
          receiverId: comment.user.id,
          type: 'comment_reply',
          title: 'New Reply',
          message:
              '${_currentUser!.userName} replied to your comment: "${content.substring(0, content.length > 50 ? 50 : content.length)}${content.length > 50 ? '...' : ''}"',
          senderId: _currentUserId!,
          senderName: _currentUser!.userName,
          senderImage: _currentUser!.profileImage,
          postId: widget.post.id,
          commentId: commentId,
          postContent: widget.post.content != null
              ? (widget.post.content!.length > 100
                    ? '${widget.post.content!.substring(0, 100)}...'
                    : widget.post.content!)
              : '',
          additionalData: {'reply_content': content},
        );
      }

      _replyController.clear();
      setState(() {
        _replyingToCommentId = null;
      });
      AppToast.showSuccess('Reply added!', context: context);

      // Open replies if not already open
      if (_expandedReplies[commentId] != true) {
        setState(() {
          _expandedReplies[commentId] = true;
        });
        // Load replies if not already loaded
        await _loadReplies(commentId);
      } else {
        // If replies are already open, the stream should update automatically
        // But we can force a refresh by reloading
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && _expandedReplies[commentId] == true) {
          // Cancel and reload to ensure we get the latest data
          _repliesSubscriptions[commentId]?.cancel();
          await _loadReplies(commentId);
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          'Failed to add reply: ${e.toString()}',
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingReply = false;
        });
      }
    }
  }

  Future<void> _loadReplies(String commentId, {bool toggle = false}) async {
    if (_currentUserId == null) return;

    // If toggle is true and replies are already expanded, collapse them
    if (toggle && _expandedReplies[commentId] == true) {
      _repliesSubscriptions[commentId]?.cancel();
      _repliesSubscriptions.remove(commentId);
      setState(() {
        _expandedReplies[commentId] = false;
        _replies[commentId] = [];
      });
      return;
    }

    // If replies are not expanded, expand them
    if (_expandedReplies[commentId] != true) {
      setState(() {
        _expandedReplies[commentId] = true;
      });
    }

    try {
      // Cancel existing subscription if any
      _repliesSubscriptions[commentId]?.cancel();

      final repliesStream = _commentsService.listenToReplies(
        postId: widget.post.id,
        commentId: commentId,
        currentUserId: _currentUserId!,
      );

      final subscription = repliesStream.listen((replies) {
        if (mounted) {
          setState(() {
            _replies[commentId] = replies;
          });
        }
      });

      _repliesSubscriptions[commentId] = subscription;
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          'Failed to load replies: ${e.toString()}',
          context: context,
        );
      }
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return AppTexts.justNow;
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return AppTexts.justNow;
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}${AppTexts.minutes} ${AppTexts.ago}';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}${AppTexts.hours} ${AppTexts.ago}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}${AppTexts.days} ${AppTexts.ago}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return AppTexts.justNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTexts.comments,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${_getAllComments().length} ${AppTexts.comments}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Bounce(
                            onTap: widget.onAddComment,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_comment_outlined,
                                    size: 18.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    AppTexts.comment,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: AppColors.divider),
                    Expanded(
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : _getAllComments().isEmpty
                          ? Center(
                              child: Text(
                                AppTexts.noCommentsYet,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              itemCount: _getAllComments().length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 10.h),
                              itemBuilder: (context, index) {
                                final comment = _getAllComments()[index];
                                final isReplying =
                                    _replyingToCommentId == comment.id;
                                final replies = _replies[comment.id] ?? [];
                                // Auto-expand if replies are loaded
                                final isExpanded =
                                    _expandedReplies[comment.id] == true ||
                                    replies.isNotEmpty;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                comment.user.profileImage ?? '',
                                            width: 32.w,
                                            height: 32.w,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                ShimmerPlaceholder(
                                                  width: 32.w,
                                                  height: 32.w,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        16.r,
                                                      ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  width: 32.w,
                                                  height: 32.w,
                                                  color:
                                                      AppColors.surfaceVariant,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 18.sp,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 8.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceVariant,
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  comment.user.userName,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  comment.content,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                  maxLines: null,
                                                ),
                                                SizedBox(height: 4.h),
                                                Row(
                                                  children: [
                                                    Bounce(
                                                      onTap: () =>
                                                          _toggleCommentLike(
                                                            comment.id,
                                                          ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            comment.userHasLiked
                                                                ? Icons.favorite
                                                                : Icons
                                                                      .favorite_border,
                                                            size: 14.sp,
                                                            color:
                                                                comment
                                                                    .userHasLiked
                                                                ? AppColors
                                                                      .primary
                                                                : AppColors
                                                                      .textSecondary,
                                                          ),
                                                          SizedBox(width: 4.w),
                                                          Text(
                                                            'Like${comment.likesCount > 0 ? ' (${comment.likesCount})' : ''}',
                                                            style: TextStyle(
                                                              fontSize: 11.sp,
                                                              color:
                                                                  comment
                                                                      .userHasLiked
                                                                  ? AppColors
                                                                        .primary
                                                                  : AppColors
                                                                        .textSecondary,
                                                              fontWeight:
                                                                  comment
                                                                      .userHasLiked
                                                                  ? FontWeight
                                                                        .w600
                                                                  : FontWeight
                                                                        .normal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Bounce(
                                                      onTap: () {
                                                        setState(() {
                                                          _replyingToCommentId =
                                                              isReplying
                                                              ? null
                                                              : comment.id;
                                                        });
                                                      },
                                                      child: Text(
                                                        'Reply',
                                                        style: TextStyle(
                                                          fontSize: 11.sp,
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Text(
                                                      _formatTime(
                                                        comment.createdAt,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 11.sp,
                                                        color: AppColors
                                                            .textTertiary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Replies section - show if there are replies or if replies are loaded
                                    if (comment.repliesCount > 0 ||
                                        replies.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 40.w,
                                          top: 8.h,
                                        ),
                                        child: Bounce(
                                          onTap: () => _loadReplies(
                                            comment.id,
                                            toggle: true,
                                          ),
                                          child: Text(
                                            isExpanded
                                                ? 'Hide ${comment.repliesCount > 0 ? comment.repliesCount : replies.length} ${(comment.repliesCount > 0 ? comment.repliesCount : replies.length) == 1 ? 'reply' : 'replies'}'
                                                : 'View ${comment.repliesCount > 0 ? comment.repliesCount : replies.length} ${(comment.repliesCount > 0 ? comment.repliesCount : replies.length) == 1 ? 'reply' : 'replies'}',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Replies list - show if expanded or if replies are already loaded
                                    if ((isExpanded || replies.isNotEmpty) &&
                                        replies.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 40.w,
                                          top: 8.h,
                                        ),
                                        child: Column(
                                          children: replies.map((reply) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 8.h,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          reply
                                                              .user
                                                              .profileImage ??
                                                          '',
                                                      width: 24.w,
                                                      height: 24.w,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => ShimmerPlaceholder(
                                                            width: 24.w,
                                                            height: 24.w,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12.r,
                                                                ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => Container(
                                                            width: 24.w,
                                                            height: 24.w,
                                                            color: AppColors
                                                                .surfaceVariant,
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 14.sp,
                                                              color: AppColors
                                                                  .textSecondary,
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 10.w,
                                                            vertical: 6.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .surfaceVariant,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            reply.user.userName,
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          Text(
                                                            reply.content,
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color: AppColors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          Text(
                                                            _formatTime(
                                                              reply.createdAt,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              color: AppColors
                                                                  .textTertiary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    // Reply input
                                    if (isReplying)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 40.w,
                                          top: 8.h,
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              child:
                                                  _currentUser?.profileImage !=
                                                      null
                                                  ? CachedNetworkImage(
                                                      imageUrl: _currentUser!
                                                          .profileImage!,
                                                      width: 24.w,
                                                      height: 24.w,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => ShimmerPlaceholder(
                                                            width: 24.w,
                                                            height: 24.w,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12.r,
                                                                ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => Container(
                                                            width: 24.w,
                                                            height: 24.w,
                                                            color: AppColors
                                                                .surfaceVariant,
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 14.sp,
                                                              color: AppColors
                                                                  .textSecondary,
                                                            ),
                                                          ),
                                                    )
                                                  : Container(
                                                      width: 24.w,
                                                      height: 24.w,
                                                      color: AppColors
                                                          .surfaceVariant,
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 14.sp,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: TextField(
                                                controller: _replyController,
                                                decoration: InputDecoration(
                                                  hintText: 'Write a reply...',
                                                  hintStyle: TextStyle(
                                                    fontSize: 12.sp,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.r,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      AppColors.surfaceVariant,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 12.w,
                                                        vertical: 8.h,
                                                      ),
                                                  isDense: true,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: AppColors.textPrimary,
                                                ),
                                                maxLines: null,
                                                textInputAction:
                                                    TextInputAction.send,
                                                onSubmitted: (_) =>
                                                    _addReply(comment.id),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Bounce(
                                              onTap: () =>
                                                  _addReply(comment.id),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 8.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _isAddingReply
                                                      ? AppColors.primary
                                                            .withOpacity(0.6)
                                                      : AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20.r,
                                                      ),
                                                ),
                                                child: _isAddingReply
                                                    ? SizedBox(
                                                        width: 12.w,
                                                        height: 12.w,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                        ),
                                                      )
                                                    : Text(
                                                        'Reply',
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                    ),
                    // Add comment input
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: _currentUser?.profileImage != null
                                ? CachedNetworkImage(
                                    imageUrl: _currentUser!.profileImage!,
                                    width: 32.w,
                                    height: 32.w,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        ShimmerPlaceholder(
                                          width: 32.w,
                                          height: 32.w,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          width: 32.w,
                                          height: 32.w,
                                          color: AppColors.surfaceVariant,
                                          child: Icon(
                                            Icons.person,
                                            size: 18.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                  )
                                : Container(
                                    width: 32.w,
                                    height: 32.w,
                                    color: AppColors.surfaceVariant,
                                    child: Icon(
                                      Icons.person,
                                      size: 18.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: AppTexts.writeComment,
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceVariant,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                isDense: true,
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _addComment(),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Bounce(
                            onTap: _addComment,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: _isAddingComment
                                    ? AppColors.primary.withOpacity(0.6)
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: _isAddingComment
                                  ? SizedBox(
                                      width: 16.w,
                                      height: 16.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      AppTexts.post,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
