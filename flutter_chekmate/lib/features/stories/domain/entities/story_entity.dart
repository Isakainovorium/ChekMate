import 'package:equatable/equatable.dart';

/// Story Entity - Domain Layer
///
/// Represents a single story in the domain layer.
/// Contains all story-related data and business logic.
///
/// Clean Architecture: Domain Layer
class StoryEntity extends Equatable {
  const StoryEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.type,
    required this.url,
    required this.createdAt,
    required this.expiresAt,
    this.thumbnailUrl,
    this.duration = 5,
    this.text,
    this.textColor,
    this.textPosition,
    this.views = 0,
    this.likes = 0,
    this.isViewed = false,
  });

  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final StoryType type;
  final String url;
  final String? thumbnailUrl;
  final int duration; // in seconds
  final String? text;
  final String? textColor;
  final String? textPosition;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int views;
  final int likes;
  final bool isViewed;

  /// Business logic: Check if story is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Business logic: Check if story is a video
  bool get isVideo => type == StoryType.video;

  /// Business logic: Check if story is an image
  bool get isImage => type == StoryType.image;

  /// Business logic: Get time remaining until expiration
  Duration get timeRemaining {
    if (isExpired) return Duration.zero;
    return expiresAt.difference(DateTime.now());
  }

  /// Business logic: Get formatted time ago
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  StoryEntity copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    StoryType? type,
    String? url,
    String? thumbnailUrl,
    int? duration,
    String? text,
    String? textColor,
    String? textPosition,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? views,
    int? likes,
    bool? isViewed,
  }) {
    return StoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      textPosition: textPosition ?? this.textPosition,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        userAvatar,
        type,
        url,
        thumbnailUrl,
        duration,
        text,
        textColor,
        textPosition,
        createdAt,
        expiresAt,
        views,
        likes,
        isViewed,
      ];
}

/// Story Type Enum
enum StoryType {
  image,
  video,
}

/// Story User Entity - Domain Layer
///
/// Represents a user with their stories.
///
/// Clean Architecture: Domain Layer
class StoryUserEntity extends Equatable {
  const StoryUserEntity({
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.stories,
    this.isOwn = false,
    this.isFollowing = false,
  });

  final String userId;
  final String username;
  final String userAvatar;
  final List<StoryEntity> stories;
  final bool isOwn;
  final bool isFollowing;

  /// Business logic: Check if user has stories
  bool get hasStories => stories.isNotEmpty;

  /// Business logic: Check if all stories are viewed
  bool get allViewed => stories.every((story) => story.isViewed);

  /// Business logic: Get unviewed stories count
  int get unviewedCount => stories.where((story) => !story.isViewed).length;

  /// Business logic: Get total views across all stories
  int get totalViews => stories.fold(0, (sum, story) => sum + story.views);

  /// Business logic: Get total likes across all stories
  int get totalLikes => stories.fold(0, (sum, story) => sum + story.likes);

  /// Business logic: Get most recent story
  StoryEntity? get mostRecentStory {
    if (stories.isEmpty) return null;
    return stories.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }

  StoryUserEntity copyWith({
    String? userId,
    String? username,
    String? userAvatar,
    List<StoryEntity>? stories,
    bool? isOwn,
    bool? isFollowing,
  }) {
    return StoryUserEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      stories: stories ?? this.stories,
      isOwn: isOwn ?? this.isOwn,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        username,
        userAvatar,
        stories,
        isOwn,
        isFollowing,
      ];
}

