import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature discovery widget for progressive disclosure
/// Shows tooltips and hints for first-time users
class FeatureDiscovery extends StatefulWidget {
  const FeatureDiscovery({
    required this.featureId,
    required this.title,
    required this.description,
    required this.child,
    super.key,
    this.tapTargetSize = 60,
    this.onComplete,
  });

  final String featureId;
  final String title;
  final String description;
  final Widget child;
  final double tapTargetSize;
  final VoidCallback? onComplete;

  @override
  State<FeatureDiscovery> createState() => _FeatureDiscoveryState();
}

class _FeatureDiscoveryState extends State<FeatureDiscovery>
    with SingleTickerProviderStateMixin {
  bool _showOverlay = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _checkIfShouldShow();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkIfShouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenKey = 'feature_discovery_${widget.featureId}';
    final hasSeen = prefs.getBool(hasSeenKey) ?? false;

    if (!hasSeen && mounted) {
      // Delay to let the page settle
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _showOverlay = true);
        _controller.forward();
      }
    }
  }

  Future<void> _markAsComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenKey = 'feature_discovery_${widget.featureId}';
    await prefs.setBool(hasSeenKey, true);

    if (mounted) {
      await _controller.reverse();
      setState(() => _showOverlay = false);
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showOverlay)
          Positioned.fill(
            child: GestureDetector(
              onTap: _markAsComplete,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Dark overlay
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),

                      // Spotlight circle
                      Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: widget.tapTargetSize,
                            height: widget.tapTargetSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Tooltip
                      Positioned(
                        top: 100,
                        left: 20,
                        right: 20,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _markAsComplete,
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                        ),
                                        child: const Text('Got it!'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Simple tooltip widget for inline hints
class FeatureHint extends StatelessWidget {
  const FeatureHint({
    required this.message,
    required this.child,
    super.key,
    this.preferBelow = true,
  });

  final String message;
  final Widget child;
  final bool preferBelow;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      waitDuration: const Duration(milliseconds: 500),
      child: child,
    );
  }
}

/// Badge widget for "New" or "Beta" features
class FeatureBadge extends StatelessWidget {
  const FeatureBadge({
    required this.label,
    required this.child,
    super.key,
    this.color,
  });

  final String label;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

