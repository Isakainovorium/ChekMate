import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppNavigation - Bottom navigation bar with badges and animations
class AppNavigation extends StatefulWidget {
  const AppNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
    this.items = const [],
    this.type = BottomNavigationBarType.fixed,
    this.showLabels = true,
    this.enableAnimation = true,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavigationItem> items;
  final BottomNavigationBarType type;
  final bool showLabels;
  final bool enableAnimation;

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex &&
        widget.enableAnimation) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;

              return Expanded(
                child: _NavigationButton(
                  item: item,
                  isSelected: isSelected,
                  showLabel: widget.showLabels,
                  animation: widget.enableAnimation ? _animation : null,
                  onTap: () => widget.onTap(index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
    this.animation,
  });

  final AppNavigationItem item;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    Widget iconWidget = Icon(
      isSelected ? item.activeIcon ?? item.icon : item.icon,
      color: color,
      size: 24,
    );

    // Add badge if present
    if (item.badge != null) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -6,
            top: -6,
            child: item.badge!,
          ),
        ],
      );
    }

    // Add animation if enabled
    if (animation != null && isSelected) {
      iconWidget = AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (animation!.value * 0.2),
            child: child,
          );
        },
        child: iconWidget,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            if (showLabel && item.label != null) ...[
              const SizedBox(height: 2),
              Text(
                item.label!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// AppFloatingNavigation - Floating bottom navigation with modern design
class AppFloatingNavigation extends StatefulWidget {
  const AppFloatingNavigation({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    super.key,
    this.margin = const EdgeInsets.all(16),
    this.borderRadius = 24,
    this.elevation = 8,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavigationItem> items;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double elevation;

  @override
  State<AppFloatingNavigation> createState() => _AppFloatingNavigationState();
}

class _AppFloatingNavigationState extends State<AppFloatingNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: widget.elevation,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == widget.currentIndex;

                  return _FloatingNavigationButton(
                    item: item,
                    isSelected: isSelected,
                    onTap: () {
                      widget.onTap(index);
                      _controller.forward(from: 0.8);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingNavigationButton extends StatelessWidget {
  const _FloatingNavigationButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? item.activeIcon ?? item.icon : item.icon,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  if (item.badge != null)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: item.badge!,
                    ),
                ],
              ),
              if (isSelected && item.label != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  item.label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// AppTabNavigation - Tab-style navigation for top placement
class AppTabNavigation extends StatefulWidget {
  const AppTabNavigation({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    super.key,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavigationItem> items;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;

  @override
  State<AppTabNavigation> createState() => _AppTabNavigationState();
}

class _AppTabNavigationState extends State<AppTabNavigation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.items.length,
      vsync: this,
      initialIndex: widget.currentIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppTabNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _tabController.animateTo(widget.currentIndex);
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      widget.onTap(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      controller: _tabController,
      isScrollable: widget.isScrollable,
      indicatorColor: widget.indicatorColor ?? theme.colorScheme.primary,
      labelColor: widget.labelColor ?? theme.colorScheme.primary,
      unselectedLabelColor:
          widget.unselectedLabelColor ?? theme.colorScheme.onSurfaceVariant,
      tabs: widget.items.map((item) {
        final Widget tabChild = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(item.icon, size: 20),
                if (item.badge != null)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: item.badge!,
                  ),
              ],
            ),
            if (item.label != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(item.label!),
            ],
          ],
        );

        return Tab(child: tabChild);
      }).toList(),
    );
  }
}

/// AppNavigationItem - Data class for navigation items
class AppNavigationItem {
  const AppNavigationItem({
    required this.icon,
    this.activeIcon,
    this.label,
    this.badge,
    this.tooltip,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String? label;
  final Widget? badge;
  final String? tooltip;
}

/// AppNavigationBadge - Badge widget for navigation items
class AppNavigationBadge extends StatelessWidget {
  const AppNavigationBadge({
    super.key,
    this.count,
    this.showDot = false,
    this.color,
    this.textColor,
  });

  final int? count;
  final bool showDot;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.error;
    final badgeTextColor = textColor ?? theme.colorScheme.onError;

    if (showDot && (count == null || count == 0)) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
        ),
      );
    }

    if (count == null || count == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        count! > 99 ? '99+' : count.toString(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: badgeTextColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// AppNavigationController - Controller for managing navigation state
class AppNavigationController extends ChangeNotifier {
  AppNavigationController({
    this.initialIndex = 0,
  }) : _currentIndex = initialIndex;

  final int initialIndex;
  int _currentIndex;
  final Map<int, int> _badgeCounts = {};

  int get currentIndex => _currentIndex;

  Map<int, int> get badgeCounts => Map.unmodifiable(_badgeCounts);

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setBadgeCount(int tabIndex, int count) {
    _badgeCounts[tabIndex] = count;
    notifyListeners();
  }

  void clearBadge(int tabIndex) {
    _badgeCounts.remove(tabIndex);
    notifyListeners();
  }

  void clearAllBadges() {
    _badgeCounts.clear();
    notifyListeners();
  }
}
