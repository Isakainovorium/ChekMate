import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Bookmark Post Use Case - Domain Layer
///
/// Encapsulates the business logic for bookmarking/unbookmarking a post.
///
/// Clean Architecture: Domain Layer
class BookmarkPostUseCase {
  const BookmarkPostUseCase(this._repository);

  final PostsRepository _repository;

  /// Execute the bookmark post use case
  ///
  /// Parameters:
  /// - postId: ID of the post to bookmark
  /// - userId: ID of the user bookmarking the post
  ///
  /// Throws:
  /// - Exception if validation fails
  /// - Exception if bookmark operation fails
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
    return _repository.bookmarkPost(
      postId: postId,
      userId: userId,
    );
  }
}

/// Unbookmark Post Use Case - Domain Layer
///
/// Encapsulates the business logic for removing a bookmark from a post.
///
/// Clean Architecture: Domain Layer
class UnbookmarkPostUseCase {
  const UnbookmarkPostUseCase(this._repository);

  final PostsRepository _repository;

  /// Execute the unbookmark post use case
  ///
  /// Parameters:
  /// - postId: ID of the post to remove bookmark from
  /// - userId: ID of the user removing bookmark
  ///
  /// Throws:
  /// - Exception if validation fails
  /// - Exception if unbookmark operation fails
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
    return _repository.unbookmarkPost(
      postId: postId,
      userId: userId,
    );
  }
}

