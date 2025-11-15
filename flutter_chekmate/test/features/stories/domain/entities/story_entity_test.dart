import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoryEntity', () {
    late StoryEntity testStory;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now().subtract(const Duration(hours: 2));
      testStory = StoryEntity(
        id: 'story1',
        userId: 'user1',
        username: 'testuser',
        userAvatar: 'https://example.com/avatar.jpg',
        type: StoryType.image,
        url: 'https://example.com/story.jpg',
        createdAt: testDate,
        expiresAt: testDate.add(const Duration(hours: 24)),
        views: 10,
        likes: 5,
      );
    });

    group('Business Logic Methods', () {
      test('isExpired returns false for active story', () {
        expect(testStory.isExpired, false);
      });

      test('isExpired returns true for expired story', () {
        final expiredStory = testStory.copyWith(
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(expiredStory.isExpired, true);
      });

      test('isVideo returns true for video story', () {
        final videoStory = testStory.copyWith(type: StoryType.video);
        expect(videoStory.isVideo, true);
      });

      test('isVideo returns false for image story', () {
        expect(testStory.isVideo, false);
      });

      test('isImage returns true for image story', () {
        expect(testStory.isImage, true);
      });

      test('isImage returns false for video story', () {
        final videoStory = testStory.copyWith(type: StoryType.video);
        expect(videoStory.isImage, false);
      });

      test('timeRemaining returns correct duration', () {
        final timeRemaining = testStory.timeRemaining;
        expect(timeRemaining.inHours, greaterThan(20));
        expect(timeRemaining.inHours, lessThan(23));
      });

      test('timeRemaining returns zero for expired story', () {
        final expiredStory = testStory.copyWith(
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(expiredStory.timeRemaining, Duration.zero);
      });

      test('timeAgo returns "Just now" for recent story', () {
        final recentStory = testStory.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        );
        expect(recentStory.timeAgo, 'Just now');
      });

      test('timeAgo returns correct format for minutes', () {
        final story = testStory.copyWith(
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        expect(story.timeAgo, '5m ago');
      });

      test('timeAgo returns correct format for hours', () {
        expect(testStory.timeAgo, '2h ago');
      });

      test('timeAgo returns correct format for days', () {
        final oldStory = testStory.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        expect(oldStory.timeAgo, '2d ago');
      });
    });

    group('Equality', () {
      test('two stories with same id are equal', () {
        final story1 = testStory;
        final story2 = testStory.copyWith(views: 20);
        expect(story1, equals(story2));
      });

      test('two stories with different ids are not equal', () {
        final story1 = testStory;
        final story2 = testStory.copyWith(id: 'story2');
        expect(story1, isNot(equals(story2)));
      });

      test('hashCode is based on id', () {
        final story1 = testStory;
        final story2 = testStory.copyWith(views: 20);
        expect(story1.hashCode, equals(story2.hashCode));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated fields', () {
        final updatedStory = testStory.copyWith(
          views: 20,
          likes: 10,
        );

        expect(updatedStory.id, testStory.id);
        expect(updatedStory.views, 20);
        expect(updatedStory.likes, 10);
        expect(updatedStory.username, testStory.username);
      });

      test('copyWith preserves original when no fields provided', () {
        final copiedStory = testStory.copyWith();

        expect(copiedStory.id, testStory.id);
        expect(copiedStory.views, testStory.views);
        expect(copiedStory.likes, testStory.likes);
      });
    });
  });

  group('StoryUserEntity', () {
    late StoryUserEntity testStoryUser;
    late List<StoryEntity> testStories;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now().subtract(const Duration(hours: 2));
      testStories = [
        StoryEntity(
          id: 'story1',
          userId: 'user1',
          username: 'testuser',
          userAvatar: 'https://example.com/avatar.jpg',
          type: StoryType.image,
          url: 'https://example.com/story1.jpg',
          createdAt: testDate,
          expiresAt: testDate.add(const Duration(hours: 24)),
          views: 10,
          likes: 5,
        ),
        StoryEntity(
          id: 'story2',
          userId: 'user1',
          username: 'testuser',
          userAvatar: 'https://example.com/avatar.jpg',
          type: StoryType.video,
          url: 'https://example.com/story2.mp4',
          createdAt: testDate.subtract(const Duration(hours: 1)),
          expiresAt: testDate.add(const Duration(hours: 23)),
          duration: 15,
          views: 20,
          likes: 10,
          isViewed: true,
        ),
      ];

      testStoryUser = StoryUserEntity(
        userId: 'user1',
        username: 'testuser',
        userAvatar: 'https://example.com/avatar.jpg',
        stories: testStories,
        isFollowing: true,
      );
    });

    group('Business Logic Methods', () {
      test('hasStories returns true when stories exist', () {
        expect(testStoryUser.hasStories, true);
      });

      test('hasStories returns false when stories are empty', () {
        final noStoriesUser = testStoryUser.copyWith(stories: []);
        expect(noStoriesUser.hasStories, false);
      });

      test('allViewed returns false when some stories are unviewed', () {
        expect(testStoryUser.allViewed, false);
      });

      test('allViewed returns true when all stories are viewed', () {
        final allViewedStories = testStories.map((s) => s.copyWith(isViewed: true)).toList();
        final allViewedUser = testStoryUser.copyWith(stories: allViewedStories);
        expect(allViewedUser.allViewed, true);
      });

      test('unviewedCount returns correct count', () {
        expect(testStoryUser.unviewedCount, 1);
      });

      test('unviewedCount returns 0 when all viewed', () {
        final allViewedStories = testStories.map((s) => s.copyWith(isViewed: true)).toList();
        final allViewedUser = testStoryUser.copyWith(stories: allViewedStories);
        expect(allViewedUser.unviewedCount, 0);
      });

      test('totalViews returns sum of all story views', () {
        expect(testStoryUser.totalViews, 30); // 10 + 20
      });

      test('totalLikes returns sum of all story likes', () {
        expect(testStoryUser.totalLikes, 15); // 5 + 10
      });

      test('mostRecentStory returns the most recent story', () {
        final mostRecent = testStoryUser.mostRecentStory;
        expect(mostRecent?.id, 'story1');
      });

      test('mostRecentStory returns null when no stories', () {
        final noStoriesUser = testStoryUser.copyWith(stories: []);
        expect(noStoriesUser.mostRecentStory, null);
      });
    });

    group('Equality', () {
      test('two story users with same userId are equal', () {
        final user1 = testStoryUser;
        final user2 = testStoryUser.copyWith(username: 'different');
        expect(user1, equals(user2));
      });

      test('two story users with different userIds are not equal', () {
        final user1 = testStoryUser;
        final user2 = testStoryUser.copyWith(userId: 'user2');
        expect(user1, isNot(equals(user2)));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated fields', () {
        final updatedUser = testStoryUser.copyWith(
          username: 'newusername',
          isFollowing: false,
        );

        expect(updatedUser.userId, testStoryUser.userId);
        expect(updatedUser.username, 'newusername');
        expect(updatedUser.isFollowing, false);
      });
    });
  });
}

