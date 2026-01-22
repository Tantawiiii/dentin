import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import '../../data/models/profile_response.dart';

class ProfileAboutTab extends StatelessWidget {
  final Doctor doctor;

  const ProfileAboutTab({super.key, required this.doctor});

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
          // _InfoTile(
          //   icon: Icons.calendar_today_outlined,
          //   label: AppTexts.profileJoined,
          //   value: _formatDate(doctor.createdAt),
          // ),
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
                          backgroundColor:
                              AppColors.primary.withOpacity(0.08),
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
                          backgroundColor:
                              AppColors.primary.withOpacity(0.08),
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
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
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
                          backgroundColor:
                              AppColors.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
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
                              errorWidget: (_, __, ___) =>
                                  const SizedBox.shrink(),
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


