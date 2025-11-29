import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/utils/haptic_feedback.dart';

/// A wrapper that adds a satisfying "bouncy" scale effect to any widget on press.
/// 
/// Implements "Option 3" of the visual upgrade plan (Micro-interactions).
class PremiumScaleButton extends StatefulWidget {
  const PremiumScaleButton({
    required this.child,
    required this.onPressed,
    super.key,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.enableHaptic = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double scale;
  final Duration duration;
  final bool enableHaptic;

  @override
  State<PremiumScaleButton> createState() => _PremiumScaleButtonState();
}

class _PremiumScaleButtonState extends State<PremiumScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    _controller.forward();
    if (widget.enableHaptic) {
      AppHaptics.light();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
