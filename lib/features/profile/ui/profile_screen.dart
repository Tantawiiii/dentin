import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart' as profile_state;

import '../data/repo/profile_repository.dart';
import 'edit_profile_screen.dart';
import 'widgets/profile_about_tab.dart';
import 'widgets/profile_loading.dart';
import 'widgets/profile_posts_tab.dart';
import 'widgets/profile_stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(di.sl<ProfileRepository>())..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<ProfileCubit, profile_state.ProfileState>(
          builder: (context, state) {
            if (state is profile_state.ProfileLoading ||
                state is profile_state.ProfileInitial) {
              return ProfileLoading();
            } else if (state is profile_state.ProfileLoaded) {
              return _ProfileContent(loadedState: state);
            } else if (state is profile_state.ProfileError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final profile_state.ProfileLoaded loadedState;

  const _ProfileContent({required this.loadedState});

  @override
  Widget build(BuildContext context) {
    final doctor = loadedState.doctor;
    final friendsCount = loadedState.friendsCount;
    final totalPosts = doctor.posts.length;
    final sponsoredPosts = doctor.posts
        .where((p) => p.isAdRequest)
        .toList()
        .length;
    final regularPosts = totalPosts - sponsoredPosts;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 260.h,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.w, top: 8.h),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfileScreen(doctor: doctor),
                          ),
                        )
                        .then((success) {
                          if (success == true) {
                            // Reload profile after successful update
                            context.read<ProfileCubit>().loadProfile();
                          }
                        });
                  },
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: Text(
                    AppTexts.profileEditProfile,
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'profile-cover',
                    child: doctor.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: doctor.coverImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => ShimmerPlaceholder(
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : Container(color: AppColors.primary),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w, bottom: 16.h),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'profile-avatar',
                            child: Container(
                              width: 68.w,
                              height: 68.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: doctor.profileImage != null
                                    ? CachedNetworkImage(
                                        imageUrl: doctor.profileImage!,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            ShimmerPlaceholder(
                                              width: 80.w,
                                              height: 80.w,
                                              shape: BoxShape.circle,
                                            ),
                                        errorWidget: (_, __, ___) =>
                                            const Icon(Icons.person),
                                      )
                                    : const Icon(Icons.person),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${doctor.firstName} ${doctor.lastName}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 144.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      children: [
                        // Expanded(
                        //   child: ProfileStatItem(
                        //     label: AppTexts.profileTotalPosts,
                        //     value: totalPosts.toString(),
                        //   ),
                        // ),
                        // SizedBox(width: 4.w),
                        Expanded(
                          child: ProfileStatItem(
                            label: AppTexts.profileRegularPosts,
                            value: regularPosts.toString(),
                            valueColor: Colors.green,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: ProfileStatItem(
                            label: AppTexts.profileSponsoredPosts,
                            value: sponsoredPosts.toString(),
                            valueColor: Colors.teal,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: ProfileStatItem(
                            label: AppTexts.profileFriends,
                            value: friendsCount.toString(),
                            valueColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      bottom: 4.h,
                    ),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: [
                        Tab(text: '${AppTexts.profilePostsTab} ($totalPosts)'),
                        const Tab(text: AppTexts.profileAboutTab),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        children: [
          ProfilePostsTab(doctor: doctor),
          ProfileAboutTab(doctor: doctor),
        ],
      ),
    );
  }
}
