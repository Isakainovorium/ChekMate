import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer Loading Widget
///
/// Provides shimmer effect for loading states throughout the app.
/// Supports light and dark themes with customizable colors.
///
/// Usage:
/// ```dart
/// ShimmerLoading(
///   child: Container(width: 100, height: 20),
/// )
/// ```
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    required this.child,
    super.key,
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
    this.direction = ShimmerDirection.ltr,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;
  final ShimmerDirection direction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveBaseColor = baseColor ??
        (isDark ? Colors.grey.shade800 : Colors.grey.shade300);
    final effectiveHighlightColor = highlightColor ??
        (isDark ? Colors.grey.shade700 : Colors.grey.shade100);

    return Shimmer.fromColors(
      baseColor: effectiveBaseColor,
      highlightColor: effectiveHighlightColor,
      enabled: enabled,
      direction: direction,
      child: child,
    );
  }
}

/// Shimmer Box - Simple rectangular shimmer placeholder
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer Circle - Circular shimmer placeholder (for avatars)
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({
    required this.size,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Shimmer Line - Single line shimmer placeholder (for text)
class ShimmerLine extends StatelessWidget {
  const ShimmerLine({
    super.key,
    this.width,
    this.height = 12.0,
    this.borderRadius = 4.0,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer Text - Multi-line text shimmer placeholder
class ShimmerText extends StatelessWidget {
  const ShimmerText({
    super.key,
    this.lines = 3,
    this.lineHeight = 12.0,
    this.spacing = 8.0,
    this.lastLineWidth = 0.7,
  });

  final int lines;
  final double lineHeight;
  final double spacing;
  final double lastLineWidth; // Fraction of full width for last line

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: ShimmerLine(
            height: lineHeight,
            width: isLastLine ? null : double.infinity,
          ),
        );
      }),
    );
  }
}

/// Shimmer Image - Image placeholder with shimmer
class ShimmerImage extends StatelessWidget {
  const ShimmerImage({
    super.key,
    this.width,
    this.height,
    this.aspectRatio = 1.0,
    this.borderRadius = 8.0,
  });

  final double? width;
  final double? height;
  final double aspectRatio;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget shimmerBox = ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );

    if (width == null && height == null) {
      shimmerBox = AspectRatio(
        aspectRatio: aspectRatio,
        child: shimmerBox,
      );
    }

    return shimmerBox;
  }
}

/// Shimmer Card - Complete card skeleton with image, title, and text
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.hasImage = true,
    this.imageHeight = 200.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  final bool hasImage;
  final double imageHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            ShimmerImage(
              height: imageHeight,
              borderRadius: 12,
            ),
          Padding(
            padding: padding,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(width: 200, height: 20),
                SizedBox(height: 12),
                ShimmerText(),
                SizedBox(height: 16),
                Row(
                  children: [
                    ShimmerCircle(size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLine(width: 100),
                          SizedBox(height: 4),
                          ShimmerLine(width: 80, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer List Item - Single list item skeleton
class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lines = 2,
  });

  final bool hasLeading;
  final bool hasTrailing;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasLeading) ...[
            const ShimmerCircle(size: 48),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ShimmerText(lines: lines),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 12),
            const ShimmerBox(width: 60, height: 32),
          ],
        ],
      ),
    );
  }
}

