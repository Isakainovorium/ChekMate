import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppSkeleton - Loading placeholder with shimmer effect
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
    this.isCircular = false,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final bool isCircular;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surface;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.isCircular 
                ? BorderRadius.circular(widget.height / 2)
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// AppSkeletonCard - Card-shaped skeleton
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({
    super.key,
    this.width,
    this.height = 200,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton(
            width: double.infinity,
            height: height * 0.6,
            borderRadius: 8,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppSkeleton(width: 120),
          const SizedBox(height: AppSpacing.sm),
          const AppSkeleton(width: 200, height: 14),
          const SizedBox(height: AppSpacing.xs),
          const AppSkeleton(width: 160, height: 14),
        ],
      ),
    );
  }
}

/// AppSkeletonList - List of skeleton items
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80,
    this.spacing = AppSpacing.md,
  });

  final int itemCount;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) => 
        Padding(
          padding: EdgeInsets.only(bottom: index < itemCount - 1 ? spacing : 0),
          child: AppSkeletonListItem(height: itemHeight),
        ),
      ),
    );
  }
}

/// AppSkeletonListItem - Single list item skeleton
class AppSkeletonListItem extends StatelessWidget {
  const AppSkeletonListItem({
    super.key,
    this.height = 80,
    this.showAvatar = true,
    this.showTrailing = true,
  });

  final double height;
  final bool showAvatar;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          if (showAvatar) ...[
            const AppSkeleton(
              width: 40,
              height: 40,
              isCircular: true,
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSkeleton(
                  width: showTrailing ? 150 : 200,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSkeleton(
                  width: showTrailing ? 100 : 160,
                  height: 14,
                ),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: AppSpacing.md),
            const AppSkeleton(
              width: 60,
              height: 32,
              borderRadius: 16,
            ),
          ],
        ],
      ),
    );
  }
}
