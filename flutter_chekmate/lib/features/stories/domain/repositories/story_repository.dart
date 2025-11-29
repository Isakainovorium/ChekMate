import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';

/// Story Repository Interface
/// Defines the contract for story-related data operations
abstract class StoryRepository {
  /// Create a new story
  Future<StoryEntity> createStory({
    required StoryType type,
    required String filePath,
    int? duration,
    String? text,
  });

  /// Delete a story
  Future<void> deleteStory(String storyId);

  /// Get stories for a specific user
  Future<List<StoryEntity>> getUserStories(String userId);

  /// Get all stories for the current user and followed users
  Future<List<StoryEntity>> getStories();

  /// Mark a story as viewed
  Future<void> markStoryViewed(String storyId, String userId);

  /// Like a story
  Future<void> likeStory(String storyId, String userId);

  /// Unlike a story
  Future<void> unlikeStory(String storyId, String userId);

  /// Get story viewers
  Future<List<String>> getStoryViewers(String storyId);

  /// Get story likers
  Future<List<String>> getStoryLikers(String storyId);
}
