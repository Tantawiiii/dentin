import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../cubit/friend_requests_cubit.dart';
import '../../data/models/friend_request_model.dart';
import 'user_avatar.dart';

class IncomingRequestItem extends StatelessWidget {
  final FriendRequest request;
  final bool isLoading;
  final int currentUserId;
  final String Function(int) formatTime;
  final FriendRequestsCubit friendRequestsCubit;

  const IncomingRequestItem({
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
                    Text(
                      otherUserName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Bounce(
                    onTap: isLoading
                        ? null
                        : () {
                            friendRequestsCubit.acceptFriendRequest(
                              request.friendshipId,
                              otherUserId,
                            );
                          },
                    duration: const Duration(milliseconds: 100),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Bounce(
                    onTap: isLoading
                        ? null
                        : () {
                            friendRequestsCubit.rejectFriendRequest(
                              request.friendshipId,
                              otherUserId,
                            );
                          },
                    duration: const Duration(milliseconds: 100),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cancel,
                        color: AppColors.error,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

