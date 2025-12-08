import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constant/app_colors.dart';
import '../../../../../core/constant/app_texts.dart';

class LoginSegmentedControl extends StatelessWidget {
  const LoginSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.3),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Bounce(
              onTap: () => onIndexChanged(0),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? AppColors.primary
                      : AppColors.textOnPrimary,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  AppTexts.email,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex == 0
                        ? AppColors.background
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Bounce(
              onTap: () => onIndexChanged(1),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? AppColors.primary
                      : AppColors.textOnPrimary,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  AppTexts.mobile,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex == 1
                        ? AppColors.background
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
