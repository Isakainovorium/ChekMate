import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Delete Post Use Case - Domain Layer
///
/// Encapsulates the business logic for deleting a post.
///
/// Clean Architecture: Domain Layer
class DeletePostUseCase {
  const DeletePostUseCase(this._repository);

  final PostsRepository _repository;

  /// Execute the delete post use case
  ///
  /// Parameters:
  /// - postId: ID of the post to delete
  /// - userId: ID of the user deleting the post (must be post author)
  ///
  /// Throws:
  /// - Exception if validation fails
  /// - Exception if user is not authorized
  /// - Exception if deletion fails
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
    // Repository will check if user is authorized to delete
    return _repository.deletePost(
      postId: postId,
      userId: userId,
    );
  }
}

