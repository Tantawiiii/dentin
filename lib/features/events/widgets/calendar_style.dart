import 'package:flutter/material.dart';

class CalendarStyle {
  final bool outsideDaysVisible;
  final TextStyle? weekendTextStyle;
  final TextStyle? defaultTextStyle;
  final BoxDecoration? selectedDecoration;
  final BoxDecoration? todayDecoration;
  final BoxDecoration? markerDecoration;

  const CalendarStyle({
    this.outsideDaysVisible = false,
    this.weekendTextStyle,
    this.defaultTextStyle,
    this.selectedDecoration,
    this.todayDecoration,
    this.markerDecoration,
  });
}
