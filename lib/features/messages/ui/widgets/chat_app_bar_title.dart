import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../cubit/chat_cubit.dart';
import '../../cubit/chat_state.dart';
import '../../data/models/chat_user_model.dart';

class ChatAppBarTitle extends StatelessWidget {
  final ChatUser receiverUser;
  final ChatCubit chatCubit;

  const ChatAppBarTitle({
    super.key,
    required this.receiverUser,
    required this.chatCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: AppColors.primary,
          backgroundImage: receiverUser.profileImage != null
              ? CachedNetworkImageProvider(receiverUser.profileImage!)
              : null,
          child: receiverUser.profileImage == null
              ? Text(
                  receiverUser.userName.isNotEmpty
                      ? receiverUser.userName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                receiverUser.userName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              BlocBuilder<ChatCubit, ChatState>(
                bloc: chatCubit,
                buildWhen: (previous, current) {
                  return previous != current;
                },
                builder: (context, state) {
                  final isTyping = chatCubit.isTyping;
                  return Text(
                    isTyping ? 'Typing...' : 'Online',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

