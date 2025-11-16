import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';

/// Post Model - Data Layer
///
/// Handles serialization/deserialization of post data to/from Firestore.
/// Extends PostEntity to inherit domain logic.
///
/// Clean Architecture: Data Layer
class PostModel extends PostEntity {
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
    required super.likedBy,
    required super.bookmarkedBy,
    required super.chekedBy,
    required super.tags,
    required super.createdAt,
    required super.updatedAt,
    required super.isVerified,
    super.videoUrl,
    super.thumbnailUrl,
    super.location,
    super.coordinates,
    super.geohash,
  });

  /// Create PostModel from JSON (Firestore document)
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String? ?? '',
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      cheks: json['cheks'] as int? ?? 0,
      likedBy: (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      bookmarkedBy: (json['bookmarkedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      chekedBy: (json['chekedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      location: json['location'] as String?,
      coordinates: json['coordinates'] as GeoPoint?,
      geohash: json['geohash'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  /// Create PostModel from Firestore DocumentSnapshot
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel.fromJson({...data, 'id': doc.id});
  }

  /// Convert PostModel to Firestore document data
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Convert PostModel to JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'images': images,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'cheks': cheks,
      'likedBy': likedBy,
      'bookmarkedBy': bookmarkedBy,
      'chekedBy': chekedBy,
      'tags': tags,
      'location': location,
      'coordinates': coordinates,
      'geohash': geohash,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
    };
  }

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
      likedBy: entity.likedBy,
      bookmarkedBy: entity.bookmarkedBy,
      chekedBy: entity.chekedBy,
      tags: entity.tags,
      location: entity.location,
      coordinates: entity.coordinates,
      geohash: entity.geohash,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isVerified: entity.isVerified,
    );
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
      likedBy: likedBy,
      bookmarkedBy: bookmarkedBy,
      chekedBy: chekedBy,
      tags: tags,
      location: location,
      coordinates: coordinates,
      geohash: geohash,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isVerified: isVerified,
    );
  }

  /// Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    } else {
      return DateTime.now();
    }
  }

  /// Copy with method for creating modified copies
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
}
