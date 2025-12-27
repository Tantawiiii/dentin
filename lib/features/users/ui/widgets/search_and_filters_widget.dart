import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/app_text_field.dart';

class SearchAndFiltersWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool showFilters;
  final int perPage;
  final VoidCallback onFilterToggle;
  final ValueChanged<int> onPerPageChanged;
  final Widget advancedFilters;

  const SearchAndFiltersWidget({
    super.key,
    required this.searchController,
    required this.showFilters,
    required this.perPage,
    required this.onFilterToggle,
    required this.onPerPageChanged,
    required this.advancedFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: searchController,
                  hint: AppTexts.searchByUsernameEmail,
                  leadingIcon: Icons.search,
                ),
              ),
              SizedBox(width: 12.w),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: showFilters
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                onPressed: onFilterToggle,
              ),
              SizedBox(width: 8.w),
              DropdownButton<int>(
                value: perPage,
                items: [5, 10, 20].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text('$value ${AppTexts.perPage}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onPerPageChanged(value);
                  }
                },
              ),
            ],
          ),
          if (showFilters) advancedFilters,
        ],
      ),
    );
  }
}

