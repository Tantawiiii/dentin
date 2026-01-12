import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import '../../data/models/profile_response.dart';

class ProfilePostsTab extends StatelessWidget {
  final List<Post> posts;

  const ProfilePostsTab({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          AppTexts.noPostsYet,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: posts.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final post = posts[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.gallery.isNotEmpty)
                ...post.gallery.map(
                  (galleryItem) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: galleryItem.fullUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => ShimmerPlaceholder(
                          width: double.infinity,
                          height: 180.h,
                        ),
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                )
              else if (post.image != null &&
                  post.image!.isNotEmpty &&
                  !post.image!.contains('default-logo.png'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: post.image!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ShimmerPlaceholder(
                      width: double.infinity,
                      height: 180.h,
                    ),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              if (post.content != null && post.content!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    post.content!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        post.isAdRequest
                            ? Icons.campaign_outlined
                            : Icons.article_outlined,
                        size: 16.sp,
                        color: post.isAdRequest
                            ? Colors.teal
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        post.isAdRequest
                            ? AppTexts.sponsored
                            : AppTexts.regular,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: post.isAdRequest
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 16.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        post.likesCount.toString(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
