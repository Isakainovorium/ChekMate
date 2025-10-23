import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';
import 'package:flutter_chekmate/features/stories/domain/repositories/story_repository.dart';

/// Create Story Use Case - Domain Layer
///
/// Creates a new story.
///
/// Clean Architecture: Domain Layer
class CreateStoryUsecase {
  const CreateStoryUsecase(this._repository);

  final StoryRepository _repository;

  Future<StoryEntity> call({
    required StoryType type,
    required String filePath,
    String? text,
    String? textColor,
    String? textPosition,
    int? duration,
  }) async {
    // Business logic: Validate file path
    if (filePath.isEmpty) {
      throw Exception('File path cannot be empty');
    }

    // Business logic: Set default duration for images and videos
    final finalDuration = duration ?? (type == StoryType.image ? 5 : 15);

    // Business logic: Validate duration for videos (after applying default)
    if (type == StoryType.video && finalDuration <= 0) {
      throw Exception('Video duration must be greater than 0');
    }

    return _repository.createStory(
      type: type,
      filePath: filePath,
      text: text,
      textColor: textColor,
      textPosition: textPosition,
      duration: finalDuration,
    );
  }
}

/// Delete Story Use Case - Domain Layer
///
/// Deletes a story.
///
/// Clean Architecture: Domain Layer
class DeleteStoryUsecase {
  const DeleteStoryUsecase(this._repository);

  final StoryRepository _repository;

  Future<void> call(String storyId) async {
    // Business logic: Validate story ID
    if (storyId.isEmpty) {
      throw Exception('Story ID cannot be empty');
    }

    await _repository.deleteStory(storyId);
  }
}
