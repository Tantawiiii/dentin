import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import 'build_dropdown_menu.dart';
import 'multi_select_specialties.dart';
import 'year_picker_field.dart';

class EducationStep extends StatelessWidget {
  const EducationStep({
    super.key,
    required this.formKey,
    required this.graduationYearController,
    required this.selectedUniversity,
    required this.selectedGrade,
    required this.selectedDegree,
    required this.selectedSpecialties,
    required this.egyptianUniversities,
    required this.grades,
    required this.degrees,
    required this.specialties,
    required this.onUniversityChanged,
    required this.onGradeChanged,
    required this.onDegreeChanged,
    required this.onSpecialtiesChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController graduationYearController;
  final String? selectedUniversity;
  final String? selectedGrade;
  final String? selectedDegree;
  final List<String> selectedSpecialties;
  final List<String> egyptianUniversities;
  final List<String> grades;
  final List<String> degrees;
  final List<String> specialties;
  final Function(String?) onUniversityChanged;
  final Function(String?) onGradeChanged;
  final Function(String?) onDegreeChanged;
  final Function(List<String>) onSpecialtiesChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  AppTexts.educationBackground,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            YearPickerField(
              controller: graduationYearController,
              hint: AppTexts.graduationYear,
              leadingIcon: Icons.calendar_today_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.graduationYearRequired;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            BuildDropdownField(
              label: AppTexts.university,
              value: selectedUniversity,
              items: egyptianUniversities,
              hint: AppTexts.selectUniversity,
              icon: Icons.school_outlined,
              onChanged: onUniversityChanged,
            ),
            SizedBox(height: 16.h),
            BuildDropdownField(
              label: AppTexts.graduationGrade,
              value: selectedGrade,
              items: grades,
              hint: AppTexts.selectGrade,
              icon: Icons.grade_outlined,
              onChanged: onGradeChanged,
            ),
            SizedBox(height: 16.h),
            BuildDropdownField(
              label: AppTexts.postgraduateDegree,
              value: selectedDegree,
              items: degrees,
              hint: AppTexts.selectDegree,
              icon: Icons.workspace_premium_outlined,
              onChanged: onDegreeChanged,
            ),
            SizedBox(height: 16.h),
            MultiSelectSpecialties(
              label: AppTexts.fieldsSpecialties,
              items: specialties,
              selectedItems: selectedSpecialties,
              onChanged: onSpecialtiesChanged,
              hint: AppTexts.selectSpecialties,
              icon: Icons.medical_services_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.specialtiesRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
