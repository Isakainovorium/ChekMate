/// Story user model
class StoryUser {
  const StoryUser({
    required this.id,
    required this.username,
    required this.avatar,
    this.hasStory = false,
    this.isOwn = false,
    this.isViewed = false,
    this.isFollowing = false,
    this.stories = const [],
  });
  final String id;
  final String username;
  final String avatar;
  final bool hasStory;
  final bool isOwn;
  final bool isViewed;
  final bool isFollowing;
  final List<Story> stories;

  StoryUser copyWith({
    String? id,
    String? username,
    String? avatar,
    bool? hasStory,
    bool? isOwn,
    bool? isViewed,
    bool? isFollowing,
    List<Story>? stories,
  }) {
    return StoryUser(
      id: id ?? this.id,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      hasStory: hasStory ?? this.hasStory,
      isOwn: isOwn ?? this.isOwn,
      isViewed: isViewed ?? this.isViewed,
      isFollowing: isFollowing ?? this.isFollowing,
      stories: stories ?? this.stories,
    );
  }
}

/// Individual story model
class Story {
  const Story({
    required this.id,
    required this.type,
    required this.url,
    required this.timestamp,
    this.duration = 5,
    this.thumbnailUrl,
    this.text,
    this.textColor,
    this.textPosition,
  });
  final String id;
  final StoryType type;
  final String url; // Image URL or Video URL
  final String? thumbnailUrl; // Thumbnail for video stories
  final int duration; // in seconds
  final String? text;
  final String? textColor;
  final String? textPosition;
  final String timestamp;

  /// Check if this story is a video
  bool get isVideo => type == StoryType.video;

  /// Check if this story is an image
  bool get isImage => type == StoryType.image;
}

enum StoryType {
  image,
  video,
}

/// Mock data for testing
class MockStories {
  static final List<StoryUser> stories = [
    const StoryUser(
      id: '1',
      username: 'Your story',
      avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      hasStory: true,
      isOwn: true,
      isFollowing: true,
      stories: [
        Story(
          id: 's1-1',
          type: StoryType.image,
          url: 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937',
          text: 'Perfect date night! 💕',
          textColor: 'white',
          textPosition: 'bottom',
          timestamp: '2h ago',
        ),
      ],
    ),
    const StoryUser(
      id: '2',
      username: 'jessica_m',
      avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb',
      hasStory: true,
      isFollowing: true,
      stories: [
        Story(
          id: 's2-1',
          type: StoryType.image,
          url: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136',
          text: 'Coffee date vibes ☕',
          textColor: 'white',
          textPosition: 'top',
          timestamp: '4h ago',
        ),
      ],
    ),
    const StoryUser(
      id: '3',
      username: 'miked_official',
      avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f',
      hasStory: true,
      isFollowing: true,
      stories: [
        Story(
          id: 's3-1',
          type: StoryType.image,
          url: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18',
          duration: 4,
          text: 'First date nerves are real! 😅',
          textColor: 'white',
          textPosition: 'bottom',
          timestamp: '6h ago',
        ),
      ],
    ),
    const StoryUser(
      id: '4',
      username: 'sarah_stories',
      avatar: 'https://images.unsplash.com/photo-1639149888905-fb39731f2e6c',
      hasStory: true,
      isFollowing: true,
      stories: [
        Story(
          id: 's4-1',
          type: StoryType.image,
          url: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
          text: 'He remembered my favorite flowers 🌸',
          textColor: 'white',
          textPosition: 'center',
          timestamp: '7h ago',
        ),
      ],
    ),
    const StoryUser(
      id: '5',
      username: 'alex_adventures',
      avatar: 'https://images.unsplash.com/photo-1758639842438-718755aa57e4',
      hasStory: true,
      isFollowing: true,
      stories: [
        Story(
          id: 's5-1',
          type: StoryType.image,
          url: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c',
          duration: 6,
          text: 'When they text back immediately 😍',
          textColor: 'black',
          textPosition: 'bottom',
          timestamp: '5h ago',
        ),
      ],
    ),
  ];
}
