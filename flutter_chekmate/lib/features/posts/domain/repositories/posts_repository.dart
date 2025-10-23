import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';

/// Posts Repository Interface - Domain Layer
///
/// This abstract class defines the contract for posts operations.
/// It has no implementation details - only the interface that the domain layer expects.
///
/// The data layer will provide the concrete implementation.
///
/// Clean Architecture: Domain Layer
abstract class PostsRepository {
  /// Create a new post
  ///
  /// Parameters:
  /// - userId: ID of the user creating the post
  /// - username: Username of the post author
  /// - userAvatar: Avatar URL of the post author
  /// - content: Text content of the post
  /// - images: Optional list of image data to upload
  /// - video: Optional video data to upload
  /// - location: Optional location tag (display name)
  /// - tags: Optional list of hashtags
  /// - coordinates: Optional GPS coordinates for location-based discovery
  ///
  /// Returns: PostEntity of the created post
  ///
  /// Throws:
  /// - Exception if post creation fails
  /// - Exception if media upload fails
  Future<PostEntity> createPost({
    required String userId,
    required String username,
    required String userAvatar,
    required String content,
    List<Uint8List>? images,
    Uint8List? video,
    String? location,
    List<String>? tags,
    GeoPoint? coordinates,
  });

  /// Get a single post by ID
  ///
  /// Parameters:
  /// - postId: ID of the post to retrieve
  ///
  /// Returns: PostEntity
  ///
  /// Throws:
  /// - Exception if post not found
  /// - Exception if retrieval fails
  Future<PostEntity> getPost(String postId);

  /// Get posts feed stream
  ///
  /// Parameters:
  /// - limit: Maximum number of posts to retrieve (default: 20)
  /// - userId: Optional user ID to filter posts by specific user
  ///
  /// Returns: Stream of list of PostEntity
  ///
  /// The stream will emit new values whenever posts are added, updated, or deleted
  Stream<List<PostEntity>> getPosts({
    int limit = 20,
    String? userId,
  });

  /// Get posts for a specific user
  ///
  /// Parameters:
  /// - userId: ID of the user whose posts to retrieve
  /// - limit: Maximum number of posts to retrieve (default: 20)
  ///
  /// Returns: Stream of list of PostEntity
  Stream<List<PostEntity>> getUserPosts({
    required String userId,
    int limit = 20,
  });

  /// Get posts near a location using geohash
  ///
  /// Parameters:
  /// - center: GeoPoint representing the center location
  /// - radiusKm: Radius in kilometers to search within
  /// - limit: Maximum number of posts to retrieve (default: 20)
  ///
  /// Returns: Future<List<PostEntity>> of posts within the specified radius
  ///
  /// Throws:
  /// - Exception if geospatial query fails
  Future<List<PostEntity>> getPostsNearLocation({
    required GeoPoint center,
    required double radiusKm,
    int limit = 20,
  });

  /// Get posts by user interests
  ///
  /// Retrieves posts that match any of the user's interests.
  ///
  /// Parameters:
  /// - interests: List of user's interests to match
  /// - limit: Maximum number of posts to retrieve (default: 20)
  ///
  /// Returns: Future<List<PostEntity>> of posts matching user interests
  ///
  /// Throws:
  /// - Exception if query fails
  Future<List<PostEntity>> getPostsByInterests({
    required List<String> interests,
    int limit = 20,
  });

  /// Like a post
  ///
  /// Parameters:
  /// - postId: ID of the post to like
  /// - userId: ID of the user liking the post
  ///
  /// Throws:
  /// - Exception if post not found
  /// - Exception if like operation fails
  Future<void> likePost({
    required String postId,
    required String userId,
  });

  /// Unlike a post
  ///
  /// Parameters:
  /// - postId: ID of the post to unlike
  /// - userId: ID of the user unliking the post
  ///
  /// Throws:
  /// - Exception if post not found
  /// - Exception if unlike operation fails
  Future<void> unlikePost({
    required String postId,
    required String userId,
  });

  /// Bookmark a post
  ///
  /// Parameters:
  /// - postId: ID of the post to bookmark
  /// - userId: ID of the user bookmarking the post
  ///
  /// Throws:
  /// - Exception if post not found
  /// - Exception if bookmark operation fails
  Future<void> bookmarkPost({
    required String postId,
    required String userId,
  });

  /// Remove bookmark from a post
  ///
  /// Parameters:
  /// - postId: ID of the post to remove bookmark from
  /// - userId: ID of the user removing bookmark
  ///
  /// Throws:
  /// - Exception if post not found
  /// - Exception if unbookmark operation fails
  Future<void> unbookmarkPost({
    required String postId,
    required String userId,
  });

  /// Delete a post
  ///
  /// Parameters:
  /// - postId: ID of the post to delete
  /// - userId: ID of the user deleting the post (must be post author)
  ///
  /// Throws:
  /// - Exception if post not found
  /// - Exception if user is not authorized to delete
  /// - Exception if deletion fails
  Future<void> deletePost({
    required String postId,
    required String userId,
  });

  /// Update a post
  ///
  /// Parameters:
  /// - postId: ID of the post to update
  /// - userId: ID of the user updating the post (must be post author)
  /// - content: Updated text content
  /// - location: Updated location tag
  /// - tags: Updated list of hashtags
  ///
  /// Returns: Updated PostEntity
  ///
  /// Throws:
  /// - Exception if post not found
  /// - Exception if user is not authorized to update
  /// - Exception if update fails
  Future<PostEntity> updatePost({
    required String postId,
    required String userId,
    String? content,
    String? location,
    List<String>? tags,
  });

  /// Share a post
  ///
  /// Parameters:
  /// - postId: ID of the post to share
  /// - userId: ID of the user sharing the post
  ///
  /// Throws:
  /// - Exception if post not found
  /// - Exception if share operation fails
  Future<void> sharePost({
    required String postId,
    required String userId,
  });

  /// Check if a user has liked a post
  ///
  /// Parameters:
  /// - postId: ID of the post to check
  /// - userId: ID of the user to check
  ///
  /// Returns: true if user has liked the post, false otherwise
  Future<bool> hasLikedPost({
    required String postId,
    required String userId,
  });

  /// Check if a user has bookmarked a post
  ///
  /// Parameters:
  /// - postId: ID of the post to check
  /// - userId: ID of the user to check
  ///
  /// Returns: true if user has bookmarked the post, false otherwise
  Future<bool> hasBookmarkedPost({
    required String postId,
    required String userId,
  });

  /// Update post engagement metrics
  ///
  /// Updates view count, viewedBy list, and engagement score.
  /// Used by TrackPostViewUseCase to track post views.
  ///
  /// Parameters:
  /// - postId: ID of the post to update
  /// - views: New view count
  /// - viewedBy: Updated list of user IDs who viewed the post
  /// - engagementScore: Calculated engagement score
  ///
  /// Returns: Updated PostEntity
  ///
  /// Throws:
  /// - Exception if update fails
  Future<PostEntity> updatePostEngagement({
    required String postId,
    required int views,
    required List<String> viewedBy,
    required double engagementScore,
  });
}
