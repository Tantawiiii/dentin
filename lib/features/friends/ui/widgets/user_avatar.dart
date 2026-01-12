import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import 'avatar_fallback.dart';

class UserAvatar extends StatelessWidget {
  final int userId;
  final String userName;
  final String? userImage;

  const UserAvatar({
    super.key,
    required this.userId,
    required this.userName,
    this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.profile, arguments: userId);
      },
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: userImage != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: userImage!,
                  width: 56.w,
                  height: 56.w,
                  fit: BoxFit.cover,
                  memCacheWidth: 112,
                  memCacheHeight: 112,
                  placeholder: (_, __) => ShimmerPlaceholder(
                    width: 56.w,
                    height: 56.w,
                    shape: BoxShape.circle,
                  ),
                  errorWidget: (_, __, ___) =>
                      AvatarFallback(userName: userName),
                ),
              )
            : AvatarFallback(userName: userName),
      ),
    );
  }
}

