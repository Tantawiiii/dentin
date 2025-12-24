import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/rent_cubit.dart';
import '../cubit/rent_state.dart';
import 'contact_seller_screen.dart';

class RentDetailsScreen extends StatefulWidget {
  final int rentId;
  final RentCubit? rentCubit;

  const RentDetailsScreen({
    super.key,
    required this.rentId,
    this.rentCubit,
  });

  @override
  State<RentDetailsScreen> createState() => _RentDetailsScreenState();
}

class _RentDetailsScreenState extends State<RentDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  late final RentCubit _rentCubit;
  bool _shouldCloseCubit = false;

  @override
  void initState() {
    super.initState();
    // Use provided cubit or create new one
    if (widget.rentCubit != null) {
      _rentCubit = widget.rentCubit!;
      _shouldCloseCubit = false;
    } else {
      _rentCubit = di.sl<RentCubit>();
      _shouldCloseCubit = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _rentCubit.loadRentDetails(widget.rentId);
      }
    });
  }

  @override
  void dispose() {
    // Only close if we created it
    if (_shouldCloseCubit) {
      _rentCubit.close();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _rentCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            AppTexts.rentDetails,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: BlocBuilder<RentCubit, RentState>(
        builder: (context, state) {
          if (state is RentDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RentDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is RentDetailsLoaded) {
            final rent = state.rent;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Slider
                  if (rent.gallery.isNotEmpty) ...[
                    SizedBox(
                      height: 300.h,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemCount: rent.gallery.length,
                            itemBuilder: (context, index) {
                              return CachedNetworkImage(
                                imageUrl: rent.gallery[index].fullUrl,
                                width: double.infinity,
                                height: 300.h,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => ShimmerPlaceholder(
                                  width: double.infinity,
                                  height: 300.h,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.surfaceVariant,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 48.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (rent.gallery.length > 1)
                            Positioned(
                              bottom: 16.h,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  rent.gallery.length,
                                  (index) => Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                                    width: _currentImageIndex == index ? 24.w : 8.w,
                                    height: 8.h,
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex == index
                                          ? AppColors.primary
                                          : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ] else
                    Container(
                      height: 300.h,
                      color: AppColors.surfaceVariant,
                      child: Center(
                        child: Icon(
                          Icons.business_center_outlined,
                          size: 64.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                rent.name,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '\$${rent.price}',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // Description
                        Text(
                          rent.des,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // Product Details
                        Text(
                          AppTexts.productDetails,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailRow(
                          AppTexts.rentName,
                          rent.name,
                        ),
                        _buildDetailRow(
                          AppTexts.rentPrice,
                          '\$${rent.price}',
                        ),
                        _buildDetailRow(
                          AppTexts.rentDuration,
                          '${rent.duration} ${AppTexts.rentDays}',
                        ),
                        _buildDetailRow(
                          AppTexts.rentType,
                          rent.type,
                        ),
                        if (rent.startDate != null)
                          _buildDetailRow(
                            AppTexts.rentStartDate,
                            rent.startDate!,
                          ),
                        if (rent.endDate != null)
                          _buildDetailRow(
                            AppTexts.rentEndDate,
                            rent.endDate!,
                          ),
                        if (rent.governorate != null)
                          _buildDetailRow(
                            AppTexts.rentGovernorate,
                            rent.governorate!,
                          ),
                        if (rent.city != null)
                          _buildDetailRow(
                            AppTexts.rentCity,
                            rent.city!,
                          ),
                        if (rent.address != null)
                          _buildDetailRow(
                            AppTexts.rentAddress,
                            rent.address!,
                          ),
                        SizedBox(height: 24.h),
                        // Seller Info
                        Text(
                          AppTexts.rentSeller,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30.r,
                              backgroundImage: rent.user.profileImage != null
                                  ? NetworkImage(rent.user.profileImage!)
                                  : null,
                              backgroundColor: AppColors.surfaceVariant,
                              child: rent.user.profileImage == null
                                  ? Icon(
                                      Icons.person,
                                      size: 30.sp,
                                      color: AppColors.textSecondary,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rent.user.userName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${AppTexts.profileJoined} ${rent.user.createdAt.split(' ')[0]}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        // Contact Seller Button
                        PrimaryButton(
                          title: AppTexts.contactSeller,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: _rentCubit,
                                  child: ContactSellerScreen(rent: rent),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

