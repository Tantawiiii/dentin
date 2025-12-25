import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';

class ChatEmojiPicker extends StatelessWidget {
  final List<String> emojis;
  final void Function(String) onEmojiTap;

  const ChatEmojiPicker({
    super.key,
    required this.emojis,
    required this.onEmojiTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: emojis.map((emoji) {
          return InkWell(
            onTap: () => onEmojiTap(emoji),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Text(emoji, style: TextStyle(fontSize: 24.sp)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

