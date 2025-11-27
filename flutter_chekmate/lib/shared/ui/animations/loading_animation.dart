import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

/// Loading Animation - ChekMate branded loader
class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({
    super.key,
    this.size = 60,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ChekMateLoaderPainter(
              progress: _controller.value,
              color: widget.color ?? AppColors.primary,
            ),
          );
        },
      ),
    );
  }
}

class _ChekMateLoaderPainter extends CustomPainter {
  _ChekMateLoaderPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw rotating arc
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Background circle (faint)
    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Animated arc
    final startAngle = progress * 2 * math.pi;
    final sweepAngle = math.sin(progress * math.pi) * math.pi + 0.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Pulsing center dot
    final dotRadius = 4 + math.sin(progress * 2 * math.pi) * 2;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(_ChekMateLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Simple pulsing loader
class PulsingLoader extends StatefulWidget {
  const PulsingLoader({
    super.key,
    this.size = 48,
  });

  final double size;

  @override
  State<PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<PulsingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFFFF8C00)],
                ),
                borderRadius: BorderRadius.circular(widget.size * 0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '✓',
                  style: TextStyle(
                    fontSize: widget.size * 0.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
