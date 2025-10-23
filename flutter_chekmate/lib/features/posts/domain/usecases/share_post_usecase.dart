import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Share Post Use Case - Domain Layer
///
/// Encapsulates the business logic for sharing a post.
///
/// Clean Architecture: Domain Layer
class SharePostUseCase {
  const SharePostUseCase(this._repository);

  final PostsRepository _repository;

  /// Execute the share post use case
  ///
  /// Parameters:
  /// - postId: ID of the post to share
  /// - userId: ID of the user sharing the post
  ///
  /// Throws:
  /// - Exception if validation fails
  /// - Exception if share operation fails
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
    return _repository.sharePost(
      postId: postId,
      userId: userId,
    );
  }
}

