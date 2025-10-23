import 'package:flutter_chekmate/features/explore/domain/entities/explore_content_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExploreContentEntity', () {
    late ExploreContentEntity content;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now().subtract(const Duration(hours: 2));
      content = ExploreContentEntity(
        id: 'test-id',
        type: ExploreContentType.post,
        title: 'Test Post',
        description: 'Test description',
        imageUrl: 'https://example.com/image.jpg',
        authorId: 'author-123',
        authorName: 'John Doe',
        authorAvatar: 'https://example.com/avatar.jpg',
        likes: 500,
        comments: 100,
        shares: 50,
        views: 10000,
        trendingScore: 0.8,
        createdAt: testDate,
        tags: const ['test', 'flutter'],
        category: 'technology',
      );
    });

    group('totalEngagement getter', () {
      test('calculates total engagement correctly', () {
        expect(content.totalEngagement, 650); // 500 + 100 + 50
      });

      test('returns 0 when all engagement metrics are 0', () {
        final zeroContent = content.copyWith(likes: 0, comments: 0, shares: 0);
        expect(zeroContent.totalEngagement, 0);
      });

      test('handles large engagement numbers', () {
        final popularContent = content.copyWith(
          likes: 1000000,
          comments: 500000,
          shares: 250000,
        );
        expect(popularContent.totalEngagement, 1750000);
      });
    });

    group('isTrending getter', () {
      test('returns true when trending score > 0.7', () {
        final trendingContent = content.copyWith(trendingScore: 0.8);
        expect(trendingContent.isTrending, true);
      });

      test('returns false when trending score <= 0.7', () {
        final nonTrendingContent = content.copyWith(trendingScore: 0.7);
        expect(nonTrendingContent.isTrending, false);
      });

      test('returns false when trending score is 0', () {
        final zeroContent = content.copyWith(trendingScore: 0.0);
        expect(zeroContent.isTrending, false);
      });

      test('returns true when trending score is 1.0', () {
        final maxContent = content.copyWith(trendingScore: 1.0);
        expect(maxContent.isTrending, true);
      });
    });

    group('isPopular getter', () {
      test('returns true when total engagement > 1000', () {
        final popularContent = content.copyWith(
          likes: 800,
          comments: 150,
          shares: 100,
        );
        expect(popularContent.isPopular, true);
      });

      test('returns false when total engagement <= 1000', () {
        final unpopularContent = content.copyWith(
          likes: 500,
          comments: 300,
          shares: 200,
        );
        expect(unpopularContent.isPopular, false);
      });

      test('returns false when total engagement is exactly 1000', () {
        final borderlineContent = content.copyWith(
          likes: 600,
          comments: 250,
          shares: 150,
        );
        expect(borderlineContent.isPopular, false);
      });
    });

    group('isRecent getter', () {
      test('returns true for content less than 24 hours old', () {
        final recentContent = content.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        );
        expect(recentContent.isRecent, true);
      });

      test('returns false for content more than 24 hours old', () {
        final oldContent = content.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        );
        expect(oldContent.isRecent, false);
      });

      test('returns true for content exactly 23 hours old', () {
        final borderlineContent = content.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 23)),
        );
        expect(borderlineContent.isRecent, true);
      });
    });

    group('timeAgo getter', () {
      test('returns "Just now" for content less than 60 seconds old', () {
        final justNowContent = content.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        );
        expect(justNowContent.timeAgo, 'Just now');
      });

      test('returns minutes for content less than 1 hour old', () {
        final minutesContent = content.copyWith(
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        expect(minutesContent.timeAgo, '5m ago');
      });

      test('returns hours for content less than 24 hours old', () {
        final hoursContent = content.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        );
        expect(hoursContent.timeAgo, '3h ago');
      });

      test('returns days for content less than 7 days old', () {
        final daysContent = content.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        expect(daysContent.timeAgo, '3d ago');
      });

      test('returns weeks for content more than 7 days old', () {
        final weeksContent = content.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        );
        expect(weeksContent.timeAgo, '2w ago');
      });
    });

    group('engagementRate getter', () {
      test('calculates engagement rate correctly', () {
        // 650 total engagement / 10000 views = 0.065
        expect(content.engagementRate, closeTo(0.065, 0.001));
      });

      test('returns 0 when views is 0', () {
        final zeroViewsContent = content.copyWith(views: 0);
        expect(zeroViewsContent.engagementRate, 0.0);
      });

      test('handles high engagement rate', () {
        final highEngagementContent = content.copyWith(
          likes: 500,
          comments: 300,
          shares: 200,
          views: 1000,
        );
        expect(highEngagementContent.engagementRate, 1.0);
      });

      test('handles low engagement rate', () {
        final lowEngagementContent = content.copyWith(
          likes: 10,
          comments: 5,
          shares: 5,
          views: 100000,
        );
        expect(lowEngagementContent.engagementRate, closeTo(0.0002, 0.0001));
      });
    });

    group('formatCount method', () {
      test('returns number as string for counts < 1000', () {
        expect(content.formatCount(999), '999');
        expect(content.formatCount(500), '500');
        expect(content.formatCount(1), '1');
      });

      test('returns K format for counts >= 1000 and < 1000000', () {
        expect(content.formatCount(1000), '1.0K');
        expect(content.formatCount(1500), '1.5K');
        expect(content.formatCount(999999), '1000.0K');
      });

      test('returns M format for counts >= 1000000', () {
        expect(content.formatCount(1000000), '1.0M');
        expect(content.formatCount(1500000), '1.5M');
        expect(content.formatCount(2500000), '2.5M');
      });

      test('handles edge cases', () {
        expect(content.formatCount(0), '0');
        expect(content.formatCount(999), '999');
        expect(content.formatCount(1000), '1.0K');
        expect(content.formatCount(999999), '1000.0K');
        expect(content.formatCount(1000000), '1.0M');
      });
    });

    group('Equatable', () {
      test('two content entities with same properties are equal', () {
        final content1 = ExploreContentEntity(
          id: 'test-id',
          type: ExploreContentType.post,
          title: 'Test',
          description: 'Test description',
          imageUrl: 'https://example.com/image.jpg',
          authorId: 'author-123',
          authorName: 'John Doe',
          authorAvatar: 'https://example.com/avatar.jpg',
          likes: 100,
          comments: 50,
          shares: 25,
          views: 1000,
          trendingScore: 0.5,
          createdAt: testDate,
        );

        final content2 = ExploreContentEntity(
          id: 'test-id',
          type: ExploreContentType.post,
          title: 'Test',
          description: 'Test description',
          imageUrl: 'https://example.com/image.jpg',
          authorId: 'author-123',
          authorName: 'John Doe',
          authorAvatar: 'https://example.com/avatar.jpg',
          likes: 100,
          comments: 50,
          shares: 25,
          views: 1000,
          trendingScore: 0.5,
          createdAt: testDate,
        );

        expect(content1, content2);
      });

      test('two content entities with different properties are not equal', () {
        final content1 = content.copyWith(id: 'id-1');
        final content2 = content.copyWith(id: 'id-2');

        expect(content1, isNot(content2));
      });
    });

    group('copyWith', () {
      test('creates new instance with updated properties', () {
        final updatedContent = content.copyWith(
          title: 'Updated Title',
          likes: 1000,
        );

        expect(updatedContent.title, 'Updated Title');
        expect(updatedContent.likes, 1000);
        expect(updatedContent.id, content.id);
        expect(updatedContent.type, content.type);
      });

      test('preserves original properties when not specified', () {
        final updatedContent = content.copyWith(likes: 1000);

        expect(updatedContent.title, content.title);
        expect(updatedContent.description, content.description);
        expect(updatedContent.type, content.type);
      });
    });
  });

  group('HashtagEntity', () {
    late HashtagEntity hashtag;

    setUp(() {
      hashtag = const HashtagEntity(
        tag: 'flutter',
        postCount: 1500,
        trendingScore: 0.8,
      );
    });

    group('formattedPostCount getter', () {
      test('formats post count correctly', () {
        expect(hashtag.formattedPostCount, '1.5K posts');
      });

      test('handles small counts', () {
        const smallHashtag = HashtagEntity(
          tag: 'flutter',
          postCount: 500,
          trendingScore: 0.8,
        );
        expect(smallHashtag.formattedPostCount, '500 posts');
      });

      test('handles large counts', () {
        const largeHashtag = HashtagEntity(
          tag: 'flutter',
          postCount: 2500000,
          trendingScore: 0.8,
        );
        expect(largeHashtag.formattedPostCount, '2.5M posts');
      });
    });

    group('isTrending getter', () {
      test('returns true when trending score > 0.7', () {
        expect(hashtag.isTrending, true);
      });

      test('returns false when trending score <= 0.7', () {
        const nonTrendingHashtag = HashtagEntity(
          tag: 'flutter',
          postCount: 1500,
          trendingScore: 0.5,
        );
        expect(nonTrendingHashtag.isTrending, false);
      });
    });
  });

  group('SuggestedUserEntity', () {
    late SuggestedUserEntity user;

    setUp(() {
      user = const SuggestedUserEntity(
        id: 'user-123',
        name: 'John Doe',
        username: 'johndoe',
        avatar: 'https://example.com/avatar.jpg',
        followers: 15000,
        isVerified: true,
        bio: 'Flutter developer',
      );
    });

    group('formattedFollowers getter', () {
      test('formats followers count correctly', () {
        expect(user.formattedFollowers, '15.0K');
      });

      test('handles small follower counts', () {
        const smallUser = SuggestedUserEntity(
          id: 'user-123',
          name: 'John Doe',
          username: 'johndoe',
          avatar: 'https://example.com/avatar.jpg',
          followers: 500,
          isVerified: true,
          bio: 'Flutter developer',
        );
        expect(smallUser.formattedFollowers, '500');
      });

      test('handles large follower counts', () {
        const largeUser = SuggestedUserEntity(
          id: 'user-123',
          name: 'John Doe',
          username: 'johndoe',
          avatar: 'https://example.com/avatar.jpg',
          followers: 2500000,
          isVerified: true,
          bio: 'Flutter developer',
        );
        expect(largeUser.formattedFollowers, '2.5M');
      });
    });
  });
}
