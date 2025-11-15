/// Story Model
/// Represents a user's story
class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final DateTime timestamp;
  final DateTime expiresAt;
  final bool isViewed;
  final int views;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.mediaUrl,
    required this.mediaType,
    required this.timestamp,
    required this.expiresAt,
    this.isViewed = false,
    this.views = 0,
  });

  StoryModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? mediaUrl,
    String? mediaType,
    DateTime? timestamp,
    DateTime? expiresAt,
    bool? isViewed,
    int? views,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      timestamp: timestamp ?? this.timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
      isViewed: isViewed ?? this.isViewed,
      views: views ?? this.views,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'timestamp': timestamp.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isViewed': isViewed,
      'views': views,
    };
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String?,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isViewed: json['isViewed'] as bool? ?? false,
      views: json['views'] as int? ?? 0,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Story User
/// Represents a user with stories
class StoryUser {
  final String id;
  final String username;
  final String? avatar;
  final List<StoryModel> stories;
  final bool hasUnviewedStories;

  const StoryUser({
    required this.id,
    required this.username,
    this.avatar,
    this.stories = const [],
    this.hasUnviewedStories = false,
  });

  StoryUser copyWith({
    String? id,
    String? username,
    String? avatar,
    List<StoryModel>? stories,
    bool? hasUnviewedStories,
  }) {
    return StoryUser(
      id: id ?? this.id,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      stories: stories ?? this.stories,
      hasUnviewedStories: hasUnviewedStories ?? this.hasUnviewedStories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'stories': stories.map((s) => s.toJson()).toList(),
      'hasUnviewedStories': hasUnviewedStories,
    };
  }

  factory StoryUser.fromJson(Map<String, dynamic> json) {
    return StoryUser(
      id: json['id'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
      stories: (json['stories'] as List?)
              ?.map((s) => StoryModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      hasUnviewedStories: json['hasUnviewedStories'] as bool? ?? false,
    );
  }
}

