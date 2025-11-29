import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppDrawer - Side navigation drawer with sections and animations
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.items,
    super.key,
    this.header,
    this.footer,
    this.selectedIndex,
    this.onItemTap,
    this.width = 280,
    this.backgroundColor,
    this.elevation = 16,
    this.shape,
  });

  final Widget? header;
  final Widget? footer;
  final List<AppDrawerItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onItemTap;
  final double width;
  final Color? backgroundColor;
  final double elevation;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: width,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      child: Column(
        children: [
          // Header
          if (header != null) header!,

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                if (item.isDivider) {
                  return const Divider();
                } else if (item.isSection) {
                  return _DrawerSection(section: item);
                } else {
                  return _DrawerTile(
                    item: item,
                    isSelected: selectedIndex == index,
                    onTap: () => onItemTap?.call(index),
                  );
                }
              },
            ),
          ),

          // Footer
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppDrawerItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: ListTile(
        leading: item.icon != null
            ? Icon(
                item.icon,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              )
            : null,
        title: Text(
          item.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: item.subtitle != null
            ? Text(
                item.subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                          .withOpacity(0.8)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: item.trailing,
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: item.enabled ? onTap : null,
        enabled: item.enabled,
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.section});

  final AppDrawerItem section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        section.title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// AppDrawerHeader - Custom drawer header with user info
class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({
    super.key,
    this.accountName,
    this.accountEmail,
    this.currentAccountPicture,
    this.otherAccountsPictures,
    this.onDetailsPressed,
    this.decoration,
    this.margin = const EdgeInsets.only(bottom: 8.0),
    this.padding = const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
  });

  final Widget? accountName;
  final Widget? accountEmail;
  final Widget? currentAccountPicture;
  final List<Widget>? otherAccountsPictures;
  final VoidCallback? onDetailsPressed;
  final Decoration? decoration;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 160,
      margin: margin,
      decoration: decoration ??
          BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account pictures
              Row(
                children: [
                  if (currentAccountPicture != null)
                    currentAccountPicture!
                  else
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          theme.colorScheme.onPrimary.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  const Spacer(),
                  if (otherAccountsPictures != null)
                    ...otherAccountsPictures!.map(
                      (picture) => Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs),
                        child: picture,
                      ),
                    ),
                  if (onDetailsPressed != null)
                    IconButton(
                      onPressed: onDetailsPressed,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Account info
              if (accountName != null)
                DefaultTextStyle(
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  child: accountName!,
                ),
              if (accountEmail != null) ...[
                const SizedBox(height: AppSpacing.xs),
                DefaultTextStyle(
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                  child: accountEmail!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// AppMiniDrawer - Collapsed drawer that shows only icons
class AppMiniDrawer extends StatelessWidget {
  const AppMiniDrawer({
    required this.items,
    super.key,
    this.selectedIndex,
    this.onItemTap,
    this.width = 72,
    this.backgroundColor,
    this.elevation = 16,
  });

  final List<AppDrawerItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onItemTap;
  final double width;
  final Color? backgroundColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.builder(
              itemCount: items
                  .where((item) => !item.isDivider && !item.isSection)
                  .length,
              itemBuilder: (context, index) {
                final validItems = items
                    .where((item) => !item.isDivider && !item.isSection)
                    .toList();
                final item = validItems[index];
                final isSelected = selectedIndex == items.indexOf(item);

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Tooltip(
                    message: item.title,
                    child: InkWell(
                      onTap: item.enabled
                          ? () => onItemTap?.call(items.indexOf(item))
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// AppResponsiveDrawer - Drawer that adapts to screen size
class AppResponsiveDrawer extends StatelessWidget {
  const AppResponsiveDrawer({
    required this.items,
    super.key,
    this.header,
    this.footer,
    this.selectedIndex,
    this.onItemTap,
    this.breakpoint = 1024,
    this.drawerWidth = 280,
    this.miniDrawerWidth = 72,
  });

  final Widget? header;
  final Widget? footer;
  final List<AppDrawerItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onItemTap;
  final double breakpoint;
  final double drawerWidth;
  final double miniDrawerWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          // Desktop: Show full drawer
          return AppDrawer(
            header: header,
            footer: footer,
            items: items,
            selectedIndex: selectedIndex,
            onItemTap: onItemTap,
            width: drawerWidth,
          );
        } else {
          // Mobile: Show mini drawer or hide
          return AppMiniDrawer(
            items: items,
            selectedIndex: selectedIndex,
            onItemTap: onItemTap,
            width: miniDrawerWidth,
          );
        }
      },
    );
  }
}

/// Data class for drawer items
class AppDrawerItem {
  const AppDrawerItem({
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.enabled = true,
    this.isDivider = false,
    this.isSection = false,
  });

  const AppDrawerItem.divider()
      : title = '',
        icon = null,
        subtitle = null,
        trailing = null,
        enabled = true,
        isDivider = true,
        isSection = false;

  const AppDrawerItem.section({required this.title})
      : icon = null,
        subtitle = null,
        trailing = null,
        enabled = true,
        isDivider = false,
        isSection = true;

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;
  final bool enabled;
  final bool isDivider;
  final bool isSection;
}
