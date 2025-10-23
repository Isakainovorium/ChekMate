/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'ChekMate';
  static const String appVersion = '1.0.0';
  
  // API & Storage
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];
  
  // Pagination
  static const int postsPerPage = 20;
  static const int messagesPerPage = 50;
  static const int notificationsPerPage = 30;
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 24);
  
  // Story Settings
  static const Duration storyDuration = Duration(seconds: 5);
  static const Duration storyTransitionDuration = Duration(milliseconds: 300);
  static const int maxStoriesPerUser = 10;
  
  // Post Settings
  static const int maxPostLength = 500;
  static const int maxCommentLength = 200;
  static const int maxBioLength = 150;
  
  // Rating Settings
  static const List<String> ratingOptions = ['WOW', 'GTFOH', 'ChekMate'];
  static const Map<String, String> ratingDescriptions = {
    'WOW': 'Amazing date!',
    'GTFOH': 'Not recommended',
    'ChekMate': 'Perfect match!',
  };
  
  // Subscription Tiers
  static const List<String> subscriptionTiers = ['Free', 'Premium', 'VIP'];
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String storiesCollection = 'stories';
  static const String messagesCollection = 'messages';
  static const String conversationsCollection = 'conversations';
  static const String notificationsCollection = 'notifications';
  static const String ratingsCollection = 'ratings';
  
  // Local Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_complete';
  static const String userIdKey = 'user_id';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // URLs
  static const String privacyPolicyUrl = 'https://chekmate.app/privacy';
  static const String termsOfServiceUrl = 'https://chekmate.app/terms';
  static const String supportUrl = 'https://chekmate.app/support';
}
