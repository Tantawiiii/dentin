import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../data/onboarding_page_data.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final int pageIndex;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w,),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 88.h),
            Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                gradient: data.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                size: 100.sp,
                color: AppColors.textOnPrimary,
              ),
            ),
            SizedBox(height: 68.h),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}







