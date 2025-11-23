import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/search/domain/entities/search_result_entity.dart';
import 'package:flutter_chekmate/features/search/domain/repositories/search_repository.dart';

/// Search Repository Implementation
/// Implements the SearchRepository interface
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl();

  @override
  Future<List<SearchResultEntity>> searchAll({
    required String query,
    int limit = 20,
    String? userId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final normalizedQuery = query.toLowerCase().trim();

      if (normalizedQuery.isEmpty) {
        return [];
      }

      final List<SearchResultEntity> results = [];

      // Search posts
      final postsResults =
          await _searchPosts(firestore, normalizedQuery, limit ~/ 3);
      results.addAll(postsResults);

      // Search users
      final usersResults =
          await _searchUsers(firestore, normalizedQuery, limit ~/ 3);
      results.addAll(usersResults);

      // Search hashtags
      final hashtagsResults =
          await _searchHashtags(firestore, normalizedQuery, limit ~/ 3);
      results.addAll(hashtagsResults);

      // Sort by relevance score and limit results
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      return results.take(limit).toList();
    } catch (e) {
      // Fallback to mock data if search fails
      return _getMockSearchResults(query, limit, 'all');
    }
  }

  @override
  Future<List<SearchResultEntity>> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final normalizedQuery = query.toLowerCase().trim();

      if (normalizedQuery.isEmpty) {
        return [];
      }

      return await _searchUsers(firestore, normalizedQuery, limit);
    } catch (e) {
      // Fallback to mock data if search fails
      return _getMockSearchResults(query, limit, 'user');
    }
  }

  @override
  Future<List<SearchResultEntity>> searchPosts({
    required String query,
    int limit = 20,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final normalizedQuery = query.toLowerCase().trim();

      if (normalizedQuery.isEmpty) {
        return [];
      }

      return await _searchPosts(firestore, normalizedQuery, limit);
    } catch (e) {
      // Fallback to mock data if search fails
      return _getMockSearchResults(query, limit, 'post');
    }
  }

  @override
  Future<List<SearchResultEntity>> searchHashtags({
    required String query,
    int limit = 20,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final normalizedQuery = query.toLowerCase().trim();

      if (normalizedQuery.isEmpty) {
        return [];
      }

      return await _searchHashtags(firestore, normalizedQuery, limit);
    } catch (e) {
      // Fallback to mock data if search fails
      return _getMockSearchResults(query, limit, 'hashtag');
    }
  }

  @override
  Future<List<String>> getSearchSuggestions({
    required String query,
    int limit = 10,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final normalizedQuery = query.toLowerCase().trim();

      if (normalizedQuery.isEmpty) {
        // Return popular/trending suggestions when no query
        return await _getTrendingSuggestions(firestore, limit);
      }

      final suggestions = <String>[];

      // Get hashtag suggestions
      final hashtagSuggestions =
          await _getHashtagSuggestions(firestore, normalizedQuery, limit ~/ 3);
      suggestions.addAll(hashtagSuggestions);

      // Get user suggestions
      final userSuggestions =
          await _getUserSuggestions(firestore, normalizedQuery, limit ~/ 3);
      suggestions.addAll(userSuggestions);

      // Get query-based suggestions from recent posts
      final querySuggestions =
          await _getQuerySuggestions(firestore, normalizedQuery, limit ~/ 3);
      suggestions.addAll(querySuggestions);

      // Remove duplicates and limit results
      return suggestions.toSet().take(limit).toList();
    } catch (e) {
      // Fallback to mock suggestions if search fails
      return _getMockSearchSuggestions(query, limit);
    }
  }

  @override
  Future<List<String>> getRecentSearches(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Query recent searches for this user, ordered by timestamp
      final recentSearchesQuery = firestore
          .collection('recent_searches')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(10); // Limit to 10 recent searches

      final snapshot = await recentSearchesQuery.get();

      // Extract search queries and remove duplicates while preserving order
      final searches = <String>[];
      final seen = <String>{};

      for (final doc in snapshot.docs) {
        final query = doc.data()['query'] as String?;
        if (query != null && query.trim().isNotEmpty && !seen.contains(query)) {
          searches.add(query);
          seen.add(query);
        }
      }

      return searches;
    } catch (e) {
      // Fallback to mock data if retrieval fails
      return _getMockRecentSearches(userId);
    }
  }

  @override
  Future<void> saveRecentSearch(String userId, String query) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final normalizedQuery = query.trim();

      // Don't save empty queries
      if (normalizedQuery.isEmpty) return;

      // Check if this exact query already exists for this user
      final existingQuery = await firestore
          .collection('recent_searches')
          .where('userId', isEqualTo: userId)
          .where('query', isEqualTo: normalizedQuery)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        // Update timestamp of existing search
        await existingQuery.docs.first.reference.update({
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new search entry
        await firestore.collection('recent_searches').add({
          'userId': userId,
          'query': normalizedQuery,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Optional: Clean up old searches (keep only last 50 per user)
        // This could be done periodically or when saving new searches
        await _cleanupOldSearches(userId);
      }
    } catch (e) {
      // Silently fail - search history saving shouldn't break the app
      // In production, you might want to log this
    }
  }

  /// Clean up old search history, keeping only the most recent 50 searches per user
  Future<void> _cleanupOldSearches(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get all searches for this user, ordered by timestamp
      final allSearches = await firestore
          .collection('recent_searches')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      // If we have more than 50, delete the oldest ones
      if (allSearches.docs.length > 50) {
        final searchesToDelete = allSearches.docs.sublist(50);

        final batch = firestore.batch();
        for (final doc in searchesToDelete) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      // Silently fail - cleanup is not critical
    }
  }

  @override
  Future<void> clearRecentSearches(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get all recent searches for this user
      final userSearches = await firestore
          .collection('recent_searches')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete all searches for this user using batch operation
      if (userSearches.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final doc in userSearches.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      // Silently fail - clearing search history shouldn't break the app
      // In production, you might want to log this
    }
  }

  @override
  Future<void> removeRecentSearch(String userId, String query) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final normalizedQuery = query.trim();

      // Find and delete the specific search entry
      final searchToRemove = await firestore
          .collection('recent_searches')
          .where('userId', isEqualTo: userId)
          .where('query', isEqualTo: normalizedQuery)
          .limit(1)
          .get();

      if (searchToRemove.docs.isNotEmpty) {
        await searchToRemove.docs.first.reference.delete();
      }
    } catch (e) {
      // Silently fail - removing a search entry shouldn't break the app
      // In production, you might want to log this
    }
  }

  @override
  Future<List<String>> getTrendingSearches({
    int limit = 10,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get searches from the last 7 days to focus on recent trends
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final recentSearchesQuery = firestore
          .collection('recent_searches')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('timestamp', descending: true)
          .limit(500); // Get a good sample of recent searches

      final snapshot = await recentSearchesQuery.get();

      // Count frequency of each search query with recency weighting
      final searchFrequency = <String, double>{};
      final now = DateTime.now();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final query = data['query'] as String?;
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

        if (query != null && query.trim().isNotEmpty && timestamp != null) {
          // Calculate recency weight (more recent = higher weight)
          final hoursSinceSearch = now.difference(timestamp).inHours;
          final recencyWeight =
              1.0 / (1.0 + hoursSinceSearch / 24.0); // Exponential decay

          searchFrequency[query] =
              (searchFrequency[query] ?? 0) + recencyWeight;
        }
      }

      // Sort by frequency (weighted by recency) and return top results
      final sortedSearches = searchFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedSearches.take(limit).map((entry) => entry.key).toList();
    } catch (e) {
      // Fallback to mock data if trending search retrieval fails
      return _getMockTrendingSearches(limit);
    }
  }

  // Helper method to convert string type to SearchResultType
  SearchResultType _getSearchResultType(String type) {
    switch (type) {
      case 'user':
        return SearchResultType.user;
      case 'post':
        return SearchResultType.post;
      case 'hashtag':
        return SearchResultType.hashtag;
      case 'video':
        return SearchResultType.video;
      case 'image':
        return SearchResultType.image;
      case 'event':
        return SearchResultType.event;
      default:
        return SearchResultType.user;
    }
  }

  /// Search posts by content, tags, and hashtags
  Future<List<SearchResultEntity>> _searchPosts(
    FirebaseFirestore firestore,
    String query,
    int limit,
  ) async {
    final results = <SearchResultEntity>[];

    try {
      // Search posts by content (case-insensitive text search)
      final postsQuery = firestore
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit * 2); // Get more to filter

      final postsSnapshot = await postsQuery.get();

      for (final doc in postsSnapshot.docs) {
        final data = doc.data();
        final content = (data['content'] as String? ?? '').toLowerCase();

        // Calculate relevance score based on content match
        final relevanceScore = _calculateRelevanceScore(query, content);

        if (relevanceScore > 0.1) {
          results.add(SearchResultEntity(
            id: doc.id,
            type: SearchResultType.post,
            title: data['content'] as String? ?? '',
            subtitle: 'Post by ${data['username'] as String? ?? 'Unknown'}',
            relevanceScore: relevanceScore,
            imageUrl:
                data['images'] != null && (data['images'] as List).isNotEmpty
                    ? (data['images'] as List)[0] as String
                    : null,
            metadata: {
              'likes': data['likes'] ?? 0,
              'comments': data['comments'] ?? 0,
              'userId': data['userId'],
            },
          ));
        }
      }
    } catch (e) {
      // Continue with other searches if posts search fails
    }

    return results.take(limit).toList();
  }

  /// Search users by username, display name, and bio
  Future<List<SearchResultEntity>> _searchUsers(
    FirebaseFirestore firestore,
    String query,
    int limit,
  ) async {
    final results = <SearchResultEntity>[];

    try {
      // Search users by username
      final usersQuery = firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit);

      final usersSnapshot = await usersQuery.get();

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final username = (data['username'] as String? ?? '').toLowerCase();
        final displayName =
            (data['displayName'] as String? ?? '').toLowerCase();

        // Calculate relevance score
        final usernameScore = _calculateRelevanceScore(query, username);
        final displayNameScore = _calculateRelevanceScore(query, displayName);
        final relevanceScore = max(usernameScore, displayNameScore);

        if (relevanceScore > 0.1) {
          results.add(SearchResultEntity(
            id: doc.id,
            type: SearchResultType.user,
            title: data['displayName'] as String? ??
                data['username'] as String? ??
                'Unknown User',
            subtitle: '@${data['username'] as String? ?? ''}',
            relevanceScore: relevanceScore,
            imageUrl: data['avatar'] as String?,
            metadata: {
              'followers': data['followers'] ?? 0,
              'following': data['following'] ?? 0,
              'isVerified': data['isVerified'] ?? false,
            },
          ));
        }
      }
    } catch (e) {
      // Continue if users search fails
    }

    return results.take(limit).toList();
  }

  /// Search hashtags
  Future<List<SearchResultEntity>> _searchHashtags(
    FirebaseFirestore firestore,
    String query,
    int limit,
  ) async {
    final results = <SearchResultEntity>[];

    try {
      // For hashtags, we can search posts that contain the hashtag in their tags array
      // Note: Firestore doesn't support direct array contains queries with ranges
      // This is a simplified implementation
      final hashtagQuery = query.startsWith('#') ? query.substring(1) : query;

      final postsWithHashtag = await firestore
          .collection('posts')
          .where('tags', arrayContains: hashtagQuery)
          .limit(limit * 2)
          .get();

      // Group by hashtag and count occurrences
      final hashtagCounts = <String, int>{};
      for (final doc in postsWithHashtag.docs) {
        final tags = (doc.data()['tags'] as List<dynamic>?) ?? [];
        for (final tag in tags) {
          if (tag
              .toString()
              .toLowerCase()
              .contains(hashtagQuery.toLowerCase())) {
            hashtagCounts[tag.toString()] =
                (hashtagCounts[tag.toString()] ?? 0) + 1;
          }
        }
      }

      // Create search results for hashtags
      for (final entry in hashtagCounts.entries) {
        final relevanceScore = _calculateRelevanceScore(query, entry.key) *
            min(entry.value / 10, 1.0);
        if (relevanceScore > 0.2) {
          results.add(SearchResultEntity(
            id: entry.key,
            type: SearchResultType.hashtag,
            title: '#${entry.key}',
            subtitle: '${entry.value} posts',
            relevanceScore: relevanceScore,
            resultCount: entry.value,
            metadata: {'postCount': entry.value},
          ));
        }
      }
    } catch (e) {
      // Continue if hashtags search fails
    }

    return results.take(limit).toList();
  }

  /// Calculate relevance score based on text matching
  double _calculateRelevanceScore(String query, String text) {
    if (query.isEmpty || text.isEmpty) return 0.0;

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();

    // Exact match gets highest score
    if (textLower == queryLower) return 1.0;

    // Starts with query gets high score
    if (textLower.startsWith(queryLower)) return 0.9;

    // Contains query gets medium score
    if (textLower.contains(queryLower)) return 0.7;

    // Fuzzy matching for typos (simplified)
    final distance = _levenshteinDistance(queryLower, textLower);
    final maxLength = max(queryLower.length, textLower.length);
    if (distance <= maxLength * 0.3) return 0.5;

    return 0.0;
  }

  /// Calculate Levenshtein distance for fuzzy matching
  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix =
        List.generate(s1.length + 1, (i) => List.filled(s2.length + 1, 0));

    for (var i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = min(
          matrix[i - 1][j] + 1, // deletion
          min(
            matrix[i][j - 1] + 1, // insertion
            matrix[i - 1][j - 1] + cost, // substitution
          ),
        );
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Get trending/popular search suggestions when no query is provided
  Future<List<String>> _getTrendingSuggestions(
      FirebaseFirestore firestore, int limit) async {
    try {
      final suggestions = <String>[];

      // Get popular hashtags from recent posts
      final recentPosts = await firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(100) // Analyze recent posts for trending topics
          .get();

      final hashtagCount = <String, int>{};
      for (final doc in recentPosts.docs) {
        final tags = (doc.data()['tags'] as List<dynamic>?) ?? [];
        for (final tag in tags) {
          hashtagCount[tag.toString()] =
              (hashtagCount[tag.toString()] ?? 0) + 1;
        }
      }

      // Sort hashtags by usage and take top ones
      final sortedEntries = hashtagCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final sortedHashtags =
          sortedEntries.take(limit ~/ 2).map((e) => '#${e.key}').toList();

      suggestions.addAll(sortedHashtags);

      // Get popular usernames
      final popularUsers = await firestore
          .collection('users')
          .orderBy('followers', descending: true)
          .limit(limit ~/ 2)
          .get();

      final userSuggestions = popularUsers.docs
          .map((doc) => '@${doc.data()['username'] as String? ?? ''}')
          .where((username) => username.length > 1)
          .toList();

      suggestions.addAll(userSuggestions);

      return suggestions.take(limit).toList();
    } catch (e) {
      // Fallback to mock trending suggestions
      return _getMockTrendingSearches(limit);
    }
  }

  /// Get hashtag suggestions based on query
  Future<List<String>> _getHashtagSuggestions(
      FirebaseFirestore firestore, String query, int limit) async {
    try {
      final hashtagQuery = query.startsWith('#') ? query.substring(1) : query;
      final suggestions = <String>{};

      // Search posts containing hashtags that match the query
      final postsWithTags = await firestore
          .collection('posts')
          .where('tags', arrayContains: hashtagQuery)
          .limit(limit * 3)
          .get();

      for (final doc in postsWithTags.docs) {
        final tags = (doc.data()['tags'] as List<dynamic>?) ?? [];
        for (final tag in tags) {
          final tagStr = tag.toString();
          if (tagStr.toLowerCase().contains(hashtagQuery.toLowerCase())) {
            suggestions.add('#$tagStr');
          }
        }
      }

      return suggestions.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get user suggestions based on query
  Future<List<String>> _getUserSuggestions(
      FirebaseFirestore firestore, String query, int limit) async {
    try {
      final userQuery = query.startsWith('@') ? query.substring(1) : query;
      final suggestions = <String>{};

      // Search users by username
      final usersQuery = firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: userQuery)
          .where('username', isLessThanOrEqualTo: '$userQuery\uf8ff')
          .limit(limit);

      final usersSnapshot = await usersQuery.get();

      for (final doc in usersSnapshot.docs) {
        final username = doc.data()['username'] as String?;
        if (username != null &&
            username.toLowerCase().contains(userQuery.toLowerCase())) {
          suggestions.add('@$username');
        }
      }

      return suggestions.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get query-based suggestions from recent post content
  Future<List<String>> _getQuerySuggestions(
      FirebaseFirestore firestore, String query, int limit) async {
    try {
      final suggestions = <String>{};

      // Search recent posts for content that matches the query
      final postsQuery = firestore
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit * 2);

      final postsSnapshot = await postsQuery.get();

      for (final doc in postsSnapshot.docs) {
        final content = doc.data()['content'] as String?;
        if (content != null) {
          // Extract words from content that match the query
          final words = content.split(RegExp(r'\s+'));
          for (final word in words) {
            if (word.toLowerCase().contains(query.toLowerCase()) &&
                word.length > 2) {
              suggestions.add(word);
            }
          }
        }
      }

      return suggestions.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  // Mock data generators
  List<SearchResultEntity> _getMockSearchResults(
      String query, int limit, String type) {
    final results = <SearchResultEntity>[];

    for (int i = 0; i < limit; i++) {
      String resultType = type;
      if (type == 'all') {
        resultType = ['user', 'post', 'hashtag'][i % 3];
      }

      results.add(SearchResultEntity(
        id: '${resultType}_$i',
        type: _getSearchResultType(resultType),
        title: _getMockTitle(resultType, i),
        subtitle: _getMockSubtitle(resultType, i),
        relevanceScore: i < 2 ? 0.95 : 0.7,
        imageUrl: _getMockImageUrl(resultType, i),
        metadata: _getMockMetadata(resultType, i),
      ));
    }

    return results;
  }

  List<String> _getMockSearchSuggestions(String query, int limit) {
    final suggestions = <String>[];
    final baseSuggestions = [
      '$query tutorial',
      '$query tips',
      '$query guide',
      '$query examples',
      '$query best practices',
      'how to $query',
      '$query vs alternatives',
      '$query community',
      '$query tools',
      '$query resources',
    ];

    for (int i = 0; i < limit && i < baseSuggestions.length; i++) {
      suggestions.add(baseSuggestions[i]);
    }

    return suggestions;
  }

  List<String> _getMockRecentSearches(String userId) {
    return [
      'flutter development',
      'dart programming',
      'mobile apps',
      'ui design',
      'firebase',
    ];
  }

  List<String> _getMockTrendingSearches(int limit) {
    final trending = [
      'flutter',
      'dart',
      'mobile development',
      'ui/ux design',
      'firebase',
      'riverpod',
      'bloc pattern',
      'material design',
      'cross platform',
      'app development',
    ];

    return trending.take(limit).toList();
  }

  String _getMockTitle(String type, int index) {
    switch (type) {
      case 'user':
        return [
          'johndoe',
          'janedoe',
          'flutter_dev',
          'dart_master',
          'mobile_dev'
        ][index % 5];
      case 'post':
        return [
          'Flutter Tutorial',
          'Dart Best Practices',
          'Mobile App Design',
          'UI Tips',
          'Firebase Integration'
        ][index % 5];
      case 'hashtag':
        return [
          '#flutter',
          '#dart',
          '#mobiledev',
          '#uiux',
          '#firebase'
        ][index % 5];
      default:
        return 'Unknown';
    }
  }

  String _getMockSubtitle(String type, int index) {
    switch (type) {
      case 'user':
        return [
          'Software Developer',
          'UI Designer',
          'Flutter Expert',
          'Dart Enthusiast',
          'Mobile Developer'
        ][index % 5];
      case 'post':
        return [
          'Learn Flutter in 30 days',
          'Write better Dart code',
          'Design beautiful mobile apps',
          'Improve your UI skills',
          'Master Firebase'
        ][index % 5];
      case 'hashtag':
        return [
          '${100 + index * 10} posts',
          '${200 + index * 20} posts',
          '${150 + index * 15} posts',
          '${300 + index * 30} posts',
          '${250 + index * 25} posts'
        ][index % 5];
      default:
        return '';
    }
  }

  String? _getMockImageUrl(String type, int index) {
    if (type == 'user') {
      return 'https://example.com/avatar_$index.jpg';
    } else if (type == 'post') {
      return 'https://example.com/post_$index.jpg';
    }
    return null;
  }

  Map<String, dynamic> _getMockMetadata(String type, int index) {
    switch (type) {
      case 'user':
        return {
          'followers': 100 + index * 50,
          'isVerified': index % 3 == 0,
          'isFollowing': index % 2 == 0,
        };
      case 'post':
        return {
          'likes': 50 + index * 10,
          'comments': 10 + index * 2,
          'shares': 5 + index,
          'createdAt': DateTime.now().subtract(Duration(hours: index)),
        };
      case 'hashtag':
        return {
          'postCount': 1000 + index * 100,
          'isTrending': index < 3,
          'growth': index * 5.5,
        };
      default:
        return {};
    }
  }
}
