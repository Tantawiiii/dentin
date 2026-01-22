import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/users_list_response.dart';

class AdvancedFiltersWidget extends StatelessWidget {
  final UsersListFilters tempFilters;
  final Map<String, TextEditingController> filterControllers;
  final ValueChanged<UsersListFilters> onFiltersChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onClearFilters;

  const AdvancedFiltersWidget({
    super.key,
    required this.tempFilters,
    required this.filterControllers,
    required this.onFiltersChanged,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 8.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          
          Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                AppTexts.advancedFilters,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.textSecondary, size: 20.sp),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _FilterSection(
                    title: 'Personal Information',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _FilterTextField(
                        label: AppTexts.email,
                        icon: Icons.email_outlined,
                        value: tempFilters.email ?? '',
                        controller: filterControllers,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => onFiltersChanged(
                          tempFilters.copyWith(email: value),
                        ),
                      ),
                      _FilterTextField(
                        label: AppTexts.phoneNumber,
                        icon: Icons.phone_outlined,
                        value: tempFilters.phone ?? '',
                        controller: filterControllers,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => onFiltersChanged(
                          tempFilters.copyWith(phone: value),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _FilterSection(
                    title: 'Education',
                    icon: Icons.school_outlined,
                    children: [
                      _FilterTextField(
                        label: AppTexts.graduationYear,
                        icon: Icons.calendar_today_outlined,
                        value: tempFilters.graduationYear ?? '',
                        controller: filterControllers,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => onFiltersChanged(
                          tempFilters.copyWith(graduationYear: value),
                        ),
                      ),
                      _DropdownFilter(
                        label: AppTexts.graduationGrade,
                        icon: Icons.star_outline,
                        value: tempFilters.graduationGrade,
                        options: ['excellent', 'very_good', 'good', 'pass'],
                        onChanged: (value) => onFiltersChanged(
                          tempFilters.copyWith(graduationGrade: value),
                        ),
                      ),
                      _DropdownFilter(
                        label: AppTexts.postgraduateDegree,
                        icon: Icons.workspace_premium_outlined,
                        value: tempFilters.postgraduateDegree,
                        options: ['diploma', 'master', 'phd'],
                        onChanged: (value) => onFiltersChanged(
                          tempFilters.copyWith(postgraduateDegree: value),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _FilterSection(
                    title: 'Experience',
                    icon: Icons.work_outline,
                    children: [
                      _FilterTextField(
                        label: AppTexts.yearsOfExperience,
                        icon: Icons.trending_up_outlined,
                        value: tempFilters.experienceYears?.toString() ?? '',
                        controller: filterControllers,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final years = int.tryParse(value);
                          onFiltersChanged(
                            tempFilters.copyWith(experienceYears: years),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  title: AppTexts.applyFilters,
                  onPressed: onApplyFilters,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: onClearFilters,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    AppTexts.clearAll,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FilterSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 18.sp, color: AppColors.primary),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children.map(
            (child) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTextField extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, TextEditingController> controller;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final IconData icon;

  const _FilterTextField({
    required this.label,
    required this.value,
    required this.controller,
    required this.keyboardType,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textController = controller.putIfAbsent(
      label,
      () => TextEditingController(text: value),
    );

    if (textController.text != value) {
      textController.text = value;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppTextField(
        controller: textController,
        hint: label,
        keyboardType: keyboardType,
        leadingIcon: icon,
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final IconData icon;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20.sp, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          labelStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary,
          size: 24.sp,
        ),
        dropdownColor: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text(
                option
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map((word) {
                      return word.isEmpty
                          ? ''
                          : word[0].toUpperCase() + word.substring(1);
                    })
                    .join(' '),
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
