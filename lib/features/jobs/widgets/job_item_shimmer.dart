import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constant/app_colors.dart';

class JobItemShimmer extends StatelessWidget {
  const JobItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.18),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo shimmer
                Shimmer.fromColors(
                  baseColor: AppColors.surfaceVariant,
                  highlightColor: AppColors.surfaceElevated,
                  child: Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title shimmer
                      Shimmer.fromColors(
                        baseColor: AppColors.surfaceVariant,
                        highlightColor: AppColors.surfaceElevated,
                        child: Container(
                          height: 16.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Company name shimmer
                      Shimmer.fromColors(
                        baseColor: AppColors.surfaceVariant,
                        highlightColor: AppColors.surfaceElevated,
                        child: Container(
                          height: 13.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Location and time shimmer
                      Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: AppColors.surfaceVariant,
                            highlightColor: AppColors.surfaceElevated,
                            child: Container(
                              height: 12.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Shimmer.fromColors(
                            baseColor: AppColors.surfaceVariant,
                            highlightColor: AppColors.surfaceElevated,
                            child: Container(
                              height: 12.h,
                              width: 60.w,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Description shimmer
            Shimmer.fromColors(
              baseColor: AppColors.surfaceVariant,
              highlightColor: AppColors.surfaceElevated,
              child: Container(
                height: 13.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Shimmer.fromColors(
              baseColor: AppColors.surfaceVariant,
              highlightColor: AppColors.surfaceElevated,
              child: Container(
                height: 13.h,
                width: 200.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Tags shimmer
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.surfaceVariant,
                  highlightColor: AppColors.surfaceElevated,
                  child: Container(
                    height: 24.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Shimmer.fromColors(
                  baseColor: AppColors.surfaceVariant,
                  highlightColor: AppColors.surfaceElevated,
                  child: Container(
                    height: 24.h,
                    width: 70.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Shimmer.fromColors(
                  baseColor: AppColors.surfaceVariant,
                  highlightColor: AppColors.surfaceElevated,
                  child: Container(
                    height: 24.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

