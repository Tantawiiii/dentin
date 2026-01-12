import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../data/models/product_models.dart';

class ProductItemWidget extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final int index;

  const ProductItemWidget({
    super.key,
    required this.product,
    required this.onTap,
    required this.index,
  });

  @override
  State<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends State<ProductItemWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galleryUrls = widget.product.gallery
        .map((gallery) => gallery.fullUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: Bounce(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight.withOpacity(0.18),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 180.h,
                  child: galleryUrls.isNotEmpty
                      ? Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemCount: galleryUrls.length,
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: galleryUrls[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      ShimmerPlaceholder(
                                        width: double.infinity,
                                        height: 180.h,
                                        borderRadius: BorderRadius.zero,
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: AppColors.surfaceVariant,
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          size: 32.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                );
                              },
                            ),
                            if (galleryUrls.length > 1)
                              Positioned(
                                bottom: 8.h,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    galleryUrls.length,
                                    (index) => Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                      ),
                                      width: _currentPage == index ? 24.w : 8.w,
                                      height: 8.h,
                                      decoration: BoxDecoration(
                                        color: _currentPage == index
                                            ? AppColors.primary
                                            : AppColors.textSecondary
                                                  .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.image,
                            size: 32.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        if (widget.product.isNew)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fiber_new,
                                  size: 13.sp,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'New',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    if (widget.product.description?.isNotEmpty == true)
                      Text(
                        widget.product.description!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${widget.product.price} EGP',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        if (widget.product.discount > 0)
                          Text(
                            '${widget.product.discount} EGP',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          size: 28.sp,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
