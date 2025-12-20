import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constant/app_colors.dart';
import '../../core/di/inject.dart' as di;
import '../../core/routing/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../features/auth/login/data/models/login_response.dart';
import '../../shared/widgets/primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserData? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final storageService = di.sl<StorageService>();
    await storageService.clearAll();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No user data found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  PrimaryButton(
                    title: 'Go to Login',
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.login);
                    },
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowGlow,
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Profile Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50.r),
                          child: _userData!.profileImage != null
                              ? CachedNetworkImage(
                                  imageUrl: _userData!.profileImage!,
                                  width: 100.w,
                                  height: 100.w,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 100.w,
                                    height: 100.w,
                                    color: AppColors.surfaceVariant,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 100.w,
                                        height: 100.w,
                                        color: AppColors.surfaceVariant,
                                        child: Icon(
                                          Icons.person,
                                          size: 50.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                )
                              : Container(
                                  width: 100.w,
                                  height: 100.w,
                                  color: AppColors.surfaceVariant,
                                  child: Icon(
                                    Icons.person,
                                    size: 50.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_userData!.firstName} ${_userData!.lastName}',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (_userData!.specialization != null)
                                Text(
                                  _userData!.specialization!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textOnPrimary.withOpacity(
                                      0.9,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 16.sp,
                                    color: AppColors.textOnPrimary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      _userData!.email,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textOnPrimary
                                            .withOpacity(0.8),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // User Information Cards
                  _buildInfoCard(
                    title: 'Personal Information',
                    children: [
                      _buildInfoRow('Username', _userData!.userName),
                      _buildInfoRow('Phone', _userData!.phone),
                      if (_userData!.birthDate != null)
                        _buildInfoRow('Birth Date', _userData!.birthDate!),
                      if (_userData!.address != null)
                        _buildInfoRow('Address', _userData!.address!),
                    ],
                  ),

                  if (_userData!.university != null ||
                      _userData!.graduationYear != null ||
                      _userData!.graduationGrade != null ||
                      _userData!.postgraduateDegree != null)
                    SizedBox(height: 16.h),
                  if (_userData!.university != null ||
                      _userData!.graduationYear != null ||
                      _userData!.graduationGrade != null ||
                      _userData!.postgraduateDegree != null)
                    _buildInfoCard(
                      title: 'Education',
                      children: [
                        if (_userData!.university != null)
                          _buildInfoRow('University', _userData!.university!),
                        if (_userData!.graduationYear != null)
                          _buildInfoRow(
                            'Graduation Year',
                            _userData!.graduationYear!,
                          ),
                        if (_userData!.graduationGrade != null)
                          _buildInfoRow(
                            'Grade',
                            _userData!.graduationGrade!.replaceAll('_', ' '),
                          ),
                        if (_userData!.postgraduateDegree != null)
                          _buildInfoRow(
                            'Degree',
                            _userData!.postgraduateDegree!,
                          ),
                      ],
                    ),

                  if (_userData!.experienceYears != null ||
                      _userData!.specialization != null ||
                      _userData!.description != null)
                    SizedBox(height: 16.h),
                  if (_userData!.experienceYears != null ||
                      _userData!.specialization != null ||
                      _userData!.description != null)
                    _buildInfoCard(
                      title: 'Professional Information',
                      children: [
                        if (_userData!.experienceYears != null)
                          _buildInfoRow(
                            'Experience Years',
                            '${_userData!.experienceYears} years',
                          ),
                        if (_userData!.specialization != null)
                          _buildInfoRow(
                            'Specialization',
                            _userData!.specialization!,
                          ),
                        if (_userData!.description != null)
                          _buildInfoRow('Description', _userData!.description!),
                      ],
                    ),

                  if (_userData!.hasClinic == true &&
                      (_userData!.clinicName != null ||
                          _userData!.clinicAddress != null))
                    SizedBox(height: 16.h),
                  if (_userData!.hasClinic == true &&
                      (_userData!.clinicName != null ||
                          _userData!.clinicAddress != null))
                    _buildInfoCard(
                      title: 'Clinic Information',
                      children: [
                        if (_userData!.clinicName != null)
                          _buildInfoRow('Clinic Name', _userData!.clinicName!),
                        if (_userData!.clinicAddress != null)
                          _buildInfoRow(
                            'Clinic Address',
                            _userData!.clinicAddress!,
                          ),
                      ],
                    ),

                  if (_userData!.skills != null &&
                      _userData!.skills!.isNotEmpty)
                    SizedBox(height: 16.h),
                  if (_userData!.skills != null &&
                      _userData!.skills!.isNotEmpty)
                    _buildInfoCard(
                      title: 'Skills',
                      children: [
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _userData!.skills!
                              .map(
                                (skill) => Chip(
                                  label: Text(
                                    skill.replaceAll('_', ' '),
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  backgroundColor: AppColors.primaryLight
                                      .withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
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
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
