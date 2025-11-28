import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/loading/shimmer_loading.dart';

/// App Network Image
///
/// A standardized network image component with consistent loading states,
/// error handling, and caching. Use this instead of raw Image.network or
/// CachedNetworkImage for consistent behavior across the app.
///
/// Features:
/// - Automatic shimmer loading placeholder
/// - Consistent error state with broken image icon
/// - Memory and disk caching via CachedNetworkImage
/// - Optional border radius
/// - Fade-in animation on load
///
/// Usage:
/// ```dart
/// AppNetworkImage(
///   url: 'https://example.com/image.jpg',
///   width: 200,
///   height: 200,
///   fit: BoxFit.cover,
///   borderRadius: BorderRadius.circular(8),
/// )
/// ```
///
/// Sprint 2 - Task 2.3.1
/// Date: November 28, 2025

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeInCurve = Curves.easeIn,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  /// The image URL
  final String url;

  /// Optional width constraint
  final double? width;

  /// Optional height constraint
  final double? height;

  /// How the image should fit within its bounds
  final BoxFit fit;

  /// Optional border radius for rounded corners
  final BorderRadius? borderRadius;

  /// Custom placeholder widget (defaults to shimmer)
  final Widget? placeholder;

  /// Custom error widget (defaults to broken image icon)
  final Widget? errorWidget;

  /// Duration of fade-in animation
  final Duration fadeInDuration;

  /// Curve of fade-in animation
  final Curve fadeInCurve;

  /// Optional color overlay
  final Color? color;

  /// Blend mode for color overlay
  final BlendMode? colorBlendMode;

  /// Image alignment
  final Alignment alignment;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      fadeInDuration: fadeInDuration,
      fadeInCurve: fadeInCurve,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(context),
    );

    // Apply border radius if provided
    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    // Add semantic label if provided
    if (semanticLabel != null) {
      image = Semantics(
        label: semanticLabel,
        image: true,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    return ShimmerBox(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      borderRadius: borderRadius?.topLeft.x ?? 0,
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: _getErrorIconSize(),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  double _getErrorIconSize() {
    if (width != null && height != null) {
      final minDimension = width! < height! ? width! : height!;
      return (minDimension * 0.3).clamp(24.0, 48.0);
    }
    return 32.0;
  }
}

/// Circular network image (for avatars)
class AppNetworkAvatar extends StatelessWidget {
  const AppNetworkAvatar({
    required this.url,
    required this.size,
    super.key,
    this.placeholder,
    this.errorWidget,
    this.border,
    this.semanticLabel,
  });

  /// The image URL
  final String url;

  /// The diameter of the avatar
  final double size;

  /// Custom placeholder widget
  final Widget? placeholder;

  /// Custom error widget
  final Widget? errorWidget;

  /// Optional border
  final BoxBorder? border;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(context),
        ),
      ),
    );

    if (semanticLabel != null) {
      avatar = Semantics(
        label: semanticLabel,
        image: true,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    return ShimmerCircle(size: size);
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Network image with gradient overlay (for cards, headers)
class AppNetworkImageWithOverlay extends StatelessWidget {
  const AppNetworkImageWithOverlay({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.gradient,
    this.overlayColor,
    this.child,
    this.semanticLabel,
  });

  /// The image URL
  final String url;

  /// Optional width
  final double? width;

  /// Optional height
  final double? height;

  /// How the image should fit
  final BoxFit fit;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Gradient overlay (defaults to bottom-to-top dark gradient)
  final Gradient? gradient;

  /// Solid color overlay (alternative to gradient)
  final Color? overlayColor;

  /// Child widget to display on top of the image
  final Widget? child;

  /// Semantic label
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        AppNetworkImage(
          url: url,
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
          semanticLabel: semanticLabel,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: gradient ?? _defaultGradient,
              color: overlayColor,
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }

  Gradient get _defaultGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.7),
        ],
      );
}
