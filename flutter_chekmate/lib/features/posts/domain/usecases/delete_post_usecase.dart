import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Delete Post Use Case
/// Handles deleting posts with validation and business logic
class DeletePostUseCase {
  final PostsRepository _repository;

  DeletePostUseCase(this._repository);

  /// Execute delete post operation
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
    return await _repository.deletePost(
      postId: postId.trim(),
      userId: userId.trim(),
    );
  }
}
