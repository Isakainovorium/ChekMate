import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/navigation/main_navigation.dart';
import 'package:flutter_chekmate/core/router/app_router.dart';
import 'package:flutter_chekmate/pages/create_post/create_post_page.dart';
import 'package:flutter_chekmate/pages/home/home_page.dart';
import 'package:flutter_chekmate/pages/messages/chat_page.dart';
import 'package:flutter_chekmate/pages/messages/messages_page.dart';
import 'package:flutter_chekmate/pages/rate_date/rate_date_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

/// Bottom Navigation Visibility Tests
///
/// Tests that bottom navigation is shown/hidden correctly based on route
void main() {
  group('Bottom Navigation Visibility Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Bottom navigation is visible on home page', (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/');
        await tester.pumpAndSettle();

        // Verify HomePage is displayed
        expect(find.byType(HomePage), findsOneWidget);

        // Verify MainNavigation wrapper is present
        expect(find.byType(MainNavigation), findsOneWidget);

        // Verify bottom navigation bar is visible
        // The MainNavigation should contain a BottomNavigationBar
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });
    });

    testWidgets('Bottom navigation is visible on messages page',
        (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/messages');
        await tester.pumpAndSettle();

        // Verify MessagesPage is displayed
        expect(find.byType(MessagesPage), findsOneWidget);

        // Verify bottom navigation bar is visible
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });
    });

    testWidgets('Bottom navigation is HIDDEN in chat page', (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/chat/test-conversation-123');
        await tester.pumpAndSettle();

        // Verify ChatPage is displayed
        expect(find.byType(ChatPage), findsOneWidget);

        // Verify MainNavigation wrapper is present (it wraps all routes)
        expect(find.byType(MainNavigation), findsOneWidget);

        // Verify bottom navigation bar is NOT visible
        // When hideNavigation is true, the BottomNavigationBar should not be rendered
        expect(find.byType(BottomNavigationBar), findsNothing);
      });
    });

    testWidgets('Bottom navigation is HIDDEN in rate-date page',
        (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/rate-date');
        await tester.pumpAndSettle();

        // Verify RateDatePage is displayed
        expect(find.byType(RateDatePage), findsOneWidget);

        // Verify MainNavigation wrapper is present
        expect(find.byType(MainNavigation), findsOneWidget);

        // Verify bottom navigation bar is NOT visible
        expect(find.byType(BottomNavigationBar), findsNothing);
      });
    });

    testWidgets('Bottom navigation is HIDDEN in create-post page',
        (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/create-post');
        await tester.pumpAndSettle();

        // Verify CreatePostPage is displayed
        expect(find.byType(CreatePostPage), findsOneWidget);

        // Verify MainNavigation wrapper is present
        expect(find.byType(MainNavigation), findsOneWidget);

        // Verify bottom navigation bar is NOT visible
        expect(find.byType(BottomNavigationBar), findsNothing);
      });
    });

    testWidgets(
        'Bottom navigation visibility toggles correctly when navigating',
        (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        // Start on home page - bottom nav should be visible
        router.go('/');
        await tester.pumpAndSettle();
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Navigate to chat - bottom nav should be hidden
        router.go('/chat/test-123');
        await tester.pumpAndSettle();
        expect(find.byType(BottomNavigationBar), findsNothing);

        // Navigate back to messages - bottom nav should be visible again
        router.go('/messages');
        await tester.pumpAndSettle();
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Navigate to rate-date - bottom nav should be hidden
        router.go('/rate-date');
        await tester.pumpAndSettle();
        expect(find.byType(BottomNavigationBar), findsNothing);

        // Navigate back to home - bottom nav should be visible again
        router.go('/');
        await tester.pumpAndSettle();
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });
    });
  });

  group('Bottom Navigation Index Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Home page has correct bottom nav index (0)', (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/');
        await tester.pumpAndSettle();

        final mainNav =
            tester.widget<MainNavigation>(find.byType(MainNavigation));
        expect(mainNav.currentIndex, equals(0));
      });
    });

    testWidgets('Messages page has correct bottom nav index (1)',
        (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/messages');
        await tester.pumpAndSettle();

        final mainNav =
            tester.widget<MainNavigation>(find.byType(MainNavigation));
        expect(mainNav.currentIndex, equals(1));
      });
    });

    testWidgets('Notifications page has correct bottom nav index (3)',
        (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/notifications');
        await tester.pumpAndSettle();

        final mainNav =
            tester.widget<MainNavigation>(find.byType(MainNavigation));
        expect(mainNav.currentIndex, equals(3));
      });
    });

    testWidgets('Profile page has correct bottom nav index (4)',
        (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/profile');
        await tester.pumpAndSettle();

        final mainNav =
            tester.widget<MainNavigation>(find.byType(MainNavigation));
        expect(mainNav.currentIndex, equals(4));
      });
    });

    testWidgets('Explore page has correct bottom nav index (0)',
        (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/explore');
        await tester.pumpAndSettle();

        final mainNav =
            tester.widget<MainNavigation>(find.byType(MainNavigation));
        // Explore is part of Home, so index should be 0
        expect(mainNav.currentIndex, equals(0));
      });
    });

    testWidgets('Live page has correct bottom nav index (0)', (tester) async {
      await mockNetworkImagesFor(() async {
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(container: container,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        router.go('/live');
        await tester.pumpAndSettle();

        final mainNav =
            tester.widget<MainNavigation>(find.byType(MainNavigation));
        // Live is part of Home, so index should be 0
        expect(mainNav.currentIndex, equals(0));
      });
    });
  });
}

