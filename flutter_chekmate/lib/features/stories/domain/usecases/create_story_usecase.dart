import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';
import 'package:flutter_chekmate/features/stories/domain/repositories/story_repository.dart';

/// Create Story Use Case
/// Handles the business logic for creating a new story
class CreateStoryUsecase {
  const CreateStoryUsecase(this._repository);

  final StoryRepository _repository;

  /// Execute the use case
  Future<StoryEntity> call({
    required StoryType type,
    required String filePath,
    int? duration,
    String? text,
  }) async {
    // Validation
    if (filePath.isEmpty) {
      throw Exception('File path cannot be empty');
    }

    // Set default durations based on type
    final actualDuration = duration ??
        (type == StoryType.image ? 5 : 15); // 5 seconds for images, 15 for videos

    // Validate video duration
    if (type == StoryType.video && actualDuration <= 0) {
      throw Exception('Video duration must be positive');
    }

    // Call repository
    return _repository.createStory(
      type: type,
      filePath: filePath,
      duration: actualDuration,
      text: text,
    );
  }
}

/// Delete Story Use Case
/// Handles the business logic for deleting a story
class DeleteStoryUsecase {
  const DeleteStoryUsecase(this._repository);

  final StoryRepository _repository;

  /// Execute the use case
  Future<void> call(String storyId) async {
    // Validation
    if (storyId.isEmpty) {
      throw Exception('Story ID cannot be empty');
    }

    // Call repository
    return _repository.deleteStory(storyId);
  }
}
