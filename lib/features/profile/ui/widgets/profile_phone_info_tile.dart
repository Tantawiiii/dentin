import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';

class ProfilePhoneInfoTile extends StatelessWidget {
  final String phone;
  final bool isHidden;
  final bool isOwnProfile;
  final bool isToggling;
  final VoidCallback onToggle;

  const ProfilePhoneInfoTile({
    super.key,
    required this.phone,
    required this.isHidden,
    required this.isOwnProfile,
    required this.isToggling,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.phone_outlined, size: 18.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppTexts.profilePhone,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  isHidden && !isOwnProfile ? AppTexts.hidden : phone,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isHidden && !isOwnProfile
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (isOwnProfile) ...[
            SizedBox(width: 8.w),
            if (isToggling)
              SizedBox(
                width: 12.w,
                height: 12.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              )
            else
              Bounce(
                onTap: onToggle,
                child: Icon(
                  isHidden ? Icons.visibility_off : Icons.visibility,
                  size: 24.sp,
                  color: isHidden
                      ? AppColors.textSecondary
                      : AppColors.primary,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
