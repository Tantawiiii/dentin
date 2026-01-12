import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../cubit/friend_requests_cubit.dart';
import '../../cubit/friend_requests_state.dart';

class IncomingTabBadge extends StatelessWidget {
  final FriendRequestsCubit friendRequestsCubit;

  const IncomingTabBadge({
    super.key,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
      bloc: friendRequestsCubit,
      buildWhen: (previous, current) {
        if (current is FriendRequestsLoaded) {
          return previous != current;
        }
        return false;
      },
      builder: (context, state) {
        if (state is FriendRequestsLoaded) {
          final count = state.incomingRequests.length;
          if (count > 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppTexts.incoming),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }
        }
        return Text(AppTexts.incoming);
      },
    );
  }
}

