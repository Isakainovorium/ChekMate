import 'package:equatable/equatable.dart';

/// Explore Content Entity - Domain Layer
///
/// Represents content that can be explored in the explore section.
/// This includes posts, stories, and other discoverable content.
///
class ExploreContentEntity extends Equatable {
  const ExploreContentEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.createdAt,
    this.videoUrl,
    this.thumbnailUrl,
    this.location,
    this.hashtags = const [],
    this.category,
    this.isTrending = false,
    this.isPopular = false,
    this.engagementScore = 0,
  });

  final String id;
  final ExploreContentType type;
  final String title;
  final String description;
  final String imageUrl;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final int likes;
  final int comments;
  final int shares;
  final DateTime createdAt;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? location;
  final List<String> hashtags;
  final String? category;
  final bool isTrending;
  final bool isPopular;
  final int engagementScore;

  /// Calculate total engagement
  int get totalEngagement => likes + comments + shares;

  /// Get formatted engagement count
  String get formattedEngagement {
    if (totalEngagement >= 1000000) {
      return '${(totalEngagement / 1000000).toStringAsFixed(1)}M';
    } else if (totalEngagement >= 1000) {
      return '${(totalEngagement / 1000).toStringAsFixed(1)}K';
    } else {
      return totalEngagement.toString();
    }
  }

  /// Check if content is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final weeks = (difference.inDays / 7).round();
      return '${weeks}w ago';
    }
  }

  /// Create a copy with updated fields
  ExploreContentEntity copyWith({
    String? id,
    ExploreContentType? type,
    String? title,
    String? description,
    String? imageUrl,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    int? likes,
    int? comments,
    int? shares,
    DateTime? createdAt,
    String? videoUrl,
    String? thumbnailUrl,
    String? location,
    List<String>? hashtags,
    String? category,
    bool? isTrending,
    bool? isPopular,
    int? engagementScore,
  }) {
    return ExploreContentEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      createdAt: createdAt ?? this.createdAt,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      location: location ?? this.location,
      hashtags: hashtags ?? this.hashtags,
      category: category ?? this.category,
      isTrending: isTrending ?? this.isTrending,
      isPopular: isPopular ?? this.isPopular,
      engagementScore: engagementScore ?? this.engagementScore,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        imageUrl,
        authorId,
        authorName,
        authorAvatar,
        likes,
        comments,
        shares,
        createdAt,
        videoUrl,
        thumbnailUrl,
        location,
        hashtags,
        category,
        isTrending,
        isPopular,
        engagementScore,
      ];
}

/// Explore Content Type Enum
enum ExploreContentType {
  post,
  story,
  video,
  image,
  article,
  event,
}

/// Hashtag Entity - Domain Layer
///
/// Represents a hashtag in the explore section.
///
class HashtagEntity extends Equatable {
  const HashtagEntity({
    required this.name,
    required this.count,
    required this.isTrending,
    this.createdAt,
  });

  final String name;
  final int count;
  final bool isTrending;
  final DateTime? createdAt;

  /// Get formatted count
  String get formattedCount {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  /// Get hashtag with # prefix
  String get hashtag => '#$name';

  @override
  List<Object?> get props => [name, count, isTrending, createdAt];
}

/// Suggested User Entity - Domain Layer
///
/// Represents a suggested user in the explore section.
///
class SuggestedUserEntity extends Equatable {
  const SuggestedUserEntity({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.avatar,
    required this.bio,
    required this.followers,
    required this.isVerified,
    this.mutualFriends = 0,
    this.reason,
  });

  final String uid;
  final String username;
  final String displayName;
  final String avatar;
  final String bio;
  final int followers;
  final bool isVerified;
  final int mutualFriends;
  final String? reason;

  /// Get formatted followers count
  String get formattedFollowers {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    } else {
      return followers.toString();
    }
  }

  /// Check if user has mutual friends
  bool get hasMutualFriends => mutualFriends > 0;

  @override
  List<Object?> get props => [
        uid,
        username,
        displayName,
        avatar,
        bio,
        followers,
        isVerified,
        mutualFriends,
        reason,
      ];
}
