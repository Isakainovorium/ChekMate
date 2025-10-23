import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// TikTok-Style Animation Extensions
///
/// Provides reusable animation patterns inspired by TikTok's UI/UX:
/// - Fade-in animations
/// - Slide-in animations
/// - Scale animations
/// - Shimmer effects
/// - Bounce effects
/// - Stagger animations for lists
///
/// Usage:
/// ```dart
/// Text('Hello').animate().fadeInSlide()
///
/// ListView.builder(
///   itemBuilder: (context, index) {
///     return ListTile(title: Text('Item $index'))
///       .animate()
///       .fadeInSlide(delay: (index * 50).ms);
///   },
/// )
/// ```

/// Extension on Widget to add TikTok-style animations
extension TikTokAnimations on Widget {
  /// Fade in with slide from bottom (TikTok feed entry)
  ///
  /// Default: 600ms duration, slides from 50px below
  Animate fadeInSlide({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 600),
    double slideOffset = 50.0,
    Curve curve = Curves.easeOutCubic,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideY(
          begin: slideOffset / 100,
          end: 0,
          duration: duration,
          curve: curve,
        );
  }

  /// Fade in with slide from right (TikTok story entry)
  ///
  /// Default: 500ms duration, slides from 30px right
  Animate fadeInSlideRight({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 500),
    double slideOffset = 30.0,
    Curve curve = Curves.easeOutCubic,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideX(
          begin: slideOffset / 100,
          end: 0,
          duration: duration,
          curve: curve,
        );
  }

  /// Fade in with slide from left
  ///
  /// Default: 500ms duration, slides from 30px left
  Animate fadeInSlideLeft({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 500),
    double slideOffset = 30.0,
    Curve curve = Curves.easeOutCubic,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideX(
          begin: -slideOffset / 100,
          end: 0,
          duration: duration,
          curve: curve,
        );
  }

  /// Scale in with fade (TikTok like button)
  ///
  /// Default: 400ms duration, scales from 0.8 to 1.0
  Animate scaleIn({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
    double begin = 0.8,
    Curve curve = Curves.easeOutBack,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOut)
        .scale(
          begin: Offset(begin, begin),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: curve,
        );
  }

  /// Bounce in animation (TikTok notification)
  ///
  /// Default: 600ms duration with bounce effect
  Animate bounceIn({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return animate(delay: delay).fadeIn(duration: duration * 0.5).scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: Curves.elasticOut,
        );
  }

  /// Shimmer effect (TikTok loading)
  ///
  /// Default: 1500ms duration, repeats infinitely
  Animate shimmer({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 1500),
    Color? color,
  }) {
    return animate(delay: delay, onPlay: (controller) => controller.repeat())
        .shimmer(
      duration: duration,
      color: color ?? Colors.white.withValues(alpha: 0.5),
    );
  }

  /// Slide up reveal (TikTok comment section)
  ///
  /// Default: 400ms duration, slides from bottom
  Animate slideUpReveal({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) {
    return animate(delay: delay).slideY(
      begin: 1.0,
      end: 0,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide down reveal (TikTok top bar)
  ///
  /// Default: 400ms duration, slides from top
  Animate slideDownReveal({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) {
    return animate(delay: delay).slideY(
      begin: -1.0,
      end: 0,
      duration: duration,
      curve: curve,
    );
  }

  /// Pulse animation (TikTok live indicator)
  ///
  /// Default: 1000ms duration, repeats infinitely
  Animate pulse({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return animate(delay: delay, onPlay: (controller) => controller.repeat())
        .scale(
          begin: Offset(minScale, minScale),
          end: Offset(maxScale, maxScale),
          duration: duration * 0.5,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: Offset(maxScale, maxScale),
          end: Offset(minScale, minScale),
          duration: duration * 0.5,
          curve: Curves.easeInOut,
        );
  }

  /// Rotate in animation (TikTok loading spinner)
  ///
  /// Default: 800ms duration, rotates 360 degrees
  Animate rotateIn({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 800),
    double begin = 0.0,
    double end = 1.0,
  }) {
    return animate(delay: delay).fadeIn(duration: duration * 0.5).rotate(
          begin: begin,
          end: end,
          duration: duration,
          curve: Curves.easeOutBack,
        );
  }

  /// Flip in animation (TikTok card flip)
  ///
  /// Default: 600ms duration, flips on Y axis
  Animate flipIn({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return animate(delay: delay).flipV(
      begin: -0.5,
      end: 0,
      duration: duration,
      curve: Curves.easeOutBack,
    );
  }

  /// Blur in animation (TikTok background blur)
  ///
  /// Default: 500ms duration, blurs from 10 to 0
  Animate blurIn({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 500),
    double begin = 10.0,
  }) {
    return animate(delay: delay).blur(
      begin: Offset(begin, begin),
      end: Offset.zero,
      duration: duration,
      curve: Curves.easeOut,
    );
  }

  /// Stagger animation for list items (TikTok feed)
  ///
  /// Use with ListView.builder index
  /// ```dart
  /// itemBuilder: (context, index) {
  ///   return widget.staggeredFadeInSlide(index);
  /// }
  /// ```
  Animate staggeredFadeInSlide(
    int index, {
    Duration itemDelay = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 600),
    double slideOffset = 50.0,
  }) {
    return fadeInSlide(
      delay: itemDelay * index,
      duration: duration,
      slideOffset: slideOffset,
    );
  }

  /// Stagger animation for grid items (TikTok explore grid)
  ///
  /// Use with GridView.builder index
  Animate staggeredScaleIn(
    int index, {
    Duration itemDelay = const Duration(milliseconds: 40),
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return scaleIn(
      delay: itemDelay * index,
      duration: duration,
    );
  }
}

/// Pre-configured animation durations matching TikTok's timing
class TikTokDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration verySlow = Duration(milliseconds: 800);
  static const Duration stagger = Duration(milliseconds: 50);
}

/// Pre-configured animation curves matching TikTok's feel
class TikTokCurves {
  static const Curve entry = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.easeOutBack;
}
