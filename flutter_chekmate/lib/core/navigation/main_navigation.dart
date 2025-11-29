import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_chekmate/shared/ui/premium/premium_glass_nav_bar.dart';

import '../router/route_constants.dart';
import 'nav_state.dart';

/// Main Navigation Widget
/// 
/// Coordinates bottom navigation bar and top tab navigation.
/// Manages navigation state and provides unified navigation interface.
/// 
/// Sprint 1 - Task 1.1.5: Added semantic accessibility support
/// Date: 11/13/2025
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({
    required this.child,
    this.currentIndex,
    this.hideNavigation = false,
    super.key,
  });

  final Widget child;
  final int? currentIndex;
  final bool hideNavigation;

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  @override
  void initState() {
    super.initState();
    // Update navigation state if currentIndex is provided
    if (widget.currentIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final index = widget.currentIndex!;
        if (index < BottomNavTab.values.length) {
          updateBottomNavTab(ref, BottomNavTab.values[index]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBottomTab = ref.watch(bottomNavTabProvider);
    final currentTopTab = ref.watch(topNavTabProvider);

    return Scaffold(
      extendBody: true, // Allow content to extend behind the floating nav bar
      body: Semantics(
        label: 'Main content area',
        container: true,
        child: Column(
          children: [
            // Top tab navigation (shown on home/explore pages)
            if (_shouldShowTopTabs(currentBottomTab) && !widget.hideNavigation)
              Semantics(
                label: 'Content filter tabs',
                container: true,
                child: _TopTabNavigation(
                  currentTab: currentTopTab,
                  onTabChanged: (tab) {
                    updateTopNavTab(ref, tab);
                    _navigateToTopTab(context, tab);
                  },
                ),
              ),
            // Main content
            Expanded(child: widget.child),
            // Add bottom padding to account for floating nav bar
            if (!widget.hideNavigation) const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: widget.hideNavigation
          ? null
          : Semantics(
              label: 'Main navigation',
              container: true,
              child: PremiumGlassNavBar(
                currentIndex: currentBottomTab.index,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message_outlined),
                    activeIcon: Icon(Icons.message),
                    label: 'Messages',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_outlined),
                    activeIcon: Icon(Icons.notifications),
                    label: 'Alerts',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
                onTap: (index) {
                  final tab = BottomNavTab.values[index];
                  updateBottomNavTab(ref, tab);
                  _navigateToBottomTab(context, tab);
                },
              ),
            ),
    );
  }

  /// Determines if top tabs should be shown
  bool _shouldShowTopTabs(BottomNavTab tab) {
    return tab == BottomNavTab.home;
  }

  /// Navigates to bottom navigation tab
  void _navigateToBottomTab(BuildContext context, BottomNavTab tab) {
    switch (tab) {
      case BottomNavTab.home:
        context.go(RoutePaths.home);
        break;
      case BottomNavTab.messages:
        context.go(RoutePaths.messages);
        break;
      case BottomNavTab.notifications:
        context.go(RoutePaths.notifications);
        break;
      case BottomNavTab.profile:
        context.go(RoutePaths.profile);
        break;
    }
  }

  /// Navigates to top tab
  void _navigateToTopTab(BuildContext context, TopNavTab tab) {
    switch (tab) {
      case TopNavTab.forYou:
        context.go(RoutePaths.home);
        break;
      case TopNavTab.following:
        context.go(RoutePaths.home);
        break;
      case TopNavTab.explore:
        context.go(RoutePaths.explore);
        break;
      case TopNavTab.live:
        context.go(RoutePaths.live);
        break;
      case TopNavTab.subscribe:
        context.go(RoutePaths.subscribe);
        break;
    }
  }
}

/// Top Tab Navigation Widget
class _TopTabNavigation extends StatelessWidget {
  const _TopTabNavigation({
    required this.currentTab,
    required this.onTabChanged,
  });

  final TopNavTab currentTab;
  final ValueChanged<TopNavTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabs: TopNavTab.values.map((tab) {
        return Tab(
          text: _getTabLabel(tab),
        );
      }).toList(),
      onTap: (index) {
        final tab = TopNavTab.values.firstWhere(
          (tab) => tab.index == index,
        );
        onTabChanged(tab);
      },
    );
  }

  String _getTabLabel(TopNavTab tab) {
    switch (tab) {
      case TopNavTab.forYou:
        return 'For You';
      case TopNavTab.following:
        return 'Following';
      case TopNavTab.explore:
        return 'Explore';
      case TopNavTab.live:
        return 'Live';
      case TopNavTab.subscribe:
        return 'Subscribe';
    }
  }
}

