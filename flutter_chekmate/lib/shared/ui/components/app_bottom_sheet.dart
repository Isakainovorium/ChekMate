import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppBottomSheet - Modal bottom sheet component
///
/// Provides a consistent bottom sheet implementation for dating experience platform actions.
/// Supports full-height and partial-height modes with drag handle and actions.
///
/// Date: November 13, 2025
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.isFullHeight = false,
    this.isDismissible = true,
    this.showDragHandle = true,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final bool isFullHeight;
  final bool isDismissible;
  final bool showDragHandle;

  /// Show a bottom sheet with the given content
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    bool isFullHeight = false,
    bool isDismissible = true,
    bool showDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isFullHeight,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        content: content,
        actions: actions,
        isFullHeight: isFullHeight,
        isDismissible: isDismissible,
        showDragHandle: showDragHandle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDragHandle)
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: DefaultTextStyle(
              style: theme.textTheme.titleLarge ?? const TextStyle(),
              child: title!,
            ),
          ),
        ],
        if (content != null) ...[
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: content,
            ),
          ),
        ],
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ),
        ],
      ],
    );

    if (isFullHeight) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: contentWidget,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: contentWidget,
    );
  }
}

