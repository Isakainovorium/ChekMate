import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Basic SVG Icon Widget
///
/// Displays an SVG icon from assets with customizable size and color.
class SvgIcon extends StatelessWidget {
  const SvgIcon(
    this.assetPath, {
    super.key,
    this.size = 24.0,
    this.color,
  });

  final String assetPath;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// SVG Icon Button Widget
///
/// A clickable SVG icon button with customizable appearance.
class SvgIconButton extends StatelessWidget {
  const SvgIconButton({
    super.key,
    required this.assetPath,
    this.onPressed,
    this.size,
    this.color,
  });

  final String assetPath;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgIcon(
        assetPath,
        size: size ?? 24.0,
        color: color,
      ),
    );
  }
}

/// Themed SVG Icon Widget
///
/// An SVG icon that automatically adapts to the current theme's icon color.
class ThemedSvgIcon extends StatelessWidget {
  const ThemedSvgIcon(
    this.assetPath, {
    super.key,
    this.size = 24.0,
  });

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconTheme = Theme.of(context).iconTheme;
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: iconTheme.color != null
          ? ColorFilter.mode(iconTheme.color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// Animated SVG Icon Widget
///
/// An SVG icon with tap animation effects.
class AnimatedSvgIcon extends StatefulWidget {
  const AnimatedSvgIcon(
    this.assetPath, {
    super.key,
    this.onTap,
    this.size = 24.0,
    this.color,
  });

  final String assetPath;
  final VoidCallback? onTap;
  final double size;
  final Color? color;

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
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      _controller.forward().then((_) => _controller.reverse());
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SvgPicture.asset(
              widget.assetPath,
              width: widget.size,
              height: widget.size,
              colorFilter: widget.color != null
                  ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// SVG Icon with Badge Widget
///
/// An SVG icon that displays a notification badge with a count.
class SvgIconWithBadge extends StatelessWidget {
  const SvgIconWithBadge({
    super.key,
    required this.assetPath,
    required this.badgeCount,
    this.size = 24.0,
    this.color,
    this.badgeColor,
  });

  final String assetPath;
  final int badgeCount;
  final double size;
  final Color? color;
  final Color? badgeColor;

  String get _displayText {
    if (badgeCount <= 0) return '';
    if (badgeCount > 99) return '99+';
    return badgeCount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: badgeCount > 0 ? Text(_displayText) : null,
      backgroundColor: badgeColor ?? Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
      child: SvgIcon(
        assetPath,
        size: size,
        color: color,
      ),
    );
  }
}
