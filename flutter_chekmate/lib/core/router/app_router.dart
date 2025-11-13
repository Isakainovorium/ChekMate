import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/pages/two_factor_verification_page.dart';
import '../../features/profile/pages/notification_schedule_settings_page.dart';
import '../../features/profile/pages/theme_settings_page.dart';
import 'route_constants.dart';

/// App Router configuration
/// 
/// Defines all GoRoute configurations with guards, transitions,
/// and error handling. This is the central routing configuration
/// for the ChekMate application.
/// 
/// Date: 11/13/2025
class AppRouter {
  AppRouter._();

  /// Creates GoRouter instance with all route configurations
  /// 
  /// [isAuthenticated] - Function to check if user is authenticated
  /// Returns GoRouter instance configured with all routes
  static GoRouter createRouter({
    required bool Function() isAuthenticated,
  }) {
    return GoRouter(
      initialLocation: RouteConstants.home,
      debugLogDiagnostics: true,
      redirect: (BuildContext context, GoRouterState state) {
        final isAuth = isAuthenticated();
        final isAuthRoute = _isAuthRoute(state.uri.path);

        // Redirect to login if not authenticated and trying to access protected route
        if (!isAuth && !isAuthRoute) {
          return RouteConstants.login;
        }

        // Redirect to home if authenticated and trying to access auth route
        if (isAuth && isAuthRoute) {
          return RouteConstants.home;
        }

        return null;
      },
      errorBuilder: (context, state) => _buildErrorPage(state.error),
      routes: _buildRoutes(),
    );
  }

  /// Builds all route configurations
  static List<RouteBase> _buildRoutes() {
    return [
      // Authentication routes
      GoRoute(
        path: RouteConstants.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Login'),
        ),
      ),
      GoRoute(
        path: RouteConstants.signup,
        name: RouteNames.signup,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Sign Up'),
        ),
      ),
      GoRoute(
        path: RouteConstants.twoFactorVerification,
        name: RouteNames.twoFactorVerification,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const TwoFactorVerificationPage(),
        ),
      ),

      // Main navigation routes
      GoRoute(
        path: RouteConstants.home,
        name: RouteNames.home,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Home'),
        ),
      ),
      GoRoute(
        path: RouteConstants.messages,
        name: RouteNames.messages,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Messages'),
        ),
      ),
      GoRoute(
        path: RouteConstants.notifications,
        name: RouteNames.notifications,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Notifications'),
        ),
      ),
      GoRoute(
        path: RouteConstants.profile,
        name: RouteNames.profile,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Profile'),
        ),
      ),

      // Content routes
      GoRoute(
        path: RouteConstants.explore,
        name: RouteNames.explore,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Explore'),
        ),
      ),
      GoRoute(
        path: RouteConstants.live,
        name: RouteNames.live,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Live'),
        ),
      ),
      GoRoute(
        path: RouteConstants.subscribe,
        name: RouteNames.subscribe,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Subscribe'),
        ),
      ),
      GoRoute(
        path: RouteConstants.rateDate,
        name: RouteNames.rateDate,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Rate Date'),
        ),
      ),
      GoRoute(
        path: RouteConstants.createPost,
        name: RouteNames.createPost,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Create Post'),
        ),
      ),

      // Chat route with parameter
      GoRoute(
        path: RouteConstants.chat,
        name: RouteNames.chat,
        pageBuilder: (context, state) {
          final conversationId =
              state.pathParameters['conversationId'] ?? 'unknown';
          return _buildPage(
            context: context,
            state: state,
            child: _PlaceholderPage(title: 'Chat: $conversationId'),
          );
        },
      ),

      // Settings routes
      GoRoute(
        path: RouteConstants.notificationScheduleSettings,
        name: RouteNames.notificationScheduleSettings,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const NotificationScheduleSettingsPage(),
        ),
      ),
      GoRoute(
        path: RouteConstants.themeSettings,
        name: RouteNames.themeSettings,
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const ThemeSettingsPage(),
        ),
      ),
    ];
  }

  /// Builds a page with custom transition
  static Page<dynamic> _buildPage({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Checks if a route is an authentication route
  static bool _isAuthRoute(String path) {
    return path == RouteConstants.login ||
        path == RouteConstants.signup ||
        path == RouteConstants.twoFactorVerification;
  }

  /// Builds error page for routing errors
  static Widget _buildErrorPage(Object? error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: ThemeData().textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              style: ThemeData().textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder page widget for routes not yet implemented
/// 
/// This will be replaced with actual page implementations
/// as features are developed.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'This page is under construction',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

