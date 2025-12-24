import 'package:bounce/bounce.dart';
import 'package:dentin/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/shimmer_placeholder.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<SliderDrawerState>? sliderDrawerKey;

  const CustomAppBar({super.key, this.sliderDrawerKey});

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
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                color: AppColors.primary,
                onPressed: () {
                  sliderDrawerKey?.currentState?.openSlider();
                },
              ),
              Image.asset(
                AppAssets.appLogoBlueHeaderImg,
                fit: BoxFit.cover,
                height: 52.h,
                width: 140.w,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.primary,
                    onPressed: () {},
                  ),
                  SizedBox(width: 2.w),
                  Bounce(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.profile);
                    },
                    child: Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
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
                                errorWidget: (context, url, error) => Container(
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
