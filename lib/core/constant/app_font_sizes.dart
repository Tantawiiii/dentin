import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized font size constants for the app
/// All font sizes use ScreenUtil (.sp) for responsive sizing
final class AppFontSizes {
  AppFontSizes._();

  // Display Sizes
  static double get displayLarge => 32.sp;
  static double get displayMedium => 28.sp;
  static double get displaySmall => 24.sp;

  // Headline Sizes
  static double get headlineLarge => 22.sp;
  static double get headlineMedium => 20.sp;
  static double get headlineSmall => 18.sp;

  // Title Sizes
  static double get titleLarge => 16.sp;
  static double get titleMedium => 14.sp;
  static double get titleSmall => 12.sp;

  // Body Sizes
  static double get bodyLarge => 15.sp;
  static double get bodyMedium => 14.sp;
  static double get bodySmall => 12.sp;

  // Label Sizes
  static double get labelLarge => 14.sp;
  static double get labelMedium => 12.sp;
  static double get labelSmall => 10.sp;

  // Button Sizes
  static double get buttonLarge => 16.sp;
  static double get buttonMedium => 14.sp;
  static double get buttonSmall => 12.sp;

  // Custom Sizes (commonly used)
  static double get extraSmall => 10.sp;
  static double get small => 12.sp;
  static double get medium => 14.sp;
  static double get large => 16.sp;
  static double get extraLarge => 18.sp;
  static double get huge => 20.sp;
}
