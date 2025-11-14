import 'package:flutter/material.dart';

/// TikTok-style Animations - Swipe and gesture-based animations
///
/// Provides TikTok-inspired animation widgets for the dating experience platform.
///
/// Date: November 13, 2025

/// SwipeableCard - Card that can be swiped left/right
class SwipeableCard extends StatefulWidget {
  const SwipeableCard({
    required this.child,
    super.key,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.threshold = 100.0,
  });

  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final double threshold;

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> {
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    if (dx.abs() > widget.threshold) {
      if (dx > 0 && widget.onSwipeRight != null) {
        widget.onSwipeRight!();
      } else if (dx < 0 && widget.onSwipeLeft != null) {
        widget.onSwipeLeft!();
      }
    } else if (dy.abs() > widget.threshold) {
      if (dy > 0 && widget.onSwipeDown != null) {
        widget.onSwipeDown!();
      } else if (dy < 0 && widget.onSwipeUp != null) {
        widget.onSwipeUp!();
      }
    }

    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: Transform.translate(
        offset: _dragOffset,
        child: widget.child,
      ),
    );
  }
}

/// DoubleTapAnimation - Animation triggered by double tap
class DoubleTapAnimation extends StatefulWidget {
  const DoubleTapAnimation({
    required this.child,
    required this.onDoubleTap,
    super.key,
    this.scale = 1.2,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final VoidCallback onDoubleTap;
  final double scale;
  final Duration duration;

  @override
  State<DoubleTapAnimation> createState() => _DoubleTapAnimationState();
}

class _DoubleTapAnimationState extends State<DoubleTapAnimation>
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
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onDoubleTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// PullToRefreshAnimation - Pull to refresh animation
class PullToRefreshAnimation extends StatefulWidget {
  const PullToRefreshAnimation({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<PullToRefreshAnimation> createState() => _PullToRefreshAnimationState();
}

class _PullToRefreshAnimationState extends State<PullToRefreshAnimation> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.child,
    );
  }
}

