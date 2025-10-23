import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/search/data/models/search_result_model.dart';
import 'package:flutter_chekmate/features/search/domain/entities/search_result_entity.dart';
import 'package:flutter_chekmate/features/search/domain/repositories/search_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SearchRepositoryImpl - Firebase Implementation of SearchRepository
///
/// Handles all search data operations with Firestore and local storage.
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = prefs;

  final FirebaseFirestore _firestore;
  final SharedPreferences? _prefs;

  static const String _recentSearchesKey = 'recent_searches';

  @override
  Future<List<SearchResultEntity>> searchAll(
    String query, {
    int limit = 20,
  }) async {
    try {
      final results = <SearchResultEntity>[];

      // Search users
      final users = await searchUsers(query, limit: limit ~/ 3);
      results.addAll(users);

      // Search posts
      final posts = await searchPosts(query, limit: limit ~/ 3);
      results.addAll(posts);

      // Search hashtags
      final hashtags = await searchHashtags(query, limit: limit ~/ 3);
      results.addAll(hashtags);

      // Sort by relevance score
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      return results.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to search all: $e');
    }
  }

  @override
  Future<List<SearchResultEntity>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('username',
              isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff',)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SearchResultModel(
          id: doc.id,
          type: SearchResultType.user,
          title: data['name'] as String? ?? '',
          subtitle: '@${data['username'] as String? ?? ''}',
          relevanceScore: _calculateRelevanceScore(
            query,
            data['username'] as String? ?? '',
          ),
          imageUrl: data['avatar'] as String?,
          metadata: {
            'followers': data['followers'] ?? 0,
            'isVerified': data['isVerified'] ?? false,
          },
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  @override
  Future<List<SearchResultEntity>> searchPosts(
    String query, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SearchResultModel(
          id: doc.id,
          type: SearchResultType.post,
          title: data['title'] as String? ?? '',
          subtitle: data['description'] as String? ?? '',
          relevanceScore: _calculateRelevanceScore(
            query,
            data['title'] as String? ?? '',
          ),
          imageUrl: data['imageUrl'] as String?,
          metadata: {
            'likes': data['likes'] ?? 0,
            'comments': data['comments'] ?? 0,
            'authorName': data['authorName'] ?? '',
          },
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }

  @override
  Future<List<SearchResultEntity>> searchHashtags(
    String query, {
    int limit = 20,
  }) async {
    try {
      final cleanQuery = query.replaceAll('#', '');

      final snapshot = await _firestore
          .collection('hashtags')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: cleanQuery)
          .where(FieldPath.documentId, isLessThanOrEqualTo: '$cleanQuery\uf8ff')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SearchResultModel(
          id: doc.id,
          type: SearchResultType.hashtag,
          title: '#${doc.id}',
          subtitle: '${data['postCount'] ?? 0} posts',
          relevanceScore: _calculateRelevanceScore(cleanQuery, doc.id),
          metadata: {
            'postCount': data['postCount'] ?? 0,
            'trendingScore': data['trendingScore'] ?? 0.0,
          },
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search hashtags: $e');
    }
  }

  @override
  Future<List<SearchSuggestionEntity>> getSearchSuggestions(
    String query, {
    int limit = 5,
  }) async {
    try {
      final suggestions = <SearchSuggestionEntity>[];

      // Get trending hashtags as suggestions
      final hashtagsSnapshot = await _firestore
          .collection('hashtags')
          .orderBy('trendingScore', descending: true)
          .limit(limit)
          .get();

      for (final doc in hashtagsSnapshot.docs) {
        final data = doc.data();
        suggestions.add(
          SearchSuggestionModel(
            text: '#${doc.id}',
            type: SearchSuggestionType.trending,
            subtitle: '${data['postCount'] ?? 0} posts',
          ),
        );
      }

      return suggestions;
    } catch (e) {
      throw Exception('Failed to get search suggestions: $e');
    }
  }

  @override
  Future<List<RecentSearchEntity>> getRecentSearches({
    int limit = 10,
  }) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];

      return recentSearches.take(limit).map((query) {
        return RecentSearchModel(
          query: query,
          timestamp:
              DateTime.now(), // Simplified - should store actual timestamp
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent searches: $e');
    }
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];

      // Remove if already exists
      recentSearches.remove(query);

      // Add to beginning
      recentSearches.insert(0, query);

      // Keep only last 10
      if (recentSearches.length > 10) {
        recentSearches.removeRange(10, recentSearches.length);
      }

      await prefs.setStringList(_recentSearchesKey, recentSearches);
    } catch (e) {
      throw Exception('Failed to save recent search: $e');
    }
  }

  @override
  Future<void> clearRecentSearches() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
    } catch (e) {
      throw Exception('Failed to clear recent searches: $e');
    }
  }

  @override
  Future<void> removeRecentSearch(String query) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];

      recentSearches.remove(query);

      await prefs.setStringList(_recentSearchesKey, recentSearches);
    } catch (e) {
      throw Exception('Failed to remove recent search: $e');
    }
  }

  @override
  Future<List<String>> getTrendingSearches({
    int limit = 10,
  }) async {
    try {
      // Get trending hashtags as trending searches
      final snapshot = await _firestore
          .collection('hashtags')
          .orderBy('trendingScore', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => '#${doc.id}').toList();
    } catch (e) {
      throw Exception('Failed to get trending searches: $e');
    }
  }

  /// Calculate relevance score based on query match
  double _calculateRelevanceScore(String query, String text) {
    final lowerQuery = query.toLowerCase();
    final lowerText = text.toLowerCase();

    if (lowerText == lowerQuery) {
      return 1.0; // Exact match
    } else if (lowerText.startsWith(lowerQuery)) {
      return 0.9; // Starts with query
    } else if (lowerText.contains(lowerQuery)) {
      return 0.7; // Contains query
    } else {
      return 0.5; // Partial match
    }
  }
}
