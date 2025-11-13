import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation state management for ChekMate application
/// 
/// Provides Riverpod providers for managing navigation state including
/// bottom navigation bar selection, top tab selection, and navigation history.
/// 
/// Date: 11/13/2025

/// Bottom navigation tab indices
enum BottomNavTab {
  home,
  messages,
  notifications,
  profile;
}

/// Top navigation tab indices
enum TopNavTab {
  forYou,
  following,
  explore,
  live,
  subscribe;
}

/// Current bottom navigation tab state provider
/// 
/// Manages which bottom navigation tab is currently selected.
final bottomNavTabProvider = StateProvider<BottomNavTab>((ref) {
  return BottomNavTab.home;
});

/// Current top navigation tab state provider
/// 
/// Manages which top navigation tab is currently selected.
final topNavTabProvider = StateProvider<TopNavTab>((ref) {
  return TopNavTab.forYou;
});

/// Navigation history provider
/// 
/// Tracks navigation history for back navigation support.
final navigationHistoryProvider =
    StateProvider<List<String>>((ref) => []);

/// Modal/drawer state provider
/// 
/// Manages whether a modal or drawer is currently open.
final modalStateProvider = StateProvider<bool>((ref) => false);

/// Drawer state provider
/// 
/// Manages whether the navigation drawer is open.
final drawerStateProvider = StateProvider<bool>((ref) => false);

/// Helper functions for navigation state management

/// Updates bottom navigation tab
void updateBottomNavTab(WidgetRef ref, BottomNavTab tab) {
  ref.read(bottomNavTabProvider.notifier).state = tab;
}

/// Updates top navigation tab
void updateTopNavTab(WidgetRef ref, TopNavTab tab) {
  ref.read(topNavTabProvider.notifier).state = tab;
}

/// Adds route to navigation history
void addToNavigationHistory(WidgetRef ref, String route) {
  final history = ref.read(navigationHistoryProvider);
  final updatedHistory = [...history, route];
  
  // Limit history to last 50 routes to prevent memory issues
  if (updatedHistory.length > 50) {
    updatedHistory.removeAt(0);
  }
  
  ref.read(navigationHistoryProvider.notifier).state = updatedHistory;
}

/// Clears navigation history
void clearNavigationHistory(WidgetRef ref) {
  ref.read(navigationHistoryProvider.notifier).state = [];
}

/// Sets modal state
void setModalState(WidgetRef ref, bool isOpen) {
  ref.read(modalStateProvider.notifier).state = isOpen;
}

/// Sets drawer state
void setDrawerState(WidgetRef ref, bool isOpen) {
  ref.read(drawerStateProvider.notifier).state = isOpen;
}

