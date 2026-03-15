import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/services/storage_service.dart';

class HomeDrawer extends StatelessWidget {
  final GlobalKey<SliderDrawerState> sliderDrawerKey;
  final Function(int)? onTabChange;

  const HomeDrawer({
    super.key,
    required this.sliderDrawerKey,
    this.onTabChange,
  });

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
              padding: EdgeInsets.all(14),
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
                  ListTile(
                    leading: Icon(
                      Icons.home_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.home,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      onTabChange?.call(0);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.work_outline, color: AppColors.primary),
                    title: Text(
                      AppTexts.jobs,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      onTabChange?.call(1);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.explore_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.exploreStories,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      onTabChange?.call(2);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.store_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.store,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      onTabChange?.call(3);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.business_outlined,
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
                      onTabChange?.call(4);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.message_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.messages,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      onTabChange?.call(5);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.events,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      Navigator.of(context).pushNamed(AppRoutes.events);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.person_add_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.friendRequests,
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
                      AppTexts.medicalProfessionals,
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
                  ListTile(
                    leading: Icon(
                      Icons.bookmark_outline,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.savedPosts,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      Navigator.of(context).pushNamed(AppRoutes.savedPosts);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.visibility_off_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      AppTexts.hiddenPosts,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      sliderDrawerKey.currentState?.closeSlider();
                      Navigator.of(context).pushNamed(AppRoutes.hiddenPosts);
                    },
                  ),

                  SizedBox(height: 14.h),

                  // ── DEBUG only: Push Notification Checker ──────────────────
                  if (kDebugMode)
                    ListTile(
                      leading: Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.deepOrange,
                      ),
                      title: Text(
                        'Test Push Notification',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                      ),
                      onTap: () async {
                        sliderDrawerKey.currentState?.closeSlider();
                        await _showPushDiagnosticsDialog(context);
                      },
                    ),
                  // ───────────────────────────────────────────────────────────

                  SizedBox(height: 14.h),
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
                  SizedBox(height: 14.h),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ─── Push Diagnostics Dialog ─────────────────────────────────────────────────
  Future<void> _showPushDiagnosticsDialog(BuildContext context) async {
    final storageService = di.sl<StorageService>();
    final fcmService = di.sl<FCMService>();

    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final status = await fcmService.checkNotificationStatus(storageService);

    if (!context.mounted) return;
    Navigator.of(context).pop();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              title: Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.deepOrange, size: 22.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Push Notification Check',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _diagRow('📱 Platform', status['platform'] ?? '-'),
                    _diagRow(
                      '🔐 Permission',
                      status['permission'] ?? '-',
                      good: status['permission'] == 'authorized',
                      bad: status['permission'] == 'denied',
                    ),
                    _diagRow(
                      '🔑 FCM Token',
                      status['has_token'] == 'true' ? '✅ Present' : '❌ Missing',
                      good: status['has_token'] == 'true',
                      bad: status['has_token'] != 'true',
                    ),
                    if (status['token_preview'] != null &&
                        status['token_preview'] != 'none')
                      Padding(
                        padding: EdgeInsets.only(left: 16.w, bottom: 6.h),
                        child: Text(
                          status['token_preview']!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    _diagRow(
                      '☁️ Saved in DB',
                      status['token_in_db'] ?? '-',
                      good: status['token_in_db']?.startsWith('true') == true,
                      bad: status['token_in_db']?.startsWith('false') == true,
                    ),
                    SizedBox(height: 10.h),
                    const Divider(),
                    SizedBox(height: 6.h),
                    Text(
                      'Tap the button below to fire a real end-to-end test.\n'
                      'The Cloud Function will push a notification to THIS device.',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Close', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.send, size: 16.sp),
                  label: Text('Send Test', style: TextStyle(fontSize: 13.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final sent = await fcmService.sendSelfTestNotification(storageService);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: sent ? Colors.green : Colors.red,
                        content: Text(
                          sent
                              ? '✅ Test notification sent! Watch for the push.'
                              : '❌ Failed – check logs (token missing or DB error)',
                          style: const TextStyle(color: Colors.white),
                        ),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _diagRow(String label, String value, {bool good = false, bool bad = false}) {
    Color valueColor = AppColors.textPrimary;
    if (good) valueColor = Colors.green;
    if (bad) valueColor = Colors.red;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, color: valueColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

