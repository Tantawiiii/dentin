import 'package:flutter/material.dart';

/// Performance utilities for optimizing Flutter app performance
class PerformanceUtils {
  PerformanceUtils._();

  /// Creates a const SizedBox with zero size for better performance
  static const Widget empty = SizedBox.shrink();

  /// Creates a const SizedBox with zero width
  static const Widget emptyWidth = SizedBox(width: 0);

  /// Creates a const SizedBox with zero height
  static const Widget emptyHeight = SizedBox(height: 0);

  /// Debounce function to limit function calls
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    Future.delayed(delay, callback);
  }

  /// Throttle function to limit function calls
  static DateTime? _lastThrottleCall;
  static void throttle(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    final now = DateTime.now();
    if (_lastThrottleCall == null ||
        now.difference(_lastThrottleCall!) > delay) {
      _lastThrottleCall = now;
      callback();
    }
  }
}

/// Extension for BuildContext to check if widget is mounted
extension BuildContextExtension on BuildContext {
  /// Safely check if widget is mounted before calling setState
  bool get isMounted => mounted;
}
