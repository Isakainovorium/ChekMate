import 'dart:typed_data';

import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';

/// Posts Repository Interface
/// Defines the contract for post-related data operations
abstract class PostsRepository {
  /// Get posts for the feed
  Future<List<PostEntity>> getFeedPosts({
    required String userId,
    int limit = 20,
  });

  /// Get posts by user
  Future<List<PostEntity>> getUserPosts({
    required String userId,
    int limit = 20,
  });

  /// Get a single post by ID
  Future<PostEntity?> getPostById(String postId);

  /// Get trending posts
  Future<List<PostEntity>> getTrendingPosts({
    int limit = 20,
  });

  /// Get posts from users the current user follows
  Future<List<PostEntity>> getFollowingPosts({
    required String userId,
    int limit = 20,
  });

  /// Get explore posts based on interests
  Future<List<PostEntity>> getExplorePosts({
    required List<String> interests,
    int limit = 20,
  });

  /// Get bookmarked posts for a user
  Future<List<PostEntity>> getBookmarkedPosts({
    required String userId,
    int limit = 20,
  });

  /// Create a new post
  Future<PostEntity> createPost({
    required String userId,
    required String username,
    required String userAvatar,
    required String content,
    List<Uint8List>? images,
    Uint8List? video,
    List<String>? tags,
    String? location,
  });

  /// Like a post
  Future<void> likePost({
    required String postId,
    required String userId,
  });

  /// Unlike a post
  Future<void> unlikePost({
    required String postId,
    required String userId,
  });

  /// Bookmark a post
  Future<void> bookmarkPost({
    required String postId,
    required String userId,
  });

  /// Remove bookmark from a post
  Future<void> unbookmarkPost({
    required String postId,
    required String userId,
  });

  /// Share a post
  Future<void> sharePost({
    required String postId,
    required String userId,
  });

  /// Delete a post
  Future<void> deletePost({
    required String postId,
    required String userId,
  });

  /// Report a post
  Future<void> reportPost({
    required String postId,
    required String userId,
    required String reason,
  });
}
