/// Route path constants for ChekMate application
/// 
/// Centralized route path definitions following Clean Architecture.
/// All route paths should be defined here to maintain consistency
/// and enable type-safe navigation.
/// 
/// Date: 11/13/2025
class RouteConstants {
  RouteConstants._();

  // Authentication routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String twoFactorVerification = '/auth/two-factor-verification';

  // Main navigation routes (bottom nav)
  static const String home = '/';
  static const String messages = '/messages';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Content routes (top tabs and full-screen)
  static const String explore = '/explore';
  static const String live = '/live';
  static const String subscribe = '/subscribe';
  static const String rateDate = '/rate-date';
  static const String createPost = '/create-post';

  // Chat routes
  static const String chat = '/chat/:conversationId';

  // Settings routes
  static const String notificationScheduleSettings =
      '/profile/notification-schedule-settings';
  static const String themeSettings = '/profile/theme-settings';

  /// Helper method to build chat route with conversation ID
  static String chatWithId(String conversationId) {
    return '/chat/$conversationId';
  }

  /// Helper method to extract conversation ID from chat route
  static String? extractConversationId(String path) {
    final match = RegExp(r'/chat/([^/]+)').firstMatch(path);
    return match?.group(1);
  }
}

/// Route names for type-safe navigation
/// 
/// Route names are used with GoRouter's named routes
/// for better maintainability and refactoring support.
class RouteNames {
  RouteNames._();

  // Authentication route names
  static const String login = 'login';
  static const String signup = 'signup';
  static const String twoFactorVerification = 'two-factor-verification';

  // Main navigation route names
  static const String home = 'home';
  static const String messages = 'messages';
  static const String notifications = 'notifications';
  static const String profile = 'profile';

  // Content route names
  static const String explore = 'explore';
  static const String live = 'live';
  static const String subscribe = 'subscribe';
  static const String rateDate = 'rate-date';
  static const String createPost = 'create-post';

  // Chat route names
  static const String chat = 'chat';

  // Settings route names
  static const String notificationScheduleSettings =
      'notification-schedule-settings';
  static const String themeSettings = 'theme-settings';
}

