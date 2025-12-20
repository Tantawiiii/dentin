import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';

class ExploreStoriesScreen extends StatefulWidget {
  const ExploreStoriesScreen({super.key});

  @override
  State<ExploreStoriesScreen> createState() => _ExploreStoriesScreenState();
}

class _ExploreStoriesScreenState extends State<ExploreStoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Stories'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Explore Stories',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

