import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// App Haptics
///
/// Centralized haptic feedback utility with graceful fallback for
/// platforms that don't support haptics (web, some desktop).
///
/// Usage:
/// ```dart
/// await AppHaptics.light();
/// await AppHaptics.medium();
/// await AppHaptics.heavy();
/// await AppHaptics.selection();
/// ```
///
/// Sprint 3 - Task 3.3.1
/// Date: November 28, 2025

class AppHaptics {
  AppHaptics._();

  /// Light impact feedback
  /// Use for: Button taps, selections, toggles
  static Future<void> light() async {
    if (_shouldSkipHaptics) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Silently fail on unsupported platforms
    }
  }

  /// Medium impact feedback
  /// Use for: Confirmations, successful actions
  static Future<void> medium() async {
    if (_shouldSkipHaptics) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Silently fail on unsupported platforms
    }
  }

  /// Heavy impact feedback
  /// Use for: Important actions, errors, warnings
  static Future<void> heavy() async {
    if (_shouldSkipHaptics) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Silently fail on unsupported platforms
    }
  }

  /// Selection click feedback
  /// Use for: Picker selections, list item selections
  static Future<void> selection() async {
    if (_shouldSkipHaptics) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Silently fail on unsupported platforms
    }
  }

  /// Vibrate feedback
  /// Use for: Notifications, alerts
  static Future<void> vibrate() async {
    if (_shouldSkipHaptics) return;

    try {
      await HapticFeedback.vibrate();
    } catch (_) {
      // Silently fail on unsupported platforms
    }
  }

  /// Success feedback pattern
  /// Use for: Successful form submissions, completed actions
  static Future<void> success() async {
    await light();
    await Future.delayed(const Duration(milliseconds: 100));
    await medium();
  }

  /// Error feedback pattern
  /// Use for: Validation errors, failed actions
  static Future<void> error() async {
    await heavy();
    await Future.delayed(const Duration(milliseconds: 100));
    await heavy();
  }

  /// Warning feedback pattern
  /// Use for: Warnings, confirmations needed
  static Future<void> warning() async {
    await medium();
    await Future.delayed(const Duration(milliseconds: 150));
    await light();
  }

  /// Check if haptics should be skipped
  static bool get _shouldSkipHaptics {
    // Skip on web
    if (kIsWeb) return true;

    // Could add user preference check here
    // if (!UserPreferences.hapticsEnabled) return true;

    return false;
  }

  /// Check if haptics are supported on current platform
  static bool get isSupported => !kIsWeb;
}

/// Extension to easily add haptic feedback to callbacks
extension HapticCallbackExtension on VoidCallback {
  /// Wrap callback with light haptic feedback
  VoidCallback withLightHaptic() {
    return () {
      AppHaptics.light();
      this();
    };
  }

  /// Wrap callback with medium haptic feedback
  VoidCallback withMediumHaptic() {
    return () {
      AppHaptics.medium();
      this();
    };
  }

  /// Wrap callback with selection haptic feedback
  VoidCallback withSelectionHaptic() {
    return () {
      AppHaptics.selection();
      this();
    };
  }
}

/// Extension for async callbacks
extension HapticAsyncCallbackExtension on Future<void> Function() {
  /// Wrap async callback with light haptic feedback
  Future<void> Function() withLightHaptic() {
    return () async {
      await AppHaptics.light();
      await this();
    };
  }

  /// Wrap async callback with success haptic pattern
  Future<void> Function() withSuccessHaptic() {
    return () async {
      await this();
      await AppHaptics.success();
    };
  }
}
