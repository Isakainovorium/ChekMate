import 'package:flutter_chekmate/features/stories/domain/repositories/story_repository.dart';

/// Mark Story As Viewed Use Case - Domain Layer
///
/// Marks a story as viewed by the current user.
///
/// Clean Architecture: Domain Layer
class MarkStoryAsViewedUsecase {
  const MarkStoryAsViewedUsecase(this._repository);

  final StoryRepository _repository;

  Future<void> call(String storyId) async {
    // Business logic: Validate story ID
    if (storyId.isEmpty) {
      throw Exception('Story ID cannot be empty');
    }

    await _repository.markAsViewed(storyId);
  }
}

/// Like Story Use Case - Domain Layer
///
/// Likes a story.
///
/// Clean Architecture: Domain Layer
class LikeStoryUsecase {
  const LikeStoryUsecase(this._repository);

  final StoryRepository _repository;

  Future<void> call(String storyId) async {
    // Business logic: Validate story ID
    if (storyId.isEmpty) {
      throw Exception('Story ID cannot be empty');
    }

    await _repository.likeStory(storyId);
  }
}

/// Unlike Story Use Case - Domain Layer
///
/// Unlikes a story.
///
/// Clean Architecture: Domain Layer
class UnlikeStoryUsecase {
  const UnlikeStoryUsecase(this._repository);

  final StoryRepository _repository;

  Future<void> call(String storyId) async {
    // Business logic: Validate story ID
    if (storyId.isEmpty) {
      throw Exception('Story ID cannot be empty');
    }

    await _repository.unlikeStory(storyId);
  }
}

/// Get Story Viewers Use Case - Domain Layer
///
/// Gets the list of users who viewed a story.
///
/// Clean Architecture: Domain Layer
class GetStoryViewersUsecase {
  const GetStoryViewersUsecase(this._repository);

  final StoryRepository _repository;

  Future<List<String>> call(String storyId) async {
    // Business logic: Validate story ID
    if (storyId.isEmpty) {
      throw Exception('Story ID cannot be empty');
    }

    return _repository.getStoryViewers(storyId);
  }
}

/// Get Story Likes Use Case - Domain Layer
///
/// Gets the list of users who liked a story.
///
/// Clean Architecture: Domain Layer
class GetStoryLikesUsecase {
  const GetStoryLikesUsecase(this._repository);

  final StoryRepository _repository;

  Future<List<String>> call(String storyId) async {
    // Business logic: Validate story ID
    if (storyId.isEmpty) {
      throw Exception('Story ID cannot be empty');
    }

    return _repository.getStoryLikes(storyId);
  }
}

