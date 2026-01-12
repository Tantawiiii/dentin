import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../core/services/storage_service.dart';

class HomeDrawer extends StatelessWidget {
  final GlobalKey<SliderDrawerState> sliderDrawerKey;

  const HomeDrawer({super.key, required this.sliderDrawerKey});

  @override
  Widget build(BuildContext context) {
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (userData?.profileImage != null)
                        CircleAvatar(
                          radius: 40.r,
                          backgroundImage: NetworkImage(
                            userData!.profileImage!,
                          ),
                        )
                      else
                        CircleAvatar(
                          radius: 40.r,
                          backgroundColor: AppColors.surface,
                          child: Icon(
                            Icons.person,
                            size: 40.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      SizedBox(height: 16.h),
                      Text(
                        '${userData?.firstName ?? ''} ${userData?.lastName ?? ''}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (userData != null && userData.email.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          userData.email,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 24.sp,
                      ),
                      onPressed: () {
                        sliderDrawerKey.currentState?.closeSlider();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person_2_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.myProfile,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      Navigator.of(context).pushNamed(AppRoutes.profile);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.business_center_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.rentClinic,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      Navigator.of(context).pushNamed(AppRoutes.rentClinic);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.person_add_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Friend Requests',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      Navigator.of(context).pushNamed(AppRoutes.friendRequests);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.people_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Medical Professionals',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      Navigator.of(context).pushNamed(AppRoutes.usersList);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.error),
              title: Text(
                AppTexts.logout,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              onTap: () async {
                sliderDrawerKey.currentState?.closeSlider();
                final storageService = di.sl<StorageService>();
                await storageService.clearAll();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                }
              },
            ),
            SizedBox(height: 44.h),
          ],
        ),
      ),
    );
  }
}
