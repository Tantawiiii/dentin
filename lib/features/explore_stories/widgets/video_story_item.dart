import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bounce/bounce.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../home/data/models/post_models.dart';
import '../../home/data/repo/post_repository.dart';
import '../../home/widgets/share_post_dialog.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../../../shared/widgets/video_player_widget.dart';

class VideoStoryItem extends StatefulWidget {
  final Post post;
  final bool isPlaying;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  const VideoStoryItem({
    super.key,
    required this.post,
    this.isPlaying = false,
    this.onPrevious,
    this.onNext,
  });

  @override
  State<VideoStoryItem> createState() => _VideoStoryItemState();
}

class _StoryCommentsBottomSheet extends StatelessWidget {
  final Post post;

  const _StoryCommentsBottomSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
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
                                  '${post.comments.length} ${AppTexts.comments}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: AppColors.divider),
                    Expanded(
                      child: post.comments.isEmpty
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
                              itemCount: post.comments.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 10.h),
                              itemBuilder: (context, index) {
                                final comment = post.comments[index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: CachedNetworkImage(
                                        imageUrl: comment.user.profileImage,
                                        width: 32.w,
                                        height: 32.w,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            ShimmerPlaceholder(
                                              width: 32.w,
                                              height: 32.w,
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
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
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comment.user.userName,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              comment.content,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              comment.createdAt,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: AppColors.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
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

class _VideoStoryItemState extends State<VideoStoryItem> {
  bool _isMuted = true;
  late Post _currentPost;
  bool _isLiked = false;
  bool _isLiking = false;
  final PostRepository _postRepository = di.sl<PostRepository>();

  bool _isDefaultImage(String? url) {
    if (url == null || url.isEmpty) return true;
    return url.contains('default-logo.png');
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  @override
  void didUpdateWidget(VideoStoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.likesCount != widget.post.likesCount ||
        oldWidget.post.comments.length != widget.post.comments.length) {
      _currentPost = widget.post;
    }
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

  void _openCommentsBottomSheet() {
    if (_currentPost.comments.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _StoryCommentsBottomSheet(post: _currentPost);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = !_isDefaultImage(widget.post.video);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: hasVideo
              ? VideoPlayerWidget(
                  videoUrl: _currentPost.video,
                  thumbnailUrl: _currentPost.image,
                  autoPlay: widget.isPlaying,
                  showControls: true,
                  fit: BoxFit.cover,
                  isMuted: _isMuted,
                )
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      Icons.videocam_off,
                      size: 64.sp,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                    onPressed: widget.onPrevious,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_downward,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                    onPressed: widget.onNext,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.favorite_outline,
                    count: _currentPost.likesCount,
                    onTap: _handleLike,
                    isActive: _isLiked,
                    isLoading: _isLiking,
                  ),
                  SizedBox(height: 24.h),
                  _buildActionButton(
                    icon: Icons.comment_outlined,
                    count: _currentPost.comments.length,
                    onTap: _openCommentsBottomSheet,
                  ),
                  SizedBox(height: 24.h),
                  _buildActionButton(
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
                  SizedBox(height: 32.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: CachedNetworkImage(
                      imageUrl: widget.post.user.profileImage,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => ShimmerPlaceholder(
                        width: 48.w,
                        height: 48.w,
                        shape: BoxShape.circle,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 48.w,
                        height: 48.w,
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.person,
                          size: 24.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          right: 80.w,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleMute,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.user.userName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.post.content != null &&
                                widget.post.content!.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                widget.post.content!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.primary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Original Sound',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    int? count,
    String? label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLoading = false,
  }) {
    return Bounce(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              color: Colors.transparent,
            ),
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isActive ? AppColors.primaryDark : AppColors.primary,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: isActive ? AppColors.primaryDark : AppColors.primary,
                    size: 24.sp,
                  ),
          ),
          if (count != null) ...[
            SizedBox(height: 4.h),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else if (label != null) ...[
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
