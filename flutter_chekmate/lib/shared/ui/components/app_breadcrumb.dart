import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppBreadcrumb - Navigation breadcrumb with consistent styling
class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({
    required this.items, super.key,
    this.separator = '/',
    this.maxItems,
    this.showRoot = true,
  });

  final List<AppBreadcrumbItem> items;
  final String separator;
  final int? maxItems;
  final bool showRoot;

  List<AppBreadcrumbItem> get _visibleItems {
    if (items.isEmpty) return [];
    
    if (maxItems == null || items.length <= maxItems!) {
      return items;
    }

    // Show first item (root), ellipsis, and last few items
    final remainingSlots = maxItems! - 2; // Reserve slots for root and ellipsis
    final lastItems = items.sublist(items.length - remainingSlots);
    
    return [
      items.first,
      const AppBreadcrumbItem(
        label: '...',
        isEllipsis: true,
      ),
      ...lastItems,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleItems = _visibleItems;
    
    if (visibleItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < visibleItems.length; i++) ...[
            _BreadcrumbItemWidget(
              item: visibleItems[i],
              isLast: i == visibleItems.length - 1,
              theme: theme,
            ),
            if (i < visibleItems.length - 1) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  separator,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _BreadcrumbItemWidget extends StatelessWidget {
  const _BreadcrumbItemWidget({
    required this.item,
    required this.isLast,
    required this.theme,
  });

  final AppBreadcrumbItem item;
  final bool isLast;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (item.isEllipsis) {
      return Text(
        item.label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isLast 
          ? theme.colorScheme.onSurface
          : theme.colorScheme.primary,
      fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: 16,
            color: textStyle?.color,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(item.label, style: textStyle),
      ],
    );

    if (!isLast && item.onTap != null) {
      content = InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// AppBreadcrumbDropdown - Breadcrumb with dropdown for overflow items
class AppBreadcrumbDropdown extends StatelessWidget {
  const AppBreadcrumbDropdown({
    required this.items, super.key,
    this.separator = '/',
    this.maxVisibleItems = 3,
  });

  final List<AppBreadcrumbItem> items;
  final String separator;
  final int maxVisibleItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    if (items.length <= maxVisibleItems) {
      return AppBreadcrumb(items: items, separator: separator);
    }

    // Show first item, dropdown, and last few items
    final visibleCount = maxVisibleItems - 1; // Reserve one slot for dropdown
    final hiddenItems = items.sublist(1, items.length - visibleCount + 1);
    final lastItems = items.sublist(items.length - visibleCount + 1);

    return Row(
      children: [
        // First item
        _BreadcrumbItemWidget(
          item: items.first,
          isLast: false,
          theme: theme,
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(separator, style: theme.textTheme.bodySmall),
        ),
        
        // Dropdown for hidden items
        PopupMenuButton<AppBreadcrumbItem>(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          itemBuilder: (context) => hiddenItems.map((item) => 
            PopupMenuItem<AppBreadcrumbItem>(
              value: item,
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: 16),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(item.label),
                ],
              ),
            ),
          ).toList(),
          onSelected: (item) => item.onTap?.call(),
        ),
        
        // Last items
        for (int i = 0; i < lastItems.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(separator, style: theme.textTheme.bodySmall),
          ),
          _BreadcrumbItemWidget(
            item: lastItems[i],
            isLast: i == lastItems.length - 1,
            theme: theme,
          ),
        ],
      ],
    );
  }
}

/// Data class for breadcrumb items
class AppBreadcrumbItem {
  const AppBreadcrumbItem({
    required this.label,
    this.onTap,
    this.icon,
    this.isEllipsis = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isEllipsis;
}
