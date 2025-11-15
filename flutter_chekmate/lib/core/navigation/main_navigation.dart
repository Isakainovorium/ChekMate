import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/route_constants.dart';
import 'nav_state.dart';

/// Main Navigation Widget
/// 
/// Coordinates bottom navigation bar and top tab navigation.
/// Manages navigation state and provides unified navigation interface.
/// 
/// Date: 11/13/2025
class MainNavigation extends ConsumerWidget {
  const MainNavigation({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBottomTab = ref.watch(bottomNavTabProvider);
    final currentTopTab = ref.watch(topNavTabProvider);

    return Scaffold(
      body: Column(
        children: [
          // Top tab navigation (shown on home/explore pages)
          if (_shouldShowTopTabs(currentBottomTab))
            _TopTabNavigation(
              currentTab: currentTopTab,
              onTabChanged: (tab) {
                updateTopNavTab(ref, tab);
                _navigateToTopTab(context, tab);
              },
            ),
          // Main content
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _BottomNavigationBar(
        currentTab: currentBottomTab,
        onTabChanged: (tab) {
          updateBottomNavTab(ref, tab);
          _navigateToBottomTab(context, tab);
        },
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
        context.go(RouteConstants.home);
        break;
      case BottomNavTab.messages:
        context.go(RouteConstants.messages);
        break;
      case BottomNavTab.notifications:
        context.go(RouteConstants.notifications);
        break;
      case BottomNavTab.profile:
        context.go(RouteConstants.profile);
        break;
    }
  }

  /// Navigates to top tab
  void _navigateToTopTab(BuildContext context, TopNavTab tab) {
    switch (tab) {
      case TopNavTab.forYou:
        context.go(RouteConstants.home);
        break;
      case TopNavTab.following:
        // TODO: Navigate to following feed when implemented
        break;
      case TopNavTab.explore:
        context.go(RouteConstants.explore);
        break;
      case TopNavTab.live:
        context.go(RouteConstants.live);
        break;
      case TopNavTab.subscribe:
        context.go(RouteConstants.subscribe);
        break;
    }
  }
}

/// Bottom Navigation Bar Widget
class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.currentTab,
    required this.onTabChanged,
  });

  final BottomNavTab currentTab;
  final ValueChanged<BottomNavTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentTab.index,
      onDestinationSelected: (index) {
        final tab = BottomNavTab.values.firstWhere(
          (tab) => tab.index == index,
        );
        onTabChanged(tab);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.message_outlined),
          selectedIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
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

