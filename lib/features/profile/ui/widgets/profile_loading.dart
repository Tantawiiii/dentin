import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';

class ProfileLoading extends StatelessWidget {
  const ProfileLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 260.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ShimmerPlaceholder(
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.35),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const ShimmerPlaceholder(
                          width: 32,
                          height: 32,
                          shape: BoxShape.circle,
                        ),
                        ShimmerPlaceholder(
                          width: 110.w,
                          height: 32.h,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ],
                    ),
                  ),
                ),
                // Avatar + name placeholders
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.w, bottom: 16.h),
                    child: Row(
                      children: [
                        const ShimmerPlaceholder(
                          width: 68,
                          height: 68,
                          shape: BoxShape.circle,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerPlaceholder(
                                width: 160.w,
                                height: 16.h,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              SizedBox(height: 8.h),
                              ShimmerPlaceholder(
                                width: 110.w,
                                height: 12.h,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 144.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ShimmerPlaceholder(
                          height: 56.h,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: ShimmerPlaceholder(
                          height: 56.h,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: ShimmerPlaceholder(
                          height: 56.h,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 4.h),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ShimmerPlaceholder(
                          height: 32.h,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ShimmerPlaceholder(
                          height: 32.h,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ShimmerPlaceholder(
                            width: 36,
                            height: 36,
                            shape: BoxShape.circle,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerPlaceholder(
                                  width: 120.w,
                                  height: 12.h,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                SizedBox(height: 6.h),
                                ShimmerPlaceholder(
                                  width: 80.w,
                                  height: 10.h,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ShimmerPlaceholder(
                        width: double.infinity,
                        height: 10.h,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      SizedBox(height: 6.h),
                      ShimmerPlaceholder(
                        width: double.infinity,
                        height: 10.h,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      SizedBox(height: 6.h),
                      ShimmerPlaceholder(
                        width: 180.w,
                        height: 10.h,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      SizedBox(height: 10.h),
                      ShimmerPlaceholder(
                        width: double.infinity,
                        height: 140.h,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
