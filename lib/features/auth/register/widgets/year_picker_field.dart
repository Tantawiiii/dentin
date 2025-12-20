import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';

class YearPickerField extends StatelessWidget {
  const YearPickerField({
    super.key,
    required this.controller,
    required this.hint,
    required this.leadingIcon,
    this.validator,
    this.onYearSelected,
  });

  final TextEditingController controller;
  final String hint;
  final IconData leadingIcon;
  final String? Function(String?)? validator;
  final Function(int?)? onYearSelected;

  Future<void> _selectYear(BuildContext context) async {
    final currentYear = DateTime.now().year;
    final initialYear = controller.text.isNotEmpty
        ? int.tryParse(controller.text) ?? currentYear
        : currentYear;

    final selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return _YearPickerDialog(
          initialYear: initialYear,
          currentYear: currentYear,
        );
      },
    );

    if (selectedYear != null) {
      controller.text = selectedYear.toString();
      onYearSelected?.call(selectedYear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return YearPickerFormField(
      controller: controller,
      hint: hint,
      leadingIcon: leadingIcon,
      validator: validator,
      onTap: () => _selectYear(context),
    );
  }
}

class YearPickerFormField extends StatefulWidget {
  const YearPickerFormField({
    super.key,
    required this.controller,
    required this.hint,
    required this.leadingIcon,
    this.validator,
    this.onTap,
  });

  final TextEditingController controller;
  final String hint;
  final IconData leadingIcon;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;

  @override
  State<YearPickerFormField> createState() => _YearPickerFormFieldState();
}

class _YearPickerFormFieldState extends State<YearPickerFormField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.isNotEmpty;

    return TextFormField(
        controller: widget.controller,
        readOnly: true,
        onTap: widget.onTap,
        validator: widget.validator,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 15.sp,
          ),
          filled: true,
          fillColor: hasValue ? AppColors.surface : AppColors.surfaceVariant,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          prefixIcon: Icon(
            widget.leadingIcon,
            color: hasValue
                ? AppColors.primary
                : AppColors.textSecondary,
            size: 22.sp,
          ),
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: hasValue
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
    );
  }
}

class _YearPickerDialog extends StatefulWidget {
  const _YearPickerDialog({
    required this.initialYear,
    required this.currentYear,
  });

  final int initialYear;
  final int currentYear;

  @override
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late int _selectedYear;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    // Generate years from 1950 to current year + 10
    final years = _generateYears();
    final initialIndex = years.indexOf(_selectedYear);
    _scrollController = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : years.length ~/ 2,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<int> _generateYears() {
    final years = <int>[];
    final startYear = 1950;
    final endYear = widget.currentYear + 10;
    for (int year = endYear; year >= startYear; year--) {
      years.add(year);
    }
    return years;
  }

  @override
  Widget build(BuildContext context) {
    final years = _generateYears();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          children: [
            // Header
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
                    'Select Year',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(_selectedYear),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Year Picker
            Expanded(
              child: ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: 50.h,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedYear = years[index];
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index >= years.length) {
                      return null;
                    }
                    final year = years[index];
                    final isSelected = year == _selectedYear;

                    return Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            fontSize: isSelected ? 20.sp : 16.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: years.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

