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
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.advancedFilters,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _FilterTextField(
                label: AppTexts.email,
                value: tempFilters.email ?? '',
                controller: filterControllers,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => onFiltersChanged(
                  tempFilters.copyWith(email: value),
                ),
              ),
              _FilterTextField(
                label: AppTexts.phoneNumber,
                value: tempFilters.phone ?? '',
                controller: filterControllers,
                keyboardType: TextInputType.phone,
                onChanged: (value) => onFiltersChanged(
                  tempFilters.copyWith(phone: value),
                ),
              ),
              _FilterTextField(
                label: AppTexts.graduationYear,
                value: tempFilters.graduationYear ?? '',
                controller: filterControllers,
                keyboardType: TextInputType.number,
                onChanged: (value) => onFiltersChanged(
                  tempFilters.copyWith(graduationYear: value),
                ),
              ),
              _DropdownFilter(
                label: AppTexts.graduationGrade,
                value: tempFilters.graduationGrade,
                options: ['excellent', 'very_good', 'good', 'pass'],
                onChanged: (value) => onFiltersChanged(
                  tempFilters.copyWith(graduationGrade: value),
                ),
              ),
              _DropdownFilter(
                label: AppTexts.postgraduateDegree,
                value: tempFilters.postgraduateDegree,
                options: ['diploma', 'master', 'phd'],
                onChanged: (value) => onFiltersChanged(
                  tempFilters.copyWith(postgraduateDegree: value),
                ),
              ),
              _FilterTextField(
                label: AppTexts.yearsOfExperience,
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
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  title: AppTexts.applyFilters,
                  onPressed: onApplyFilters,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(width: 12.w),
              OutlinedButton(
                onPressed: onClearFilters,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text(AppTexts.clearAll),
              ),
            ],
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

  const _FilterTextField({
    required this.label,
    required this.value,
    required this.controller,
    required this.keyboardType,
    required this.onChanged,
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

    return SizedBox(
      width: 150.w,
      child: AppTextField(
        controller: textController,
        hint: label,
        keyboardType: keyboardType,
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.w,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: AppColors.border),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 8.h,
          ),
        ),
        value: value,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option.replaceAll('_', ' ').toUpperCase()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

