import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import 'calendar_format.dart';
import 'starting_day_of_week.dart';
import 'calendar_style.dart';
import 'header_style.dart';
import 'calendar_builders.dart';

class TableCalendar<T> extends StatefulWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final bool Function(DateTime) selectedDayPredicate;
  final void Function(DateTime, DateTime) onDaySelected;
  final CalendarFormat calendarFormat;
  final StartingDayOfWeek startingDayOfWeek;
  final CalendarStyle calendarStyle;
  final HeaderStyle headerStyle;
  final List<T> Function(DateTime) eventLoader;
  final CalendarBuilders<T>? calendarBuilders;

  const TableCalendar({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDayPredicate,
    required this.onDaySelected,
    required this.calendarFormat,
    required this.startingDayOfWeek,
    required this.calendarStyle,
    required this.headerStyle,
    required this.eventLoader,
    this.calendarBuilders,
  });

  @override
  State<TableCalendar<T>> createState() => _TableCalendarState<T>();
}

class _TableCalendarState<T> extends State<TableCalendar<T>> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
  }

  @override
  void didUpdateWidget(TableCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      _focusedDay = widget.focusedDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildHeader(), _buildCalendar()]);
  }

  Widget _buildHeader() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(widget.headerStyle.leftChevronIcon),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
          ),
          Text(
            '${monthNames[_focusedDay.month - 1]} ${_focusedDay.year}',
            style: widget.headerStyle.titleTextStyle,
          ),
          IconButton(
            icon: Icon(widget.headerStyle.rightChevronIcon),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final startOffset = widget.startingDayOfWeek == StartingDayOfWeek.sunday
        ? firstDayWeekday % 7
        : (firstDayWeekday + 6) % 7;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h),
          ...List.generate(((daysInMonth + startOffset) / 7).ceil(), (
            weekIndex,
          ) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - startOffset + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return Expanded(child: SizedBox());
                }

                final day = DateTime(
                  _focusedDay.year,
                  _focusedDay.month,
                  dayNumber,
                );
                final isSelected = widget.selectedDayPredicate(day);
                final isToday = _isToday(day);
                final events = widget.eventLoader(day);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.onDaySelected(day, day);
                      setState(() {
                        _focusedDay = day;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.calendarStyle.selectedDecoration?.color
                            : isToday
                            ? widget.calendarStyle.todayDecoration?.color
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : widget
                                          .calendarStyle
                                          .defaultTextStyle
                                          ?.color,
                              ),
                            ),
                          ),
                          if (events.isNotEmpty &&
                              widget.calendarBuilders?.markerBuilder != null)
                            Builder(
                              builder: (context) {
                                final marker = widget
                                    .calendarBuilders!
                                    .markerBuilder!(context, day, events);
                                if (marker != null) {
                                  return Positioned(bottom: 2, child: marker);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }
}
