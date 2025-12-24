import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../shared/widgets/shimmer_placeholder.dart';
import '../../shared/widgets/primary_button.dart';
import '../../core/di/inject.dart' as di;
import 'data/models/product_models.dart';
import 'data/repo/product_repository.dart';
import 'widgets/send_message_dialog.dart';
import 'widgets/product_details_shimmer.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductRepository _productRepository = di.sl<ProductRepository>();

  Product? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _productRepository.getProductDetails(
        widget.productId,
      );
      setState(() {
        _product = response.data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_product?.name ?? AppTexts.productDetailsTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ProductDetailsShimmer();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.error, fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              PrimaryButton(title: AppTexts.retry, onPressed: _loadProduct),
            ],
          ),
        ),
      );
    }

    if (_product == null) {
      return const SizedBox.shrink();
    }

    final product = _product!;
    final images = product.gallery;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty)
            SizedBox(
              height: 260.h,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final gallery = images[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CachedNetworkImage(
                        imageUrl: gallery.fullUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => ShimmerPlaceholder(
                          width: double.infinity,
                          height: 260.h,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.error,
                            size: 40.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.image,
                size: 64.sp,
                color: AppColors.textSecondary,
              ),
            ),
          SizedBox(height: 20.h),
          Text(
            product.name,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '${product.price} EGP',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 8.w),
              if (product.discount > 0)
                Text(
                  '${product.discount} EGP',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Price after discount: ${product.priceAfterDiscount} EGP',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 12.h),
          if (product.isNew)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_new, size: 16.sp, color: AppColors.success),
                  SizedBox(width: 4.w),
                  Text(
                    AppTexts.productNewBadge,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20.h),
          Text(
            AppTexts.productDescription,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            product.description?.isNotEmpty == true
                ? product.description!
                : AppTexts.productNoDescription,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 20.h),
          Text(
            AppTexts.productSeller,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: CachedNetworkImage(
                  imageUrl: product.user.profileImage,
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ShimmerPlaceholder(
                    width: 40.w,
                    height: 40.w,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40.w,
                    height: 40.w,
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      size: 24.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.user.userName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${AppTexts.productJoinedAtPrefix}${product.user.createdAt}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          PrimaryButton(
            title: AppTexts.sendMessageToSeller,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SendMessageDialog(product: product),
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
