import 'package:flutter/widgets.dart';

/// AppSpacing - Consistent spacing constants for the dating experience platform
///
/// Provides standardized spacing values used throughout the application
/// for consistent UI spacing and layout.
///
/// Date: November 13, 2025
class AppSpacing {
  AppSpacing._();

  /// Extra small spacing (4.0)
  static const double xs = 4.0;

  /// Small spacing (8.0)
  static const double sm = 8.0;

  /// Medium spacing (12.0)
  static const double md = 12.0;

  /// Large spacing (16.0)
  static const double lg = 16.0;

  /// Extra large spacing (24.0)
  static const double xl = 24.0;

  /// 2XL spacing (32.0)
  static const double xxl = 32.0;

  /// 3XL spacing (48.0)
  static const double xxxl = 48.0;

  // Gap widgets for vertical spacing

  /// Extra small gap (4.0)
  static const Widget gapXS = SizedBox(height: xs);

  /// Small gap (8.0)
  static const Widget gapSM = SizedBox(height: sm);

  /// Medium gap (12.0)
  static const Widget gapMD = SizedBox(height: md);

  /// Large gap (16.0)
  static const Widget gapLG = SizedBox(height: lg);

  /// Extra large gap (24.0)
  static const Widget gapXL = SizedBox(height: xl);

  /// 2XL gap (32.0)
  static const Widget gapXXL = SizedBox(height: xxl);

  /// 3XL gap (48.0)
  static const Widget gapXXXL = SizedBox(height: xxxl);

  // Horizontal gap widgets

  /// Extra small horizontal gap (4.0)
  static const Widget hGapXS = SizedBox(width: xs);

  /// Small horizontal gap (8.0)
  static const Widget hGapSM = SizedBox(width: sm);

  /// Medium horizontal gap (12.0)
  static const Widget hGapMD = SizedBox(width: md);

  /// Large horizontal gap (16.0)
  static const Widget hGapLG = SizedBox(width: lg);

  /// Extra large horizontal gap (24.0)
  static const Widget hGapXL = SizedBox(width: xl);

  /// 2XL horizontal gap (32.0)
  static const Widget hGapXXL = SizedBox(width: xxl);

  /// 3XL horizontal gap (48.0)
  static const Widget hGapXXXL = SizedBox(width: xxxl);
}
