import 'package:flutter/material.dart';

/// Navigation utilities for optimized routing
class NavigationUtils {
  NavigationUtils._();

  /// Navigate with fade transition for better performance
  static Future<T?> navigateWithFade<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  /// Navigate with slide transition
  static Future<T?> navigateWithSlide<T>(
    BuildContext context,
    Widget page, {
    bool fromRight = true,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(fromRight ? 1.0 : -1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  /// Pop with result
  static void popWithResult<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  /// Pop until condition
  static void popUntil(
    BuildContext context,
    bool Function(Route<dynamic>) predicate,
  ) {
    Navigator.of(context).popUntil(predicate);
  }
}
