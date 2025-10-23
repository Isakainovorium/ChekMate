import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppMenubar - Desktop-style menu bar with dropdowns
class AppMenubar extends StatefulWidget {
  const AppMenubar({
    required this.menus, super.key,
    this.backgroundColor,
    this.height = 48,
  });

  final List<AppMenubarItem> menus;
  final Color? backgroundColor;
  final double height;

  @override
  State<AppMenubar> createState() => _AppMenubarState();
}

class _AppMenubarState extends State<AppMenubar> {
  int? _activeMenuIndex;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _onMenuTap(int index) {
    if (_activeMenuIndex == index) {
      _closeMenu();
    } else {
      _showMenu(index);
    }
  }

  void _showMenu(int index) {
    _removeOverlay();
    
    setState(() {
      _activeMenuIndex = index;
    });

    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    
    // Calculate menu button position
    double menuX = 0;
    for (var i = 0; i < index; i++) {
      menuX += _getMenuWidth(widget.menus[i].label);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeMenu,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: position.dx + menuX,
              top: position.dy + widget.height,
              child: _MenuDropdown(
                items: widget.menus[index].items,
                onItemSelected: (item) {
                  _closeMenu();
                  item.onTap?.call();
                },
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    _removeOverlay();
    setState(() {
      _activeMenuIndex = null;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getMenuWidth(String label) {
    // Approximate width calculation
    return label.length * 8.0 + AppSpacing.lg * 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: widget.menus.asMap().entries.map((entry) {
          final index = entry.key;
          final menu = entry.value;
          final isActive = _activeMenuIndex == index;
          
          return _MenuButton(
            label: menu.label,
            isActive: isActive,
            onTap: () => _onMenuTap(index),
          );
        }).toList(),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive 
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _MenuDropdown extends StatelessWidget {
  const _MenuDropdown({
    required this.items,
    required this.onItemSelected,
  });

  final List<AppMenubarDropdownItem> items;
  final ValueChanged<AppMenubarDropdownItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minWidth: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            if (item.isDivider) {
              return Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              );
            }
            
            return _MenuDropdownItem(
              item: item,
              onTap: () => onItemSelected(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuDropdownItem extends StatelessWidget {
  const _MenuDropdownItem({
    required this.item,
    required this.onTap,
  });

  final AppMenubarDropdownItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: item.enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 16,
                color: item.enabled 
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                item.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: item.enabled 
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
          ],
        ),
      ),
    );
  }
}

/// AppBottomMenubar - Mobile-friendly bottom menu bar
class AppBottomMenubar extends StatelessWidget {
  const AppBottomMenubar({
    required this.items, required this.currentIndex, required this.onTap, super.key,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showLabels = true,
  });

  final List<AppBottomMenubarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;
            
            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon ?? item.icon : item.icon,
                        color: isSelected 
                            ? selectedItemColor ?? theme.colorScheme.primary
                            : unselectedItemColor ?? theme.colorScheme.onSurfaceVariant,
                      ),
                      if (showLabels) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected 
                                ? selectedItemColor ?? theme.colorScheme.primary
                                : unselectedItemColor ?? theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Data classes for menubar
class AppMenubarItem {
  const AppMenubarItem({
    required this.label,
    required this.items,
  });

  final String label;
  final List<AppMenubarDropdownItem> items;
}

class AppMenubarDropdownItem {
  const AppMenubarDropdownItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.onTap,
    this.enabled = true,
    this.isDivider = false,
  });

  const AppMenubarDropdownItem.divider()
      : label = '',
        icon = null,
        shortcut = null,
        onTap = null,
        enabled = true,
        isDivider = true;

  final String label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isDivider;
}

class AppBottomMenubarItem {
  const AppBottomMenubarItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final String label;
  final IconData? selectedIcon;
}
