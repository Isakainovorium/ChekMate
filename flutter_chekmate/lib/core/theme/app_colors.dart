import 'package:flutter/material.dart';

/// App color palette for ChekMate
/// Colors extracted from official ChekMate brand logo
/// Extraction date: 2025-10-09
/// Source: CheckMate Logo.png (MCP color extraction process)
class AppColors {
  // ========== PRIMARY BRAND COLORS ==========
  /// Main brand color - Golden/Amber (#FEBD59)
  /// This is the primary golden color from the ChekMate logo (81.1% of logo)
  static const Color primary = Color(0xFFFEBD59);
  static const Color primaryLight = Color(0xFFFDD698); // Lighter golden tint
  static const Color primaryDark = Color(0xFFDF912F); // Darker gold accent

  /// Navy Blue - Brand color from logo text (#2D497B)
  /// Used for text "KMATE" in logo and important UI elements (2.5% of logo)
  static const Color navyBlue = Color(0xFF2D497B);
  static const Color navyBlueLight = Color(0xFF3D5A8F);
  static const Color navyBlueDark = Color(0xFF1D3967);

  /// Secondary brand color - Darker Gold (#DF912F)
  /// Accent shade of gold used in the logo (2.1% of logo)
  static const Color secondary = Color(0xFFDF912F);

  /// Accent color - Light golden tint
  static const Color accent = Color(0xFFFDD698);

  // ========== NEUTRAL COLORS ==========
  /// Backgrounds
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Light gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light gray

  /// Text colors
  static const Color textPrimary = Color(0xFF000000); // Black
  static const Color textSecondary = Color(0xFF666666); // Gray
  static const Color textTertiary = Color(0xFF999999); // Light gray
  static const Color textDisabled = Color(0xFFBDBDBD); // Very light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White (for orange backgrounds)

  /// Border colors
  static const Color border = Color(0xFFE0E0E0); // Light gray
  static const Color borderLight = Color(0xFFEEEEEE); // Very light gray
  static const Color borderDark = Color(0xFFBDBDBD); // Medium gray

  // ========== STATUS COLORS ==========
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFF44336); // Red
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Blue

  // ========== INPUT COLORS ==========
  static const Color inputBackground = Color(0xFFFFFFFF); // White
  static const Color inputBorder = Color(0xFFE0E0E0); // Light gray
  static const Color inputBorderFocused = Color(0xFFFEBD59); // Golden (primary)
  static const Color inputBorderError = Color(0xFFF44336); // Red
  static const Color inputPlaceholder = Color(0xFF999999); // Light gray

  // ========== SOCIAL INTERACTION COLORS ==========
  static const Color like = Color(0xFFF44336); // Red (heart)
  static const Color comment = Color(0xFF666666); // Gray
  static const Color share = Color(0xFF666666); // Gray
  static const Color bookmark = Color(0xFFFEBD59); // Golden (primary)

  // ========== LIVE STREAMING COLORS ==========
  static const Color liveBadge = Color(0xFFF44336); // Red
  static const Color liveText = Color(0xFFFFFFFF); // White

  // ========== RATING COLORS (Rate Your Date) ==========
  static const Color ratingPass = Color(0xFFF44336); // Red (X)
  static const Color ratingSuperLike = Color(0xFF2196F3); // Blue (Star)
  static const Color ratingLike = Color(0xFF4CAF50); // Green (Heart)

  // ========== GRADIENT COLORS ==========
  /// Primary gradient: Golden to Darker Gold (used in branding)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFEBD59), Color(0xFFDF912F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Profile card gradient: Light gold to primary gold
  static const LinearGradient profileGradient = LinearGradient(
    colors: [Color(0xFFFDD698), Color(0xFFFEBD59)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Button gradient: Primary gold to darker gold
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFFFEBD59), Color(0xFFDF912F)],
  );

  // ========== OVERLAY COLORS ==========
  static const Color overlay = Color(0x80000000); // Black 50%
  static const Color overlayLight = Color(0x40000000); // Black 25%
  static const Color overlayDark = Color(0xB3000000); // Black 70%
  static const Color overlayWhite = Color(0x80FFFFFF); // White 50%

  // ========== SHIMMER/LOADING COLORS ==========
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ========== NAVIGATION COLORS ==========
  static const Color navActive = Color(0xFFFEBD59); // Golden (primary)
  static const Color navInactive = Color(0xFF999999); // Gray
  static const Color navBackground = Color(0xFFFFFFFF); // White
  static const Color navBorder = Color(0xFFE0E0E0); // Light gray

  // ========== BADGE COLORS ==========
  static const Color badgeBackground = Color(0xFFFEBD59); // Golden (primary)
  static const Color badgeText = Color(0xFFFFFFFF); // White
  static const Color notificationBadge = Color(0xFFF44336); // Red

  // ========== DARK THEME COLORS (Future Use) ==========
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkBorder = Color(0xFF333333);
}
