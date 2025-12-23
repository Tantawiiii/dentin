import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constant/app_colors.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape? shape;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surfaceElevated,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: borderRadius,
          shape: shape ?? BoxShape.rectangle,
        ),
      ),
    );
  }
}

