import 'package:flutter_chekmate/core/navigation/nav_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Navigation State Management Tests
///
/// Tests the NavState provider and NavController functionality
void main() {
  group('NavState Tests', () {
    test('NavState has correct default values', () {
      const navState = NavState();

      expect(navState.activeTab, equals('For you'));
      expect(navState.isViewingStories, isFalse);
      expect(navState.isInConversation, isFalse);
    });

    test('NavState copyWith updates activeTab', () {
      const navState = NavState();
      final updated = navState.copyWith(activeTab: 'Explore');

      expect(updated.activeTab, equals('Explore'));
      expect(updated.isViewingStories, isFalse);
      expect(updated.isInConversation, isFalse);
    });

    test('NavState copyWith updates isViewingStories', () {
      const navState = NavState();
      final updated = navState.copyWith(isViewingStories: true);

      expect(updated.activeTab, equals('For you'));
      expect(updated.isViewingStories, isTrue);
      expect(updated.isInConversation, isFalse);
    });

    test('NavState copyWith updates isInConversation', () {
      const navState = NavState();
      final updated = navState.copyWith(isInConversation: true);

      expect(updated.activeTab, equals('For you'));
      expect(updated.isViewingStories, isFalse);
      expect(updated.isInConversation, isTrue);
    });

    test('NavState copyWith updates multiple fields', () {
      const navState = NavState();
      final updated = navState.copyWith(
        activeTab: 'Live',
        isViewingStories: true,
        isInConversation: true,
      );

      expect(updated.activeTab, equals('Live'));
      expect(updated.isViewingStories, isTrue);
      expect(updated.isInConversation, isTrue);
    });

    test('NavState copyWith preserves unchanged fields', () {
      const navState = NavState(
        activeTab: 'Following',
        isViewingStories: true,
        isInConversation: true,
      );
      final updated = navState.copyWith(activeTab: 'Explore');

      expect(updated.activeTab, equals('Explore'));
      expect(updated.isViewingStories, isTrue);
      expect(updated.isInConversation, isTrue);
    });
  });

  group('NavController Tests', () {
    late ProviderContainer container;
    late NavController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(navStateProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('NavController initializes with default state', () {
      final state = container.read(navStateProvider);

      expect(state.activeTab, equals('For you'));
      expect(state.isViewingStories, isFalse);
      expect(state.isInConversation, isFalse);
    });

    test('setActiveTab updates activeTab', () {
      controller.setActiveTab('Explore');
      final state = container.read(navStateProvider);

      expect(state.activeTab, equals('Explore'));
      expect(state.isViewingStories, isFalse);
      expect(state.isInConversation, isFalse);
    });

    test('setActiveTab can switch between all tabs', () {
      final tabs = ['For you', 'Following', 'Explore', 'Live', 'Subscribe'];

      for (final tab in tabs) {
        controller.setActiveTab(tab);
        final state = container.read(navStateProvider);
        expect(state.activeTab, equals(tab));
      }
    });

    test('setViewingStories updates isViewingStories', () {
      controller.setViewingStories(true);
      final state = container.read(navStateProvider);

      expect(state.activeTab, equals('For you'));
      expect(state.isViewingStories, isTrue);
      expect(state.isInConversation, isFalse);
    });

    test('setViewingStories can toggle between true and false', () {
      controller.setViewingStories(true);
      var state = container.read(navStateProvider);
      expect(state.isViewingStories, isTrue);

      controller.setViewingStories(false);
      state = container.read(navStateProvider);
      expect(state.isViewingStories, isFalse);
    });

    test('setInConversation updates isInConversation', () {
      controller.setInConversation(true);
      final state = container.read(navStateProvider);

      expect(state.activeTab, equals('For you'));
      expect(state.isViewingStories, isFalse);
      expect(state.isInConversation, isTrue);
    });

    test('setInConversation can toggle between true and false', () {
      controller.setInConversation(true);
      var state = container.read(navStateProvider);
      expect(state.isInConversation, isTrue);

      controller.setInConversation(false);
      state = container.read(navStateProvider);
      expect(state.isInConversation, isFalse);
    });

    test('resetToHome resets activeTab to For you', () {
      controller.setActiveTab('Explore');
      controller.setViewingStories(true);
      controller.setInConversation(true);

      controller.resetToHome();
      final state = container.read(navStateProvider);

      expect(state.activeTab, equals('For you'));
      // Note: resetToHome only resets activeTab, not other flags
      expect(state.isViewingStories, isTrue);
      expect(state.isInConversation, isTrue);
    });

    test('Multiple state updates work correctly', () {
      controller.setActiveTab('Live');
      controller.setViewingStories(true);
      controller.setInConversation(true);

      final state = container.read(navStateProvider);

      expect(state.activeTab, equals('Live'));
      expect(state.isViewingStories, isTrue);
      expect(state.isInConversation, isTrue);
    });

    test('State updates are independent', () {
      controller.setActiveTab('Following');
      var state = container.read(navStateProvider);
      expect(state.activeTab, equals('Following'));
      expect(state.isViewingStories, isFalse);

      controller.setViewingStories(true);
      state = container.read(navStateProvider);
      expect(state.activeTab, equals('Following'));
      expect(state.isViewingStories, isTrue);

      controller.setInConversation(true);
      state = container.read(navStateProvider);
      expect(state.activeTab, equals('Following'));
      expect(state.isViewingStories, isTrue);
      expect(state.isInConversation, isTrue);
    });
  });

  group('NavState Provider Tests', () {
    test('navStateProvider can be read from container', () {
      final container = ProviderContainer();
      final state = container.read(navStateProvider);

      expect(state, isA<NavState>());
      expect(state.activeTab, equals('For you'));

      container.dispose();
    });

    test('navStateProvider notifier can be accessed', () {
      final container = ProviderContainer();
      final notifier = container.read(navStateProvider.notifier);

      expect(notifier, isA<NavController>());

      container.dispose();
    });

    test('Multiple containers have independent state', () {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();

      container1.read(navStateProvider.notifier).setActiveTab('Explore');
      container2.read(navStateProvider.notifier).setActiveTab('Live');

      final state1 = container1.read(navStateProvider);
      final state2 = container2.read(navStateProvider);

      expect(state1.activeTab, equals('Explore'));
      expect(state2.activeTab, equals('Live'));

      container1.dispose();
      container2.dispose();
    });
  });

  group('Navigation State Scenarios', () {
    late ProviderContainer container;
    late NavController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(navStateProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Scenario: User views stories', () {
      // User starts on For you tab
      var state = container.read(navStateProvider);
      expect(state.activeTab, equals('For you'));
      expect(state.isViewingStories, isFalse);

      // User taps on a story
      controller.setViewingStories(true);
      state = container.read(navStateProvider);
      expect(state.isViewingStories, isTrue);

      // User closes story viewer
      controller.setViewingStories(false);
      state = container.read(navStateProvider);
      expect(state.isViewingStories, isFalse);
    });

    test('Scenario: User enters and exits conversation', () {
      // User is on messages page
      var state = container.read(navStateProvider);
      expect(state.isInConversation, isFalse);

      // User opens a chat
      controller.setInConversation(true);
      state = container.read(navStateProvider);
      expect(state.isInConversation, isTrue);

      // User goes back to messages list
      controller.setInConversation(false);
      state = container.read(navStateProvider);
      expect(state.isInConversation, isFalse);
    });

    test('Scenario: User switches between tabs', () {
      // User starts on For you
      controller.setActiveTab('For you');
      var state = container.read(navStateProvider);
      expect(state.activeTab, equals('For you'));

      // User switches to Following
      controller.setActiveTab('Following');
      state = container.read(navStateProvider);
      expect(state.activeTab, equals('Following'));

      // User switches to Explore
      controller.setActiveTab('Explore');
      state = container.read(navStateProvider);
      expect(state.activeTab, equals('Explore'));

      // User switches to Live
      controller.setActiveTab('Live');
      state = container.read(navStateProvider);
      expect(state.activeTab, equals('Live'));

      // User switches to Subscribe
      controller.setActiveTab('Subscribe');
      state = container.read(navStateProvider);
      expect(state.activeTab, equals('Subscribe'));
    });

    test('Scenario: User views stories while on different tab', () {
      // User is on Following tab
      controller.setActiveTab('Following');
      var state = container.read(navStateProvider);
      expect(state.activeTab, equals('Following'));

      // User views stories
      controller.setViewingStories(true);
      state = container.read(navStateProvider);
      expect(state.activeTab, equals('Following'));
      expect(state.isViewingStories, isTrue);

      // User closes stories and is still on Following tab
      controller.setViewingStories(false);
      state = container.read(navStateProvider);
      expect(state.activeTab, equals('Following'));
      expect(state.isViewingStories, isFalse);
    });
  });
}

