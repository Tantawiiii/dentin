import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';

class ChatImageMessageWidget extends StatelessWidget {
  final String imageUrl;

  const ChatImageMessageWidget({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      constraints: BoxConstraints(maxWidth: 200.w, maxHeight: 200.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          memCacheWidth: 400,
          memCacheHeight: 400,
          maxWidthDiskCache: 800,
          maxHeightDiskCache: 800,
          placeholder: (context, url) => Container(
            color: AppColors.surfaceVariant,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          errorWidget: (context, url, error) =>
              Icon(Icons.error, color: AppColors.error),
        ),
      ),
    );
  }
}

