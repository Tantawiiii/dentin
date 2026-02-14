import 'package:flutter/material.dart';

class HeaderStyle {
  final bool formatButtonVisible;
  final bool titleCentered;
  final TextStyle? titleTextStyle;
  final IconData? leftChevronIcon;
  final IconData? rightChevronIcon;

  const HeaderStyle({
    this.formatButtonVisible = true,
    this.titleCentered = false,
    this.titleTextStyle,
    this.leftChevronIcon,
    this.rightChevronIcon,
  });
}
