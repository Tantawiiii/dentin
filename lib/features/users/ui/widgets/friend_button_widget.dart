import 'package:flutter/material.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../friends/data/models/friend_request_model.dart';
import 'user_action_button.dart';

class FriendButtonWidget extends StatelessWidget {
  final FriendRequestStatus friendStatus;
  final VoidCallback onTap;

  const FriendButtonWidget({
    super.key,
    required this.friendStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (friendStatus) {
      case FriendRequestStatus.none:
        return UserActionButton(
          icon: Icons.person_add,
          label: AppTexts.add,
          onTap: onTap,
          color: AppColors.primary,
        );
      case FriendRequestStatus.pending:
        return UserActionButton(
          icon: Icons.schedule,
          label: AppTexts.pending,
          onTap: onTap,
          color: AppColors.warning,
          isDisabled: true,
        );
      case FriendRequestStatus.friends:
        return UserActionButton(
          icon: Icons.person_remove,
          label: AppTexts.remove,
          onTap: onTap,
          color: AppColors.error,
        );
      default:
        return UserActionButton(
          icon: Icons.person_add,
          label: AppTexts.add,
          onTap: onTap,
          color: AppColors.primary,
        );
    }
  }
}

