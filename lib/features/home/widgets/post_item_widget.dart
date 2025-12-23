import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constant/app_colors.dart';
import '../data/models/post_models.dart';

class PostItemWidget extends StatelessWidget {
  final Post post;

  const PostItemWidget({
    super.key,
    required this.post,
  });

  String _formatTime(String? dateTime) {
    if (dateTime == null) return 'Just now';
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  bool _isDefaultImage(String? url) {
    if (url == null || url.isEmpty) return true;
    return url.contains('default-logo.png');
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = !_isDefaultImage(post.image);
    final hasVideo = !_isDefaultImage(post.video);
    final hasGallery = post.gallery.isNotEmpty;
    final isAd = post.isAdRequest && post.isAdApproved == true;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isAd ? AppColors.primaryLight.withOpacity(0.1) : AppColors.surface,
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
                    'Sponsored • Promoted Post',
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: post.user.profileImage,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 40.w,
                          height: 40.w,
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
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
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.user.userName,
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
                            _formatTime(post.user.createdAt),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, size: 20.sp),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (post.content != null && post.content!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    post.content!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasImage || hasVideo || hasGallery)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 400.h),
              child: hasGallery
                  ? SizedBox(
                      height: 300.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.gallery.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: EdgeInsets.only(
                              left: index == 0 ? 16.w : 8.w,
                              right: index == post.gallery.length - 1 ? 16.w : 0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: CachedNetworkImage(
                                imageUrl: post.gallery[index].fullUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.surfaceVariant,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
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
                    )
                  : hasVideo
                      ? Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              width: double.infinity,
                              height: 300.h,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: CachedNetworkImage(
                                  imageUrl: post.image,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.black,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.black,
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle_filled,
                                        size: 64.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    size: 48.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          constraints: BoxConstraints(maxHeight: 400.h),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: CachedNetworkImage(
                              imageUrl: post.image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 300.h,
                                color: AppColors.surfaceVariant,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
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
                        ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.likesCount} likes ${post.comments.length} comments',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.favorite_outline,
                        label: 'Like',
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.comment_outlined,
                        label: 'Comment',
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onTap: () {},
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
                        'Sponsored',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
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
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: AppColors.textSecondary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

