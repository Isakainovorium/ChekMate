import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

/// Empty State Animations - Beautiful illustrated empty states
///
/// Provides animated empty state widgets for various scenarios.

enum EmptyStateType {
  noPosts,
  noMessages,
  noMatches,
  noNotifications,
  noSearch,
  noConnection,
}

/// Animated empty state widget with illustrations
class AnimatedEmptyState extends StatefulWidget {
  const AnimatedEmptyState({
    required this.type,
    this.title,
    this.message,
    this.action,
    super.key,
  });

  final EmptyStateType type;
  final String? title;
  final String? message;
  final Widget? action;

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated illustration
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_floatAnimation.value),
                    child: _buildIllustration(),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                widget.title ?? _getDefaultTitle(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                widget.message ?? _getDefaultMessage(),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              if (widget.action != null) ...[
                const SizedBox(height: 24),
                widget.action!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative circles
          ..._buildDecorativeCircles(),
          // Main icon
          _buildMainIcon(),
        ],
      ),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    final colors = [
      AppColors.primary.withOpacity(0.2),
      AppColors.secondary.withOpacity(0.15),
      const Color(0xFF8B5CF6).withOpacity(0.1),
    ];

    return List.generate(3, (index) {
      final angle = (index * 2 * math.pi / 3);
      final radius = 60.0;
      return Positioned(
        left: 90 + math.cos(angle) * radius - 12,
        top: 90 + math.sin(angle) * radius - 12,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colors[index],
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  Widget _buildMainIcon() {
    IconData icon;
    Color color;

    switch (widget.type) {
      case EmptyStateType.noPosts:
        icon = Icons.article_outlined;
        color = AppColors.primary;
        break;
      case EmptyStateType.noMessages:
        icon = Icons.chat_bubble_outline;
        color = const Color(0xFF3B82F6);
        break;
      case EmptyStateType.noMatches:
        icon = Icons.favorite_outline;
        color = const Color(0xFFFF6B6B);
        break;
      case EmptyStateType.noNotifications:
        icon = Icons.notifications_none;
        color = const Color(0xFFF59E0B);
        break;
      case EmptyStateType.noSearch:
        icon = Icons.search_off;
        color = const Color(0xFF8B5CF6);
        break;
      case EmptyStateType.noConnection:
        icon = Icons.wifi_off;
        color = AppColors.error;
        break;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, size: 40, color: color),
    );
  }

  String _getDefaultTitle() {
    switch (widget.type) {
      case EmptyStateType.noPosts:
        return 'No Posts Yet';
      case EmptyStateType.noMessages:
        return 'No Messages';
      case EmptyStateType.noMatches:
        return 'No Matches Yet';
      case EmptyStateType.noNotifications:
        return 'All Caught Up!';
      case EmptyStateType.noSearch:
        return 'No Results Found';
      case EmptyStateType.noConnection:
        return 'No Connection';
    }
  }

  String _getDefaultMessage() {
    switch (widget.type) {
      case EmptyStateType.noPosts:
        return 'Be the first to share your dating experience with the community!';
      case EmptyStateType.noMessages:
        return 'Start a conversation and connect with someone new.';
      case EmptyStateType.noMatches:
        return 'Keep exploring! Your perfect match is out there.';
      case EmptyStateType.noNotifications:
        return 'You\'re all caught up. Check back later for updates.';
      case EmptyStateType.noSearch:
        return 'Try adjusting your search or filters.';
      case EmptyStateType.noConnection:
        return 'Please check your internet connection and try again.';
    }
  }
}
