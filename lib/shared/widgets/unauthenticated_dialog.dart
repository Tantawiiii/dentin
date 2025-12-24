import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/di/inject.dart' as di;
import '../../core/routing/app_routes.dart';
import '../../core/services/storage_service.dart';
import 'app_toast.dart';
import 'primary_button.dart';

class UnauthenticatedDialog {
  static bool _isShowing = false;

  /// Show unauthenticated dialog
  static Future<void> show() async {
    // Prevent multiple dialogs
    if (_isShowing) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    _isShowing = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UnauthenticatedDialogWidget(),
    );

    _isShowing = false;
  }
}

class _UnauthenticatedDialogWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container with gradient
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.error,
                    AppColors.errorLight,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textOnPrimary,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              AppTexts.sessionExpired,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Message
            Text(
              AppTexts.sessionExpiredMessage,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Login Button
            PrimaryButton(
              title: AppTexts.goToLogin,
              onPressed: () async {
                // Clear storage
                final storageService = di.sl<StorageService>();
                await storageService.clearAll();

                // Close dialog
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                // Navigate to login
                final navigatorContext = navigatorKey.currentContext;
                if (navigatorContext != null) {
                  Navigator.of(navigatorContext).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


