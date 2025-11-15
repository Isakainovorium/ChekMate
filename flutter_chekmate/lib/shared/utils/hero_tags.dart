/// Hero Tags
/// Provides unique hero tags for hero animations
class HeroTags {
  /// Profile avatar hero tag
  static String profileAvatar(String userId) => 'profile_avatar_$userId';

  /// Message avatar hero tag
  static String messageAvatar(String userId) => 'message_avatar_$userId';

  /// Post image hero tag
  static String postImage(String postId) => 'post_image_$postId';

  /// Story avatar hero tag
  static String storyAvatar(String userId) => 'story_avatar_$userId';

  /// User avatar hero tag
  static String userAvatar(String userId) => 'user_avatar_$userId';

  /// Cover photo hero tag
  static String coverPhoto(String userId) => 'cover_photo_$userId';

  /// Video thumbnail hero tag
  static String videoThumbnail(String videoId) => 'video_thumbnail_$videoId';

  /// Profile header hero tag
  static String profileHeader(String userId) => 'profile_header_$userId';

  /// Chat avatar hero tag
  static String chatAvatar(String chatId) => 'chat_avatar_$chatId';

  /// Notification avatar hero tag
  static String notificationAvatar(String notificationId) =>
      'notification_avatar_$notificationId';
}

