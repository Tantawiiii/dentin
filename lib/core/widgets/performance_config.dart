import 'package:flutter/foundation.dart';

class PerformanceConfig {
  static void configure() {
    if (kDebugMode) {
      // Enable performance overlay in debug mode if needed
      // debugPaintSizeEnabled = false;
      // debugRepaintRainbowEnabled = false;
    }
  }

  static const double defaultCacheExtent = 500.0;
  static const bool defaultAddAutomaticKeepAlives = true;
  static const bool defaultAddRepaintBoundaries = true;
  static const bool defaultAddSemanticIndexes = true;
}

