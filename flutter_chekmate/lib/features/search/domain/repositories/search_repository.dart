import 'package:flutter_chekmate/features/search/domain/entities/search_result_entity.dart';

/// Search Repository Interface
/// Defines the contract for search-related data operations
abstract class SearchRepository {
  /// Search across all content types
  Future<List<SearchResultEntity>> searchAll({
    required String query,
    int limit = 20,
    String? userId,
  });

  /// Search for users
  Future<List<SearchResultEntity>> searchUsers({
    required String query,
    int limit = 20,
  });

  /// Search for posts
  Future<List<SearchResultEntity>> searchPosts({
    required String query,
    int limit = 20,
  });

  /// Search for hashtags
  Future<List<SearchResultEntity>> searchHashtags({
    required String query,
    int limit = 20,
  });

  /// Get search suggestions based on query
  Future<List<String>> getSearchSuggestions({
    required String query,
    int limit = 10,
  });

  /// Get recent searches for a user
  Future<List<String>> getRecentSearches(String userId);

  /// Save a recent search for a user
  Future<void> saveRecentSearch(String userId, String query);

  /// Clear all recent searches for a user
  Future<void> clearRecentSearches(String userId);

  /// Remove a specific recent search for a user
  Future<void> removeRecentSearch(String userId, String query);

  /// Get trending search terms
  Future<List<String>> getTrendingSearches({
    int limit = 10,
  });
}
