import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added for context.go

/// Analytics Service for tracking user interactions
class AnalyticsService {
  AnalyticsService._internal();

  static final AnalyticsService instance = AnalyticsService._internal();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log navigation events
  void logNavigation(String destination) {
    try {
      _analytics.logEvent(
        name: 'navigation',
        parameters: {
          'destination': destination,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: Navigated to $destination');
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log user actions
  void logUserAction(String action, {Map<String, Object>? parameters}) {
    try {
      _analytics.logEvent(
        name: 'user_action',
        parameters: <String, Object>{
          'action': action,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          if (parameters != null) ...parameters,
        },
      );
      debugPrint('Analytics: User action - $action');
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log screen views
  void logScreenView(String screenName) {
    try {
      _analytics.logScreenView(screenName: screenName);
      debugPrint('Analytics: Screen view - $screenName');
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log authentication events
  void logAuth(String method) {
    try {
      _analytics.logLogin(loginMethod: method);
      debugPrint('Analytics: Login with $method');
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log post creation
  void logPostCreation(String postType) {
    try {
      _analytics.logEvent(
        name: 'post_created',
        parameters: {
          'post_type': postType,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: Post created - $postType');
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log subscription events
  void logSubscription(String planType) {
    try {
      _analytics.logEvent(
        name: 'subscription_purchased',
        parameters: {
          'plan_type': planType,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: Subscription purchased - $planType');
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // ========== A/B TESTING ANALYTICS ==========

  /// Log feed viewed event
  ///
  /// Tracks when a user views a feed with specific type and variant.
  ///
  /// Parameters:
  /// - feedType: Type of feed (hybrid, following, nearby, forYou)
  /// - variant: A/B test variant (control, variant)
  /// - userId: User's unique ID
  void logFeedViewed({
    required String feedType,
    required String variant,
    required String userId,
  }) {
    try {
      _analytics.logEvent(
        name: 'feed_viewed',
        parameters: {
          'feed_type': feedType,
          'ab_test_variant': variant,
          'user_id': userId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: Feed viewed - $feedType (variant: $variant)');
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log post viewed event
  ///
  /// Tracks when a user views a post with duration.
  ///
  /// Parameters:
  /// - postId: Post's unique ID
  /// - feedType: Type of feed where post was viewed
  /// - variant: A/B test variant
  /// - userId: User's unique ID
  /// - durationSeconds: How long the post was viewed (in seconds)
  void logPostViewed({
    required String postId,
    required String feedType,
    required String variant,
    required String userId,
    required int durationSeconds,
  }) {
    try {
      _analytics.logEvent(
        name: 'post_viewed',
        parameters: {
          'post_id': postId,
          'feed_type': feedType,
          'ab_test_variant': variant,
          'user_id': userId,
          'duration_seconds': durationSeconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint(
        'Analytics: Post viewed - $postId for ${durationSeconds}s (variant: $variant)',
      );
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log post engaged event
  ///
  /// Tracks when a user engages with a post (like, comment, share).
  ///
  /// Parameters:
  /// - postId: Post's unique ID
  /// - engagementType: Type of engagement (like, comment, share)
  /// - feedType: Type of feed where engagement occurred
  /// - variant: A/B test variant
  /// - userId: User's unique ID
  void logPostEngaged({
    required String postId,
    required String engagementType,
    required String feedType,
    required String variant,
    required String userId,
  }) {
    try {
      _analytics.logEvent(
        name: 'post_engaged',
        parameters: {
          'post_id': postId,
          'engagement_type': engagementType,
          'feed_type': feedType,
          'ab_test_variant': variant,
          'user_id': userId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint(
        'Analytics: Post engaged - $postId ($engagementType) (variant: $variant)',
      );
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log session duration
  ///
  /// Tracks how long a user spent in the app.
  ///
  /// Parameters:
  /// - variant: A/B test variant
  /// - userId: User's unique ID
  /// - durationSeconds: Session duration in seconds
  void logSessionDuration({
    required String variant,
    required String userId,
    required int durationSeconds,
  }) {
    try {
      _analytics.logEvent(
        name: 'session_duration',
        parameters: {
          'ab_test_variant': variant,
          'user_id': userId,
          'duration_seconds': durationSeconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint(
        'Analytics: Session duration - ${durationSeconds}s (variant: $variant)',
      );
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log feed scroll depth
  ///
  /// Tracks how far a user scrolled in the feed.
  ///
  /// Parameters:
  /// - feedType: Type of feed
  /// - variant: A/B test variant
  /// - userId: User's unique ID
  /// - scrollDepth: Scroll depth percentage (0-100)
  /// - postsViewed: Number of posts viewed
  void logFeedScrollDepth({
    required String feedType,
    required String variant,
    required String userId,
    required int scrollDepth,
    required int postsViewed,
  }) {
    try {
      _analytics.logEvent(
        name: 'feed_scroll_depth',
        parameters: {
          'feed_type': feedType,
          'ab_test_variant': variant,
          'user_id': userId,
          'scroll_depth_percent': scrollDepth,
          'posts_viewed': postsViewed,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint(
        'Analytics: Feed scroll depth - $scrollDepth% ($postsViewed posts) (variant: $variant)',
      );
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log A/B test assignment
  ///
  /// Tracks when a user is assigned to an A/B test variant.
  ///
  /// Parameters:
  /// - testName: Name of the A/B test
  /// - variant: Assigned variant
  /// - userId: User's unique ID
  void logABTestAssignment({
    required String testName,
    required String variant,
    required String userId,
  }) {
    try {
      _analytics.logEvent(
        name: 'ab_test_assignment',
        parameters: {
          'test_name': testName,
          'variant': variant,
          'user_id': userId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: A/B test assignment - $testName = $variant');
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}

abstract class NavigationCommand {
  Future<void> execute(BuildContext context);
}

class NavigateToSearchCommand implements NavigationCommand {
  @override
  Future<void> execute(BuildContext context) async {
    context.go('/search');
    AnalyticsService.instance.logNavigation('search');
  }
}

class NavigateToNotificationsCommand implements NavigationCommand {
  @override
  Future<void> execute(BuildContext context) async {
    context.go('/notifications');
    AnalyticsService.instance.logNavigation('notifications');
  }
}

class NavigationService {
  NavigationService._internal();

  static final NavigationService _instance = NavigationService._internal();
  static NavigationService get instance => _instance;

  final Map<String, NavigationCommand> _commands = {
    'search': NavigateToSearchCommand(),
    'notifications': NavigateToNotificationsCommand(),
  };

  Future<void> navigate(BuildContext context, String commandKey) async {
    final command = _commands[commandKey];
    if (command != null) {
      await command.execute(context);
    } else {
      debugPrint('Navigation command not found: $commandKey');
    }
  }

  // Type-safe navigation with return values
  Future<T?> navigateTo<T>({
    required BuildContext context,
    required Widget destination,
    RouteSettings? settings,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(
        builder: (_) => destination,
        settings: settings,
      ),
    );
  }
}
