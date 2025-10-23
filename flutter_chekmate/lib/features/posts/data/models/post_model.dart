import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';

/// Post Model - Data Layer
///
/// Extends PostEntity and adds JSON/Firestore serialization.
/// Handles conversion between Firestore documents and domain entities.
///
/// Clean Architecture: Data Layer
class PostModel extends PostEntity {
  /// Create PostModel from PostEntity
  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userId: entity.userId,
      username: entity.username,
      userAvatar: entity.userAvatar,
      content: entity.content,
      images: entity.images,
      videoUrl: entity.videoUrl,
      thumbnailUrl: entity.thumbnailUrl,
      likes: entity.likes,
      comments: entity.comments,
      shares: entity.shares,
      cheks: entity.cheks,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      location: entity.location,
      tags: entity.tags,
      isVerified: entity.isVerified,
      likedBy: entity.likedBy,
      bookmarkedBy: entity.bookmarkedBy,
      coordinates: entity.coordinates,
      geohash: entity.geohash,
      views: entity.views,
      viewedBy: entity.viewedBy,
      engagementScore: entity.engagementScore,
      lastEngagementUpdate: entity.lastEngagementUpdate,
    );
  }
  const PostModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.userAvatar,
    required super.content,
    required super.images,
    required super.likes,
    required super.comments,
    required super.shares,
    required super.cheks,
    required super.createdAt,
    required super.updatedAt,
    required super.isVerified,
    required super.likedBy,
    required super.bookmarkedBy,
    super.videoUrl,
    super.thumbnailUrl,
    super.location,
    super.tags,
    super.coordinates,
    super.geohash,
    super.views,
    super.viewedBy,
    super.engagementScore,
    super.lastEngagementUpdate,
  });

  /// Create PostModel from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String? ?? '',
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      cheks: json['cheks'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      location: json['location'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      isVerified: json['isVerified'] as bool? ?? false,
      likedBy: (json['likedBy'] as List<dynamic>?)?.cast<String>() ?? [],
      bookmarkedBy:
          (json['bookmarkedBy'] as List<dynamic>?)?.cast<String>() ?? [],
      coordinates: json['coordinates'] as GeoPoint?,
      geohash: json['geohash'] as String?,
      views: json['views'] as int? ?? 0,
      viewedBy: (json['viewedBy'] as List<dynamic>?)?.cast<String>() ?? [],
      engagementScore: (json['engagementScore'] as num?)?.toDouble() ?? 0.0,
      lastEngagementUpdate: json['lastEngagementUpdate'] != null
          ? (json['lastEngagementUpdate'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create PostModel from Firestore document
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  /// Convert PostModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'images': images,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'cheks': cheks,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (location != null) 'location': location,
      if (tags != null) 'tags': tags,
      'isVerified': isVerified,
      'likedBy': likedBy,
      'bookmarkedBy': bookmarkedBy,
      if (coordinates != null) 'coordinates': coordinates,
      if (geohash != null) 'geohash': geohash,
      'views': views,
      'viewedBy': viewedBy,
      'engagementScore': engagementScore,
      if (lastEngagementUpdate != null)
        'lastEngagementUpdate': Timestamp.fromDate(lastEngagementUpdate!),
    };
  }

  /// Convert PostModel to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Remove id from Firestore document (it's stored as document ID)
    json.remove('id');
    return json;
  }

  /// Convert PostModel to PostEntity
  PostEntity toEntity() {
    return PostEntity(
      id: id,
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      content: content,
      images: images,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      likes: likes,
      comments: comments,
      shares: shares,
      cheks: cheks,
      createdAt: createdAt,
      updatedAt: updatedAt,
      location: location,
      tags: tags,
      isVerified: isVerified,
      likedBy: likedBy,
      bookmarkedBy: bookmarkedBy,
      coordinates: coordinates,
      geohash: geohash,
      views: views,
      viewedBy: viewedBy,
      engagementScore: engagementScore,
      lastEngagementUpdate: lastEngagementUpdate,
    );
  }

  /// Create a copy with updated fields
  @override
  PostModel copyWith({
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
    return PostModel(
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
}
