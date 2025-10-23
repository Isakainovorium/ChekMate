import 'package:flutter/material.dart';

/// Typing Indicator Widget
///
/// Displays animated dots to indicate that someone is typing.
/// Features:
/// - Three animated dots with staggered bounce animation
/// - Smooth continuous loop
/// - Customizable colors and sizes
/// - Lightweight and performant
///
/// Usage:
/// ```dart
/// if (isTyping)
///   TypingIndicator()
/// ```
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    super.key,
    this.dotSize = 8.0,
    this.dotColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final double dotSize;
  final Color? dotColor;
  final Color? backgroundColor;
  final EdgeInsets padding;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDotColor = widget.dotColor ?? Colors.grey.shade600;
    final effectiveBackgroundColor =
        widget.backgroundColor ?? Colors.grey.shade200;

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTypingDot(0, effectiveDotColor),
          const SizedBox(width: 4),
          _buildTypingDot(1, effectiveDotColor),
          const SizedBox(width: 4),
          _buildTypingDot(2, effectiveDotColor),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index, Color color) {
    // Stagger the animation for each dot
    final delay = index * 0.2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate the bounce offset with stagger
        final value = (_controller.value - delay) % 1.0;
        final bounce = value < 0.5
            ? Curves.easeOut.transform(value * 2)
            : Curves.easeIn.transform((1 - value) * 2);
        final offset = -6 * bounce;

        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
