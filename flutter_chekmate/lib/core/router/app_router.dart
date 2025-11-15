import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App Router
/// Defines the routing configuration for the app
class AppRouter {
  AppRouter._();

  /// Create router with authentication state
  static GoRouter createRouter({
    required bool Function() isAuthenticated,
  }) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      ],
      redirect: (context, state) {
        final authenticated = isAuthenticated();
        final isAuthRoute = state.matchedLocation.startsWith('/auth');

        // If not authenticated and not on auth route, redirect to login
        if (!authenticated && !isAuthRoute) {
          return '/auth/login';
        }

        // If authenticated and on auth route, redirect to home
        if (authenticated && isAuthRoute) {
          return '/';
        }

        return null;
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home')),
        ),
      ),
    ],
  );

  /// Navigate to a route
  static void navigateTo(BuildContext context, String route) {
    context.go(route);
  }

  /// Navigate back
  static void navigateBack(BuildContext context) {
    context.pop();
  }

  /// Replace current route
  static void replaceTo(BuildContext context, String route) {
    context.replace(route);
  }
}
