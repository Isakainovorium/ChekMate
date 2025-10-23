import 'package:cloud_firestore/cloud_firestore.dart';

/// Post Entity - Domain Layer
///
/// Pure Dart class representing a post in the ChekMate app.
/// Contains no framework dependencies - only business logic.
///
/// Clean Architecture: Domain Layer
class PostEntity {
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
    required this.createdAt,
    required this.updatedAt,
    required this.isVerified,
    required this.likedBy,
    required this.bookmarkedBy,
    this.videoUrl,
    this.thumbnailUrl,
    this.location,
    this.tags,
    this.coordinates,
    this.geohash,
    this.views = 0,
    this.viewedBy = const [],
    this.engagementScore = 0.0,
    this.lastEngagementUpdate,
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? location;
  final List<String>? tags;
  final bool isVerified;
  final List<String> likedBy;
  final List<String> bookmarkedBy;

  // Geolocation fields for location-based discovery
  final GeoPoint? coordinates;
  final String? geohash;

  // Engagement tracking fields for personalized recommendations
  final int views;
  final List<String> viewedBy;
  final double engagementScore;
  final DateTime? lastEngagementUpdate;

  // ========== BUSINESS LOGIC METHODS ==========

  /// Check if this post has any media (images or video)
  bool get hasMedia => hasImages || hasVideo;

  /// Check if this post has a video
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  /// Check if this post has images
  bool get hasImages => images.isNotEmpty;

  /// Check if this post has multiple images
  bool get hasMultipleImages => images.length > 1;

  /// Check if this post has a location
  bool get hasLocation => location != null && location!.isNotEmpty;

  /// Check if this post has tags
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Check if a specific user can edit this post
  /// Only the post author can edit their own posts
  bool canEdit(String currentUserId) {
    return userId == currentUserId;
  }

  /// Check if a specific user can delete this post
  /// Only the post author can delete their own posts
  bool canDelete(String currentUserId) {
    return userId == currentUserId;
  }

  /// Check if a specific user has liked this post
  bool isLikedBy(String currentUserId) {
    return likedBy.contains(currentUserId);
  }

  /// Check if a specific user has bookmarked this post
  bool isBookmarkedBy(String currentUserId) {
    return bookmarkedBy.contains(currentUserId);
  }

  /// Check if this post is recent (created within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Get formatted time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if this post has been edited
  bool get isEdited {
    return updatedAt.isAfter(createdAt.add(const Duration(minutes: 1)));
  }

  /// Create a copy with updated fields
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
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    List<String>? tags,
    bool? isVerified,
    List<String>? likedBy,
    List<String>? bookmarkedBy,
    GeoPoint? coordinates,
    String? geohash,
    int? views,
    List<String>? viewedBy,
    double? engagementScore,
    DateTime? lastEngagementUpdate,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isVerified: isVerified ?? this.isVerified,
      likedBy: likedBy ?? this.likedBy,
      bookmarkedBy: bookmarkedBy ?? this.bookmarkedBy,
      coordinates: coordinates ?? this.coordinates,
      geohash: geohash ?? this.geohash,
      views: views ?? this.views,
      viewedBy: viewedBy ?? this.viewedBy,
      engagementScore: engagementScore ?? this.engagementScore,
      lastEngagementUpdate: lastEngagementUpdate ?? this.lastEngagementUpdate,
    );
  }

  // ========== EQUALITY ==========

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PostEntity(id: $id, userId: $userId, username: $username, content: $content, likes: $likes, comments: $comments, hasVideo: $hasVideo, hasImages: $hasImages)';
  }
}
