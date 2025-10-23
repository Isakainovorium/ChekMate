import 'package:flutter_chekmate/core/utils/interest_matching_utils.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Get Interest-Based Feed Use Case - Domain Layer
///
/// Retrieves posts matching user's interests with relevance scoring.
///
/// Algorithm:
/// 1. Query posts matching any user interests (Firestore array-contains-any)
/// 2. Calculate relevance score for each post
/// 3. Sort by relevance score (highest first)
/// 4. Return top N posts
///
/// Relevance Scoring:
/// - Base score: Number of shared interests × 10
/// - Engagement multiplier: (likes + comments×2 + shares×3) × 0.5
/// - Recency multiplier: Age-based score (100 for <1h, 10 for >30d) × 0.3
///
/// Clean Architecture: Domain Layer
class GetInterestBasedFeedUseCase {
  const GetInterestBasedFeedUseCase(this._repository);

  final PostsRepository _repository;

  /// Execute the use case
  ///
  /// Parameters:
  /// - userInterests: List of user's selected interests
  /// - limit: Maximum number of posts to return (default: 20)
  /// - minRelevanceScore: Minimum relevance score to include (default: 10.0)
  ///
  /// Returns:
  /// - List of posts sorted by relevance score (highest first)
  ///
  /// Throws:
  /// - Exception if query fails
  Future<List<PostEntity>> call({
    required List<String> userInterests,
    int limit = 20,
    double minRelevanceScore = 10.0,
  }) async {
    // Validate inputs
    if (userInterests.isEmpty) {
      return [];
    }

    // Query posts matching user interests
    // Firestore will return posts where tags array contains any of the interests
    final posts = await _repository.getPostsByInterests(
      interests: userInterests,
      limit: limit * 2, // Fetch 2x limit to allow for filtering and sorting
    );

    // If no posts found, return empty list
    if (posts.isEmpty) {
      return [];
    }

    // Filter posts by minimum relevance score
    final relevantPosts = InterestMatchingUtils.filterByRelevance(
      userInterests: userInterests,
      posts: posts,
      minScore: minRelevanceScore,
    );

    // Sort by relevance score (highest first)
    final sortedPosts = InterestMatchingUtils.sortByRelevance(
      userInterests: userInterests,
      posts: relevantPosts,
    );

    // Return top N posts
    return sortedPosts.take(limit).toList();
  }

  /// Get posts with detailed relevance information
  ///
  /// Returns posts with their relevance scores for debugging/analytics
  ///
  /// Parameters:
  /// - userInterests: List of user's selected interests
  /// - limit: Maximum number of posts to return (default: 20)
  ///
  /// Returns:
  /// - List of PostWithRelevance objects
  Future<List<PostWithRelevance>> callWithScores({
    required List<String> userInterests,
    int limit = 20,
  }) async {
    // Validate inputs
    if (userInterests.isEmpty) {
      return [];
    }

    // Query posts matching user interests
    final posts = await _repository.getPostsByInterests(
      interests: userInterests,
      limit: limit * 2,
    );

    // If no posts found, return empty list
    if (posts.isEmpty) {
      return [];
    }

    // Calculate scores for all posts
    final postsWithScores = posts.map((post) {
      final score = InterestMatchingUtils.calculateRelevanceScore(
        userInterests: userInterests,
        post: post,
      );
      final matchPercentage = InterestMatchingUtils.getMatchPercentage(
        userInterests: userInterests,
        post: post,
      );
      return PostWithRelevance(
        post: post,
        relevanceScore: score,
        matchPercentage: matchPercentage,
      );
    }).toList();

    // Sort by relevance score (highest first)
    postsWithScores.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    // Return top N posts
    return postsWithScores.take(limit).toList();
  }
}

/// Post with relevance information
///
/// Used for debugging and analytics to understand why posts were ranked
class PostWithRelevance {
  const PostWithRelevance({
    required this.post,
    required this.relevanceScore,
    required this.matchPercentage,
  });

  final PostEntity post;
  final double relevanceScore;
  final double matchPercentage;

  @override
  String toString() {
    return 'PostWithRelevance(postId: ${post.id}, score: $relevanceScore, match: ${matchPercentage.toStringAsFixed(1)}%)';
  }
}

