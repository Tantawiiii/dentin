import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';

Widget BuildDropdownField({
  required String label,
  required String? value,
  required List<String> items,
  required String hint,
  required IconData icon,
  required Function(String?) onChanged,
  String? title,
}) {
  final validatedValue = value != null && items.contains(value) ? value : null;
  final isFocused = validatedValue != null;

  final dropdown = DropdownButtonFormField<String>(
    value: validatedValue,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 10.sp),
      filled: true,
      fillColor: isFocused ? AppColors.surface : AppColors.surfaceVariant,
      prefixIcon: Icon(
        icon,
        color: isFocused ? AppColors.primary : AppColors.textSecondary,
        size: 20.sp,
      ),
      suffixIcon: Icon(
        Icons.arrow_drop_down,
        color: AppColors.textSecondary,
        size: 22.sp,
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
      isDense: false,
    ),
    isExpanded: true,
    items: items.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }).toList(),
    onChanged: onChanged,
    selectedItemBuilder: (BuildContext context) {
      return items.map<Widget>((String item) {
        return Text(
          item,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      }).toList();
    },
    style: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
    ),
    dropdownColor: AppColors.surface,
    iconSize: 0,
  );

  if (title != null) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title *',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        dropdown,
      ],
    );
  }

  return dropdown;
}
