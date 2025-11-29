import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Like Post Use Case
/// Handles liking posts with validation and business logic
class LikePostUseCase {
  final PostsRepository _repository;

  LikePostUseCase(this._repository);

  /// Execute like post operation
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
    return await _repository.likePost(
      postId: postId.trim(),
      userId: userId.trim(),
    );
  }
}

/// Unlike Post Use Case
/// Handles unliking posts with validation and business logic
class UnlikePostUseCase {
  final PostsRepository _repository;

  UnlikePostUseCase(this._repository);

  /// Execute unlike post operation
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
    return await _repository.unlikePost(
      postId: postId.trim(),
      userId: userId.trim(),
    );
  }
}
