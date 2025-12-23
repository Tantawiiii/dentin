import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../data/models/profile_response.dart';
import '../data/repo/profile_repository.dart';
import 'widgets/profile_about_tab.dart';
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
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const _ProfileLoading();
            } else if (state is ProfileLoaded) {
              return _ProfileContent(loadedState: state);
            } else if (state is ProfileError) {
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

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileLoaded loadedState;

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
                    // TODO: Navigate to edit profile when available
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
          ProfilePostsTab(posts: doctor.posts),
          ProfileAboutTab(doctor: doctor),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InlineInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final Doctor doctor;

  const _AboutTab({required this.doctor});

  String _formatDate(String? date) {
    if (date == null) return '-';
    return date;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoTile(
            icon: Icons.location_on_outlined,
            label: AppTexts.profileLocation,
            value: doctor.address ?? '-',
          ),
          _InfoTile(
            icon: Icons.email_outlined,
            label: AppTexts.email,
            value: doctor.email,
          ),
          _InfoTile(
            icon: Icons.phone_outlined,
            label: AppTexts.profilePhone,
            value: doctor.phone,
          ),
          _InfoTile(
            icon: Icons.cake_outlined,
            label: AppTexts.profileBirthDate,
            value: _formatDate(doctor.birthDate),
          ),
          _InfoTile(
            icon: Icons.calendar_today_outlined,
            label: AppTexts.profileJoined,
            value: _formatDate(doctor.createdAt),
          ),
          if (doctor.university != null && doctor.university!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: _SectionCard(
                title: AppTexts.profileEducation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InlineInfoRow(
                      icon: Icons.school_outlined,
                      label: AppTexts.profileUniversity,
                      value: doctor.university!,
                    ),
                    if (doctor.graduationYear != null &&
                        doctor.graduationYear!.isNotEmpty)
                      _InlineInfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: AppTexts.profileGraduationYear,
                        value: doctor.graduationYear!,
                      ),
                    if (doctor.graduationGrade != null &&
                        doctor.graduationGrade!.isNotEmpty)
                      _InlineInfoRow(
                        icon: Icons.star_outline,
                        label: AppTexts.profileGraduationGrade,
                        value: doctor.graduationGrade!,
                      ),
                    if (doctor.postgraduateDegree != null &&
                        doctor.postgraduateDegree!.isNotEmpty)
                      _InlineInfoRow(
                        icon: Icons.workspace_premium_outlined,
                        label: AppTexts.profilePostgraduateDegree,
                        value: doctor.postgraduateDegree!,
                      ),
                    if (doctor.specialization != null &&
                        doctor.specialization!.isNotEmpty)
                      _InlineInfoRow(
                        icon: Icons.medical_services_outlined,
                        label: AppTexts.profileSpecialization,
                        value: doctor.specialization!,
                      ),
                  ],
                ),
              ),
            ),
          if (doctor.experienceYears != null ||
              (doctor.experience != null && doctor.experience!.isNotEmpty) ||
              (doctor.whereDidYouWork != null &&
                  doctor.whereDidYouWork!.isNotEmpty))
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: _SectionCard(
                title: AppTexts.profileExperience,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (doctor.experienceYears != null)
                      _InlineInfoRow(
                        icon: Icons.timeline_outlined,
                        label: AppTexts.profileExperienceYears,
                        value: '${doctor.experienceYears} years',
                      ),
                    if (doctor.experience != null &&
                        doctor.experience!.isNotEmpty)
                      _InlineInfoRow(
                        icon: Icons.work_outline,
                        label: AppTexts.profileExperience,
                        value: doctor.experience!,
                      ),
                    if (doctor.whereDidYouWork != null &&
                        doctor.whereDidYouWork!.isNotEmpty)
                      _InlineInfoRow(
                        icon: Icons.business_outlined,
                        label: AppTexts.profileWhereDidYouWork,
                        value: doctor.whereDidYouWork!,
                      ),
                  ],
                ),
              ),
            ),
          if (doctor.availableTimes.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: _SectionCard(
                title: AppTexts.profileAvailableTimes,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: doctor.availableTimes
                      .map(
                        (time) => Chip(
                          label: Text(time, style: TextStyle(fontSize: 11.sp)),
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          if (doctor.description != null && doctor.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: _SectionCard(
                title: AppTexts.profileAboutTab,
                child: Text(
                  doctor.description!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          if (doctor.fields.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: _SectionCard(
                title: AppTexts.profileFields,
                child: Wrap(
                  spacing: 4.w,
                  runSpacing: 2.h,
                  children: doctor.fields
                      .map(
                        (f) => Chip(
                          label: Text(
                            f.name,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          if (doctor.graduationCertificateImage != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: _SectionCard(
                title: AppTexts.profileGraduationCertificate,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: doctor.graduationCertificateImage!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ShimmerPlaceholder(
                      width: double.infinity,
                      height: 160.h,
                    ),
                  ),
                ),
              ),
            ),
          if (doctor.skills.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: _SectionCard(
                title: AppTexts.profileSkills,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: doctor.skills
                      .map(
                        (s) => Chip(
                          label: Text(s, style: TextStyle(fontSize: 11.sp)),
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ).borderRadius,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          if (doctor.cv != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: _SectionCard(
                title: AppTexts.cv,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: () => _launchUrl(doctor.cv!),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text(AppTexts.profileCvDownload),
                ),
              ),
            ),
          if (doctor.courseCertificates.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
              child: _SectionCard(
                title: AppTexts.profileCourseCertificates,
                child: GridView.builder(
                  itemCount: doctor.courseCertificates.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 4 / 3,
                  ),
                  itemBuilder: (context, index) {
                    final certificate = doctor.courseCertificates[index];
                    return GestureDetector(
                      onTap: () => _launchUrl(certificate.fullUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: certificate.fullUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => ShimmerPlaceholder(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.65),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(
                                  certificate.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostsTab extends StatelessWidget {
  final List<Post> posts;

  const _PostsTab({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          AppTexts.noPostsYet,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: posts.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final post = posts[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.image != null && post.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: post.image!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ShimmerPlaceholder(
                      width: double.infinity,
                      height: 180.h,
                    ),
                  ),
                ),
              if (post.content != null && post.content!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    post.content!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        post.isAdRequest
                            ? Icons.campaign_outlined
                            : Icons.article_outlined,
                        size: 16.sp,
                        color: post.isAdRequest
                            ? Colors.teal
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        post.isAdRequest
                            ? AppTexts.sponsored
                            : AppTexts.regular,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: post.isAdRequest
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 16.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        post.likesCount.toString(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
