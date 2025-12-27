import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import '../../../friends/data/models/friend_request_model.dart';
import '../../../profile/data/models/profile_response.dart';
import 'friend_button_widget.dart';
import 'user_action_button.dart';

class UserCard extends StatelessWidget {
  final Doctor user;
  final FriendRequestStatus friendStatus;
  final VoidCallback onProfileTap;
  final VoidCallback onMessageTap;
  final VoidCallback onFriendTap;

  const UserCard({
    super.key,
    required this.user,
    required this.friendStatus,
    required this.onProfileTap,
    required this.onMessageTap,
    required this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onProfileTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _CoverImage(coverImage: user.coverImage),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    user: user,
                    friendStatus: friendStatus,
                    onProfileTap: onProfileTap,
                  ),
                  SizedBox(height: 8.h),
                  if (user.fields.isNotEmpty)
                    _Specializations(fields: user.fields),
                  SizedBox(height: 8.h),
                  _UserStats(
                    postsCount: user.posts.length,
                    fieldsCount: user.fields.length,
                  ),
                  SizedBox(height: 12.h),
                  _ActionButtons(
                    onProfileTap: onProfileTap,
                    onMessageTap: onMessageTap,
                    onFriendTap: onFriendTap,
                    friendStatus: friendStatus,
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

class _CoverImage extends StatelessWidget {
  final String? coverImage;

  const _CoverImage({required this.coverImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: coverImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              child: CachedNetworkImage(
                imageUrl: coverImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180.h,
                memCacheWidth: 400,
                memCacheHeight: 200,
                maxWidthDiskCache: 800,
                maxHeightDiskCache: 400,
                placeholder: (_, __) =>
                    ShimmerPlaceholder(width: double.infinity, height: 180.h),
              ),
            )
          : null,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Doctor user;
  final FriendRequestStatus friendStatus;
  final VoidCallback onProfileTap;

  const _ProfileHeader({
    required this.user,
    required this.friendStatus,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UserAvatar(
          profileImage: user.profileImage,
          firstName: user.firstName,
          onTap: onProfileTap,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${user.firstName} ${user.lastName}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                '@${user.userName}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              _FriendBadge(friendStatus: friendStatus),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? profileImage;
  final String firstName;
  final VoidCallback onTap;

  const _UserAvatar({
    required this.profileImage,
    required this.firstName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: profileImage != null
              ? CachedNetworkImage(
                  imageUrl: profileImage!,
                  fit: BoxFit.cover,
                  memCacheWidth: 120,
                  memCacheHeight: 120,
                  maxWidthDiskCache: 240,
                  maxHeightDiskCache: 240,
                  placeholder: (_, __) => ShimmerPlaceholder(
                    width: 60.w,
                    height: 60.w,
                    shape: BoxShape.circle,
                  ),
                  errorWidget: (_, __, ___) =>
                      _AvatarFallback(firstName: firstName),
                )
              : _AvatarFallback(firstName: firstName),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String firstName;

  const _AvatarFallback({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FriendBadge extends StatelessWidget {
  final FriendRequestStatus friendStatus;

  const _FriendBadge({required this.friendStatus});

  @override
  Widget build(BuildContext context) {
    switch (friendStatus) {
      case FriendRequestStatus.pending:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            AppTexts.pending,
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case FriendRequestStatus.friends:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            AppTexts.friends,
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _Specializations extends StatelessWidget {
  final List<Field> fields;

  const _Specializations({required this.fields});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.w,
      runSpacing: 4.h,
      children: fields.take(2).map((field) {
        return Container(
          key: ValueKey('field_${field.id}'),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            field.name.length > 12
                ? '${field.name.substring(0, 12)}...'
                : field.name,
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UserStats extends StatelessWidget {
  final int postsCount;
  final int fieldsCount;

  const _UserStats({required this.postsCount, required this.fieldsCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$postsCount ${AppTexts.posts}',
          style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
        ),
        Text(
          '$fieldsCount ${AppTexts.fields}',
          style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onMessageTap;
  final VoidCallback onFriendTap;
  final FriendRequestStatus friendStatus;

  const _ActionButtons({
    required this.onProfileTap,
    required this.onMessageTap,
    required this.onFriendTap,
    required this.friendStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: UserActionButton(
            icon: Icons.visibility,
            label: AppTexts.view,
            onTap: onProfileTap,
            color: AppColors.info,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: UserActionButton(
            icon: Icons.message,
            label: AppTexts.msg,
            onTap: onMessageTap,
            color: AppColors.success,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          flex: 2,
          child: FriendButtonWidget(
            friendStatus: friendStatus,
            onTap: onFriendTap,
          ),
        ),
      ],
    );
  }
}
