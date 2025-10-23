import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Get Posts Use Case - Domain Layer
///
/// Encapsulates the business logic for retrieving posts.
///
/// Clean Architecture: Domain Layer
class GetPostsUseCase {
  const GetPostsUseCase(this._repository);

  final PostsRepository _repository;

  /// Execute the get posts use case
  ///
  /// Parameters:
  /// - limit: Maximum number of posts to retrieve (default: 20)
  /// - userId: Optional user ID to filter posts by specific user
  ///
  /// Returns: Stream of list of PostEntity
  Stream<List<PostEntity>> call({
    int limit = 20,
    String? userId,
  }) {
    // Business logic: Validate limit
    if (limit <= 0) {
      throw Exception('Limit must be greater than 0');
    }

    if (limit > 100) {
      throw Exception('Limit cannot exceed 100 posts');
    }

    // Delegate to repository
    return _repository.getPosts(
      limit: limit,
      userId: userId,
    );
  }
}

