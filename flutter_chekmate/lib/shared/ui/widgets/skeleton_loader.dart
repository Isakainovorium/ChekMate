import 'package:flutter/material.dart';

/// Skeleton loader widget for better loading UX
/// Provides shimmer effect while content is loading
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Post skeleton loader - mimics post structure
class PostSkeleton extends StatelessWidget {
  const PostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (avatar + username)
          Row(
            children: [
              const SkeletonLoader(
                width: 40,
                height: 40,
                borderRadius: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLoader(width: 120, height: 14),
                  SizedBox(height: 4),
                  SkeletonLoader(width: 80, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content lines
          const SkeletonLoader(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const SkeletonLoader(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const SkeletonLoader(width: 200, height: 14),
          const SizedBox(height: 16),

          // Image placeholder
          const SkeletonLoader(
            width: double.infinity,
            height: 200,
            borderRadius: 8,
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: const [
              SkeletonLoader(width: 60, height: 32, borderRadius: 16),
              SizedBox(width: 12),
              SkeletonLoader(width: 60, height: 32, borderRadius: 16),
              SizedBox(width: 12),
              SkeletonLoader(width: 60, height: 32, borderRadius: 16),
            ],
          ),
        ],
      ),
    );
  }
}

/// Story skeleton loader - mimics story circle
class StorySkeleton extends StatelessWidget {
  const StorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SkeletonLoader(
          width: 64,
          height: 64,
          borderRadius: 32,
        ),
        SizedBox(height: 8),
        SkeletonLoader(width: 60, height: 12),
      ],
    );
  }
}

/// List skeleton - shows multiple post skeletons
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const PostSkeleton(),
    );
  }
}

/// Circular skeleton - for avatars, icons
class CircularSkeleton extends StatelessWidget {
  const CircularSkeleton({
    super.key,
    this.size = 40,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

/// Text skeleton - for text lines
class TextSkeleton extends StatelessWidget {
  const TextSkeleton({
    super.key,
    this.width,
    this.height = 14,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: 4,
    );
  }
}

/// Button skeleton - for buttons
class ButtonSkeleton extends StatelessWidget {
  const ButtonSkeleton({
    super.key,
    this.width = 100,
    this.height = 40,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: 8,
    );
  }
}

