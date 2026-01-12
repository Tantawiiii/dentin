import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../../../shared/widgets/video_player_widget.dart';
import '../data/models/post_models.dart';
import '../data/repo/post_repository.dart';
import 'post_action_button.dart';
import 'post_comments_bottom_sheet.dart';
import 'post_media_models.dart';
import 'share_post_dialog.dart';

class PostItemWidget extends StatefulWidget {
  final Post post;
  final VoidCallback? onPostUpdated;

  final int index;

  const PostItemWidget({
    super.key,
    required this.post,
    this.onPostUpdated,
    required this.index,
  });

  @override
  State<PostItemWidget> createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  late Post _currentPost;
  bool _isLiked = false;
  bool _isLiking = false;
  bool _isCommenting = false;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final PageController _mediaPageController = PageController();
  int _currentMediaPage = 0;
  final PostRepository _postRepository = di.sl<PostRepository>();

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  @override
  void didUpdateWidget(PostItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.likesCount != widget.post.likesCount ||
        oldWidget.post.comments.length != widget.post.comments.length) {
      _currentPost = widget.post;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _mediaPageController.dispose();
    super.dispose();
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
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return AppTexts.justNow;
    }
  }

  List<PostMediaItem> _buildMediaItems() {
    final List<PostMediaItem> items = [];

    final hasVideo = !_isDefaultImage(_currentPost.video);
    final hasGallery = _currentPost.gallery.isNotEmpty;

    // Use gallery items (with fullUrl) for images
    if (hasGallery) {
      for (final galleryItem in _currentPost.gallery) {
        items.add(
          PostMediaItem(type: PostMediaType.image, url: galleryItem.fullUrl),
        );
      }
    } else {
      final hasImage = !_isDefaultImage(_currentPost.image);
      if (hasImage) {
        items.add(
          PostMediaItem(type: PostMediaType.image, url: _currentPost.image),
        );
      }
    }

    if (hasVideo) {
      String? thumbnailUrl;
      if (hasGallery && _currentPost.gallery.isNotEmpty) {
        thumbnailUrl = _currentPost.gallery.first.fullUrl;
      } else if (!_isDefaultImage(_currentPost.image)) {
        thumbnailUrl = _currentPost.image;
      }

      items.add(
        PostMediaItem(
          type: PostMediaType.video,
          url: _currentPost.video,
          thumbnailUrl: thumbnailUrl,
        ),
      );
    }

    return items;
  }

  bool _isDefaultImage(String? url) {
    if (url == null || url.isEmpty) return true;
    return url.contains('default-logo.png');
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    final previousLikedState = _isLiked;
    final previousLikesCount = _currentPost.likesCount;

    setState(() {
      _isLiking = true;
      _isLiked = !_isLiked;
      _currentPost = _currentPost.copyWith(
        likesCount: _isLiked
            ? _currentPost.likesCount + 1
            : _currentPost.likesCount - 1,
      );
    });

    try {
      await _postRepository.likePost(
        _currentPost.id,
        LikePostRequest(liked: _isLiked, likesCount: _currentPost.likesCount),
      );
    } catch (e) {
      setState(() {
        _isLiked = previousLikedState;
        _currentPost = _currentPost.copyWith(likesCount: previousLikesCount);
      });
      if (mounted) {
        AppToast.showError(
          'Failed to like post: ${e.toString()}',
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  Future<void> _handleComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _isCommenting) return;

    setState(() {
      _isCommenting = true;
    });

    try {
      final storageService = di.sl<StorageService>();
      final userData = storageService.getUserData();
      if (userData == null) {
        throw Exception('User not logged in');
      }

      final request = CreateCommentRequest(
        postId: _currentPost.id,
        content: content,
        reaction: 'like',
      );

      final response = await _postRepository.createComment(request);

      final newComments = List<Comment>.from(_currentPost.comments)
        ..add(response.data);

      setState(() {
        _currentPost = _currentPost.copyWith(comments: newComments);
        _commentController.clear();
      });

      if (widget.onPostUpdated != null) {
        widget.onPostUpdated!();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          'Failed to post comment: ${e.toString()}',
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCommenting = false;
        });
      }
    }
  }

  void _openCommentsBottomSheet() {
    if (_currentPost.comments.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PostCommentsBottomSheet(
          post: _currentPost,
          onAddComment: () {
            Navigator.of(context).pop();
            _commentFocusNode.requestFocus();
          },
        );
      },
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'report':
        _handleReport();
        break;
      case 'hide':
        _handleHide();
        break;
      case 'save':
        _handleSave();
        break;
    }
  }

  Future<void> _handleReport() async {
    final result = await _showReportDialog();
    if (result == null) return;

    final complaint = result['complaint']!.trim();
    final note = result['note']!.trim();
    if (complaint.isEmpty) return;

    try {
      await _postRepository.reportPost(
        postId: _currentPost.id,
        complaint: complaint,
        note: note,
      );

      // Also hide the post after reporting
      await _postRepository.togglePostHidden(_currentPost.id);

      setState(() {
        _currentPost = _currentPost.copyWith(isHidden: true);
      });

      if (mounted) {
        AppToast.showSuccess(AppTexts.postReported, context: context);
        // Ask parent to refresh list so the post disappears
        widget.onPostUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          'Failed to report post: ${e.toString()}',
          context: context,
        );
      }
    }
  }

  Future<void> _handleHide() async {
    try {
      await _postRepository.togglePostHidden(_currentPost.id);

      final newHidden = !_currentPost.isHidden;

      setState(() {
        _currentPost = _currentPost.copyWith(isHidden: newHidden);
      });

      if (mounted) {
        AppToast.showSuccess(
          newHidden ? AppTexts.postHidden : AppTexts.postUnhidden,
          context: context,
        );
        // Ask parent to refresh list (home / saved / hidden screens)
        widget.onPostUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          'Failed to hide post: ${e.toString()}',
          context: context,
        );
      }
    }
  }

  Future<void> _handleSave() async {
    try {
      await _postRepository.togglePostSaved(_currentPost.id);

      // Toggle local saved state for better UX
      final wasSaved = _currentPost.isSaved;
      setState(() {
        _currentPost = _currentPost.copyWith(isSaved: !_currentPost.isSaved);
      });

      if (mounted) {
        AppToast.showSuccess(
          wasSaved ? AppTexts.postUnsaved : AppTexts.postSaved,
          context: context,
        );
        // Let parent refresh lists if needed (e.g. SavedPostsScreen)
        widget.onPostUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          'Failed to save post: ${e.toString()}',
          context: context,
        );
      }
    }
  }

  Future<Map<String, String>?> _showReportDialog() async {
    final complaintController = TextEditingController();
    final noteController = TextEditingController(text: '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'إبلاغ عن المنشور',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: complaintController,
                    decoration: const InputDecoration(
                      labelText: 'سبب الشكوى *',
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء كتابة سبب الشكوى';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات إضافية (اختياري)',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                AppTexts.cancel,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop({
                    'complaint': complaintController.text,
                    'note': noteController.text,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final mediaItems = _buildMediaItems();
    final hasMedia = mediaItems.isNotEmpty;
    final isAd = _currentPost.isAdApproved == true;
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: isAd
              ? AppColors.primaryLight.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: isAd
              ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAd)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16.sp, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    Text(
                      AppTexts.sponsoredPromotedPost,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Bounce(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.userProfile,
                            arguments: _currentPost.user.id,
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: CachedNetworkImage(
                            imageUrl: _currentPost.user.profileImage,
                            width: 40.w,
                            height: 40.w,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => ShimmerPlaceholder(
                              width: 40.w,
                              height: 40.w,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 40.w,
                              height: 40.w,
                              color: AppColors.surfaceVariant,
                              child: Icon(
                                Icons.person,
                                size: 24.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _currentPost.user.userName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isAd) ...[
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.verified,
                                    size: 16.sp,
                                    color: AppColors.success,
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _formatTime(_currentPost.user.createdAt),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, size: 20.sp),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'report',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 20.sp,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  AppTexts.report,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'hide',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.visibility_off_outlined,
                                  size: 20.sp,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  AppTexts.hide,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'save',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bookmark_outline,
                                  size: 20.sp,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  AppTexts.save,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          _handleMenuAction(value);
                        },
                      ),
                    ],
                  ),
                  if (_currentPost.content != null &&
                      _currentPost.content!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      _currentPost.content!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasMedia)
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 400.h),
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _mediaPageController,
                      itemCount: mediaItems.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentMediaPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final media = mediaItems[index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          width: double.infinity,
                          height: 300.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: media.type == PostMediaType.video
                                ? Container(
                                    color: Colors.black,
                                    child: VideoPlayerWidget(
                                      videoUrl: media.url,
                                      thumbnailUrl: media.thumbnailUrl,
                                      autoPlay: false,
                                      showControls: true,
                                      fit: BoxFit.cover,
                                      isMuted: true,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: media.url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        ShimmerPlaceholder(
                                          width: double.infinity,
                                          height: 300.h,
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          height: 300.h,
                                          color: AppColors.surfaceVariant,
                                          child: Icon(
                                            Icons.error,
                                            size: 48.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                  ),
                          ),
                        );
                      },
                    ),
                    if (mediaItems.length > 1)
                      Positioned(
                        bottom: 12.h,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            mediaItems.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              width: _currentMediaPage == index ? 10.w : 6.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  _currentMediaPage == index ? 0.95 : 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentPost.likesCount} ${AppTexts.likes}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_currentPost.comments.isNotEmpty)
                        GestureDetector(
                          onTap: _openCommentsBottomSheet,
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 14.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${_currentPost.comments.length} ${AppTexts.comments}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: PostActionButton(
                          icon: _isLiked
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          label: AppTexts.like,
                          onTap: _handleLike,
                          isActive: _isLiked,
                          isLoading: _isLiking,
                        ),
                      ),
                      Expanded(
                        child: PostActionButton(
                          icon: Icons.comment_outlined,
                          label: AppTexts.comment,
                          onTap: _openCommentsBottomSheet,
                        ),
                      ),
                      Expanded(
                        child: PostActionButton(
                          icon: Icons.share_outlined,
                          label: AppTexts.share,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  SharePostDialog(post: _currentPost),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (isAd)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          AppTexts.sponsored,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  Divider(height: 24.h, thickness: 1, color: AppColors.divider),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: userData?.profileImage != null
                            ? CachedNetworkImage(
                                imageUrl: userData!.profileImage!,
                                width: 32.w,
                                height: 32.w,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    ShimmerPlaceholder(
                                      width: 32.w,
                                      height: 32.w,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                errorWidget: (context, url, error) => Container(
                                  width: 32.w,
                                  height: 32.w,
                                  color: AppColors.surfaceVariant,
                                  child: Icon(
                                    Icons.person,
                                    size: 16.sp,
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
                                  size: 16.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          focusNode: _commentFocusNode,
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
                          onSubmitted: (_) => _handleComment(),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Bounce(
                        onTap: _handleComment,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: _isCommenting
                                ? AppColors.primary.withOpacity(0.6)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: _isCommenting
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
