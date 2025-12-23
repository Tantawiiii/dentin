import 'package:dentin/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/shimmer_placeholder.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                AppAssets.appLogoBlueHeaderImg,
                fit: BoxFit.cover,
                height: 52.h,
                width: 120.w,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.primary,
                    onPressed: () {},
                  ),
                  SizedBox(width: 4.w),
                  PopupMenuButton<String>(
                    offset: Offset(0, 56.h),
                    child: Row(
                      children: [
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28.r),
                            child: userData?.profileImage != null
                                ? CachedNetworkImage(
                                    imageUrl: userData!.profileImage!,
                                    width: 56.w,
                                    height: 56.w,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        ShimmerPlaceholder(
                                          width: 56.w,
                                          height: 56.w,
                                          shape: BoxShape.circle,
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          width: 56.w,
                                          height: 56.w,
                                          color: AppColors.surface,
                                          child: Icon(
                                            Icons.person,
                                            size: 28.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                  )
                                : Container(
                                    width: 56.w,
                                    height: 56.w,
                                    color: AppColors.surface,
                                    child: Icon(
                                      Icons.person,
                                      size: 28.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'My-Profile',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_2_outlined,
                              size: 20.sp,
                              color: AppColors.primaryDark,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'My Profile',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 20.sp,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 12.w),
                            Text('Logout', style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await storageService.clearAll();
                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRoutes.login);
                        }
                      } else if (value == "My-Profile") {
                        if (context.mounted) {
                          Navigator.of(context).pushNamed(AppRoutes.profile);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
