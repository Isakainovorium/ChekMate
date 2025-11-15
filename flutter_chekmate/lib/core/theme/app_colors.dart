import 'package:flutter/material.dart';

/// AppColors - ChekMate brand colors and semantic color palette
///
/// Provides consistent color values used throughout the ChekMate application
/// for branding, UI elements, and semantic states.
///
/// Date: January 15, 2025
class AppColors {
  AppColors._();

  // ============================================================================
  // BRAND COLORS
  // ============================================================================
  
  /// Primary brand color - Golden Orange (#F5A623)
  /// Used for: Primary buttons, active states, brand elements
  static const Color primary = Color(0xFFF5A623);

  /// Secondary brand color - Primary Red (#FF6B6B)
  /// Used for: Accent elements, highlights, love/like actions
  static const Color secondary = Color(0xFFFF6B6B);

  /// Navy Blue - Professional accent color
  /// Used for: Text emphasis, secondary actions, professional elements
  static const Color navyBlue = Color(0xFF1E3A8A);

  // ============================================================================
  // SURFACE COLORS (Light Mode)
  // ============================================================================
  
  /// Background color for the app (light mode)
  static const Color background = Color(0xFFFFFFFF);

  /// Surface color for cards and containers (light mode)
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant for subtle backgrounds (light mode)
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  /// Surface container for elevated elements (light mode)
  static const Color surfaceContainer = Color(0xFFFAFAFA);

  // ============================================================================
  // TEXT COLORS (Light Mode)
  // ============================================================================
  
  /// Primary text color (light mode)
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text color (light mode)
  static const Color textSecondary = Color(0xFF6B7280);

  /// Tertiary text color (light mode)
  static const Color textTertiary = Color(0xFF9CA3AF);

  /// Disabled text color (light mode)
  static const Color textDisabled = Color(0xFFD1D5DB);

  // ============================================================================
  // BORDER & DIVIDER COLORS
  // ============================================================================
  
  /// Border color for inputs, cards, dividers
  static const Color border = Color(0xFFE5E7EB);

  /// Divider color for separators
  static const Color divider = Color(0xFFF3F4F6);

  /// Outline color for focused elements
  static const Color outline = Color(0xFFD1D5DB);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  
  /// Success color - Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  /// Error color - Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  /// Warning color - Orange
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  /// Info color - Blue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ============================================================================
  // DARK MODE COLORS
  // ============================================================================
  
  /// Background color for the app (dark mode)
  static const Color backgroundDark = Color(0xFF121212);

  /// Surface color for cards and containers (dark mode)
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Surface variant for subtle backgrounds (dark mode)
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  /// Surface container for elevated elements (dark mode)
  static const Color surfaceContainerDark = Color(0xFF252525);

  /// Primary text color (dark mode)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Secondary text color (dark mode)
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  /// Tertiary text color (dark mode)
  static const Color textTertiaryDark = Color(0xFF808080);

  /// Border color (dark mode)
  static const Color borderDark = Color(0xFF3A3A3A);

  /// Divider color (dark mode)
  static const Color dividerDark = Color(0xFF2C2C2C);

  // ============================================================================
  // SOCIAL FEATURE COLORS
  // ============================================================================
  
  /// Like/Love action color
  static const Color like = Color(0xFFFF6B6B);

  /// Comment action color
  static const Color comment = Color(0xFF3B82F6);

  /// Share action color
  static const Color share = Color(0xFF10B981);

  /// Bookmark/Save action color
  static const Color bookmark = Color(0xFFF59E0B);

  /// Live streaming indicator color
  static const Color live = Color(0xFFEF4444);

  /// Story ring gradient colors
  static const List<Color> storyGradient = [
    Color(0xFFF59E0B), // Orange
    Color(0xFFEF4444), // Red
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
  ];

  // ============================================================================
  // RATING COLORS (for Rate Your Date feature)
  // ============================================================================
  
  /// Excellent rating (9-10)
  static const Color ratingExcellent = Color(0xFF10B981);

  /// Good rating (7-8)
  static const Color ratingGood = Color(0xFF3B82F6);

  /// Average rating (5-6)
  static const Color ratingAverage = Color(0xFFF59E0B);

  /// Poor rating (3-4)
  static const Color ratingPoor = Color(0xFFEF4444);

  /// Very poor rating (1-2)
  static const Color ratingVeryPoor = Color(0xFF991B1B);

  // ============================================================================
  // SUBSCRIPTION TIER COLORS
  // ============================================================================
  
  /// Free tier color
  static const Color tierFree = Color(0xFF6B7280);

  /// Premium tier color
  static const Color tierPremium = Color(0xFFF59E0B);

  /// VIP tier color
  static const Color tierVIP = Color(0xFF8B5CF6);

  // ============================================================================
  // UTILITY COLORS
  // ============================================================================
  
  /// Overlay color for modals and dialogs
  static const Color overlay = Color(0x80000000);

  /// Shimmer base color (light mode)
  static const Color shimmerBase = Color(0xFFE5E7EB);

  /// Shimmer highlight color (light mode)
  static const Color shimmerHighlight = Color(0xFFF9FAFB);

  /// Shimmer base color (dark mode)
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);

  /// Shimmer highlight color (dark mode)
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);

  /// Shadow color
  static const Color shadow = Color(0x1A000000);

  /// Focus ring color
  static const Color focusRing = Color(0xFF3B82F6);

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get rating color based on score (1-10)
  static Color getRatingColor(int score) {
    if (score >= 9) return ratingExcellent;
    if (score >= 7) return ratingGood;
    if (score >= 5) return ratingAverage;
    if (score >= 3) return ratingPoor;
    return ratingVeryPoor;
  }

  /// Get tier color based on tier name
  static Color getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'premium':
        return tierPremium;
      case 'vip':
        return tierVIP;
      default:
        return tierFree;
    }
  }

  /// Get semantic color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}

