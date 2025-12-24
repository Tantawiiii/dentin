import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../cubit/rent_cubit.dart';
import '../cubit/rent_state.dart';
import '../data/models/rent_models.dart';
import 'add_rent_screen.dart';
import 'rent_details_screen.dart';

class RentListScreen extends StatefulWidget {
  const RentListScreen({super.key});

  @override
  State<RentListScreen> createState() => _RentListScreenState();
}

class _RentListScreenState extends State<RentListScreen> {
  late final RentCubit _rentCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _rentCubit = di.sl<RentCubit>();
    _rentCubit.loadRents(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = _rentCubit.state;
      if (state is RentLoaded && state.hasMore) {
        _rentCubit.loadMoreRents();
      }
    }
  }

  void _refreshRents() {
    _rentCubit.loadRents(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _rentCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            AppTexts.rentClinicTitle,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: BlocConsumer<RentCubit, RentState>(
          listener: (context, state) {
            if (state is RentCreated) {
              AppToast.showSuccess(
                AppTexts.rentCreatedSuccessfully,
                context: context,
              );
            } else if (state is RentCreateError) {
              AppToast.showError(state.message, context: context);
            }
          },
          builder: (context, state) {
            if (state is RentLoading) {
              return ListView.builder(
                padding: EdgeInsets.all(12.w),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildRentShimmer();
                },
              );
            }

            if (state is RentError) {
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
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: _refreshRents,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                      child: Text(AppTexts.retry),
                    ),
                  ],
                ),
              );
            }

            final rents = state is RentLoaded ? state.rents : [];
            final isLoadingMore = state is RentLoadingMore;

            return RefreshIndicator(
              onRefresh: () async {
                _refreshRents();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: rents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_center_outlined,
                            size: 64.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            AppTexts.noRentsYet,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            AppTexts.tapToAddFirstRent,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(12.w),
                      itemCount: rents.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == rents.length) {
                          return Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        }
                        return _buildRentItem(rents[index]);
                      },
                    ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: _rentCubit,
                      child: const AddRentScreen(),
                    ),
                  ),
                )
                .then((_) {
                  // Refresh list if needed
                });
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.textOnPrimary),
        ),
      ),
    );
  }

  Widget _buildRentItem(RentItem rent) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: _rentCubit,
                child: RentDetailsScreen(
                  rentId: rent.id,
                  rentCubit: _rentCubit,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            if (rent.gallery.isNotEmpty)
              SizedBox(
                height: 200.h,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: rent.gallery.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: rent.gallery[index].fullUrl,
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => ShimmerPlaceholder(
                              width: double.infinity,
                              height: 200.h,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceVariant,
                              child: Icon(
                                Icons.broken_image,
                                size: 48.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (rent.gallery.length > 1)
                      Positioned(
                        bottom: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${rent.gallery.length} ${AppTexts.rentGallery}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.business_center_outlined,
                    size: 48.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rent.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '\$${rent.price}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.calendar_today,
                        size: 18.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${rent.duration} ${AppTexts.rentDays}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (rent.address != null || rent.city != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            rent.address ?? rent.city ?? '',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Text(
                    rent.des,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentShimmer() {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerPlaceholder(width: double.infinity, height: 200.h),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerPlaceholder(width: double.infinity, height: 20.h),
                SizedBox(height: 8.h),
                ShimmerPlaceholder(width: 150.w, height: 16.h),
                SizedBox(height: 8.h),
                ShimmerPlaceholder(width: double.infinity, height: 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
