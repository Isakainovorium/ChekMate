import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG Icon Widget
///
/// A reusable widget for rendering SVG icons with consistent styling
/// and theme integration.
class SvgIcon extends StatelessWidget {
  const SvgIcon(
    this.assetPath, {
    super.key,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
    this.fit = BoxFit.contain,
  });

  /// Path to the SVG asset
  final String assetPath;

  /// Size of the icon (width and height)
  final double size;

  /// Color to apply to the icon (overrides SVG colors)
  final Color? color;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// How to fit the icon within its bounds
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      semanticsLabel: semanticLabel,
      fit: fit,
    );
  }
}

/// SVG Icon Button
///
/// A button that displays an SVG icon with proper touch targets
/// and Material Design ripple effects.
class SvgIconButton extends StatelessWidget {
  const SvgIconButton({
    required this.assetPath,
    required this.onPressed,
    super.key,
    this.size = 24.0,
    this.color,
    this.tooltip,
    this.padding = const EdgeInsets.all(8.0),
  });

  /// Path to the SVG asset
  final String assetPath;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Size of the icon
  final double size;

  /// Color of the icon
  final Color? color;

  /// Tooltip text
  final String? tooltip;

  /// Padding around the icon
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      padding: padding,
      icon: SvgIcon(
        assetPath,
        size: size,
        color: color ?? Theme.of(context).iconTheme.color,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Themed SVG Icon
///
/// An SVG icon that automatically adapts to the current theme.
class ThemedSvgIcon extends StatelessWidget {
  const ThemedSvgIcon(
    this.assetPath, {
    super.key,
    this.size = 24.0,
    this.useThemeColor = true,
    this.color,
    this.semanticLabel,
  });

  /// Path to the SVG asset
  final String assetPath;

  /// Size of the icon
  final double size;

  /// Whether to use theme color
  final bool useThemeColor;

  /// Custom color (overrides theme color)
  final Color? color;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (useThemeColor ? Theme.of(context).iconTheme.color : null);

    return SvgIcon(
      assetPath,
      size: size,
      color: effectiveColor,
      semanticLabel: semanticLabel,
    );
  }
}

/// Network SVG Icon
///
/// Loads and displays an SVG icon from a network URL.
class NetworkSvgIcon extends StatelessWidget {
  const NetworkSvgIcon(
    this.url, {
    super.key,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
    this.placeholder,
    this.errorWidget,
  });

  /// URL of the SVG icon
  final String url;

  /// Size of the icon
  final double size;

  /// Color to apply to the icon
  final Color? color;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Widget to show while loading
  final Widget? placeholder;

  /// Widget to show on error
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      url,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      semanticsLabel: semanticLabel,
      placeholderBuilder: placeholder != null
          ? (context) => placeholder!
          : (context) => SizedBox(
                width: size,
                height: size,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
    );
  }
}

/// Animated SVG Icon
///
/// An SVG icon with scale animation on tap.
class AnimatedSvgIcon extends StatefulWidget {
  const AnimatedSvgIcon(
    this.assetPath, {
    super.key,
    this.size = 24.0,
    this.color,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  /// Path to the SVG asset
  final String assetPath;

  /// Size of the icon
  final double size;

  /// Color of the icon
  final Color? color;

  /// Callback when icon is tapped
  final VoidCallback? onTap;

  /// Duration of the animation
  final Duration animationDuration;

  @override
  State<AnimatedSvgIcon> createState() => _AnimatedSvgIconState();
}

class _AnimatedSvgIconState extends State<AnimatedSvgIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SvgIcon(
          widget.assetPath,
          size: widget.size,
          color: widget.color,
        ),
      ),
    );
  }
}

/// SVG Icon with Badge
///
/// An SVG icon with an optional badge (e.g., notification count).
class SvgIconWithBadge extends StatelessWidget {
  const SvgIconWithBadge({
    required this.assetPath,
    super.key,
    this.size = 24.0,
    this.color,
    this.badgeCount,
    this.showBadge = false,
    this.badgeColor,
  });

  /// Path to the SVG asset
  final String assetPath;

  /// Size of the icon
  final double size;

  /// Color of the icon
  final Color? color;

  /// Badge count to display
  final int? badgeCount;

  /// Whether to show the badge
  final bool showBadge;

  /// Color of the badge
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgIcon(
          assetPath,
          size: size,
          color: color,
        ),
        if (showBadge)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: badgeCount != null
                  ? Text(
                      badgeCount! > 99 ? '99+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

