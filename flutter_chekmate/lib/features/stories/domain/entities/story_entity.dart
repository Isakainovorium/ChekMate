import 'package:equatable/equatable.dart';

/// Story Type Enum
enum StoryType {
  image,
  video,
}

/// Story Entity - Domain Layer
///
/// Represents a story in the ChekMate application.
/// Stories are temporary content that expire after 24 hours.
///
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
    required this.views,
    required this.likes,
    this.duration,
    this.isViewed = false,
  });

  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final StoryType type;
  final String url;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int views;
  final int likes;
  final int? duration; // Duration in seconds for videos
  final bool isViewed;

  /// Check if the story has expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if the story is a video
  bool get isVideo {
    return type == StoryType.video;
  }

  /// Check if the story is an image
  bool get isImage {
    return type == StoryType.image;
  }

  /// Get the remaining time before the story expires
  Duration get timeRemaining {
    if (isExpired) {
      return Duration.zero;
    }
    return expiresAt.difference(DateTime.now());
  }

  /// Get human-readable time ago string for when the story was created
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  /// Create a copy with updated fields
  StoryEntity copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    StoryType? type,
    String? url,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? views,
    int? likes,
    int? duration,
    bool? isViewed,
  }) {
    return StoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      type: type ?? this.type,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      duration: duration ?? this.duration,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  bool get stringify => true;
}

/// Story User Entity
///
/// Represents a user who has posted stories.
/// Contains user information and their collection of stories.
///
class StoryUserEntity extends Equatable {
  const StoryUserEntity({
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.stories,
    required this.isFollowing,
  });

  final String userId;
  final String username;
  final String userAvatar;
  final List<StoryEntity> stories;
  final bool isFollowing;

  /// Check if the user has any stories
  bool get hasStories => stories.isNotEmpty;

  /// Check if all stories have been viewed
  bool get allViewed => stories.every((story) => story.isViewed);

  /// Get the count of unviewed stories
  int get unviewedCount => stories.where((story) => !story.isViewed).length;

  /// Get the total views across all stories
  int get totalViews => stories.fold(0, (sum, story) => sum + story.views);

  /// Get the total likes across all stories
  int get totalLikes => stories.fold(0, (sum, story) => sum + story.likes);

  /// Get the most recent story (by creation date)
  StoryEntity? get mostRecentStory {
    if (stories.isEmpty) return null;
    return stories.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }

  /// Create a copy with updated fields
  StoryUserEntity copyWith({
    String? userId,
    String? username,
    String? userAvatar,
    List<StoryEntity>? stories,
    bool? isFollowing,
  }) {
    return StoryUserEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      stories: stories ?? this.stories,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [userId, username, userAvatar, stories, isFollowing];

  @override
  bool get stringify => true;
}
