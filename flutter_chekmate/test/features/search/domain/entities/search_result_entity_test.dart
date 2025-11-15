import 'package:flutter_chekmate/features/search/domain/entities/search_result_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchResultEntity', () {
    late SearchResultEntity searchResult;

    setUp(() {
      searchResult = const SearchResultEntity(
        id: 'test-id',
        type: SearchResultType.user,
        title: 'John Doe',
        subtitle: '@johndoe',
        relevanceScore: 0.9,
        imageUrl: 'https://example.com/avatar.jpg',
        metadata: {'followers': 1000, 'isVerified': true},
      );
    });

    group('isHighlyRelevant getter', () {
      test('returns true when relevance score > 0.8', () {
        final highlyRelevant = searchResult.copyWith(relevanceScore: 0.9);
        expect(highlyRelevant.isHighlyRelevant, true);
      });

      test('returns false when relevance score <= 0.8', () {
        final notHighlyRelevant = searchResult.copyWith(relevanceScore: 0.8);
        expect(notHighlyRelevant.isHighlyRelevant, false);
      });

      test('returns false when relevance score is 0', () {
        final zeroRelevance = searchResult.copyWith(relevanceScore: 0.0);
        expect(zeroRelevance.isHighlyRelevant, false);
      });

      test('returns true when relevance score is 1.0', () {
        final perfectMatch = searchResult.copyWith(relevanceScore: 1.0);
        expect(perfectMatch.isHighlyRelevant, true);
      });
    });

    group('typeIcon getter', () {
      test('returns correct icon for user type', () {
        final userResult = searchResult.copyWith(type: SearchResultType.user);
        expect(userResult.typeIcon, '👤');
      });

      test('returns correct icon for post type', () {
        final postResult = searchResult.copyWith(type: SearchResultType.post);
        expect(postResult.typeIcon, '📝');
      });

      test('returns correct icon for hashtag type', () {
        final hashtagResult =
            searchResult.copyWith(type: SearchResultType.hashtag);
        expect(hashtagResult.typeIcon, '#️⃣');
      });

      test('returns correct icon for video type', () {
        final videoResult = searchResult.copyWith(type: SearchResultType.video);
        expect(videoResult.typeIcon, '🎥');
      });

      test('returns correct icon for image type', () {
        final imageResult = searchResult.copyWith(type: SearchResultType.image);
        expect(imageResult.typeIcon, '🖼️');
      });

      test('returns correct icon for event type', () {
        final eventResult = searchResult.copyWith(type: SearchResultType.event);
        expect(eventResult.typeIcon, '📅');
      });
    });

    group('typeLabel getter', () {
      test('returns correct label for user type', () {
        final userResult = searchResult.copyWith(type: SearchResultType.user);
        expect(userResult.typeLabel, 'User');
      });

      test('returns correct label for post type', () {
        final postResult = searchResult.copyWith(type: SearchResultType.post);
        expect(postResult.typeLabel, 'Post');
      });

      test('returns correct label for hashtag type', () {
        final hashtagResult =
            searchResult.copyWith(type: SearchResultType.hashtag);
        expect(hashtagResult.typeLabel, 'Hashtag');
      });

      test('returns correct label for video type', () {
        final videoResult = searchResult.copyWith(type: SearchResultType.video);
        expect(videoResult.typeLabel, 'Video');
      });

      test('returns correct label for image type', () {
        final imageResult = searchResult.copyWith(type: SearchResultType.image);
        expect(imageResult.typeLabel, 'Image');
      });

      test('returns correct label for event type', () {
        final eventResult = searchResult.copyWith(type: SearchResultType.event);
        expect(eventResult.typeLabel, 'Event');
      });
    });

    group('Equatable', () {
      test('two search results with same properties are equal', () {
        const result1 = SearchResultEntity(
          id: 'test-id',
          type: SearchResultType.user,
          title: 'John Doe',
          subtitle: '@johndoe',
          relevanceScore: 0.9,
        );

        const result2 = SearchResultEntity(
          id: 'test-id',
          type: SearchResultType.user,
          title: 'John Doe',
          subtitle: '@johndoe',
          relevanceScore: 0.9,
        );

        expect(result1, result2);
      });

      test('two search results with different properties are not equal', () {
        final result1 = searchResult.copyWith(id: 'id-1');
        final result2 = searchResult.copyWith(id: 'id-2');

        expect(result1, isNot(result2));
      });
    });

    group('copyWith', () {
      test('creates new instance with updated properties', () {
        final updatedResult = searchResult.copyWith(
          title: 'Updated Title',
          relevanceScore: 0.95,
        );

        expect(updatedResult.title, 'Updated Title');
        expect(updatedResult.relevanceScore, 0.95);
        expect(updatedResult.id, searchResult.id);
        expect(updatedResult.type, searchResult.type);
      });

      test('preserves original properties when not specified', () {
        final updatedResult = searchResult.copyWith(relevanceScore: 0.95);

        expect(updatedResult.title, searchResult.title);
        expect(updatedResult.subtitle, searchResult.subtitle);
        expect(updatedResult.type, searchResult.type);
      });
    });

    group('metadata handling', () {
      test('handles empty metadata', () {
        final emptyMetadata = searchResult.copyWith(metadata: {});
        expect(emptyMetadata.metadata, isEmpty);
      });

      test('handles complex metadata', () {
        final complexMetadata = searchResult.copyWith(
          metadata: {
            'followers': 1000,
            'following': 500,
            'posts': 250,
            'isVerified': true,
            'bio': 'Test bio',
          },
        );

        expect(complexMetadata.metadata['followers'], 1000);
        expect(complexMetadata.metadata['following'], 500);
        expect(complexMetadata.metadata['posts'], 250);
        expect(complexMetadata.metadata['isVerified'], true);
        expect(complexMetadata.metadata['bio'], 'Test bio');
      });
    });
  });

  group('SearchFilterEntity', () {
    late SearchFilterEntity filter;

    setUp(() {
      filter = const SearchFilterEntity(
        id: 'all',
        label: 'All',
        count: 1500,
        isActive: true,
      );
    });

    group('formattedCount getter', () {
      test('formats count correctly for small numbers', () {
        final smallFilter = filter.copyWith(count: 500);
        expect(smallFilter.formattedCount, '500');
      });

      test('formats count correctly for thousands', () {
        expect(filter.formattedCount, '1.5K');
      });

      test('formats count correctly for millions', () {
        final largeFilter = filter.copyWith(count: 2500000);
        expect(largeFilter.formattedCount, '2.5M');
      });

      test('handles zero count', () {
        final zeroFilter = filter.copyWith(count: 0);
        expect(zeroFilter.formattedCount, '0');
      });
    });

    group('Equatable', () {
      test('two filters with same properties are equal', () {
        const filter1 = SearchFilterEntity(
          id: 'all',
          label: 'All',
          count: 100,
          isActive: true,
        );

        const filter2 = SearchFilterEntity(
          id: 'all',
          label: 'All',
          count: 100,
          isActive: true,
        );

        expect(filter1, filter2);
      });

      test('two filters with different properties are not equal', () {
        final filter1 = filter.copyWith(id: 'all');
        final filter2 = filter.copyWith(id: 'users');

        expect(filter1, isNot(filter2));
      });
    });
  });

  group('SearchSuggestionEntity', () {
    group('icon getter', () {
      test('returns correct icon for recent type', () {
        const recentSuggestion = SearchSuggestionEntity(
          text: 'flutter',
          type: SearchSuggestionType.recent,
        );
        expect(recentSuggestion.icon, '🕐');
      });

      test('returns correct icon for trending type', () {
        const trendingSuggestion = SearchSuggestionEntity(
          text: 'flutter',
          type: SearchSuggestionType.trending,
        );
        expect(trendingSuggestion.icon, '🔥');
      });

      test('returns correct icon for popular type', () {
        const popularSuggestion = SearchSuggestionEntity(
          text: 'flutter',
          type: SearchSuggestionType.popular,
        );
        expect(popularSuggestion.icon, '⭐');
      });

      test('returns correct icon for category type', () {
        const categorySuggestion = SearchSuggestionEntity(
          text: 'flutter',
          type: SearchSuggestionType.category,
        );
        expect(categorySuggestion.icon, '📁');
      });
    });

    group('Equatable', () {
      test('two suggestions with same properties are equal', () {
        const suggestion1 = SearchSuggestionEntity(
          text: 'flutter',
          type: SearchSuggestionType.trending,
        );

        const suggestion2 = SearchSuggestionEntity(
          text: 'flutter',
          type: SearchSuggestionType.trending,
        );

        expect(suggestion1, suggestion2);
      });

      test('two suggestions with different properties are not equal', () {
        const suggestion1 = SearchSuggestionEntity(
          text: 'flutter',
          type: SearchSuggestionType.trending,
        );
        const suggestion2 = SearchSuggestionEntity(
          text: 'dart',
          type: SearchSuggestionType.trending,
        );

        expect(suggestion1, isNot(suggestion2));
      });
    });
  });

  group('RecentSearchEntity', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now().subtract(const Duration(hours: 2));
    });

    group('timeAgo getter', () {
      test('returns minutes for searches less than 1 hour old', () {
        final minutes = RecentSearchEntity(
          query: 'flutter',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        expect(minutes.timeAgo, '5m ago');
      });

      test('returns hours for searches less than 24 hours old', () {
        final hours = RecentSearchEntity(
          query: 'flutter',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        );
        expect(hours.timeAgo, '3h ago');
      });

      test('returns days for searches less than 7 days old', () {
        final days = RecentSearchEntity(
          query: 'flutter',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        );
        expect(days.timeAgo, '3d ago');
      });

      test('returns weeks for searches more than 7 days old', () {
        final weeks = RecentSearchEntity(
          query: 'flutter',
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
        );
        expect(weeks.timeAgo, '2w ago');
      });
    });

    group('Equatable', () {
      test('two recent searches with same properties are equal', () {
        final search1 = RecentSearchEntity(
          query: 'flutter',
          timestamp: testDate,
          resultCount: 100,
        );

        final search2 = RecentSearchEntity(
          query: 'flutter',
          timestamp: testDate,
          resultCount: 100,
        );

        expect(search1, search2);
      });

      test('two recent searches with different properties are not equal', () {
        final search1 = RecentSearchEntity(
          query: 'flutter',
          timestamp: testDate,
          resultCount: 100,
        );
        final search2 = RecentSearchEntity(
          query: 'dart',
          timestamp: testDate,
          resultCount: 100,
        );

        expect(search1, isNot(search2));
      });
    });
  });
}
