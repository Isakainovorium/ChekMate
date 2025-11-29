import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

/// Success Animation - Animated checkmark with celebration
class SuccessAnimation extends StatefulWidget {
  const SuccessAnimation({
    super.key,
    this.size = 120,
    this.onComplete,
  });

  final double size;
  final VoidCallback? onComplete;

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _circleController;
  late AnimationController _particleController;

  late Animation<double> _checkAnimation;
  late Animation<double> _circleScale;
  late Animation<double> _circleOpacity;

  @override
  void initState() {
    super.initState();

    // Circle animation
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _circleScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.elasticOut),
    );
    _circleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeOut),
    );

    // Checkmark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack),
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _circleController.forward();
    await _checkController.forward();
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _circleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ParticlePainter(
                  progress: _particleController.value,
                  color: AppColors.success,
                ),
              );
            },
          ),

          // Circle background
          AnimatedBuilder(
            animation: _circleController,
            builder: (context, child) {
              return Transform.scale(
                scale: _circleScale.value,
                child: Opacity(
                  opacity: _circleOpacity.value,
                  child: Container(
                    width: widget.size * 0.7,
                    height: widget.size * 0.7,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.success, Color(0xFF059669)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Checkmark
          AnimatedBuilder(
            animation: _checkController,
            builder: (context, child) {
              return Transform.scale(
                scale: _checkAnimation.value,
                child: Icon(
                  Icons.check_rounded,
                  size: widget.size * 0.4,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final particleCount = 8;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = size.width * 0.5 * progress;
      final particleSize = 6.0 * (1 - progress);
      final opacity = 1.0 - progress;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final particleCenter = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      canvas.drawCircle(particleCenter, particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
