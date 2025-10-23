import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// AppSidebar - Drawer navigation with sections and user info
class AppSidebar extends StatefulWidget {
  const AppSidebar({
    required this.items, super.key,
    this.header,
    this.footer,
    this.selectedIndex,
    this.onItemTap,
    this.showUserInfo = true,
    this.userInfo,
    this.width = 280,
  });

  final Widget? header;
  final Widget? footer;
  final List<AppSidebarItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onItemTap;
  final bool showUserInfo;
  final AppSidebarUserInfo? userInfo;
  final double width;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: widget.width,
      child: Column(
        children: [
          // Header or User Info
          if (widget.header != null)
            widget.header!
          else if (widget.showUserInfo && widget.userInfo != null)
            _UserInfoHeader(userInfo: widget.userInfo!),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                
                if (item.isDivider) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Divider(),
                  );
                } else if (item.isSection) {
                  return _SectionHeader(title: item.title);
                } else {
                  return _SidebarTile(
                    item: item,
                    isSelected: widget.selectedIndex == index,
                    onTap: () => widget.onItemTap?.call(index),
                  );
                }
              },
            ),
          ),

          // Footer
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }
}

class _UserInfoHeader extends StatelessWidget {
  const _UserInfoHeader({required this.userInfo});

  final AppSidebarUserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar and basic info
              Row(
                children: [
                  AppAvatar(
                    imageUrl: userInfo.avatarUrl,
                    size: AppAvatarSize.large,
                  ),
                  const Spacer(),
                  if (userInfo.onSettingsTap != null)
                    IconButton(
                      onPressed: userInfo.onSettingsTap,
                      icon: Icon(
                        Icons.settings,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // User name and email
              Text(
                userInfo.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (userInfo.email != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  userInfo.email!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],

              const Spacer(),

              // Stats or additional info
              if (userInfo.stats != null)
                Row(
                  children: userInfo.stats!.entries.map((entry) {
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            entry.key,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppSidebarItem item;
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
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              item.icon,
              color: isSelected 
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            if (item.badge != null)
              Positioned(
                right: -6,
                top: -6,
                child: item.badge!,
              ),
          ],
        ),
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
                      ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
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

/// AppCollapsibleSidebar - Sidebar that can collapse to mini mode
class AppCollapsibleSidebar extends StatefulWidget {
  const AppCollapsibleSidebar({
    required this.items, super.key,
    this.selectedIndex,
    this.onItemTap,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.collapsedWidth = 72,
    this.expandedWidth = 280,
    this.userInfo,
  });

  final List<AppSidebarItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onItemTap;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final double collapsedWidth;
  final double expandedWidth;
  final AppSidebarUserInfo? userInfo;

  @override
  State<AppCollapsibleSidebar> createState() => _AppCollapsibleSidebarState();
}

class _AppCollapsibleSidebarState extends State<AppCollapsibleSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(
      begin: widget.collapsedWidth,
      end: widget.expandedWidth,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);

    if (!widget.isCollapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppCollapsibleSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with toggle button
              Container(
                height: 80,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    if (!widget.isCollapsed && widget.userInfo != null) ...[
                      AppAvatar(
                        imageUrl: widget.userInfo!.avatarUrl,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.userInfo!.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.userInfo!.email != null)
                              Text(
                                widget.userInfo!.email!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                    IconButton(
                      onPressed: widget.onToggleCollapse,
                      icon: Icon(
                        widget.isCollapsed ? Icons.menu : Icons.menu_open,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Navigation items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: widget.items.where((item) => !item.isDivider && !item.isSection).length,
                  itemBuilder: (context, index) {
                    final validItems = widget.items.where((item) => !item.isDivider && !item.isSection).toList();
                    final item = validItems[index];
                    final isSelected = widget.selectedIndex == widget.items.indexOf(item);

                    if (widget.isCollapsed) {
                      return _CollapsedSidebarTile(
                        item: item,
                        isSelected: isSelected,
                        onTap: () => widget.onItemTap?.call(widget.items.indexOf(item)),
                      );
                    } else {
                      return _SidebarTile(
                        item: item,
                        isSelected: isSelected,
                        onTap: () => widget.onItemTap?.call(widget.items.indexOf(item)),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CollapsedSidebarTile extends StatelessWidget {
  const _CollapsedSidebarTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppSidebarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Tooltip(
        message: item.title,
        child: InkWell(
          onTap: item.enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.colorScheme.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  item.icon,
                  color: isSelected 
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                if (item.badge != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: item.badge!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// AppSidebarItem - Data class for sidebar items
class AppSidebarItem {
  const AppSidebarItem({
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.badge,
    this.enabled = true,
    this.isDivider = false,
    this.isSection = false,
  });

  const AppSidebarItem.divider()
      : title = '',
        icon = null,
        subtitle = null,
        trailing = null,
        badge = null,
        enabled = true,
        isDivider = true,
        isSection = false;

  const AppSidebarItem.section({required this.title})
      : icon = null,
        subtitle = null,
        trailing = null,
        badge = null,
        enabled = true,
        isDivider = false,
        isSection = true;

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;
  final Widget? badge;
  final bool enabled;
  final bool isDivider;
  final bool isSection;
}

/// AppSidebarUserInfo - User information for sidebar header
class AppSidebarUserInfo {
  const AppSidebarUserInfo({
    required this.name,
    required this.avatarUrl,
    this.email,
    this.stats,
    this.onSettingsTap,
  });

  final String name;
  final String avatarUrl;
  final String? email;
  final Map<String, int>? stats;
  final VoidCallback? onSettingsTap;
}

/// AppSidebarController - Controller for managing sidebar state
class AppSidebarController extends ChangeNotifier {
  AppSidebarController({
    int initialIndex = 0,
    bool initialCollapsed = false,
  }) : _selectedIndex = initialIndex,
       _isCollapsed = initialCollapsed;

  int _selectedIndex;
  bool _isCollapsed;
  final Map<int, int> _badgeCounts = {};

  int get selectedIndex => _selectedIndex;
  bool get isCollapsed => _isCollapsed;
  Map<int, int> get badgeCounts => Map.unmodifiable(_badgeCounts);

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void toggleCollapse() {
    _isCollapsed = !_isCollapsed;
    notifyListeners();
  }

  void setCollapsed(bool collapsed) {
    if (_isCollapsed != collapsed) {
      _isCollapsed = collapsed;
      notifyListeners();
    }
  }

  void setBadgeCount(int itemIndex, int count) {
    _badgeCounts[itemIndex] = count;
    notifyListeners();
  }

  void clearBadge(int itemIndex) {
    _badgeCounts.remove(itemIndex);
    notifyListeners();
  }

  void clearAllBadges() {
    _badgeCounts.clear();
    notifyListeners();
  }
}
