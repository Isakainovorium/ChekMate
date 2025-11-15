import 'package:flutter/material.dart';

/// AppTooltip - Consistent tooltip styling
class AppTooltip extends StatelessWidget {
  const AppTooltip({
    required this.message, required this.child, super.key,
    this.preferBelow = true,
    this.verticalOffset,
    this.showDuration = const Duration(seconds: 2),
    this.waitDuration = const Duration(milliseconds: 500),
  });

  final String message;
  final Widget child;
  final bool preferBelow;
  final double? verticalOffset;
  final Duration showDuration;
  final Duration waitDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      verticalOffset: verticalOffset,
      showDuration: showDuration,
      waitDuration: waitDuration,
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onInverseSurface,
      ),
      child: child,
    );
  }
}

/// AppTooltipButton - Button with built-in tooltip
class AppTooltipButton extends StatelessWidget {
  const AppTooltipButton({
    required this.tooltip, required this.icon, required this.onPressed, super.key,
    this.size = 24.0,
    this.color,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppTooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: size, color: color),
        iconSize: size,
      ),
    );
  }
}
