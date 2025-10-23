/// Route Constants for ChekMate App
///
/// Centralized route names and paths following GoRouter best practices.
/// This prevents typos and makes route changes easier to manage.
///
/// Usage:
/// ```dart
/// context.goNamed(RouteNames.home);
/// context.goNamed(RouteNames.chat, pathParameters: {'conversationId': '123'});
/// ```
library;

/// Route Names - Use with context.goNamed()
abstract class RouteNames {
  // Auth Routes
  static const String login = 'login';
  static const String signup = 'signup';

  // Bottom Navigation Routes
  static const String home = 'home';
  static const String messages = 'messages';
  static const String notifications = 'notifications';
  static const String profile = 'profile';

  // Top Navigation Routes (within Home)
  static const String explore = 'explore';
  static const String live = 'live';
  static const String subscribe = 'subscribe';

  // Full-Screen Routes
  static const String rateDate = 'rate-date';
  static const String createPost = 'create-post';
  static const String locationSettings = 'location-settings';
  static const String interestsManagement = 'interests-management';

  // Parameterized Routes
  static const String chat = 'chat';
  static const String userProfile = 'user-profile';
  static const String post = 'post';

  // Development Routes
  static const String themeTest = 'theme-test';
}

/// Route Paths - Actual URL paths
abstract class RoutePaths {
  // Auth Routes
  static const String login = '/login';
  static const String signup = '/signup';

  // Bottom Navigation Routes
  static const String home = '/';
  static const String messages = '/messages';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Top Navigation Routes
  static const String explore = '/explore';
  static const String live = '/live';
  static const String subscribe = '/subscribe';

  // Full-Screen Routes
  static const String rateDate = '/rate-date';
  static const String createPost = '/create-post';
  static const String locationSettings = '/profile/location-settings';
  static const String interestsManagement = '/profile/interests-management';

  // Parameterized Routes
  static const String chat = '/chat/:conversationId';
  static const String userProfile = '/profile/:userId';
  static const String post = '/post/:postId';

  // Development Routes
  static const String themeTest = '/theme-test';
}

/// Route Parameters - Type-safe parameter keys
abstract class RouteParams {
  static const String conversationId = 'conversationId';
  static const String userId = 'userId';
  static const String postId = 'postId';
  static const String userName = 'userName';
  static const String userAvatar = 'userAvatar';
}

/// Query Parameters - Type-safe query parameter keys
abstract class QueryParams {
  static const String userId = 'userId';
  static const String userName = 'userName';
  static const String userAvatar = 'userAvatar';
  static const String returnTo = 'returnTo';
}
