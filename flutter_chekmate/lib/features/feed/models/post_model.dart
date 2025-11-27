/// Legacy Post Model
/// This is a legacy model for backward compatibility with old feed pages
/// New code should use PostEntity from features/posts/domain/entities/post_entity.dart
class Post {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String content;
  final List<String> images;
  final String? videoUrl;
  final int likes;
  final int comments;
  final int shares;
  final int cheks;
  final DateTime timestamp;
  final bool isLiked;
  final bool isBookmarked;
  final bool isCheked;
  final String? location;
  final List<String> tags;
  final List<String> likedByNames; // Names of users who liked this post

  const Post({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.content,
    this.images = const [],
    this.videoUrl,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.cheks = 0,
    required this.timestamp,
    this.isLiked = false,
    this.isBookmarked = false,
    this.isCheked = false,
    this.location,
    this.tags = const [],
    this.likedByNames = const [],
  });

  // Helper getters
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasImage => images.isNotEmpty;
  String get caption => content;
  String? get imageUrl => images.isNotEmpty ? images.first : null;
  String? get thumbnailUrl => hasVideo ? imageUrl : null;
  List<String> get allImageUrls => images;

  Post copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? content,
    List<String>? images,
    String? videoUrl,
    int? likes,
    int? comments,
    int? shares,
    int? cheks,
    DateTime? timestamp,
    bool? isLiked,
    bool? isBookmarked,
    bool? isCheked,
    String? location,
    List<String>? tags,
    List<String>? likedByNames,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      cheks: cheks ?? this.cheks,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isCheked: isCheked ?? this.isCheked,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      likedByNames: likedByNames ?? this.likedByNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'images': images,
      'videoUrl': videoUrl,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'cheks': cheks,
      'timestamp': timestamp.toIso8601String(),
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'isCheked': isCheked,
      'location': location,
      'tags': tags,
      'likedByNames': likedByNames,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      videoUrl: json['videoUrl'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      cheks: json['cheks'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isCheked: json['isCheked'] as bool? ?? false,
      location: json['location'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      likedByNames: List<String>.from(json['likedByNames'] as List? ?? []),
    );
  }
}
