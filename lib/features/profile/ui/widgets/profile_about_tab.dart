import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/di/inject.dart' as di;
import '../../../../core/network/dio_client.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import '../../data/models/profile_response.dart';
import '../../data/repo/profile_repository.dart';
import 'profile_info_tile.dart';
import 'profile_inline_info_row.dart';
import 'profile_phone_info_tile.dart';
import 'profile_section_card.dart';

class ProfileAboutTab extends StatefulWidget {
  final Doctor doctor;
  final bool isOwnProfile;
  final VoidCallback? onProfileUpdated;

  const ProfileAboutTab({
    super.key,
    required this.doctor,
    this.isOwnProfile = false,
    this.onProfileUpdated,
  });

  @override
  State<ProfileAboutTab> createState() => _ProfileAboutTabState();
}

class _ProfileAboutTabState extends State<ProfileAboutTab> {
  late Doctor _doctor;
  bool _isToggling = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _doctor = widget.doctor;
  }

  @override
  void didUpdateWidget(ProfileAboutTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doctor.id != widget.doctor.id ||
        oldWidget.doctor.isPhoneHidden != widget.doctor.isPhoneHidden) {
      _doctor = widget.doctor;
    }
  }

  Future<void> _togglePhoneVisibility() async {
    if (_isToggling) return;

    setState(() => _isToggling = true);

    try {
      final repository = di.sl<ProfileRepository>();
      final newValue = (_doctor.isPhoneHidden == true) ? 0 : 1;

      await repository.togglePhoneVisibility(_doctor.id, newValue);
      setState(() {
        _doctor = Doctor(
          id: _doctor.id,
          userName: _doctor.userName,
          firstName: _doctor.firstName,
          lastName: _doctor.lastName,
          email: _doctor.email,
          phone: _doctor.phone,
          birthDate: _doctor.birthDate,
          description: _doctor.description,
          address: _doctor.address,
          university: _doctor.university,
          graduationYear: _doctor.graduationYear,
          graduationGrade: _doctor.graduationGrade,
          postgraduateDegree: _doctor.postgraduateDegree,
          specialization: _doctor.specialization,
          experienceYears: _doctor.experienceYears,
          experience: _doctor.experience,
          whereDidYouWork: _doctor.whereDidYouWork,
          availableTimes: _doctor.availableTimes,
          skills: _doctor.skills,
          fields: _doctor.fields,
          profileImage: _doctor.profileImage,
          coverImage: _doctor.coverImage,
          posts: _doctor.posts,
          graduationCertificateImage: _doctor.graduationCertificateImage,
          cv: _doctor.cv,
          courseCertificates: _doctor.courseCertificates,
          createdAt: _doctor.createdAt,
          isWorkAssistantUniversity: _doctor.isWorkAssistantUniversity,
          assistantUniversity: _doctor.assistantUniversity,
          tools: _doctor.tools,
          hasClinic: _doctor.hasClinic,
          clinicName: _doctor.clinicName,
          clinicAddress: _doctor.clinicAddress,
          isPhoneHidden: newValue == 1,
        );
      });

      widget.onProfileUpdated?.call();

      if (mounted) {
        AppToast.showSuccess(
          newValue == 1
              ? AppTexts.phoneNumberHidden
              : AppTexts.phoneNumberVisible,
          context: context,
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        AppToast.showError(
          '${AppTexts.failedToUpdatePhoneVisibility}: $e',
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

  String _formatDate(String? date) {
    if (date == null) return AppTexts.notAvailable;
    return date;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _requestDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppTexts.deleteAccountWarningTitle,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppTexts.deleteAccountWarningMessage,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              AppTexts.cancel,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppTexts.deleteAccountConfirm,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final repository = di.sl<ProfileRepository>();
      await repository.deleteAccount();

      di.sl<DioClient>().clearAuthToken();
      await di.sl<StorageService>().clearAll();

      if (!mounted) return;
      AppToast.showSuccess(AppTexts.accountDeletedSuccessfully, context: context);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          '${AppTexts.failedToDeleteAccount}: $e',
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
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
          ProfileInfoTile(
            icon: Icons.location_on_outlined,
            label: AppTexts.profileLocation,
            value: _doctor.address ?? AppTexts.notAvailable,
          ),
          ProfileInfoTile(
            icon: Icons.email_outlined,
            label: AppTexts.email,
            value: _doctor.email,
          ),
          if (_doctor.isPhoneHidden != true || widget.isOwnProfile)
            ProfilePhoneInfoTile(
              phone: _doctor.phone,
              isHidden: _doctor.isPhoneHidden == true,
              isOwnProfile: widget.isOwnProfile,
              isToggling: _isToggling,
              onToggle: _togglePhoneVisibility,
            ),
          ProfileInfoTile(
            icon: Icons.cake_outlined,
            label: AppTexts.profileBirthDate,
            value: _formatDate(_doctor.birthDate),
          ),
          if (_doctor.createdAt != null)
            ProfileInfoTile(
              icon: Icons.calendar_today_outlined,
              label: AppTexts.profileJoined,
              value: _formatDate(_doctor.createdAt),
            ),
          if (_doctor.university != null && _doctor.university!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.profileEducation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileInlineInfoRow(
                      icon: Icons.school_outlined,
                      label: AppTexts.profileUniversity,
                      value: _doctor.university!,
                    ),
                    if (_doctor.graduationYear != null &&
                        _doctor.graduationYear!.isNotEmpty)
                      ProfileInlineInfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: AppTexts.profileGraduationYear,
                        value: _doctor.graduationYear!,
                      ),
                    if (_doctor.graduationGrade != null &&
                        _doctor.graduationGrade!.isNotEmpty)
                      ProfileInlineInfoRow(
                        icon: Icons.star_outline,
                        label: AppTexts.profileGraduationGrade,
                        value: _doctor.graduationGrade!,
                      ),
                    if (_doctor.postgraduateDegree != null &&
                        _doctor.postgraduateDegree!.isNotEmpty)
                      ProfileInlineInfoRow(
                        icon: Icons.workspace_premium_outlined,
                        label: AppTexts.profilePostgraduateDegree,
                        value: _doctor.postgraduateDegree!,
                      ),
                    if (_doctor.specialization != null &&
                        _doctor.specialization!.isNotEmpty)
                      ProfileInlineInfoRow(
                        icon: Icons.medical_services_outlined,
                        label: AppTexts.profileSpecialization,
                        value: _doctor.specialization!,
                      ),
                    if (_doctor.isWorkAssistantUniversity == true &&
                        _doctor.assistantUniversity != null &&
                        _doctor.assistantUniversity!.isNotEmpty)
                      ProfileInlineInfoRow(
                        icon: Icons.school_outlined,
                        label: AppTexts.teacherAssistantAtUniversity,
                        value: _doctor.assistantUniversity!,
                      ),
                  ],
                ),
              ),
            ),
          if (_doctor.experienceYears != null ||
              (_doctor.experience != null && _doctor.experience!.isNotEmpty) ||
              (_doctor.whereDidYouWork != null &&
                  _doctor.whereDidYouWork!.isNotEmpty))
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.profileExperience,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_doctor.experienceYears != null)
                      ProfileInlineInfoRow(
                        icon: Icons.timeline_outlined,
                        label: AppTexts.profileExperienceYears,
                        value: '${_doctor.experienceYears} ${AppTexts.years}',
                      ),
                    if (_doctor.experience != null &&
                        _doctor.experience!.isNotEmpty)
                      ProfileInlineInfoRow(
                        icon: Icons.work_outline,
                        label: AppTexts.profileExperience,
                        value: _doctor.experience!,
                      ),
                    if (_doctor.whereDidYouWork != null &&
                        _doctor.whereDidYouWork!.isNotEmpty)
                      ProfileInlineInfoRow(
                        icon: Icons.business_outlined,
                        label: AppTexts.profileWhereDidYouWork,
                        value: _doctor.whereDidYouWork!,
                      ),
                  ],
                ),
              ),
            ),
          if (_doctor.hasClinic == true &&
              ((_doctor.clinicName != null &&
                      _doctor.clinicName!.isNotEmpty) ||
                  (_doctor.clinicAddress != null &&
                      _doctor.clinicAddress!.isNotEmpty)))
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.haveClinic,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_doctor.clinicName != null &&
                        _doctor.clinicName!.isNotEmpty)
                      ProfileInlineInfoRow(
                        icon: Icons.local_hospital_outlined,
                        label: AppTexts.clinicName,
                        value: _doctor.clinicName!,
                      ),
                    if (_doctor.clinicAddress != null &&
                        _doctor.clinicAddress!.isNotEmpty)
                      ProfileInlineInfoRow(
                        icon: Icons.location_on_outlined,
                        label: AppTexts.clinicAddress,
                        value: _doctor.clinicAddress!,
                      ),
                  ],
                ),
              ),
            ),
          if (_doctor.availableTimes.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.profileAvailableTimes,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _doctor.availableTimes
                      .map(
                        (time) => Chip(
                          label: Text(time, style: TextStyle(fontSize: 11.sp)),
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          if (_doctor.description != null && _doctor.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.profileAboutTab,
                child: Text(
                  _doctor.description!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          if (_doctor.fields.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.profileFields,
                child: Wrap(
                  spacing: 4.w,
                  runSpacing: 2.h,
                  children: _doctor.fields
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
          if (_doctor.graduationCertificateImage != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.profileGraduationCertificate,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: _doctor.graduationCertificateImage!,
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
          if (_doctor.skills.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.profileSkills,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _doctor.skills
                      .map(
                        (s) => Chip(
                          label: Text(s, style: TextStyle(fontSize: 11.sp)),
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
          if (_doctor.tools != null && _doctor.tools!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.toolsYouHave,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: (_doctor.tools ?? '')
                      .split(',')
                      .map((t) => t.trim())
                      .where((t) => t.isNotEmpty)
                      .map(
                        (t) => Chip(
                          label: Text(
                            t,
                            style: TextStyle(fontSize: 11.sp),
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
          if (_doctor.cv != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.cv,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: () => _launchUrl(_doctor.cv!),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text(AppTexts.profileCvDownload),
                ),
              ),
            ),
          if (_doctor.courseCertificates.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileSectionCard(
                title: AppTexts.profileCourseCertificates,
                child: GridView.builder(
                  itemCount: _doctor.courseCertificates.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 4 / 3,
                  ),
                  itemBuilder: (context, index) {
                    final certificate = _doctor.courseCertificates[index];
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
          if (widget.isOwnProfile)
            Padding(
              padding: EdgeInsets.only(top: 24.h, bottom: 24.h),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isDeleting ? null : _requestDeleteAccount,
                  icon: _isDeleting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.delete_outline, size: 20.sp, color: AppColors.error),
                  label: Text(
                    AppTexts.deleteAccount,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
