import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/app_text_field.dart';

class SearchAndFiltersWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool showFilters;
  final VoidCallback onFilterToggle;

  const SearchAndFiltersWidget({
    super.key,
    required this.searchController,
    required this.showFilters,
    required this.onFilterToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: searchController,
              hint: AppTexts.searchByUsernameEmail,
              leadingIcon: Icons.search,
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            decoration: BoxDecoration(
              color: showFilters
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: showFilters ? AppColors.primary : AppColors.border,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: showFilters ? AppColors.primary : AppColors.textSecondary,
                size: 22.sp,
              ),
              onPressed: onFilterToggle,
            ),
          ),
        ],
      ),
    );
  }
}
