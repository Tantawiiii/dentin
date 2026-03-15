import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../shared/widgets/app_toast.dart';
import '../data/models/post_models.dart';

class SharePostDialog extends StatelessWidget {
  final Post post;

  const SharePostDialog({super.key, required this.post});

  String _getPostUrl() {
    return 'https://back.dentin.cloud/posts/${post.id}';
  }

  Future<void> _shareOnWhatsApp(BuildContext context) async {
    try {
      final url = 'whatsapp://send?text=${Uri.encodeComponent(_getPostUrl())}';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        final webUrl =
            'https://wa.me/?text=${Uri.encodeComponent(_getPostUrl())}';
        final webUri = Uri.parse(webUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          if (context.mounted) {
            AppToast.showInfo('WhatsApp is not installed', context: context);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(
          'Failed to share: ${e.toString()}',
          context: context,
        );
      }
    }
  }

  Future<void> _shareToProfile(BuildContext context) async {
    // TODO: Implement share to profile functionality
    if (context.mounted) {
      Navigator.of(context).pop();
      AppToast.showInfo('Feature coming soon', context: context);
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    try {
      final url = _getPostUrl();
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        Navigator.of(context).pop();
        AppToast.showSuccess('Link copied to clipboard', context: context);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(
          'Failed to copy link: ${e.toString()}',
          context: context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.shareThisPost,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppTexts.chooseHowToShare,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildShareOption(
              context: context,
              icon: Icons.chat,
              iconColor: const Color(0xFF25D366), // WhatsApp green
              backgroundColor: const Color(0xFF25D366).withOpacity(0.1),
              title: AppTexts.shareOnWhatsApp,
              subtitle: AppTexts.shareWithContacts,
              titleColor: const Color(0xFF25D366),
              subtitleColor: const Color(0xFF25D366).withOpacity(0.7),
              onTap: () => _shareOnWhatsApp(context),
            ),
            SizedBox(height: 12.h),
            _buildShareOption(
              context: context,
              icon: Icons.arrow_upward,
              iconColor: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              title: AppTexts.shareToProfile,
              subtitle: AppTexts.postToTimeline,
              titleColor: AppColors.primary,
              subtitleColor: AppColors.primary.withOpacity(0.7),
              onTap: () => _shareToProfile(context),
            ),
            SizedBox(height: 12.h),
            _buildShareOption(
              context: context,
              icon: Icons.copy,
              iconColor: AppColors.textSecondary,
              backgroundColor: AppColors.surfaceVariant,
              title: AppTexts.copyLink,
              subtitle: AppTexts.copyPostLinkToClipboard,
              titleColor: AppColors.textPrimary,
              subtitleColor: AppColors.textSecondary,
              onTap: () => _copyLink(context),
            ),
            SizedBox(height: 24.h),
            Bounce(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    AppTexts.cancel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required Color titleColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return Bounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconColor,
                shape: icon == Icons.chat
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: icon == Icons.chat
                    ? null
                    : BorderRadius.circular(12.r),
              ),
              child: icon == Icons.chat
                  ? Center(
                      child: Text(
                        'WA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: subtitleColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
