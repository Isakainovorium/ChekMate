import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppContextMenu - Right-click context menu with consistent styling
class AppContextMenu extends StatelessWidget {
  const AppContextMenu({
    required this.child, required this.menuItems, super.key,
    this.enabled = true,
  });

  final Widget child;
  final List<AppContextMenuItem> menuItems;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || menuItems.isEmpty) {
      return child;
    }

    return GestureDetector(
      onSecondaryTapUp: (details) => _showContextMenu(context, details.globalPosition),
      onLongPress: () => _showContextMenu(context, null),
      child: child,
    );
  }

  void _showContextMenu(BuildContext context, Offset? position) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect menuPosition;
    
    if (position != null) {
      menuPosition = RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      );
    } else {
      // Center the menu if no position provided (long press)
      final center = overlay.size.center(Offset.zero);
      menuPosition = RelativeRect.fromLTRB(
        center.dx - 100,
        center.dy - 50,
        center.dx + 100,
        center.dy + 50,
      );
    }

    showMenu<AppContextMenuItem>(
      context: context,
      position: menuPosition,
      items: _buildMenuItems(context),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ).then((selectedItem) {
      if (selectedItem != null) {
        selectedItem.onTap?.call();
      }
    });
  }

  List<PopupMenuEntry<AppContextMenuItem>> _buildMenuItems(BuildContext context) {
    final entries = <PopupMenuEntry<AppContextMenuItem>>[];
    
    for (var i = 0; i < menuItems.length; i++) {
      final item = menuItems[i];
      
      if (item.isDivider) {
        entries.add(const PopupMenuDivider());
      } else {
        entries.add(
          PopupMenuItem<AppContextMenuItem>(
            value: item,
            enabled: item.enabled,
            child: _ContextMenuItemWidget(item: item),
          ),
        );
      }
    }
    
    return entries;
  }
}

class _ContextMenuItemWidget extends StatelessWidget {
  const _ContextMenuItemWidget({required this.item});

  final AppContextMenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: 18,
            color: item.enabled 
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Text(
            item.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: item.enabled 
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        if (item.shortcut != null) ...[
          const SizedBox(width: AppSpacing.md),
          Text(
            item.shortcut!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (item.hasSubmenu) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }
}

/// AppContextMenuRegion - Wrapper for adding context menu to any widget
class AppContextMenuRegion extends StatelessWidget {
  const AppContextMenuRegion({
    required this.child, required this.contextMenuBuilder, super.key,
  });

  final Widget child;
  final List<AppContextMenuItem> Function(BuildContext context) contextMenuBuilder;

  @override
  Widget build(BuildContext context) {
    return AppContextMenu(
      menuItems: contextMenuBuilder(context),
      child: child,
    );
  }
}

/// AppSelectableText - Text with built-in context menu
class AppSelectableText extends StatelessWidget {
  const AppSelectableText({
    required this.text, super.key,
    this.style,
    this.showCursor = false,
    this.enableInteractiveSelection = true,
    this.additionalMenuItems = const [],
  });

  final String text;
  final TextStyle? style;
  final bool showCursor;
  final bool enableInteractiveSelection;
  final List<AppContextMenuItem> additionalMenuItems;

  @override
  Widget build(BuildContext context) {
    return AppContextMenu(
      menuItems: [
        AppContextMenuItem(
          label: 'Copy',
          icon: Icons.copy,
          onTap: () {
            // Copy selected text or full text
            // Implementation would depend on selection state
          },
        ),
        AppContextMenuItem(
          label: 'Select All',
          icon: Icons.select_all,
          onTap: () {
            // Select all text
          },
        ),
        if (additionalMenuItems.isNotEmpty) ...[
          const AppContextMenuItem.divider(),
          ...additionalMenuItems,
        ],
      ],
      child: SelectableText(
        text,
        style: style,
        showCursor: showCursor,
        enableInteractiveSelection: enableInteractiveSelection,
      ),
    );
  }
}

/// Data class for context menu items
class AppContextMenuItem {
  const AppContextMenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.onTap,
    this.enabled = true,
    this.isDivider = false,
    this.hasSubmenu = false,
  });

  const AppContextMenuItem.divider()
      : label = '',
        icon = null,
        shortcut = null,
        onTap = null,
        enabled = true,
        isDivider = true,
        hasSubmenu = false;

  final String label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isDivider;
  final bool hasSubmenu;
}
