import 'package:equatable/equatable.dart';

/// ExploreContentEntity - Domain Entity for Explore Content
///
/// Represents content displayed in the explore feed.
/// Includes trending posts, popular content, and discovery items.
///
/// Business Logic:
/// - Content type classification
/// - Trending score calculation
/// - Engagement metrics
/// - Time-based relevance
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
    required this.views,
    required this.trendingScore,
    required this.createdAt,
    this.tags = const [],
    this.category,
  });

  final String id;
  final ExploreContentType type;
  final String title;
  final String description;
  final String? imageUrl;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final double trendingScore;
  final DateTime createdAt;
  final List<String> tags;
  final String? category;

  /// Get total engagement count
  int get totalEngagement => likes + comments + shares;

  /// Check if content is trending (score > 0.7)
  bool get isTrending => trendingScore > 0.7;

  /// Check if content is popular (engagement > 1000)
  bool get isPopular => totalEngagement > 1000;

  /// Check if content is recent (within 24 hours)
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
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  /// Get engagement rate (engagement / views)
  double get engagementRate {
    if (views == 0) return 0.0;
    return totalEngagement / views;
  }

  /// Format count (1.2K, 1.5M, etc.)
  String formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// Get formatted likes
  String get formattedLikes => formatCount(likes);

  /// Get formatted comments
  String get formattedComments => formatCount(comments);

  /// Get formatted shares
  String get formattedShares => formatCount(shares);

  /// Get formatted views
  String get formattedViews => formatCount(views);

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
        views,
        trendingScore,
        createdAt,
        tags,
        category,
      ];

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
    int? views,
    double? trendingScore,
    DateTime? createdAt,
    List<String>? tags,
    String? category,
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
      views: views ?? this.views,
      trendingScore: trendingScore ?? this.trendingScore,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }
}

/// ExploreContentType - Type of explore content
enum ExploreContentType {
  post,
  video,
  image,
  story,
  event,
}

/// HashtagEntity - Domain Entity for Hashtags
class HashtagEntity extends Equatable {
  const HashtagEntity({
    required this.tag,
    required this.postCount,
    required this.trendingScore,
  });

  final String tag;
  final int postCount;
  final double trendingScore;

  /// Get formatted post count
  String get formattedPostCount {
    if (postCount < 1000) {
      return '$postCount posts';
    } else if (postCount < 1000000) {
      return '${(postCount / 1000).toStringAsFixed(1)}K posts';
    } else {
      return '${(postCount / 1000000).toStringAsFixed(1)}M posts';
    }
  }

  /// Check if trending
  bool get isTrending => trendingScore > 0.7;

  @override
  List<Object?> get props => [tag, postCount, trendingScore];
}

/// SuggestedUserEntity - Domain Entity for Suggested Users
class SuggestedUserEntity extends Equatable {
  const SuggestedUserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.followers,
    required this.isVerified,
    this.bio,
  });

  final String id;
  final String name;
  final String username;
  final String? avatar;
  final int followers;
  final bool isVerified;
  final String? bio;

  /// Get formatted followers count
  String get formattedFollowers {
    if (followers < 1000) {
      return '$followers';
    } else if (followers < 1000000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    }
  }

  @override
  List<Object?> get props => [id, name, username, avatar, followers, isVerified, bio];
}

