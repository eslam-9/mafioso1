import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Standardized spacing values for consistent UI
/// All values are responsive using ScreenUtil
class AppSpacing {
  // Prevent instantiation
  AppSpacing._();

  /// Extra small spacing: 4.0
  static double get xs => 4.w;

  /// Small spacing: 8.0
  static double get small => 8.w;

  /// Medium spacing: 16.0
  static double get medium => 16.w;

  /// Large spacing: 24.0
  static double get large => 24.w;

  /// Extra large spacing: 32.0
  static double get xlarge => 32.w;

  /// Extra extra large spacing: 48.0
  static double get xxlarge => 48.w;

  /// Minimum touch target size (accessibility)
  static double get minTouchTarget => 48.w;

  /// Standard page padding
  static double get pagePadding => 24.w;

  /// Standard card padding
  static double get cardPadding => 16.w;
}
