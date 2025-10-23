import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Track Post View Use Case
///
/// Tracks when a user views a post and updates engagement metrics.
/// 
/// Engagement Formula:
/// engagementScore = (likes + comments*2 + shares*3 + views*0.1) / 100
///
/// Features:
/// - Increments view count
/// - Adds user to viewedBy list (max 100 most recent viewers)
/// - Calculates and updates engagement score
/// - Updates lastEngagementUpdate timestamp
///
/// Clean Architecture: Domain Layer
class TrackPostViewUseCase {
  const TrackPostViewUseCase(this._repository);

  final PostsRepository _repository;

  /// Track a post view
  ///
  /// Parameters:
  /// - postId: ID of the post being viewed
  /// - userId: ID of the user viewing the post
  ///
  /// Returns:
  /// - Updated PostEntity with new engagement metrics
  ///
  /// Throws:
  /// - Exception if tracking fails
  Future<PostEntity> call({
    required String postId,
    required String userId,
  }) async {
    // Get current post
    final post = await _repository.getPost(postId);

    // Don't track if user is viewing their own post
    if (post.userId == userId) {
      return post;
    }

    // Don't track if user already viewed this post (in current session)
    if (post.viewedBy.contains(userId)) {
      return post;
    }

    // Increment views
    final newViews = post.views + 1;

    // Add user to viewedBy list (keep last 100 viewers)
    final newViewedBy = List<String>.from(post.viewedBy);
    newViewedBy.add(userId);
    if (newViewedBy.length > 100) {
      newViewedBy.removeAt(0); // Remove oldest viewer
    }

    // Calculate engagement score
    // Formula: (likes + comments*2 + shares*3 + views*0.1) / 100
    final engagementScore = _calculateEngagementScore(
      likes: post.likes,
      comments: post.comments,
      shares: post.shares,
      views: newViews,
    );

    // Update post with new engagement metrics
    final updatedPost = await _repository.updatePostEngagement(
      postId: postId,
      views: newViews,
      viewedBy: newViewedBy,
      engagementScore: engagementScore,
    );

    return updatedPost;
  }

  /// Calculate engagement score
  ///
  /// Formula: (likes + comments*2 + shares*3 + views*0.1) / 100
  ///
  /// Parameters:
  /// - likes: Number of likes
  /// - comments: Number of comments
  /// - shares: Number of shares
  /// - views: Number of views
  ///
  /// Returns:
  /// - Engagement score as a double
  double _calculateEngagementScore({
    required int likes,
    required int comments,
    required int shares,
    required int views,
  }) {
    final score = (likes + (comments * 2) + (shares * 3) + (views * 0.1)) / 100;
    return double.parse(score.toStringAsFixed(2)); // Round to 2 decimal places
  }
}

