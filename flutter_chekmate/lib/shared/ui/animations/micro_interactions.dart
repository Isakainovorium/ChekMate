import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Micro-Interactions for ChekMate
///
/// Collection of subtle, delightful animations that make the app feel alive
/// Based on 2025 Flutter animation best practices
///
/// Features:
/// - Button tap feedback
/// - Icon animations
/// - Ripple effects
/// - Bounce effects
/// - Pulse animations
/// - Shake animations
/// - Success/error feedback

/// Animated Button with Tap Feedback
///
/// Scales down on tap, bounces back on release
class AnimatedTapButton extends StatefulWidget {
  const AnimatedTapButton({
    required this.child,
    required this.onTap,
    super.key,
    this.scaleAmount = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  final Widget child;
  final VoidCallback onTap;
  final double scaleAmount;
  final Duration duration;

  @override
  State<AnimatedTapButton> createState() => _AnimatedTapButtonState();
}

class _AnimatedTapButtonState extends State<AnimatedTapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleAmount,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Pulsing Badge (for notifications, live indicators)
class PulsingBadge extends StatelessWidget {
  const PulsingBadge({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scale(
          begin: Offset(minScale, minScale),
          end: Offset(maxScale, maxScale),
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}

/// Shake Animation (for errors, invalid input)
class ShakeWidget extends StatelessWidget {
  const ShakeWidget({
    required this.child,
    super.key,
    this.shakeCount = 3,
    this.shakeOffset = 10.0,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final int shakeCount;
  final double shakeOffset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child.animate().shake(
          hz: shakeCount.toDouble(),
          offset: Offset(shakeOffset, 0),
          duration: duration,
        );
  }
}

/// Bounce Animation (for success feedback)
class BounceWidget extends StatelessWidget {
  const BounceWidget({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child.animate().scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: Curves.elasticOut,
        );
  }
}

/// Shimmer Loading Effect
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: duration,
          color: Colors.white.withValues(alpha: 0.5),
        );
  }
}

/// Ripple Effect (for taps, interactions)
class RippleEffect extends StatefulWidget {
  const RippleEffect({
    required this.child,
    required this.onTap,
    super.key,
    this.rippleColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color? rippleColor;

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: widget.rippleColor ??
            Theme.of(context).primaryColor.withValues(alpha: 0.2),
        highlightColor: widget.rippleColor?.withValues(alpha: 0.1) ??
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: widget.child,
      ),
    );
  }
}

/// Floating Animation (for floating action buttons)
class FloatingAnimation extends StatelessWidget {
  const FloatingAnimation({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 2000),
    this.offset = 5.0,
  });

  final Widget child;
  final Duration duration;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: -offset,
          end: offset,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}

/// Success Checkmark Animation
class SuccessCheckmark extends StatelessWidget {
  const SuccessCheckmark({
    super.key,
    this.size = 60,
    this.color = Colors.green,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.check_circle,
      size: size,
      color: color,
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 200.ms);
  }
}

/// Stagger Animation Extension
///
/// Adds staggered animations to lists
extension StaggerAnimation on Widget {
  Widget staggeredFadeIn({
    required int index,
    int itemsPerRow = 1,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 400),
  }) {
    final itemDelay = delay * index;
    return animate(delay: itemDelay)
        .fadeIn(duration: duration, curve: Curves.easeOut)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}
