import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../cubit/friend_requests_cubit.dart';
import '../../data/models/friend_request_model.dart';
import 'user_avatar.dart';

class FriendItem extends StatelessWidget {
  final FriendRequest friend;
  final bool isLoading;
  final int currentUserId;
  final void Function(int, String, String?) onChatTap;
  final FriendRequestsCubit friendRequestsCubit;

  const FriendItem({
    super.key,
    required this.friend,
    required this.isLoading,
    required this.currentUserId,
    required this.onChatTap,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserId = friend.getOtherUserId(currentUserId);
    final otherUserName = friend.getOtherUserName(currentUserId);
    final otherUserImage = friend.getOtherUserImage(currentUserId);

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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChatTap(otherUserId, otherUserName, otherUserImage),
            borderRadius: BorderRadius.circular(16.r),
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
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                AppTexts.friends,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Bounce(
                        onTap: () => onChatTap(
                          otherUserId,
                          otherUserName,
                          otherUserImage,
                        ),
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.message,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Bounce(
                        onTap: isLoading
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    title: Text(
                                      AppTexts.removeFriend,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      '${AppTexts.removeFriendConfirmation} $otherUserName ${AppTexts.removeFriendFromFriends}',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(AppTexts.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          friendRequestsCubit.removeFriend(
                                            friend.friendshipId,
                                            otherUserId,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                        ),
                                        child: Text(
                                          AppTexts.removeFriendButton,
                                        ),
                                      ),
                                    ],
                                  ),
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
                            Icons.person_remove,
                            color: AppColors.error,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

