import 'package:flutter/material.dart';

class OptimizedScrollView extends StatelessWidget {
  final Widget child;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool primary;

  const OptimizedScrollView({
    super.key,
    required this.child,
    this.physics,
    this.controller,
    this.padding,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics ?? const ClampingScrollPhysics(),
      controller: controller,
      padding: padding,
      primary: primary,
      child: child,
    );
  }
}



