import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../cubit/friend_requests_cubit.dart';
import '../../data/models/friend_request_model.dart';
import 'user_avatar.dart';

class OutgoingRequestItem extends StatelessWidget {
  final FriendRequest request;
  final bool isLoading;
  final int currentUserId;
  final String Function(int) formatTime;
  final FriendRequestsCubit friendRequestsCubit;

  const OutgoingRequestItem({
    super.key,
    required this.request,
    required this.isLoading,
    required this.currentUserId,
    required this.formatTime,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserId = request.getOtherUserId(currentUserId);
    final otherUserName = request.getOtherUserName(currentUserId);
    final otherUserImage = request.getOtherUserImage(currentUserId);

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.border.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              UserAvatar(
                userId: otherUserId,
                userName: otherUserName,
                userImage: otherUserImage,
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
                            otherUserName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            AppTexts.pending,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      formatTime(request.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Bounce(
                onTap: isLoading
                    ? null
                    : () {
                        friendRequestsCubit.cancelFriendRequest(
                          request.friendshipId,
                        );
                      },
                duration: const Duration(milliseconds: 100),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: AppColors.error, size: 24.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

