import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';

/// Story Model - Data Layer
///
/// Extends StoryEntity with JSON serialization capabilities.
/// Handles conversion between Firestore documents and domain entities.
///
/// Clean Architecture: Data Layer
class StoryModel extends StoryEntity {
  const StoryModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.userAvatar,
    required super.type,
    required super.url,
    required super.createdAt,
    required super.expiresAt,
    super.thumbnailUrl,
    super.duration,
    super.text,
    super.textColor,
    super.textPosition,
    super.views,
    super.likes,
    super.isViewed,
  });

  /// Create from JSON
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String,
      type: StoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StoryType.image,
      ),
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: json['duration'] as int? ?? 5,
      text: json['text'] as String?,
      textColor: json['textColor'] as String?,
      textPosition: json['textPosition'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] is Timestamp
          ? (json['expiresAt'] as Timestamp).toDate()
          : DateTime.parse(json['expiresAt'] as String),
      views: json['views'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      isViewed: json['isViewed'] as bool? ?? false,
    );
  }

  /// Create from Firestore document
  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'type': type.name,
      'url': url,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      if (text != null) 'text': text,
      if (textColor != null) 'textColor': textColor,
      if (textPosition != null) 'textPosition': textPosition,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'views': views,
      'likes': likes,
      'isViewed': isViewed,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Convert to StoryEntity
  StoryEntity toEntity() {
    return StoryEntity(
      id: id,
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      type: type,
      url: url,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      text: text,
      textColor: textColor,
      textPosition: textPosition,
      createdAt: createdAt,
      expiresAt: expiresAt,
      views: views,
      likes: likes,
      isViewed: isViewed,
    );
  }

  @override
  StoryModel copyWith({
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
    return StoryModel(
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
}

/// Story User Model - Data Layer
class StoryUserModel extends StoryUserEntity {
  const StoryUserModel({
    required super.userId,
    required super.username,
    required super.userAvatar,
    required super.stories,
    super.isOwn,
    super.isFollowing,
  });

  factory StoryUserModel.fromJson(Map<String, dynamic> json) {
    return StoryUserModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String,
      stories: (json['stories'] as List<dynamic>)
          .map((e) => StoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isOwn: json['isOwn'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'stories': stories.map((e) => (e as StoryModel).toJson()).toList(),
      'isOwn': isOwn,
      'isFollowing': isFollowing,
    };
  }

  StoryUserEntity toEntity() {
    return StoryUserEntity(
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      stories: stories,
      isOwn: isOwn,
      isFollowing: isFollowing,
    );
  }

  @override
  StoryUserModel copyWith({
    String? userId,
    String? username,
    String? userAvatar,
    List<StoryEntity>? stories,
    bool? isOwn,
    bool? isFollowing,
  }) {
    return StoryUserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      stories: stories ?? this.stories,
      isOwn: isOwn ?? this.isOwn,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

