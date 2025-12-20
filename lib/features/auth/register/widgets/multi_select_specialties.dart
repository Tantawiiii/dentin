import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';

class MultiSelectSpecialties extends StatelessWidget {
  const MultiSelectSpecialties({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    required this.hint,
    required this.icon,
    this.validator,
  });

  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;
  final String hint;
  final IconData icon;
  final String? Function(List<String>?)? validator;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedItems.isNotEmpty;
    final hasError = validator != null && validator!(selectedItems) != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: hasError ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _showMultiSelectDialog(context),
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: hasSelection ? AppColors.surface : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : hasSelection
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.border,
                width: hasError ? 1.5 : (hasSelection ? 1.5 : 1.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: hasSelection ? AppColors.primary : AppColors.textSecondary,
                  size: 22.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: selectedItems.isEmpty
                      ? Text(
                          hint,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 15.sp,
                          ),
                        )
                      : Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: selectedItems.map((item) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  GestureDetector(
                                    onTap: () {
                                      final updated = List<String>.from(selectedItems)
                                        ..remove(item);
                                      onChanged(updated);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 16.sp,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
        if (hasError && validator != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              validator!(selectedItems) ?? '',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }

  void _showMultiSelectDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MultiSelectBottomSheet(
        items: items,
        selectedItems: selectedItems,
        onChanged: onChanged,
        label: label,
      ),
    );
  }
}

class _MultiSelectBottomSheet extends StatefulWidget {
  const _MultiSelectBottomSheet({
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    required this.label,
  });

  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;
  final String label;

  @override
  State<_MultiSelectBottomSheet> createState() => _MultiSelectBottomSheetState();
}

class _MultiSelectBottomSheetState extends State<_MultiSelectBottomSheet> {
  late List<String> _tempSelectedItems;

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List<String>.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onChanged(_tempSelectedItems);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = _tempSelectedItems.contains(item);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _tempSelectedItems.remove(item);
                      } else {
                        _tempSelectedItems.add(item);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  color: AppColors.textOnPrimary,
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
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
        ],
      ),
    );
  }
}

