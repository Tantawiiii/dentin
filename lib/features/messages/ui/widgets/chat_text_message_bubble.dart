import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../data/models/chat_message_model.dart';

class ChatTextMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String Function(String?) formatTime;

  const ChatTextMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
          bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
          bottomRight: Radius.circular(isMe ? 4.r : 16.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.body,
            style: TextStyle(
              fontSize: 14.sp,
              color: isMe ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatTime(message.createdAt),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isMe ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              if (isMe) ...[
                SizedBox(width: 4.w),
                Icon(
                  message.isRead == true ? Icons.done_all : Icons.done,
                  size: 14.sp,
                  color: message.isRead == true
                      ? Colors.blue.shade300
                      : Colors.white70,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

