import 'package:flutter_chekmate/features/search/domain/entities/search_result_entity.dart';

/// SearchRepository - Domain Repository Interface
///
/// Defines the contract for search data operations.
/// Implementations should handle search queries to Firebase/API.
abstract class SearchRepository {
  /// Search all content
  Future<List<SearchResultEntity>> searchAll(
    String query, {
    int limit = 20,
  });

  /// Search users
  Future<List<SearchResultEntity>> searchUsers(
    String query, {
    int limit = 20,
  });

  /// Search posts
  Future<List<SearchResultEntity>> searchPosts(
    String query, {
    int limit = 20,
  });

  /// Search hashtags
  Future<List<SearchResultEntity>> searchHashtags(
    String query, {
    int limit = 20,
  });

  /// Get search suggestions
  Future<List<SearchSuggestionEntity>> getSearchSuggestions(
    String query, {
    int limit = 5,
  });

  /// Get recent searches
  Future<List<RecentSearchEntity>> getRecentSearches({
    int limit = 10,
  });

  /// Save recent search
  Future<void> saveRecentSearch(String query);

  /// Clear recent searches
  Future<void> clearRecentSearches();

  /// Remove recent search
  Future<void> removeRecentSearch(String query);

  /// Get trending searches
  Future<List<String>> getTrendingSearches({
    int limit = 10,
  });
}

