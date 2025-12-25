import 'package:flutter/material.dart';

class PerformanceUtils {
  static const double defaultCacheExtent = 500.0;
  static const bool defaultAddAutomaticKeepAlives = true;
  static const bool defaultAddRepaintBoundaries = true;
  
  static Widget wrapWithRepaintBoundary({
    required Widget child,
    String? key,
  }) {
    return RepaintBoundary(
      key: key != null ? ValueKey(key) : null,
      child: child,
    );
  }
  
  static ScrollPhysics getDefaultScrollPhysics() {
    return const AlwaysScrollableScrollPhysics();
  }
}

