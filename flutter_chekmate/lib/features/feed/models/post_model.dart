/// Post model - represents a social media post
class Post {
  const Post({
    required this.id,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.timestamp,
    this.imageUrl,
    this.imageUrls = const [],
    this.videoUrl,
    this.thumbnailUrl,
    this.caption,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      caption: json['caption'] as String?,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      shares: json['shares'] as int,
      timestamp: json['timestamp'] as String,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }
  final String id;
  final String username;
  final String userAvatar;
  final String content;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? caption;
  final int likes;
  final int comments;
  final int shares;
  final String timestamp;
  final bool isLiked;
  final bool isBookmarked;

  /// Check if this post has a video
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  /// Check if this post has an image (single or multiple)
  bool get hasImage =>
      (imageUrl != null && imageUrl!.isNotEmpty) || imageUrls.isNotEmpty;

  /// Check if this post has multiple images
  bool get hasMultipleImages => imageUrls.length > 1;

  /// Get all image URLs (combines single imageUrl with imageUrls list)
  List<String> get allImageUrls {
    final urls = <String>[];
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      urls.add(imageUrl!);
    }
    urls.addAll(imageUrls);
    return urls;
  }

  Post copyWith({
    String? id,
    String? username,
    String? userAvatar,
    String? content,
    String? imageUrl,
    List<String>? imageUrls,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    int? likes,
    int? comments,
    int? shares,
    String? timestamp,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return Post(
      id: id ?? this.id,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'timestamp': timestamp,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
    };
  }
}

/// Mock data for testing
class MockPosts {
  static final List<Post> posts = [
    const Post(
      id: '1',
      username: 'Tbabee100',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      content: 'How I found out my fiancé was getting married',
      imageUrls: [
        'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
        'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
        'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb',
      ],
      caption: 'How I found out my fiancé was getting MARRIED',
      likes: 265000,
      comments: 8000,
      shares: 2562,
      timestamp: '2h ago',
    ),
    const Post(
      id: '2',
      username: 'JessicaM',
      userAvatar:
          'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb',
      content:
          'Finally found someone who appreciates my weird sense of humor 😂 Date night was amazing!',
      likes: 1240,
      comments: 89,
      shares: 23,
      timestamp: '4h ago',
    ),
    const Post(
      id: '3',
      username: 'MikeD_Official',
      userAvatar:
          'https://images.unsplash.com/photo-1672685667592-0392f458f46f',
      content:
          'Pro tip: Cook together on the first date. You learn so much about someone by how they handle kitchen chaos 👨‍🍳',
      likes: 892,
      comments: 156,
      shares: 67,
      timestamp: '6h ago',
    ),
    const Post(
      id: '4',
      username: 'SarahJ_Stories',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      content:
          'When they remember your coffee order after one date ☕️ That\'s when you know they\'re paying attention to the little things',
      likes: 2100,
      comments: 234,
      shares: 89,
      timestamp: '8h ago',
    ),
  ];
}
