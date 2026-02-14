import 'package:flutter/material.dart';

class CalendarBuilders<T> {
  final Widget? Function(BuildContext, DateTime, List<T>)? markerBuilder;

  const CalendarBuilders({this.markerBuilder});
}
