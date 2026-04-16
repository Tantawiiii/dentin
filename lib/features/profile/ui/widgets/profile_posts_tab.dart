import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../home/data/models/post_models.dart' as shared_post;
import '../../../home/widgets/post_item_widget.dart';
import '../../data/models/profile_response.dart';

class ProfilePostsTab extends StatelessWidget {
  final Doctor doctor;

  const ProfilePostsTab({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final posts = doctor.posts;

    if (posts.isEmpty) {
      return Center(
        child: Text(
          AppTexts.noPostsYet,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        // Map ProfilePost to shared_post.Post
        final sharedPost = shared_post.Post(
          id: post.id,
          user: shared_post.PostUser(
            id: doctor.id,
            userName: doctor.userName,
            profileImage: doctor.profileImage ?? '',
            createdAt: doctor.createdAt ?? '',
            updatedAt: doctor.createdAt ?? '',
          ),
          content: post.content,
          image: post.image ?? '',
          video: '', // ProfilePost doesn't seem to have video
          gallery: post.gallery
              .map(
                (g) => shared_post.PostGallery(
                  id: g.id,
                  name: g.name,
                  mimeType: g.mimeType,
                  size: g.size,
                  previewUrl: g.previewUrl,
                  fullUrl: g.fullUrl,
                  createdAt: g.createdAt,
                  authorId: g.authorId,
                ),
              )
              .toList(),
          comments: [], // Comments are not in ProfilePost
          likesCount: post.likesCount,
          isAdRequest: post.isAdRequest,
          isHidden: false,
          isSaved: false,
          isLiked: false,
          createdAt: post.createdAt ?? '',
          updatedAt: post.createdAt ?? '',
        );

        return PostItemWidget(
          key: ValueKey('profile_post_${post.id}'),
          post: sharedPost,
          index: index,
          onPostUpdated: () {
            // Ideally call refresh on ProfileCubit
          },
        );
      },
    );
  }
}
