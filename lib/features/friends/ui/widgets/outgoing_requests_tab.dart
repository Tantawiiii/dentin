import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../cubit/friend_requests_cubit.dart';
import '../../data/models/friend_request_model.dart';
import 'outgoing_request_item.dart';

class OutgoingRequestsTab extends StatelessWidget {
  final List<FriendRequest> requests;
  final bool isLoading;
  final int? currentUserId;
  final String Function(int) formatTime;
  final FriendRequestsCubit friendRequestsCubit;

  const OutgoingRequestsTab({
    super.key,
    required this.requests,
    required this.isLoading,
    required this.currentUserId,
    required this.formatTime,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 80.sp,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              AppTexts.noOutgoingRequests,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      physics: const BouncingScrollPhysics(),
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return OutgoingRequestItem(
          key: ValueKey('outgoing_${request.friendshipId}'),
          request: request,
          isLoading: isLoading,
          currentUserId: currentUserId!,
          formatTime: formatTime,
          friendRequestsCubit: friendRequestsCubit,
        );
      },
    );
  }
}

