import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';

/// Interest Matching Utilities
///
/// Provides algorithms for matching user interests with post tags
/// and calculating relevance scores for interest-based content discovery.
///
/// Scoring Algorithm:
/// - Base score: Number of shared interests between user and post
/// - Engagement multiplier: Boosts score based on post engagement (likes, comments, shares)
/// - Recency multiplier: Boosts score for newer posts
/// - Final score = (shared interests × 10) + (engagement score × 0.5) + (recency score × 0.3)
class InterestMatchingUtils {
  InterestMatchingUtils._();

  /// Calculate relevance score between user interests and post tags
  ///
  /// Parameters:
  /// - userInterests: List of user's selected interests
  /// - post: Post entity to score
  ///
  /// Returns:
  /// - Relevance score (0-100+)
  /// - Higher score = more relevant to user's interests
  static double calculateRelevanceScore({
    required List<String> userInterests,
    required PostEntity post,
  }) {
    // If post has no tags, return 0
    if (post.tags == null || post.tags!.isEmpty) {
      return 0.0;
    }

    // Calculate shared interests
    final sharedInterests = _getSharedInterests(
      userInterests: userInterests,
      postTags: post.tags!,
    );

    // Base score: 10 points per shared interest
    final baseScore = sharedInterests.length * 10.0;

    // Engagement score: Based on likes, comments, shares
    final engagementScore = _calculateEngagementScore(post);

    // Recency score: Based on post age
    final recencyScore = _calculateRecencyScore(post);

    // Final score = base + (engagement × 0.5) + (recency × 0.3)
    final finalScore = baseScore + (engagementScore * 0.5) + (recencyScore * 0.3);

    return finalScore;
  }

  /// Get shared interests between user and post
  ///
  /// Parameters:
  /// - userInterests: List of user's selected interests
  /// - postTags: List of post tags
  ///
  /// Returns:
  /// - Set of shared interests (case-insensitive)
  static Set<String> _getSharedInterests({
    required List<String> userInterests,
    required List<String> postTags,
  }) {
    // Convert to lowercase for case-insensitive comparison
    final userInterestsLower = userInterests.map((e) => e.toLowerCase()).toSet();
    final postTagsLower = postTags.map((e) => e.toLowerCase()).toSet();

    // Find intersection
    return userInterestsLower.intersection(postTagsLower);
  }

  /// Calculate engagement score based on likes, comments, shares
  ///
  /// Formula: (likes × 1) + (comments × 2) + (shares × 3)
  /// - Comments are worth 2× likes (more engagement)
  /// - Shares are worth 3× likes (highest engagement)
  ///
  /// Parameters:
  /// - post: Post entity
  ///
  /// Returns:
  /// - Engagement score (0-1000+)
  static double _calculateEngagementScore(PostEntity post) {
    final likesScore = post.likes * 1.0;
    final commentsScore = post.comments * 2.0;
    final sharesScore = post.shares * 3.0;

    return likesScore + commentsScore + sharesScore;
  }

  /// Calculate recency score based on post age
  ///
  /// Formula:
  /// - Posts < 1 hour old: 100 points
  /// - Posts < 6 hours old: 80 points
  /// - Posts < 24 hours old: 60 points
  /// - Posts < 7 days old: 40 points
  /// - Posts < 30 days old: 20 points
  /// - Posts > 30 days old: 10 points
  ///
  /// Parameters:
  /// - post: Post entity
  ///
  /// Returns:
  /// - Recency score (10-100)
  static double _calculateRecencyScore(PostEntity post) {
    final now = DateTime.now();
    final age = now.difference(post.createdAt);

    if (age.inHours < 1) {
      return 100.0;
    } else if (age.inHours < 6) {
      return 80.0;
    } else if (age.inHours < 24) {
      return 60.0;
    } else if (age.inDays < 7) {
      return 40.0;
    } else if (age.inDays < 30) {
      return 20.0;
    } else {
      return 10.0;
    }
  }

  /// Sort posts by relevance score (highest first)
  ///
  /// Parameters:
  /// - userInterests: List of user's selected interests
  /// - posts: List of posts to sort
  ///
  /// Returns:
  /// - Sorted list of posts (highest relevance first)
  static List<PostEntity> sortByRelevance({
    required List<String> userInterests,
    required List<PostEntity> posts,
  }) {
    // Calculate scores for all posts
    final postsWithScores = posts.map((post) {
      final score = calculateRelevanceScore(
        userInterests: userInterests,
        post: post,
      );
      return _PostWithScore(post: post, score: score);
    }).toList();

    // Sort by score (highest first)
    postsWithScores.sort((a, b) => b.score.compareTo(a.score));

    // Return sorted posts
    return postsWithScores.map((e) => e.post).toList();
  }

  /// Filter posts by minimum relevance score
  ///
  /// Parameters:
  /// - userInterests: List of user's selected interests
  /// - posts: List of posts to filter
  /// - minScore: Minimum relevance score (default: 10.0)
  ///
  /// Returns:
  /// - Filtered list of posts with score >= minScore
  static List<PostEntity> filterByRelevance({
    required List<String> userInterests,
    required List<PostEntity> posts,
    double minScore = 10.0,
  }) {
    return posts.where((post) {
      final score = calculateRelevanceScore(
        userInterests: userInterests,
        post: post,
      );
      return score >= minScore;
    }).toList();
  }

  /// Get top N most relevant posts
  ///
  /// Parameters:
  /// - userInterests: List of user's selected interests
  /// - posts: List of posts to filter
  /// - limit: Maximum number of posts to return (default: 20)
  ///
  /// Returns:
  /// - Top N most relevant posts
  static List<PostEntity> getTopRelevantPosts({
    required List<String> userInterests,
    required List<PostEntity> posts,
    int limit = 20,
  }) {
    final sorted = sortByRelevance(
      userInterests: userInterests,
      posts: posts,
    );

    return sorted.take(limit).toList();
  }

  /// Check if post matches any user interests
  ///
  /// Parameters:
  /// - userInterests: List of user's selected interests
  /// - post: Post entity to check
  ///
  /// Returns:
  /// - true if post has at least one matching interest
  static bool hasMatchingInterests({
    required List<String> userInterests,
    required PostEntity post,
  }) {
    if (post.tags == null || post.tags!.isEmpty) {
      return false;
    }

    final sharedInterests = _getSharedInterests(
      userInterests: userInterests,
      postTags: post.tags!,
    );

    return sharedInterests.isNotEmpty;
  }

  /// Get percentage of user interests matched by post
  ///
  /// Parameters:
  /// - userInterests: List of user's selected interests
  /// - post: Post entity
  ///
  /// Returns:
  /// - Percentage of user interests matched (0-100)
  static double getMatchPercentage({
    required List<String> userInterests,
    required PostEntity post,
  }) {
    if (userInterests.isEmpty || post.tags == null || post.tags!.isEmpty) {
      return 0.0;
    }

    final sharedInterests = _getSharedInterests(
      userInterests: userInterests,
      postTags: post.tags!,
    );

    return (sharedInterests.length / userInterests.length) * 100;
  }
}

/// Internal class to hold post with its relevance score
class _PostWithScore {
  const _PostWithScore({
    required this.post,
    required this.score,
  });

  final PostEntity post;
  final double score;
}

