import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/navigation/main_navigation.dart';
import 'package:flutter_chekmate/core/router/app_router_provider.dart';
import 'package:flutter_chekmate/pages/auth/login_page.dart';
import 'package:flutter_chekmate/pages/auth/signup_page.dart';
import 'package:flutter_chekmate/pages/create_post/create_post_page.dart';
import 'package:flutter_chekmate/pages/explore/explore_page.dart';
import 'package:flutter_chekmate/pages/home/home_page.dart';
import 'package:flutter_chekmate/pages/live/live_page.dart';
import 'package:flutter_chekmate/pages/messages/chat_page.dart';
import 'package:flutter_chekmate/pages/messages/messages_page.dart';
import 'package:flutter_chekmate/pages/notifications/notifications_page.dart';
import 'package:flutter_chekmate/pages/profile/my_profile_page.dart';
import 'package:flutter_chekmate/pages/rate_date/rate_date_page.dart';
import 'package:flutter_chekmate/pages/subscribe/subscribe_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:network_image_mock/network_image_mock.dart';

/// Comprehensive Routing Tests for ChekMate App
///
/// Tests all routes, navigation patterns, and routing behavior
/// based on the Figma routing guide implementation.
void main() {
  group('App Router Tests', () {
    late GoRouter router;
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      router = container.read(appRouterProvider);
    });

    tearDown(() {
      container.dispose();
    });

    group('Route Existence Tests', () {
      test('All routes from Figma guide are configured', () {
        final routes = router.configuration.routes;
        expect(routes.length, greaterThanOrEqualTo(13));

        // Extract route paths
        final routePaths =
            routes.whereType<GoRoute>().map((r) => r.path).toList();

        // Auth routes
        expect(routePaths, contains('/login'));
        expect(routePaths, contains('/signup'));

        // Bottom navigation routes
        expect(routePaths, contains('/'));
        expect(routePaths, contains('/messages'));
        expect(routePaths, contains('/notifications'));
        expect(routePaths, contains('/profile'));

        // Top navigation tab routes (dual access)
        expect(routePaths, contains('/explore'));
        expect(routePaths, contains('/live'));
        expect(routePaths, contains('/subscribe'));

        // Full-screen routes
        expect(routePaths, contains('/rate-date'));
        expect(routePaths, contains('/create-post'));

        // Chat route with parameter
        expect(routePaths, contains('/chat/:conversationId'));
      });

      test('All routes have names configured', () {
        final routes = router.configuration.routes.whereType<GoRoute>();

        for (final route in routes) {
          expect(route.name, isNotNull,
              reason: 'Route ${route.path} should have a name',);
          expect(route.name, isNotEmpty,
              reason: 'Route ${route.path} name should not be empty',);
        }
      });

      test('Route names match expected values', () {
        final routes = router.configuration.routes.whereType<GoRoute>();
        final routeMap = {for (var r in routes) r.path: r.name};

        expect(routeMap['/login'], equals('login'));
        expect(routeMap['/signup'], equals('signup'));
        expect(routeMap['/'], equals('home'));
        expect(routeMap['/messages'], equals('messages'));
        expect(routeMap['/chat/:conversationId'], equals('chat'));
        expect(routeMap['/profile'], equals('profile'));
        expect(routeMap['/notifications'], equals('notifications'));
        expect(routeMap['/explore'], equals('explore'));
        expect(routeMap['/live'], equals('live'));
        expect(routeMap['/subscribe'], equals('subscribe'));
        expect(routeMap['/rate-date'], equals('rate-date'));
        expect(routeMap['/create-post'], equals('create-post'));
      });
    });

    group('Navigation Tests', () {
      testWidgets('Navigate to login page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/login');
          await tester.pumpAndSettle();

          expect(find.byType(LoginPage), findsOneWidget);
        });
      });

      testWidgets('Navigate to signup page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/signup');
          await tester.pumpAndSettle();

          expect(find.byType(SignUpPage), findsOneWidget);
        });
      });

      testWidgets('Navigate to home page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/');
          await tester.pumpAndSettle();

          expect(find.byType(HomePage), findsOneWidget);
          expect(find.byType(MainNavigation), findsOneWidget);
        });
      });

      testWidgets('Navigate to messages page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/messages');
          await tester.pumpAndSettle();

          expect(find.byType(MessagesPage), findsOneWidget);
          expect(find.byType(MainNavigation), findsOneWidget);
        });
      });

      testWidgets('Navigate to notifications page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/notifications');
          await tester.pumpAndSettle();

          expect(find.byType(NotificationsPage), findsOneWidget);
          expect(find.byType(MainNavigation), findsOneWidget);
        });
      });

      testWidgets('Navigate to profile page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/profile');
          await tester.pumpAndSettle();

          expect(find.byType(MyProfilePage), findsOneWidget);
          expect(find.byType(MainNavigation), findsOneWidget);
        });
      });

      testWidgets('Navigate to explore page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/explore');
          await tester.pumpAndSettle();

          expect(find.byType(ExplorePage), findsOneWidget);
          expect(find.byType(MainNavigation), findsOneWidget);
        });
      });

      testWidgets('Navigate to live page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/live');
          await tester.pumpAndSettle();

          expect(find.byType(LivePage), findsOneWidget);
          expect(find.byType(MainNavigation), findsOneWidget);
        });
      });

      testWidgets('Navigate to subscribe page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/subscribe');
          await tester.pumpAndSettle();

          expect(find.byType(SubscribePage), findsOneWidget);
          expect(find.byType(MainNavigation), findsOneWidget);
        });
      });

      testWidgets('Navigate to rate-date page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/rate-date');
          await tester.pumpAndSettle();

          expect(find.byType(RateDatePage), findsOneWidget);
          expect(find.byType(MainNavigation), findsOneWidget);
        });
      });

      testWidgets('Navigate to create-post page', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/create-post');
          await tester.pumpAndSettle();

          expect(find.byType(CreatePostPage), findsOneWidget);
          expect(find.byType(MainNavigation), findsOneWidget);
        });
      });
    });

    group('Route Parameter Tests', () {
      testWidgets('Chat route handles conversationId parameter',
          (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          const testConversationId = 'test-conversation-123';
          router.go('/chat/$testConversationId');
          await tester.pumpAndSettle();

          expect(find.byType(ChatPage), findsOneWidget);

          // Verify the ChatPage received the correct conversationId
          final chatPage = tester.widget<ChatPage>(find.byType(ChatPage));
          expect(chatPage.conversationId, equals(testConversationId));
        });
      });

      testWidgets('Chat route handles query parameters', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          const testConversationId = 'test-conversation-123';
          const testUserId = 'user-456';
          const testUserName = 'John Doe';
          const testUserAvatar = 'https://example.com/avatar.jpg';

          router.go(
            '/chat/$testConversationId?userId=$testUserId&userName=$testUserName&userAvatar=$testUserAvatar',
          );
          await tester.pumpAndSettle();

          expect(find.byType(ChatPage), findsOneWidget);

          // Verify the ChatPage received all parameters
          final chatPage = tester.widget<ChatPage>(find.byType(ChatPage));
          expect(chatPage.conversationId, equals(testConversationId));
          expect(chatPage.otherUserId, equals(testUserId));
          expect(chatPage.otherUserName, equals(testUserName));
          expect(chatPage.otherUserAvatar, equals(testUserAvatar));
        });
      });

      testWidgets('Chat route handles missing query parameters gracefully',
          (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          const testConversationId = 'test-conversation-123';
          router.go('/chat/$testConversationId');
          await tester.pumpAndSettle();

          expect(find.byType(ChatPage), findsOneWidget);

          // Verify the ChatPage uses default values for missing parameters
          final chatPage = tester.widget<ChatPage>(find.byType(ChatPage));
          expect(chatPage.conversationId, equals(testConversationId));
          expect(chatPage.otherUserId, equals(''));
          expect(chatPage.otherUserName, equals('User'));
          expect(chatPage.otherUserAvatar, equals(''));
        });
      });
    });

    group('Deep Linking Tests', () {
      testWidgets('Deep link to chat conversation works', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          // Simulate deep link
          router.go(
              '/chat/deep-link-conversation-789?userId=user-999&userName=Jane',);
          await tester.pumpAndSettle();

          expect(find.byType(ChatPage), findsOneWidget);

          final chatPage = tester.widget<ChatPage>(find.byType(ChatPage));
          expect(chatPage.conversationId, equals('deep-link-conversation-789'));
          expect(chatPage.otherUserId, equals('user-999'));
          expect(chatPage.otherUserName, equals('Jane'));
        });
      });

      testWidgets('Deep link to explore page works', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/explore');
          await tester.pumpAndSettle();

          expect(find.byType(ExplorePage), findsOneWidget);
        });
      });

      testWidgets('Deep link to live page works', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/live');
          await tester.pumpAndSettle();

          expect(find.byType(LivePage), findsOneWidget);
        });
      });

      testWidgets('Deep link to rate-date page works', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/rate-date');
          await tester.pumpAndSettle();

          expect(find.byType(RateDatePage), findsOneWidget);
        });
      });

      testWidgets('Deep link to create-post page works', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                routerConfig: router,
              ),
            ),
          );

          router.go('/create-post');
          await tester.pumpAndSettle();

          expect(find.byType(CreatePostPage), findsOneWidget);
        });
      });
    });
  });
}
