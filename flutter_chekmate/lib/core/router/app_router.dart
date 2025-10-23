import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/navigation/main_navigation.dart';
import 'package:flutter_chekmate/features/theme_test/theme_test_page.dart';
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
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),

      // Home/Feed wrapped in bottom navigation shell
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainNavigation(
          currentIndex: 0,
          child: HomePage(),
        ),
      ),

      // Messages (with bottom nav)
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const MainNavigation(
          currentIndex: 1,
          child: MessagesPage(),
        ),
      ),

      // Chat (hide bottom nav inside conversation)
      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          final otherUserId = state.uri.queryParameters['userId'] ?? '';
          final otherUserName = state.uri.queryParameters['userName'] ?? 'User';
          final otherUserAvatar = state.uri.queryParameters['userAvatar'] ?? '';
          return MainNavigation(
            currentIndex: 1,
            hideNavigation: true,
            child: ChatPage(
              conversationId: conversationId,
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              otherUserAvatar: otherUserAvatar,
            ),
          );
        },
      ),

      // Profile (with bottom nav) - using existing profile page
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) {
          return const MainNavigation(
            currentIndex: 4,
            child: MyProfilePage(
              userAvatar: 'https://via.placeholder.com/150', // Default avatar
            ),
          );
        },
      ),

      // Notifications (with bottom nav)
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const MainNavigation(
          currentIndex: 3,
          child: NotificationsPage(),
        ),
      ),

      // Explore (accessible both as route and as tab within Home)
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (context, state) => const MainNavigation(
          currentIndex: 0,
          child: ExplorePage(),
        ),
      ),

      // Live (accessible both as route and as tab within Home)
      GoRoute(
        path: '/live',
        name: 'live',
        builder: (context, state) => const MainNavigation(
          currentIndex: 0,
          child: LivePage(
            userAvatar: 'https://via.placeholder.com/150', // Default avatar
          ),
        ),
      ),

      // Subscribe (accessible as tab within Home)
      GoRoute(
        path: '/subscribe',
        name: 'subscribe',
        builder: (context, state) => const MainNavigation(
          currentIndex: 0,
          child: SubscribePage(),
        ),
      ),

      // Rate Your Date (full screen; hide bottom nav)
      GoRoute(
        path: '/rate-date',
        name: 'rate-date',
        builder: (context, state) => const MainNavigation(
          currentIndex: 0,
          hideNavigation: true,
          child: RateDatePage(),
        ),
      ),

      // Create Post (full screen; hide bottom nav)
      GoRoute(
        path: '/create-post',
        name: 'create-post',
        builder: (context, state) => const MainNavigation(
          currentIndex: 0,
          hideNavigation: true,
          child: CreatePostPage(),
        ),
      ),

      // Theme Test (Development only)
      GoRoute(
        path: '/theme-test',
        name: 'theme-test',
        builder: (context, state) => const ThemeTestPage(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
