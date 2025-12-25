import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';

class ChatQuickRepliesBar extends StatelessWidget {
  final List<String> quickReplies;
  final void Function(String) onReplyTap;

  const ChatQuickRepliesBar({
    super.key,
    required this.quickReplies,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SizedBox(
        height: 40.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          cacheExtent: 200,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemCount: quickReplies.length,
          itemBuilder: (context, index) {
            return RepaintBoundary(
              key: ValueKey('quick_reply_$index'),
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: InkWell(
                  onTap: () => onReplyTap(quickReplies[index]),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      quickReplies[index],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

