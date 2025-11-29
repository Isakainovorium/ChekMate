import 'package:flutter_chekmate/features/explore/domain/entities/explore_content_entity.dart';

/// Explore Repository Interface
/// Defines the contract for explore-related data operations
abstract class ExploreRepository {
  /// Get trending content
  Future<List<ExploreContentEntity>> getTrendingContent({
    int limit = 20,
    String? category,
  });

  /// Get popular content
  Future<List<ExploreContentEntity>> getPopularContent({
    int limit = 20,
    String? category,
  });

  /// Get trending hashtags
  Future<List<HashtagEntity>> getTrendingHashtags({
    int limit = 10,
  });

  /// Get suggested users
  Future<List<SuggestedUserEntity>> getSuggestedUsers({
    int limit = 10,
    String? forUserId,
  });

  /// Get content by hashtag
  Future<List<ExploreContentEntity>> getContentByHashtag(
    String hashtag, {
    int limit = 20,
  });

  /// Get content by category
  Future<List<ExploreContentEntity>> getContentByCategory(
    String category, {
    int limit = 20,
  });

  /// Search content
  Future<List<ExploreContentEntity>> searchContent(
    String query, {
    int limit = 20,
  });

  /// Get explore statistics
  Future<Map<String, dynamic>> getExploreStats();
}
