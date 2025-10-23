import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/explore/domain/entities/explore_content_entity.dart';

/// ExploreContentModel - Data Model for Explore Content
///
/// Handles serialization/deserialization for Firebase.
class ExploreContentModel extends ExploreContentEntity {

  /// From Entity
  factory ExploreContentModel.fromEntity(ExploreContentEntity entity) {
    return ExploreContentModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      authorId: entity.authorId,
      authorName: entity.authorName,
      authorAvatar: entity.authorAvatar,
      likes: entity.likes,
      comments: entity.comments,
      shares: entity.shares,
      views: entity.views,
      trendingScore: entity.trendingScore,
      createdAt: entity.createdAt,
      tags: entity.tags,
      category: entity.category,
    );
  }
  const ExploreContentModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.authorId,
    required super.authorName,
    required super.authorAvatar,
    required super.likes,
    required super.comments,
    required super.shares,
    required super.views,
    required super.trendingScore,
    required super.createdAt,
    super.tags,
    super.category,
  });

  /// From JSON
  factory ExploreContentModel.fromJson(Map<String, dynamic> json) {
    return ExploreContentModel(
      id: json['id'] as String,
      type: _parseContentType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      trendingScore: (json['trendingScore'] as num?)?.toDouble() ?? 0.0,
      createdAt: _parseTimestamp(json['createdAt']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      category: json['category'] as String?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _contentTypeToString(type),
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
      'trendingScore': trendingScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
      'category': category,
    };
  }

  /// Parse content type from string
  static ExploreContentType _parseContentType(String? type) {
    switch (type) {
      case 'video':
        return ExploreContentType.video;
      case 'image':
        return ExploreContentType.image;
      case 'story':
        return ExploreContentType.story;
      case 'event':
        return ExploreContentType.event;
      default:
        return ExploreContentType.post;
    }
  }

  /// Convert content type to string
  static String _contentTypeToString(ExploreContentType type) {
    switch (type) {
      case ExploreContentType.video:
        return 'video';
      case ExploreContentType.image:
        return 'image';
      case ExploreContentType.story:
        return 'story';
      case ExploreContentType.event:
        return 'event';
      case ExploreContentType.post:
        return 'post';
    }
  }

  /// Parse Firestore Timestamp
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else {
      return DateTime.now();
    }
  }
}

/// HashtagModel - Data Model for Hashtags
class HashtagModel extends HashtagEntity {

  /// From Entity
  factory HashtagModel.fromEntity(HashtagEntity entity) {
    return HashtagModel(
      tag: entity.tag,
      postCount: entity.postCount,
      trendingScore: entity.trendingScore,
    );
  }
  const HashtagModel({
    required super.tag,
    required super.postCount,
    required super.trendingScore,
  });

  /// From JSON
  factory HashtagModel.fromJson(Map<String, dynamic> json) {
    return HashtagModel(
      tag: json['tag'] as String,
      postCount: json['postCount'] as int? ?? 0,
      trendingScore: (json['trendingScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'postCount': postCount,
      'trendingScore': trendingScore,
    };
  }
}

/// SuggestedUserModel - Data Model for Suggested Users
class SuggestedUserModel extends SuggestedUserEntity {

  /// From Entity
  factory SuggestedUserModel.fromEntity(SuggestedUserEntity entity) {
    return SuggestedUserModel(
      id: entity.id,
      name: entity.name,
      username: entity.username,
      avatar: entity.avatar,
      followers: entity.followers,
      isVerified: entity.isVerified,
      bio: entity.bio,
    );
  }
  const SuggestedUserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.avatar,
    required super.followers,
    required super.isVerified,
    super.bio,
  });

  /// From JSON
  factory SuggestedUserModel.fromJson(Map<String, dynamic> json) {
    return SuggestedUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
      followers: json['followers'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      bio: json['bio'] as String?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'followers': followers,
      'isVerified': isVerified,
      'bio': bio,
    };
  }
}

