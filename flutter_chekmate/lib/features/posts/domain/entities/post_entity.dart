import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Post Entity - Domain Layer
///
/// Represents a post in the ChekMate application.
/// This is the domain model used throughout the application.
///
/// Clean Architecture: Domain Layer
class PostEntity extends Equatable {
  const PostEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.images,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.cheks,
    required this.likedBy,
    required this.bookmarkedBy,
    required this.chekedBy,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.isVerified,
    this.videoUrl,
    this.thumbnailUrl,
    this.location,
    this.coordinates,
    this.geohash,
  });

  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String content;
  final List<String> images;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int likes;
  final int comments;
  final int shares;
  final int cheks;
  final List<String> likedBy;
  final List<String> bookmarkedBy;
  final List<String> chekedBy;
  final List<String> tags;
  final String? location;
  final GeoPoint? coordinates;
  final String? geohash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;

  /// Check if the current user has liked this post
  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }

  /// Check if the current user has bookmarked this post
  bool isBookmarkedBy(String userId) {
    return bookmarkedBy.contains(userId);
  }

  /// Check if the current user has cheked this post
  bool isChekedBy(String userId) {
    return chekedBy.contains(userId);
  }

  /// Get formatted timestamp (e.g., "2h ago", "1d ago")
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  /// Check if post has media (images or video)
  bool get hasMedia {
    return images.isNotEmpty || videoUrl != null;
  }

  /// Check if post has video
  bool get hasVideo {
    return videoUrl != null;
  }

  /// Check if post has images
  bool get hasImages {
    return images.isNotEmpty;
  }

  /// Get engagement count (likes + comments + shares)
  int get engagementCount {
    return likes + comments + shares;
  }

  /// Get first image URL (for compatibility with widgets expecting single image)
  String? get imageUrl {
    return images.isNotEmpty ? images.first : thumbnailUrl;
  }

  /// Get post title (first line of content or truncated content)
  String get title {
    final lines = content.split('\n');
    final firstLine = lines.first.trim();
    if (firstLine.length > 50) {
      return '${firstLine.substring(0, 50)}...';
    }
    return firstLine.isNotEmpty ? firstLine : 'Untitled Post';
  }

  /// Get author name (alias for username)
  String get authorName => username;

  /// Get formatted likes count (e.g., "1.2K", "3.5M")
  String get formattedLikes {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    } else {
      return likes.toString();
    }
  }

  /// Get formatted comments count (e.g., "1.2K", "3.5M")
  String get formattedComments {
    if (comments >= 1000000) {
      return '${(comments / 1000000).toStringAsFixed(1)}M';
    } else if (comments >= 1000) {
      return '${(comments / 1000).toStringAsFixed(1)}K';
    } else {
      return comments.toString();
    }
  }

  /// Get formatted shares count (e.g., "1.2K", "3.5M")
  String get formattedShares {
    if (shares >= 1000000) {
      return '${(shares / 1000000).toStringAsFixed(1)}M';
    } else if (shares >= 1000) {
      return '${(shares / 1000).toStringAsFixed(1)}K';
    } else {
      return shares.toString();
    }
  }

  /// Get time ago (alias for formattedTimestamp)
  String get timeAgo => formattedTimestamp;

  /// Check if post is trending (high engagement in short time)
  bool get isTrending {
    final now = DateTime.now();
    final hoursSinceCreation = now.difference(createdAt).inHours;

    // Consider trending if:
    // - Less than 24 hours old
    // - Has high engagement rate (engagement per hour)
    if (hoursSinceCreation > 24) return false;

    final engagementPerHour = hoursSinceCreation > 0
        ? engagementCount / hoursSinceCreation
        : engagementCount.toDouble();

    // Trending threshold: 10+ engagements per hour
    return engagementPerHour >= 10;
  }

  /// Get list of user IDs who viewed this post (placeholder for future implementation)
  List<String> get viewedBy => const [];

  /// Copy with method for creating modified copies
  PostEntity copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? content,
    List<String>? images,
    String? videoUrl,
    String? thumbnailUrl,
    int? likes,
    int? comments,
    int? shares,
    int? cheks,
    List<String>? likedBy,
    List<String>? bookmarkedBy,
    List<String>? chekedBy,
    List<String>? tags,
    String? location,
    GeoPoint? coordinates,
    String? geohash,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      cheks: cheks ?? this.cheks,
      likedBy: likedBy ?? this.likedBy,
      bookmarkedBy: bookmarkedBy ?? this.bookmarkedBy,
      chekedBy: chekedBy ?? this.chekedBy,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      geohash: geohash ?? this.geohash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        userAvatar,
        content,
        images,
        videoUrl,
        thumbnailUrl,
        likes,
        comments,
        shares,
        cheks,
        likedBy,
        bookmarkedBy,
        tags,
        location,
        coordinates,
        geohash,
        createdAt,
        updatedAt,
        isVerified,
      ];
}
