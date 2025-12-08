import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/app_text_field.dart';

class EducationStep extends StatelessWidget {
  const EducationStep({
    super.key,
    required this.formKey,
    required this.graduationYearController,
    required this.selectedUniversity,
    required this.selectedGrade,
    required this.selectedDegree,
    required this.egyptianUniversities,
    required this.grades,
    required this.degrees,
    required this.onUniversityChanged,
    required this.onGradeChanged,
    required this.onDegreeChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController graduationYearController;
  final String? selectedUniversity;
  final String? selectedGrade;
  final String? selectedDegree;
  final List<String> egyptianUniversities;
  final List<String> grades;
  final List<String> degrees;
  final Function(String?) onUniversityChanged;
  final Function(String?) onGradeChanged;
  final Function(String?) onDegreeChanged;

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    final isFocused = value != null;
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15.sp),
        filled: true,
        fillColor: isFocused ? AppColors.surface : AppColors.surfaceVariant,
        prefixIcon: Icon(
          icon,
          color: isFocused ? AppColors.primary : AppColors.textSecondary,
          size: 22.sp,
        ),
        suffixIcon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
          size: 24.sp,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isFocused
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(14.r),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
          borderRadius: BorderRadius.circular(14.r),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
          borderRadius: BorderRadius.circular(14.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: AppColors.surface,
      iconSize: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(AppTexts.educationBackground),
            SizedBox(height: 24.h),
            AppTextField(
              controller: graduationYearController,
              hint: AppTexts.graduationYear,
              leadingIcon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.graduationYearRequired;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildDropdownField(
              label: AppTexts.university,
              value: selectedUniversity,
              items: egyptianUniversities,
              hint: AppTexts.selectUniversity,
              icon: Icons.school_outlined,
              onChanged: onUniversityChanged,
            ),
            SizedBox(height: 16.h),
            _buildDropdownField(
              label: AppTexts.graduationGrade,
              value: selectedGrade,
              items: grades,
              hint: AppTexts.selectGrade,
              icon: Icons.grade_outlined,
              onChanged: onGradeChanged,
            ),
            SizedBox(height: 16.h),
            _buildDropdownField(
              label: AppTexts.postgraduateDegree,
              value: selectedDegree,
              items: degrees,
              hint: AppTexts.selectDegree,
              icon: Icons.workspace_premium_outlined,
              onChanged: onDegreeChanged,
            ),
          ],
        ),
      ),
    );
  }
}


