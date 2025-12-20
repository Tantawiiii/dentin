import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constant/app_colors.dart';

class AppToast {
  AppToast._();

  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  /// Show success toast with check icon
  static void showSuccess(String message, {BuildContext? context}) {
    _showToastWithIcon(
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
      context: context,
    );
  }

  /// Show error toast with error icon
  static void showError(String message, {BuildContext? context}) {
    _showToastWithIcon(
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error,
      context: context,
    );
  }

  /// Show warning toast with warning icon
  static void showWarning(String message, {BuildContext? context}) {
    _showToastWithIcon(
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning,
      context: context,
    );
  }

  /// Show info toast with info icon
  static void showInfo(String message, {BuildContext? context}) {
    _showToastWithIcon(
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info,
      context: context,
    );
  }

  static void _showToastWithIcon({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    BuildContext? context,
  }) {
    // Hide previous toast if visible
    _hideToast();

    // Try to get overlay from context or navigator
    OverlayState? overlayState;

    if (context != null) {
      overlayState = Overlay.of(context);
    } else {
      // Try to get from navigator key if available
      final navigatorContext = navigatorKey.currentContext;
      if (navigatorContext != null) {
        overlayState = Overlay.of(navigatorContext);
      }
    }

    if (overlayState == null) {
      // If no overlay available, just return (shouldn't happen in normal flow)
      return;
    }

    _isVisible = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
      ),
    );

    overlayState.insert(_overlayEntry!);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _hideToast();
    });
  }

  static void _hideToast() {
    if (_isVisible && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isVisible = false;
    }
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50.h,
      left: 20.w,
      right: 20.w,
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.textOnPrimary, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Global navigator key for toast (should be set in main.dart)
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
