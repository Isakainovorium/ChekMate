import 'package:flutter/material.dart';

/// AppTabs - Tab navigation with consistent styling
class AppTabs extends StatelessWidget {
  const AppTabs({
    required this.tabs, required this.children, super.key,
    this.controller,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.onTap,
  });

  final List<AppTab> tabs;
  final List<Widget> children;
  final TabController? controller;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          TabBar(
            controller: controller,
            tabs: tabs.map((tab) => Tab(
              text: tab.label,
              icon: tab.icon,
            ),).toList(),
            isScrollable: isScrollable,
            indicatorColor: indicatorColor ?? theme.colorScheme.primary,
            labelColor: labelColor ?? theme.colorScheme.primary,
            unselectedLabelColor: unselectedLabelColor ?? theme.colorScheme.onSurfaceVariant,
            onTap: onTap,
            tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// AppTabBar - Just the tab bar without TabBarView
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    required this.tabs, super.key,
    this.controller,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.onTap,
  });

  final List<AppTab> tabs;
  final TabController? controller;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TabBar(
      controller: controller,
      tabs: tabs.map((tab) => Tab(
        text: tab.label,
        icon: tab.icon,
      ),).toList(),
      isScrollable: isScrollable,
      indicatorColor: indicatorColor ?? theme.colorScheme.primary,
      labelColor: labelColor ?? theme.colorScheme.primary,
      unselectedLabelColor: unselectedLabelColor ?? theme.colorScheme.onSurfaceVariant,
      onTap: onTap,
      tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
    );
  }
}

/// Data class for tab items
class AppTab {
  const AppTab({
    required this.label,
    this.icon,
    this.badge,
  });

  final String label;
  final Widget? icon;
  final Widget? badge;
}
