import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation State
class NavigationState {
  final int currentIndex;
  final String currentRoute;
  final String activeTab;
  final bool isViewingStories;

  const NavigationState({
    this.currentIndex = 0,
    this.currentRoute = '/',
    this.activeTab = 'For You',
    this.isViewingStories = false,
  });

  NavigationState copyWith({
    int? currentIndex,
    String? currentRoute,
    String? activeTab,
    bool? isViewingStories,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      currentRoute: currentRoute ?? this.currentRoute,
      activeTab: activeTab ?? this.activeTab,
      isViewingStories: isViewingStories ?? this.isViewingStories,
    );
  }
}

/// Navigation State Notifier
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setRoute(String route) {
    state = state.copyWith(currentRoute: route);
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setViewingStories(bool isViewing) {
    state = state.copyWith(isViewingStories: isViewing);
  }

  void navigateToHome() {
    state = state.copyWith(currentIndex: 0, currentRoute: '/');
  }

  void navigateToExplore() {
    state = state.copyWith(currentIndex: 1, currentRoute: '/explore');
  }

  void navigateToCreate() {
    state = state.copyWith(currentIndex: 2, currentRoute: '/create');
  }

  void navigateToMessages() {
    state = state.copyWith(currentIndex: 3, currentRoute: '/messages');
  }

  void navigateToProfile() {
    state = state.copyWith(currentIndex: 4, currentRoute: '/profile');
  }
}

/// Navigation State Provider
final navStateProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
