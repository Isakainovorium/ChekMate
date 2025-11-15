import 'package:flutter/material.dart';

/// Animated Widgets - Collection of reusable animated widgets
///
/// Provides common animation widgets for the dating experience platform.
///
/// Date: November 13, 2025

/// AnimatedFadeIn - Fade in animation widget
class AnimatedFadeIn extends StatefulWidget {
  const AnimatedFadeIn({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeIn,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// AnimatedSlideIn - Slide in animation widget
class AnimatedSlideIn extends StatefulWidget {
  const AnimatedSlideIn({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.direction = AxisDirection.down,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final AxisDirection direction;

  @override
  State<AnimatedSlideIn> createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    final begin = _getOffsetForDirection(widget.direction);
    _animation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _controller.forward();
  }

  Offset _getOffsetForDirection(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
        return const Offset(-1, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

/// AnimatedScale - Scale animation widget
class AnimatedScale extends StatefulWidget {
  const AnimatedScale({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.begin = 0.0,
    this.end = 1.0,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double begin;
  final double end;

  @override
  State<AnimatedScale> createState() => _AnimatedScaleState();
}

class _AnimatedScaleState extends State<AnimatedScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

