import 'package:flutter/material.dart';

/// App Animation Constants
///
/// Standardized animation durations and curves following Material Design 3
/// motion guidelines. Use these constants throughout the app for consistent
/// animation timing.
///
/// Reference: https://m3.material.io/styles/motion/overview
///
/// Sprint 3 - Task 3.1.1
/// Date: November 28, 2025

class AppAnimations {
  AppAnimations._();

  // ============================================================
  // DURATIONS
  // ============================================================

  /// Instant feedback (100ms)
  /// Use for: Ripples, state changes, micro-feedback
  static const Duration instant = Duration(milliseconds: 100);

  /// Fast transitions (200ms)
  /// Use for: Simple transitions, icon changes, small movements
  static const Duration fast = Duration(milliseconds: 200);

  /// Medium transitions (300ms)
  /// Use for: Page transitions, modal appearances, standard animations
  static const Duration medium = Duration(milliseconds: 300);

  /// Slow transitions (400ms)
  /// Use for: Complex transitions, emphasis animations
  static const Duration slow = Duration(milliseconds: 400);

  /// Emphasis transitions (500ms)
  /// Use for: Celebratory animations, important state changes
  static const Duration emphasis = Duration(milliseconds: 500);

  /// Long animations (800ms)
  /// Use for: Onboarding animations, splash screens
  static const Duration long = Duration(milliseconds: 800);

  // ============================================================
  // SEMANTIC DURATION ALIASES
  // ============================================================

  /// Page transition duration
  static const Duration pageTransition = medium;

  /// Tab switch duration
  static const Duration tabSwitch = medium;

  /// Modal/sheet appearance
  static const Duration modalAppear = medium;

  /// Micro-interaction (like, bookmark, etc.)
  static const Duration microInteraction = fast;

  /// Button press feedback
  static const Duration buttonFeedback = instant;

  /// Loading shimmer cycle
  static const Duration shimmerCycle = Duration(milliseconds: 1500);

  /// Stagger delay between list items
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Toast/snackbar display duration
  static const Duration toastDuration = Duration(seconds: 4);

  // ============================================================
  // CURVES
  // ============================================================

  /// Standard easing - use for most transitions
  static const Curve standard = Curves.easeInOut;

  /// Decelerate - use for entering elements
  static const Curve decelerate = Curves.easeOut;

  /// Accelerate - use for exiting elements
  static const Curve accelerate = Curves.easeIn;

  /// Emphasized - use for important transitions
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// Bounce - use for playful interactions
  static const Curve bounce = Curves.elasticOut;

  /// Sharp - use for quick, snappy animations
  static const Curve sharp = Curves.easeInOutCubic;

  /// Linear - use for continuous animations (loading, progress)
  static const Curve linear = Curves.linear;

  // ============================================================
  // SEMANTIC CURVE ALIASES
  // ============================================================

  /// Page enter curve
  static const Curve pageEnter = decelerate;

  /// Page exit curve
  static const Curve pageExit = accelerate;

  /// Modal enter curve
  static const Curve modalEnter = emphasized;

  /// Like/heart animation curve
  static const Curve likeAnimation = bounce;

  /// Scale animation curve
  static const Curve scaleAnimation = emphasized;

  // ============================================================
  // ANIMATION BUILDERS
  // ============================================================

  /// Create a standard fade transition
  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Create a standard slide transition (from right)
  static Widget slideFromRight({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: standard,
      )),
      child: child,
    );
  }

  /// Create a standard slide transition (from bottom)
  static Widget slideFromBottom({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: decelerate,
      )),
      child: child,
    );
  }

  /// Create a scale transition
  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
    double beginScale = 0.8,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: beginScale,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: emphasized,
      )),
      child: child,
    );
  }

  /// Create a combined fade + scale transition
  static Widget fadeScaleTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: emphasized,
        )),
        child: child,
      ),
    );
  }

  // ============================================================
  // STAGGER HELPERS
  // ============================================================

  /// Calculate stagger delay for list item
  static Duration getStaggerDelay(int index, {int maxItems = 10}) {
    // Cap the stagger effect to avoid long delays
    final effectiveIndex = index.clamp(0, maxItems);
    return Duration(milliseconds: effectiveIndex * staggerDelay.inMilliseconds);
  }

  /// Calculate stagger interval for AnimationController
  static Interval getStaggerInterval(
    int index, {
    int totalItems = 10,
    double overlapFactor = 0.5,
  }) {
    final start = (index / totalItems) * overlapFactor;
    final end = start + (1 - overlapFactor);
    return Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0));
  }
}

/// Extension to easily apply standard animations to widgets
extension AnimationExtensions on Widget {
  /// Wrap with animated opacity
  Widget animatedOpacity({
    required bool visible,
    Duration duration = AppAnimations.fast,
    Curve curve = AppAnimations.standard,
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  /// Wrap with animated scale
  Widget animatedScale({
    required double scale,
    Duration duration = AppAnimations.fast,
    Curve curve = AppAnimations.emphasized,
  }) {
    return AnimatedScale(
      scale: scale,
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  /// Wrap with animated container for size changes
  Widget animatedSize({
    Duration duration = AppAnimations.medium,
    Curve curve = AppAnimations.standard,
    Alignment alignment = Alignment.center,
  }) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: this,
    );
  }
}
