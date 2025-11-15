import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppPopover - Overlay content with positioning
class AppPopover extends StatelessWidget {
  const AppPopover({
    required this.child,
    super.key,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  static Future<T?> show<T>({
    required BuildContext context,
    required RelativeRect position,
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.md),
    Color? barrierColor,
    bool barrierDismissible = true,
  }) {
    return showMenu<T>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<T>(
          enabled: false,
          child: AppPopover(
            width: width,
            height: height,
            padding: padding,
            child: child,
          ),
        ),
      ],
      color: Colors.transparent,
      elevation: 0,
    );
  }

  static Future<T?> showFromWidget<T>({
    required BuildContext context,
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.md),
    Offset offset = Offset.zero,
  }) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return show<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + offset.dx,
        position.dy + size.height + offset.dy,
        position.dx + size.width + offset.dx,
        position.dy + size.height + 100 + offset.dy,
      ),
      child: child,
      width: width,
      height: height,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }
}

/// AppPopoverButton - Button that shows popover on tap
class AppPopoverButton extends StatelessWidget {
  const AppPopoverButton({
    required this.child,
    required this.popoverChild,
    super.key,
    this.popoverWidth,
    this.popoverHeight,
    this.offset = Offset.zero,
  });

  final Widget child;
  final Widget popoverChild;
  final double? popoverWidth;
  final double? popoverHeight;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => AppPopover.showFromWidget<void>(
          context: context,
          child: popoverChild,
          width: popoverWidth,
          height: popoverHeight,
          offset: offset,
        ),
        child: child,
      ),
    );
  }
}
