import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
  });

  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return Bounce(
      onTap: isEnabled ? onPressed : null,
      duration: const Duration(milliseconds: 120),
      child: Container(
        height: 56.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.surface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isEnabled
                ? AppColors.border
                : AppColors.border.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && iconPosition == IconPosition.leading) ...[
                    Icon(
                      icon,
                      size: 20.sp,
                      color: isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      color: isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (icon != null &&
                      iconPosition == IconPosition.trailing) ...[
                    SizedBox(width: 8.w),
                    Icon(
                      icon,
                      size: 20.sp,
                      color: isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

enum IconPosition { leading, trailing }

