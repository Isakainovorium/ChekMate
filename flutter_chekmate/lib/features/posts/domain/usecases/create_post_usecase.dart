import 'dart:typed_data';

import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Create Post Use Case
/// Handles creating new posts with validation and business logic
class CreatePostUseCase {
  final PostsRepository _repository;

  CreatePostUseCase(this._repository);

  /// Execute create post operation
  Future<PostEntity> call({
    required String userId,
    required String username,
    required String userAvatar,
    required String content,
    List<Uint8List>? images,
    Uint8List? video,
    String? location,
    List<String>? tags,
  }) async {
    // Validate userId
    if (userId.trim().isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Validate username
    if (username.trim().isEmpty) {
      throw Exception('Username cannot be empty');
    }

    // Validate userAvatar
    if (userAvatar.trim().isEmpty) {
      throw Exception('User avatar cannot be empty');
    }

    // Validate content (must have content or media)
    final hasMedia = (images != null && images.isNotEmpty) || (video != null && video.isNotEmpty);
    if (!hasMedia && content.trim().isEmpty) {
      throw Exception('Post must have content or media');
    }

    // Validate content length (max 5000 characters)
    if (content.length > 5000) {
      throw Exception('Post content cannot exceed 5000 characters');
    }

    // Validate images (max 10 images)
    if (images != null && images.length > 10) {
      throw Exception('Post cannot have more than 10 images');
    }

    // Process tags (remove duplicates, lowercase, remove empty)
    final processedTags = _processTags(tags);

    // Validate location
    final processedLocation = location?.trim().isNotEmpty == true ? location!.trim() : null;

    // Call repository
    return await _repository.createPost(
      userId: userId.trim(),
      username: username.trim(),
      userAvatar: userAvatar.trim(),
      content: content.trim(),
      images: images,
      video: video,
      location: processedLocation,
      tags: processedTags,
    );
  }

  /// Process and validate tags
  List<String>? _processTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) {
      return null;
    }

    // Remove empty tags, trim whitespace, convert to lowercase, remove duplicates
    final processedTags = tags
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) => tag.trim().toLowerCase())
        .toSet() // Remove duplicates
        .toList();

    // Validate tag format (alphanumeric and underscores only)
    final validTags = processedTags.where((tag) {
      final tagRegex = RegExp(r'^[a-zA-Z0-9_]+$');
      return tagRegex.hasMatch(tag);
    }).toList();

    return validTags.isNotEmpty ? validTags : null;
  }
}
