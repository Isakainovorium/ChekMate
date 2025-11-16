import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Bookmark Post Use Case
/// Handles bookmarking posts with validation and business logic
class BookmarkPostUseCase {
  final PostsRepository _repository;

  BookmarkPostUseCase(this._repository);

  /// Execute bookmark post operation
  Future<void> call({
    required String postId,
    required String userId,
  }) async {
    // Validate postId
    if (postId.trim().isEmpty) {
      throw Exception('Post ID cannot be empty');
    }

    // Validate userId
    if (userId.trim().isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Call repository
    return await _repository.bookmarkPost(
      postId: postId.trim(),
      userId: userId.trim(),
    );
  }
}

/// Unbookmark Post Use Case
/// Handles removing bookmarks from posts with validation and business logic
class UnbookmarkPostUseCase {
  final PostsRepository _repository;

  UnbookmarkPostUseCase(this._repository);

  /// Execute unbookmark post operation
  Future<void> call({
    required String postId,
    required String userId,
  }) async {
    // Validate postId
    if (postId.trim().isEmpty) {
      throw Exception('Post ID cannot be empty');
    }

    // Validate userId
    if (userId.trim().isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Call repository
    return await _repository.unbookmarkPost(
      postId: postId.trim(),
      userId: userId.trim(),
    );
  }
}
