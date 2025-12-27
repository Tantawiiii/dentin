import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import 'build_dropdown_menu.dart';

class AvailableTimeSlot {
  final String day;
  final String from;
  final String to;

  AvailableTimeSlot({
    required this.day,
    required this.from,
    required this.to,
  });
}

class AvailableTimesWidget extends StatefulWidget {
  const AvailableTimesWidget({
    super.key,
    required this.timeSlots,
    required this.onTimeSlotsChanged,
  });

  final List<AvailableTimeSlot> timeSlots;
  final Function(List<AvailableTimeSlot>) onTimeSlotsChanged;

  @override
  State<AvailableTimesWidget> createState() => AvailableTimesWidgetState();
}

class AvailableTimesWidgetState extends State<AvailableTimesWidget> {
  String? _selectedDay;
  String? _selectedFrom;
  String? _selectedTo;
  String? _errorMessage;


  String? validate() {
    if (widget.timeSlots.isEmpty) {
      setState(() {
        _errorMessage = AppTexts.availableTimesRequired;
      });
      return AppTexts.availableTimesRequired;
    }
    setState(() {
      _errorMessage = null;
    });
    return null;
  }

  void clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  static final List<String> _days = [
    AppTexts.sunday,
    AppTexts.monday,
    AppTexts.tuesday,
    AppTexts.wednesday,
    AppTexts.thursday,
    AppTexts.friday,
    AppTexts.saturday,
  ];

  static final List<String> _timeOptions = [
    '00:00', '00:30', '01:00', '01:30', '02:00', '02:30', '03:00', '03:30',
    '04:00', '04:30', '05:00', '05:30', '06:00', '06:30', '07:00', '07:30',
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
    '20:00', '20:30', '21:00', '21:30', '22:00', '22:30', '23:00', '23:30',
  ];

  void _addTimeSlot() {
    if (_selectedDay != null && _selectedFrom != null && _selectedTo != null) {
      final exists = widget.timeSlots.any((slot) =>
          slot.day == _selectedDay &&
          slot.from == _selectedFrom &&
          slot.to == _selectedTo);

      if (!exists) {
        final updatedSlots = List<AvailableTimeSlot>.from(widget.timeSlots)
          ..add(AvailableTimeSlot(
            day: _selectedDay!,
            from: _selectedFrom!,
            to: _selectedTo!,
          ));
        widget.onTimeSlotsChanged(updatedSlots);
        setState(() {
          _selectedDay = null;
          _selectedFrom = null;
          _selectedTo = null;
          _errorMessage = null;
        });
      }
    }
  }

  void _removeTimeSlot(int index) {
    final updatedSlots = List<AvailableTimeSlot>.from(widget.timeSlots)
      ..removeAt(index);
    widget.onTimeSlotsChanged(updatedSlots);
    if (updatedSlots.isEmpty) {
      setState(() {
        _errorMessage = AppTexts.availableTimesRequired;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.availableTimes,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.day,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      BuildDropdownField(
                        label: AppTexts.day,
                        value: _selectedDay,
                        items: _days,
                        hint: AppTexts.day,
                       // icon: Icons.calendar_today_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedDay = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.from,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      BuildDropdownField(
                        label: AppTexts.from,
                        value: _selectedFrom,
                        items: _timeOptions,
                        hint: AppTexts.from,
                        onChanged: (value) {
                          setState(() {
                            _selectedFrom = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.to,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      BuildDropdownField(
                        label: AppTexts.to,
                        value: _selectedTo,
                        items: _timeOptions,
                        hint: AppTexts.to,
                       // icon: Icons.access_time_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedTo = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTimeSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppTexts.addTimeSlot,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_errorMessage != null) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        if (widget.timeSlots.isNotEmpty) ...[
          SizedBox(height: 16.h),
          ...widget.timeSlots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      slot.day,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${slot.from} - ${slot.to}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _removeTimeSlot(index),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    child: Text(
                      '${AppTexts.remove} ×',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

