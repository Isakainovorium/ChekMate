import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Like Post Use Case - Domain Layer
///
/// Encapsulates the business logic for liking/unliking a post.
///
/// Clean Architecture: Domain Layer
class LikePostUseCase {
  const LikePostUseCase(this._repository);

  final PostsRepository _repository;

  /// Execute the like post use case
  ///
  /// Parameters:
  /// - postId: ID of the post to like
  /// - userId: ID of the user liking the post
  ///
  /// Throws:
  /// - Exception if validation fails
  /// - Exception if like operation fails
  Future<void> call({
    required String postId,
    required String userId,
  }) async {
    // Business logic: Validate post ID
    if (postId.isEmpty) {
      throw Exception('Post ID cannot be empty');
    }

    // Business logic: Validate user ID
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Delegate to repository
    return _repository.likePost(
      postId: postId,
      userId: userId,
    );
  }
}

/// Unlike Post Use Case - Domain Layer
///
/// Encapsulates the business logic for unliking a post.
///
/// Clean Architecture: Domain Layer
class UnlikePostUseCase {
  const UnlikePostUseCase(this._repository);

  final PostsRepository _repository;

  /// Execute the unlike post use case
  ///
  /// Parameters:
  /// - postId: ID of the post to unlike
  /// - userId: ID of the user unliking the post
  ///
  /// Throws:
  /// - Exception if validation fails
  /// - Exception if unlike operation fails
  Future<void> call({
    required String postId,
    required String userId,
  }) async {
    // Business logic: Validate post ID
    if (postId.isEmpty) {
      throw Exception('Post ID cannot be empty');
    }

    // Business logic: Validate user ID
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Delegate to repository
    return _repository.unlikePost(
      postId: postId,
      userId: userId,
    );
  }
}

