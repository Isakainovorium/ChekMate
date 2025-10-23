import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Create Post Use Case - Domain Layer
///
/// Encapsulates the business logic for creating a new post.
/// Validates content and media before delegating to the repository.
///
/// Clean Architecture: Domain Layer
class CreatePostUseCase {
  const CreatePostUseCase(this._repository);

  final PostsRepository _repository;

  /// Execute the create post use case
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
  /// - Exception if validation fails
  /// - Exception if post creation fails
  Future<PostEntity> call({
    required String userId,
    required String username,
    required String userAvatar,
    required String content,
    List<Uint8List>? images,
    Uint8List? video,
    String? location,
    List<String>? tags,
    GeoPoint? coordinates,
  }) async {
    // Business logic: Validate user ID
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Business logic: Validate username
    if (username.isEmpty) {
      throw Exception('Username cannot be empty');
    }

    // Business logic: Validate content
    // Content is required and must not be empty (unless there's media)
    final hasMedia = (images != null && images.isNotEmpty) || video != null;
    if (content.trim().isEmpty && !hasMedia) {
      throw Exception('Post must have either content or media');
    }

    // Business logic: Validate content length
    if (content.length > 5000) {
      throw Exception('Post content cannot exceed 5000 characters');
    }

    // Business logic: Validate images
    if (images != null && images.isNotEmpty) {
      if (images.length > 10) {
        throw Exception('Cannot upload more than 10 images per post');
      }

      // Validate each image size (max 10MB per image)
      for (var i = 0; i < images.length; i++) {
        final sizeInMB = images[i].lengthInBytes / (1024 * 1024);
        if (sizeInMB > 10) {
          throw Exception('Image ${i + 1} exceeds 10MB size limit');
        }
      }
    }

    // Business logic: Validate video
    if (video != null) {
      // Validate video size (max 100MB)
      final sizeInMB = video.lengthInBytes / (1024 * 1024);
      if (sizeInMB > 100) {
        throw Exception('Video exceeds 100MB size limit');
      }

      // Cannot have both images and video
      if (images != null && images.isNotEmpty) {
        throw Exception('Cannot upload both images and video in the same post');
      }
    }

    // Business logic: Validate tags
    if (tags != null && tags.isNotEmpty) {
      if (tags.length > 30) {
        throw Exception('Cannot add more than 30 tags per post');
      }

      // Validate each tag
      for (final tag in tags) {
        if (tag.isEmpty) {
          throw Exception('Tags cannot be empty');
        }
        if (tag.length > 50) {
          throw Exception('Tag "$tag" exceeds 50 character limit');
        }
        // Tags should not contain spaces
        if (tag.contains(' ')) {
          throw Exception('Tag "$tag" cannot contain spaces');
        }
      }
    }

    // Business logic: Validate location
    if (location != null && location.isNotEmpty) {
      if (location.length > 200) {
        throw Exception('Location cannot exceed 200 characters');
      }
    }

    // Delegate to repository
    return _repository.createPost(
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      content: content.trim(),
      images: images,
      video: video,
      location: location?.trim(),
      tags: tags,
      coordinates: coordinates,
    );
  }
}
