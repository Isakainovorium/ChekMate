import 'package:flutter_chekmate/features/feed/models/post_model.dart';
import 'package:flutter_chekmate/features/stories/models/story_model.dart';

/// Mock Posts
/// Sample posts for testing and development
class MockPosts {
  static final List<Post> posts = [
    Post(
      id: '1',
      userId: 'user1',
      username: 'john_doe',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      content: 'Just had an amazing first date! 🎉',
      images: ['https://picsum.photos/400/300?random=1'],
      likes: 42,
      comments: 8,
      shares: 3,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      location: 'New York, NY',
      tags: ['#firstdate', '#amazing'],
    ),
    Post(
      id: '2',
      userId: 'user2',
      username: 'jane_smith',
      userAvatar: 'https://i.pravatar.cc/150?img=2',
      content: 'Coffee date went better than expected! ☕',
      images: ['https://picsum.photos/400/300?random=2'],
      likes: 28,
      comments: 5,
      shares: 1,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      location: 'Los Angeles, CA',
      tags: ['#coffeedate', '#love'],
    ),
    Post(
      id: '3',
      userId: 'user3',
      username: 'mike_wilson',
      userAvatar: 'https://i.pravatar.cc/150?img=3',
      content: 'Dinner and a movie - classic but perfect! 🎬',
      images: [
        'https://picsum.photos/400/300?random=3',
        'https://picsum.photos/400/300?random=4',
      ],
      likes: 56,
      comments: 12,
      shares: 4,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      location: 'Chicago, IL',
      tags: ['#datenight', '#movies'],
    ),
    Post(
      id: '4',
      userId: 'user4',
      username: 'sarah_jones',
      userAvatar: 'https://i.pravatar.cc/150?img=4',
      content: 'Beach sunset date was magical! 🌅',
      images: ['https://picsum.photos/400/300?random=5'],
      likes: 89,
      comments: 15,
      shares: 7,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Miami, FL',
      tags: ['#beachdate', '#sunset'],
    ),
    Post(
      id: '5',
      userId: 'user5',
      username: 'alex_brown',
      userAvatar: 'https://i.pravatar.cc/150?img=5',
      content: 'Hiking adventure date - got to know each other better! 🏔️',
      images: ['https://picsum.photos/400/300?random=6'],
      likes: 34,
      comments: 6,
      shares: 2,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      location: 'Denver, CO',
      tags: ['#hiking', '#adventure'],
    ),
  ];

  static Post getById(String id) {
    return posts.firstWhere(
      (post) => post.id == id,
      orElse: () => posts.first,
    );
  }

  static List<Post> getRecent({int limit = 10}) {
    return posts.take(limit).toList();
  }
}

/// Mock Stories
/// Sample stories for testing and development
class MockStories {
  static final List<StoryUser> stories = [
    StoryUser(
      id: 'user1',
      username: 'john_doe',
      avatar: 'https://i.pravatar.cc/150?img=1',
      hasUnviewedStories: true,
      stories: [
        StoryModel(
          id: 'story1',
          userId: 'user1',
          username: 'john_doe',
          userAvatar: 'https://i.pravatar.cc/150?img=1',
          mediaUrl: 'https://picsum.photos/400/600?random=10',
          mediaType: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          expiresAt: DateTime.now().add(const Duration(hours: 23)),
          views: 45,
        ),
      ],
    ),
    StoryUser(
      id: 'user2',
      username: 'jane_smith',
      avatar: 'https://i.pravatar.cc/150?img=2',
      hasUnviewedStories: true,
      stories: [
        StoryModel(
          id: 'story2',
          userId: 'user2',
          username: 'jane_smith',
          userAvatar: 'https://i.pravatar.cc/150?img=2',
          mediaUrl: 'https://picsum.photos/400/600?random=11',
          mediaType: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          expiresAt: DateTime.now().add(const Duration(hours: 21)),
          views: 32,
        ),
      ],
    ),
    StoryUser(
      id: 'user3',
      username: 'mike_wilson',
      avatar: 'https://i.pravatar.cc/150?img=3',
      hasUnviewedStories: false,
      stories: [
        StoryModel(
          id: 'story3',
          userId: 'user3',
          username: 'mike_wilson',
          userAvatar: 'https://i.pravatar.cc/150?img=3',
          mediaUrl: 'https://picsum.photos/400/600?random=12',
          mediaType: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          expiresAt: DateTime.now().add(const Duration(hours: 18)),
          isViewed: true,
          views: 67,
        ),
      ],
    ),
    StoryUser(
      id: 'user4',
      username: 'sarah_jones',
      avatar: 'https://i.pravatar.cc/150?img=4',
      hasUnviewedStories: true,
      stories: [
        StoryModel(
          id: 'story4',
          userId: 'user4',
          username: 'sarah_jones',
          userAvatar: 'https://i.pravatar.cc/150?img=4',
          mediaUrl: 'https://picsum.photos/400/600?random=13',
          mediaType: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          expiresAt: DateTime.now().add(const Duration(hours: 22)),
          views: 89,
        ),
      ],
    ),
  ];

  static StoryUser getById(String id) {
    return stories.firstWhere(
      (story) => story.id == id,
      orElse: () => stories.first,
    );
  }

  static List<StoryUser> getRecent({int limit = 10}) {
    return stories.take(limit).toList();
  }
}

