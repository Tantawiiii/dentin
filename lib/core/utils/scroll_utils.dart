import 'package:flutter/material.dart';

/// Scroll utilities for optimized scrolling
class ScrollUtils {
  ScrollUtils._();

  /// Check if scroll position is near bottom
  static bool isNearBottom(
    ScrollController controller, {
    double threshold = 0.8,
  }) {
    if (!controller.hasClients) return false;
    final position = controller.position;
    return position.pixels >= position.maxScrollExtent * threshold;
  }

  /// Check if scroll position is at top
  static bool isAtTop(ScrollController controller) {
    if (!controller.hasClients) return false;
    return controller.position.pixels <= 0;
  }

  /// Scroll to top smoothly
  static Future<void> scrollToTop(ScrollController controller) async {
    if (!controller.hasClients) return;
    await controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Scroll to bottom smoothly
  static Future<void> scrollToBottom(ScrollController controller) async {
    if (!controller.hasClients) return;
    await controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

