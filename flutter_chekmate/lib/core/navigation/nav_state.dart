import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavState {

  const NavState({
    this.activeTab = 'For you',
    this.isViewingStories = false,
    this.isInConversation = false,
  });
  final String activeTab; // 'For you' | 'Following' | 'Explore' | 'Live' | 'Subscribe'
  final bool isViewingStories;
  final bool isInConversation;

  NavState copyWith({
    String? activeTab,
    bool? isViewingStories,
    bool? isInConversation,
  }) {
    return NavState(
      activeTab: activeTab ?? this.activeTab,
      isViewingStories: isViewingStories ?? this.isViewingStories,
      isInConversation: isInConversation ?? this.isInConversation,
    );
  }
}

class NavController extends StateNotifier<NavState> {
  NavController() : super(const NavState());

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setViewingStories(bool value) {
    state = state.copyWith(isViewingStories: value);
  }

  void setInConversation(bool value) {
    state = state.copyWith(isInConversation: value);
  }

  void resetToHome() {
    state = state.copyWith(activeTab: 'For you');
  }
}

final navStateProvider = StateNotifierProvider<NavController, NavState>((ref) {
  return NavController();
});
