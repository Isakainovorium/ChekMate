import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

/// Error Animation - Animated X mark with shake
class ErrorAnimation extends StatefulWidget {
  const ErrorAnimation({
    super.key,
    this.size = 120,
    this.onComplete,
  });

  final double size;
  final VoidCallback? onComplete;

  @override
  State<ErrorAnimation> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _xController;
  late AnimationController _shakeController;

  late Animation<double> _circleScale;
  late Animation<double> _xScale;
  late Animation<double> _shakeAnimation;

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

    // X mark animation
    _xController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _xScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _xController, curve: Curves.easeOutBack),
    );

    // Shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(_shakeController);

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _circleController.forward();
    await _xController.forward();
    await _shakeController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _circleController.dispose();
    _xController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circle background
                AnimatedBuilder(
                  animation: _circleController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _circleScale.value,
                      child: Container(
                        width: widget.size * 0.7,
                        height: widget.size * 0.7,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.error, Color(0xFFDC2626)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // X mark
                AnimatedBuilder(
                  animation: _xController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _xScale.value,
                      child: Icon(
                        Icons.close_rounded,
                        size: widget.size * 0.4,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
