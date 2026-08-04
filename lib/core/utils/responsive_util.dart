import 'package:flutter/material.dart';

class ResponsiveUtil {
  ResponsiveUtil._();

  /// Design screen width (e.g., iPhone 13/14)
  static const double _designWidth = 390.0;
  
  /// Scale factor based on screen width
  static double scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Lower the scale cap to prevent "too big" feeling on tablets
    return (width > 480 ? 480 : width) / _designWidth;
  }

  /// Responsive Font Size with aggressive cap
  static double fontSize(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    final scaleFactor = (width > 450 ? 450 : width) / _designWidth;
    return size * scaleFactor;
  }

  /// Responsive Spacing / Width / Height
  static double size(BuildContext context, double size) {
    return size * scale(context);
  }

  /// Helper to get optimal cross axis count for grids
  static int getGridCount(BuildContext context, {int base = 2}) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return base + 2;
    if (width > 600) return base + 1;
    return base;
  }

  /// Check if screen is small (e.g., iPhone SE)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if screen is large (e.g., Tablet)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }
}

extension ResponsiveExtension on BuildContext {
  double rs(double val) => ResponsiveUtil.size(this, val);
  double rf(double val) => ResponsiveUtil.fontSize(this, val);
  bool get isSmallScreen => ResponsiveUtil.isSmallScreen(this);
  bool get isTablet => ResponsiveUtil.isTablet(this);
}
