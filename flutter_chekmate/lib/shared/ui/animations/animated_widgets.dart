import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_chekmate/shared/ui/animations/tiktok_animations.dart';

/// Animated Widgets Collection
///
/// Pre-built animated widgets using TikTok-style animations.
/// These widgets wrap common UI components with smooth animations.
///
/// Usage:
/// ```dart
/// AnimatedFeedCard(
///   index: 0,
///   child: PostWidget(post: post),
/// )
///
/// AnimatedStoryCircle(
///   index: 0,
///   child: StoryCircle(story: story),
/// )
/// ```

/// Animated Feed Card
///
/// Wraps feed items with fade-in slide animation
/// Automatically staggers based on index
class AnimatedFeedCard extends StatelessWidget {
  const AnimatedFeedCard({
    required this.child,
    super.key,
    this.index = 0,
    this.delay,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget child;
  final int index;
  final Duration? delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay ?? (index * 50).ms)
        .fadeIn(
          duration: duration,
          curve: TikTokCurves.entry,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: duration,
          curve: TikTokCurves.entry,
        );
  }
}

/// Animated Story Circle
///
/// Wraps story circles with scale-in animation
/// Automatically staggers based on index
class AnimatedStoryCircle extends StatelessWidget {
  const AnimatedStoryCircle({
    required this.child,
    super.key,
    this.index = 0,
    this.delay,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final int index;
  final Duration? delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay ?? (index * 40).ms)
        .fadeIn(duration: duration * 0.6, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: TikTokCurves.spring,
        );
  }
}

/// Animated Grid Item
///
/// Wraps grid items (explore, profile photos) with scale-in animation
/// Automatically staggers based on index
class AnimatedGridItem extends StatelessWidget {
  const AnimatedGridItem({
    required this.child,
    super.key,
    this.index = 0,
    this.delay,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final int index;
  final Duration? delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay ?? (index * 30).ms)
        .fadeIn(duration: duration * 0.6)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: Curves.easeOutBack,
        );
  }
}

/// Animated List Item
///
/// Wraps list items (messages, notifications) with slide-in animation
/// Automatically staggers based on index
class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    required this.child,
    super.key,
    this.index = 0,
    this.delay,
    this.duration = const Duration(milliseconds: 500),
    this.slideDirection = SlideDirection.left,
  });

  final Widget child;
  final int index;
  final Duration? delay;
  final Duration duration;
  final SlideDirection slideDirection;

  @override
  Widget build(BuildContext context) {
    final slideOffset = slideDirection == SlideDirection.left ? -0.3 : 0.3;

    return child
        .animate(delay: delay ?? (index * 40).ms)
        .fadeIn(duration: duration * 0.6)
        .slideX(
          begin: slideOffset,
          end: 0,
          duration: duration,
          curve: TikTokCurves.entry,
        );
  }
}

/// Animated Button
///
/// Wraps buttons with scale animation on tap
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    required this.child,
    super.key,
    this.onTap,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
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
      end: widget.scaleDown,
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

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated Icon Button
///
/// Icon button with bounce animation on tap
class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton({
    required this.icon,
    super.key,
    this.onTap,
    this.size = 24.0,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(
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

  Future<void> _handleTap() async {
    await _controller.forward();
    _controller.reset();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.icon,
          size: widget.size,
          color: widget.color,
        ),
      ),
    );
  }
}

/// Animated Counter
///
/// Animates number changes (likes, views, etc.)
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    required this.count,
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.style,
  });

  final int count;
  final Duration duration;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }
}

/// Slide Direction enum
enum SlideDirection {
  left,
  right,
  up,
  down,
}
