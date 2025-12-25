import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../cubit/chat_state.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final bool isUploading;
  final bool showEmojis;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onEmojiToggle;
  final ChatState state;

  const ChatInputArea({
    super.key,
    required this.messageController,
    required this.isUploading,
    required this.showEmojis,
    required this.onSend,
    required this.onAttach,
    required this.onEmojiToggle,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: isUploading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.attach_file,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
              onPressed: isUploading ? null : onAttach,
            ),
            IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: AppColors.primary,
                size: 24.sp,
              ),
              onPressed: onEmojiToggle,
            ),
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
                onPressed: state is MessageSending ? null : onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

