import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppSheet - Modal bottom sheet wrapper with consistent styling
class AppSheet extends StatelessWidget {
  const AppSheet({
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
      enableDrag: isDismissible,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => AppSheet(
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
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: isFullHeight ? screenHeight * 0.95 : screenHeight * 0.75,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: DefaultTextStyle.merge(
                style: theme.textTheme.titleLarge!,
                child: title!,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (content != null)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: content!,
              ),
            ),
          if (actions != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var i = 0; i < actions!.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.md),
                    actions![i],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
