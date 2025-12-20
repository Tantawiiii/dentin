import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';

class ChipInputField extends StatefulWidget {
  const ChipInputField({
    super.key,
    required this.label,
    required this.chips,
    required this.onChipsChanged,
    required this.hint,
    required this.addButtonText,
    required this.icon,
    this.validator,
  });

  final String label;
  final List<String> chips;
  final Function(List<String>) onChipsChanged;
  final String hint;
  final String addButtonText;
  final IconData icon;
  final String? Function(List<String>?)? validator;

  @override
  State<ChipInputField> createState() => _ChipInputFieldState();
}

class _ChipInputFieldState extends State<ChipInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addChip() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.chips.contains(text)) {
      final updatedChips = List<String>.from(widget.chips)..add(text);
      widget.onChipsChanged(updatedChips);
      _controller.clear();
    }
  }

  void _removeChip(String chip) {
    final updatedChips = List<String>.from(widget.chips)..remove(chip);
    widget.onChipsChanged(updatedChips);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.validator != null && widget.validator!(widget.chips) != null;
    final hasChips = widget.chips.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.label} *',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: hasError ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
          },
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  onFieldSubmitted: (_) => _addChip(),
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
                    fillColor: _isFocused || hasChips
                        ? AppColors.surface
                        : AppColors.surfaceVariant,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    prefixIcon: Icon(
                      widget.icon,
                      color: _isFocused || hasChips
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 22.sp,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: hasError
                            ? AppColors.error
                            : (_isFocused || hasChips
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.border),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: hasError ? AppColors.error : AppColors.primary,
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
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: _addChip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.addButtonText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasChips) ...[
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.chips.map((chip) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
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
                      chip,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => _removeChip(chip),
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
        ],
        if (hasError && widget.validator != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              widget.validator!(widget.chips) ?? '',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }
}

