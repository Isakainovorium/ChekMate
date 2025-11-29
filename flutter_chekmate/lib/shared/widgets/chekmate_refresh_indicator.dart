import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

/// ChekMate branded pull-to-refresh indicator
/// Features:
/// - Custom golden checkmark animation
/// - Pulse effect during refresh
/// - Smooth spring physics
class ChekMateRefreshIndicator extends StatefulWidget {
  const ChekMateRefreshIndicator({
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  State<ChekMateRefreshIndicator> createState() =>
      _ChekMateRefreshIndicatorState();
}

class _ChekMateRefreshIndicatorState extends State<ChekMateRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    _pulseController.repeat(reverse: true);
    try {
      await widget.onRefresh();
    } finally {
      _pulseController.stop();
      _pulseController.reset();
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: Colors.white,
          strokeWidth: 3,
          displacement: 60,
          edgeOffset: 0,
          child: widget.child,
        ),
        // Show custom header when refreshing
        if (_isRefreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ChekMateRefreshHeader(
              isRefreshing: _isRefreshing,
              pulseAnimation: _pulseAnimation,
            ),
          ),
      ],
    );
  }
}

/// Custom refresh header with ChekMate branding
class ChekMateRefreshHeader extends StatelessWidget {
  const ChekMateRefreshHeader({
    required this.isRefreshing,
    required this.pulseAnimation,
    super.key,
  });

  final bool isRefreshing;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: pulseAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFFFF8C00)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '✓',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Enhanced scroll physics for smooth pull-to-refresh
class ChekMateScrollPhysics extends BouncingScrollPhysics {
  const ChekMateScrollPhysics({super.parent});

  @override
  ChekMateScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ChekMateScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.5;
}
