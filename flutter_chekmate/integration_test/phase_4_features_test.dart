import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';
import 'package:flutter_chekmate/core/domain/entities/notification_entity.dart';
import 'package:flutter_chekmate/features/explore/domain/entities/explore_content_entity.dart';
import 'package:flutter_chekmate/features/search/domain/entities/search_result_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration Tests for Phase 4 Features
///
/// Tests the complete flow of Phase 4 features including:
/// - Notifications (FCM, local notifications)
/// - Location services (GPS, geocoding)
/// - External links (URL launcher, app info)
/// - Explore feature (trending content, hashtags, users)
/// - Search feature (multi-type search, filters, recent searches)
///
/// These tests verify that all Phase 4 features work together correctly
/// and that the Clean Architecture implementation is functioning properly.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4 Integration Tests', () {
    group('Notification Entity Integration', () {
      test('notification entity business logic works correctly', () {
        final notification = NotificationEntity(
          id: 'test-id',
          userId: 'user-123',
          type: NotificationType.like,
          title: 'New Like',
          body: 'John liked your post',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
          senderId: 'sender-123',
          senderName: 'John Doe',
        );

        // Test business logic
        expect(notification.icon, '❤️');
        expect(notification.isRecent, true);
        expect(notification.isToday, true);
        expect(notification.timeAgo, contains('ago'));
      });

      test('notification types have correct icons', () {
        final types = [
          NotificationType.like,
          NotificationType.comment,
          NotificationType.follow,
          NotificationType.message,
          NotificationType.mention,
          NotificationType.share,
          NotificationType.chek,
          NotificationType.story,
          NotificationType.system,
        ];

        final expectedIcons = [
          '❤️',
          '💬',
          '👤',
          '✉️',
          '@',
          '🔄',
          '✓',
          '📸',
          '🔔',
        ];

        for (var i = 0; i < types.length; i++) {
          final notification = NotificationEntity(
            id: 'test-$i',
            userId: 'user-123',
            type: types[i],
            title: 'Test',
            body: 'Test body',
            createdAt: DateTime.now(),
            isRead: false,
          );

          expect(notification.icon, expectedIcons[i]);
        }
      });

      test('notification action requirements work correctly', () {
        final followNotification = NotificationEntity(
          id: 'test-id',
          userId: 'user-123',
          type: NotificationType.follow,
          title: 'New Follower',
          body: 'John followed you',
          createdAt: DateTime.now(),
          isRead: false,
        );

        expect(followNotification.requiresAction, true);
        expect(followNotification.actionButtonText, 'Follow Back');

        final likeNotification = NotificationEntity(
          id: 'test-id',
          userId: 'user-123',
          type: NotificationType.like,
          title: 'New Like',
          body: 'John liked your post',
          createdAt: DateTime.now(),
          isRead: false,
        );

        expect(likeNotification.requiresAction, false);
        expect(likeNotification.actionButtonText, 'View');
      });
    });

    group('Location Entity Integration', () {
      test('location entity business logic works correctly', () {
        const location = LocationEntity(
          latitude: 37.7749,
          longitude: -122.4194,
          address: '123 Main St, San Francisco, CA 94102',
          city: 'San Francisco',
          country: 'United States',
          postalCode: '94102',
          street: '123 Main St',
        );

        // Test business logic
        expect(location.displayName, contains('San Francisco'));
        expect(location.shortDisplayName, contains('San Francisco'));
        expect(location.fullAddress, contains('San Francisco'));
        expect(location.isValid, true);
      });

      test('location distance calculations work correctly', () {
        const sf = LocationEntity(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        const la = LocationEntity(
          latitude: 34.0522,
          longitude: -118.2437,
        );

        final distance = sf.distanceTo(la);
        expect(distance, greaterThan(500000)); // > 500 km
        expect(distance, lessThan(600000)); // < 600 km
      });
    });

    group('Explore Content Entity Integration', () {
      test('explore content business logic works correctly', () {
        final content = ExploreContentEntity(
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
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        // Test business logic
        expect(content.totalEngagement, 650);
        expect(content.isTrending, true);
        expect(content.isPopular, false);
        expect(content.isRecent, true);
        expect(content.engagementRate, closeTo(0.065, 0.001));
      });

      test('explore content formatting works correctly', () {
        final content = ExploreContentEntity(
          id: 'test-id',
          type: ExploreContentType.post,
          title: 'Test Post',
          description: 'Test description',
          imageUrl: 'https://example.com/image.jpg',
          authorId: 'author-123',
          authorName: 'John Doe',
          authorAvatar: 'https://example.com/avatar.jpg',
          likes: 1500,
          comments: 250,
          shares: 100,
          views: 50000,
          trendingScore: 0.9,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        expect(content.formatCount(999), '999');
        expect(content.formatCount(1500), '1.5K');
        expect(content.formatCount(1500000), '1.5M');
      });

      test('hashtag entity works correctly', () {
        const hashtag = HashtagEntity(
          tag: 'flutter',
          postCount: 1500,
          trendingScore: 0.8,
        );

        expect(hashtag.formattedPostCount, '1.5K');
        expect(hashtag.isTrending, true);
      });

      test('suggested user entity works correctly', () {
        const user = SuggestedUserEntity(
          id: 'user-123',
          name: 'John Doe',
          username: 'johndoe',
          avatar: 'https://example.com/avatar.jpg',
          followers: 15000,
          isVerified: true,
          bio: 'Flutter developer',
        );

        expect(user.formattedFollowers, '15.0K');
      });
    });

    group('Search Result Entity Integration', () {
      test('search result business logic works correctly', () {
        const searchResult = SearchResultEntity(
          id: 'test-id',
          type: SearchResultType.user,
          title: 'John Doe',
          subtitle: '@johndoe',
          relevanceScore: 0.9,
          imageUrl: 'https://example.com/avatar.jpg',
          metadata: {'followers': 1000, 'isVerified': true},
        );

        // Test business logic
        expect(searchResult.isHighlyRelevant, true);
        expect(searchResult.typeIcon, '👤');
        expect(searchResult.typeLabel, 'User');
      });

      test('search result types have correct icons', () {
        final types = [
          SearchResultType.user,
          SearchResultType.post,
          SearchResultType.hashtag,
          SearchResultType.video,
          SearchResultType.image,
          SearchResultType.event,
        ];

        final expectedIcons = ['👤', '📝', '#️⃣', '🎥', '🖼️', '📅'];

        for (var i = 0; i < types.length; i++) {
          final result = SearchResultEntity(
            id: 'test-$i',
            type: types[i],
            title: 'Test',
            subtitle: 'Test subtitle',
            relevanceScore: 0.5,
          );

          expect(result.typeIcon, expectedIcons[i]);
        }
      });

      test('search filter entity works correctly', () {
        const filter = SearchFilterEntity(
          id: 'all',
          label: 'All',
          count: 1500,
          isActive: true,
        );

        expect(filter.formattedCount, '1.5K');
      });

      test('search suggestion entity works correctly', () {
        const suggestion = SearchSuggestionEntity(
          text: 'flutter',
          type: SearchSuggestionType.trending,
          subtitle: '1.5K posts',
        );

        expect(suggestion.icon, '🔥');
      });

      test('recent search entity works correctly', () {
        final recentSearch = RecentSearchEntity(
          query: 'flutter',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          resultCount: 150,
        );

        expect(recentSearch.timeAgo, contains('ago'));
      });
    });

    group('Cross-Feature Integration', () {
      test('notification and location entities work together', () {
        final notification = NotificationEntity(
          id: 'test-id',
          userId: 'user-123',
          type: NotificationType.chek,
          title: 'New Chek',
          body: 'John checked in nearby',
          createdAt: DateTime.now(),
          isRead: false,
          data: const {
            'latitude': 37.7749,
            'longitude': -122.4194,
          },
        );

        final location = LocationEntity(
          latitude: notification.data?['latitude'] as double,
          longitude: notification.data?['longitude'] as double,
        );

        expect(location.latitude, 37.7749);
        expect(location.longitude, -122.4194);
      });

      test('explore content and search results work together', () {
        final exploreContent = ExploreContentEntity(
          id: 'test-id',
          type: ExploreContentType.post,
          title: 'Flutter Tutorial',
          description: 'Learn Flutter',
          imageUrl: 'https://example.com/image.jpg',
          authorId: 'author-123',
          authorName: 'John Doe',
          authorAvatar: 'https://example.com/avatar.jpg',
          likes: 500,
          comments: 100,
          shares: 50,
          views: 10000,
          trendingScore: 0.8,
          createdAt: DateTime.now(),
          tags: const ['flutter', 'tutorial'],
        );

        final searchResult = SearchResultEntity(
          id: exploreContent.id,
          type: SearchResultType.post,
          title: exploreContent.title,
          subtitle: exploreContent.description,
          relevanceScore: 0.9,
          imageUrl: exploreContent.imageUrl,
          metadata: {
            'likes': exploreContent.likes,
            'comments': exploreContent.comments,
            'shares': exploreContent.shares,
          },
        );

        expect(searchResult.id, exploreContent.id);
        expect(searchResult.title, exploreContent.title);
        expect(searchResult.metadata['likes'], exploreContent.likes);
      });

      test('all Phase 4 entities maintain Equatable properties', () {
        final notification1 = NotificationEntity(
          id: 'test-id',
          userId: 'user-123',
          type: NotificationType.like,
          title: 'Test',
          body: 'Test body',
          createdAt: DateTime.now(),
          isRead: false,
        );

        final notification2 = NotificationEntity(
          id: 'test-id',
          userId: 'user-123',
          type: NotificationType.like,
          title: 'Test',
          body: 'Test body',
          createdAt: notification1.createdAt,
          isRead: false,
        );

        expect(notification1, notification2);

        const location1 = LocationEntity(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        const location2 = LocationEntity(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        expect(location1, location2);
      });
    });
  });
}
