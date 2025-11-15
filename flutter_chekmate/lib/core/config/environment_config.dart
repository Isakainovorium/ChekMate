/// Environment Configuration for ChekMate App
///
/// Manages environment-specific settings (development, staging, production)
/// and provides centralized access to configuration values.
///
/// Created: October 17, 2025
/// Part of: Phase 1 - Critical Fixes & Foundation
library;

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.firebaseProjectId,
    required this.enableAnalytics,
    required this.enableCrashlytics,
    required this.enableDebugLogging,
    required this.apiTimeout,
    required this.maxRetries,
  });

  final Environment environment;
  final String apiBaseUrl;
  final String firebaseProjectId;
  final bool enableAnalytics;
  final bool enableCrashlytics;
  final bool enableDebugLogging;
  final int apiTimeout;
  final int maxRetries;

  /// Development environment configuration
  static const development = EnvironmentConfig(
    environment: Environment.development,
    apiBaseUrl: 'https://dev-api.chekmate.app',
    firebaseProjectId: 'chekmate-dev',
    enableAnalytics: false,
    enableCrashlytics: false,
    enableDebugLogging: true,
    apiTimeout: 30000, // 30 seconds
    maxRetries: 3,
  );

  /// Staging environment configuration
  static const staging = EnvironmentConfig(
    environment: Environment.staging,
    apiBaseUrl: 'https://staging-api.chekmate.app',
    firebaseProjectId: 'chekmate-staging',
    enableAnalytics: true,
    enableCrashlytics: true,
    enableDebugLogging: true,
    apiTimeout: 20000, // 20 seconds
    maxRetries: 3,
  );

  /// Production environment configuration
  static const production = EnvironmentConfig(
    environment: Environment.production,
    apiBaseUrl: 'https://api.chekmate.app',
    firebaseProjectId: 'chekmate-prod',
    enableAnalytics: true,
    enableCrashlytics: true,
    enableDebugLogging: false,
    apiTimeout: 15000, // 15 seconds
    maxRetries: 2,
  );

  /// Current environment (defaults to development)
  ///
  /// This should be set at app startup based on build configuration
  /// or environment variables.
  static EnvironmentConfig _current = development;

  /// Get the current environment configuration
  static EnvironmentConfig get current => _current;

  /// Set the current environment configuration
  ///
  /// This should be called once at app startup before any other
  /// configuration is accessed.
  static void setCurrent(EnvironmentConfig config) {
    _current = config;
  }

  /// Initialize environment from string name
  ///
  /// Usage:
  /// ```dart
  /// EnvironmentConfig.initFromString('production');
  /// ```
  static void initFromString(String envName) {
    switch (envName.toLowerCase()) {
      case 'production':
      case 'prod':
        _current = production;
        break;
      case 'staging':
      case 'stage':
        _current = staging;
        break;
      case 'development':
      case 'dev':
      default:
        _current = development;
        break;
    }
  }

  /// Check if current environment is development
  bool get isDevelopment => environment == Environment.development;

  /// Check if current environment is staging
  bool get isStaging => environment == Environment.staging;

  /// Check if current environment is production
  bool get isProduction => environment == Environment.production;

  @override
  String toString() {
    return 'EnvironmentConfig(environment: $environment, apiBaseUrl: $apiBaseUrl)';
  }
}

/// App Configuration Constants
///
/// Centralized location for app-wide configuration values that don't
/// change between environments.
class AppConfig {
  // Prevent instantiation
  AppConfig._();

  // App Information
  static const String appName = 'ChekMate';
  static const String appTagline = 'Dating can be a Game - Don\'t Get Played';
  static const String appCategory = 'Dating Experience Platform';
  static const String appDescription =
      'The first social platform dedicated to sharing and rating dating experiences. '
      'We\'re NOT a dating app - we\'re a community for discussing dating.';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Feature Flags
  static const bool enableVoiceMessages = true;
  static const bool enableVideoPlayback = true;
  static const bool enableMultiPhotoUpload = true;
  static const bool enableLocationServices = true;
  static const bool enablePushNotifications = true;

  // Media Constraints
  static const int maxPhotoUploadCount = 10;
  static const int maxVideoLengthSeconds = 60;
  static const int maxVoiceMessageSeconds = 60;
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;

  // UI Configuration
  static const int defaultAnimationDurationMs = 300;
  static const int splashScreenDurationMs = 2000;
  static const int snackBarDurationMs = 3000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Configuration
  static const int imageCacheDurationDays = 7;
  static const int dataCacheDurationHours = 24;

  // Network Configuration
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;

  // Security
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;

  // Analytics
  static const bool enablePerformanceMonitoring = true;
  static const bool enableUserTracking = true;
  static const bool enableErrorReporting = true;
}

/// Firebase Configuration
///
/// Centralized Firebase-specific configuration
class FirebaseConfig {
  // Prevent instantiation
  FirebaseConfig._();

  // Collection Names
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String messagesCollection = 'messages';
  static const String storiesCollection = 'stories';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String followsCollection = 'follows';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String postImagesPath = 'post_images';
  static const String postVideosPath = 'post_videos';
  static const String storyImagesPath = 'story_images';
  static const String storyVideosPath = 'story_videos';
  static const String voiceMessagesPath = 'voice_messages';

  // Firebase Analytics Events
  static const String eventLogin = 'login';
  static const String eventSignup = 'signup';
  static const String eventPostCreated = 'post_created';
  static const String eventStoryCreated = 'story_created';
  static const String eventMessageSent = 'message_sent';
  static const String eventProfileViewed = 'profile_viewed';
  static const String eventPostLiked = 'post_liked';
  static const String eventUserFollowed = 'user_followed';
}

/// API Endpoints
///
/// Centralized API endpoint definitions
class ApiEndpoints {
  // Prevent instantiation
  ApiEndpoints._();

  // Base URL is provided by EnvironmentConfig
  static String get baseUrl => EnvironmentConfig.current.apiBaseUrl;

  // Auth Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get signup => '$baseUrl/auth/signup';
  static String get logout => '$baseUrl/auth/logout';
  static String get refreshToken => '$baseUrl/auth/refresh';

  // User Endpoints
  static String get users => '$baseUrl/users';
  static String userById(String id) => '$baseUrl/users/$id';
  static String get currentUser => '$baseUrl/users/me';

  // Post Endpoints
  static String get posts => '$baseUrl/posts';
  static String postById(String id) => '$baseUrl/posts/$id';
  static String get feed => '$baseUrl/posts/feed';

  // Message Endpoints
  static String get messages => '$baseUrl/messages';
  static String messageThread(String userId) => '$baseUrl/messages/$userId';

  // Story Endpoints
  static String get stories => '$baseUrl/stories';
  static String storyById(String id) => '$baseUrl/stories/$id';

  // Notification Endpoints
  static String get notifications => '$baseUrl/notifications';
  static String get notificationSettings => '$baseUrl/notifications/settings';
}
