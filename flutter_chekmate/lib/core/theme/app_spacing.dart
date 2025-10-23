import 'package:flutter/material.dart';

/// AppSpacing defines the spacing system for the ChekMate app.
/// Based on a 4px base unit matching the Figma design system.
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();
  
  // ========== BASE UNIT ==========
  /// Base spacing unit: 4px
  /// All spacing values are multiples of this base unit
  static const double base = 4.0;
  
  // ========== SPACING SCALE ==========
  /// Extra small spacing: 4px (base * 1)
  static const double xs = 4.0;
  
  /// Small spacing: 8px (base * 2)
  static const double sm = 8.0;
  
  /// Medium spacing: 16px (base * 4)
  static const double md = 16.0;
  
  /// Large spacing: 24px (base * 6)
  static const double lg = 24.0;
  
  /// Extra large spacing: 32px (base * 8)
  static const double xl = 32.0;
  
  /// Extra extra large spacing: 48px (base * 12)
  static const double xxl = 48.0;
  
  // ========== PADDING HELPERS ==========
  /// Padding: 4px all sides
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  
  /// Padding: 8px all sides
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  
  /// Padding: 16px all sides
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  
  /// Padding: 24px all sides
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  
  /// Padding: 32px all sides
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  /// Padding: 48px all sides
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
  
  // Horizontal padding
  /// Horizontal padding: 4px
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  
  /// Horizontal padding: 8px
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  
  /// Horizontal padding: 16px
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  
  /// Horizontal padding: 24px
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  
  /// Horizontal padding: 32px
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);
  
  // Vertical padding
  /// Vertical padding: 4px
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  
  /// Vertical padding: 8px
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  
  /// Vertical padding: 16px
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  
  /// Vertical padding: 24px
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  
  /// Vertical padding: 32px
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);
  
  // ========== BORDER RADIUS ==========
  /// Small border radius: 8px
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(8));
  
  /// Medium border radius: 12px
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(12));
  
  /// Large border radius: 16px
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(16));
  
  /// Extra large border radius: 24px
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(24));
  
  /// Full/circular border radius: 999px
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(999));
  
  // Circular radius values (for use with BorderRadius.circular())
  /// Small radius value: 8.0
  static const double radiusSMValue = 8.0;
  
  /// Medium radius value: 12.0
  static const double radiusMDValue = 12.0;
  
  /// Large radius value: 16.0
  static const double radiusLGValue = 16.0;
  
  /// Extra large radius value: 24.0
  static const double radiusXLValue = 24.0;
  
  // ========== COMMON SPACING PATTERNS ==========
  /// Page padding: 16px horizontal, 24px vertical
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );
  
  /// Card padding: 16px all sides
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  
  /// List item padding: 16px horizontal, 12px vertical
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 12,
  );
  
  /// Button padding: 24px horizontal, 12px vertical
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: 12,
  );
  
  /// Input padding: 16px horizontal, 12px vertical
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 12,
  );
  
  /// Dialog padding: 24px all sides
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);
  
  /// Bottom sheet padding: 16px horizontal, 24px vertical
  static const EdgeInsets bottomSheetPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );
  
  // ========== GAPS (for Row/Column spacing) ==========
  /// Extra small gap: 4px
  static const SizedBox gapXS = SizedBox(width: xs, height: xs);
  
  /// Small gap: 8px
  static const SizedBox gapSM = SizedBox(width: sm, height: sm);
  
  /// Medium gap: 16px
  static const SizedBox gapMD = SizedBox(width: md, height: md);
  
  /// Large gap: 24px
  static const SizedBox gapLG = SizedBox(width: lg, height: lg);
  
  /// Extra large gap: 32px
  static const SizedBox gapXL = SizedBox(width: xl, height: xl);
  
  /// Extra extra large gap: 48px
  static const SizedBox gapXXL = SizedBox(width: xxl, height: xxl);
}

