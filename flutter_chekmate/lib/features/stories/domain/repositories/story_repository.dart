import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';

/// Story Repository Interface - Domain Layer
///
/// Defines the contract for story data operations.
/// Implementations are in the data layer.
///
/// Clean Architecture: Domain Layer
abstract class StoryRepository {
  /// Get all stories from following users
  Future<List<StoryUserEntity>> getFollowingStories();

  /// Get user's own stories
  Future<List<StoryEntity>> getMyStories();

  /// Get stories by user ID
  Future<List<StoryEntity>> getUserStories(String userId);

  /// Create a new story
  Future<StoryEntity> createStory({
    required StoryType type,
    required String filePath,
    String? text,
    String? textColor,
    String? textPosition,
    int? duration,
  });

  /// Delete a story
  Future<void> deleteStory(String storyId);

  /// Mark story as viewed
  Future<void> markAsViewed(String storyId);

  /// Like a story
  Future<void> likeStory(String storyId);

  /// Unlike a story
  Future<void> unlikeStory(String storyId);

  /// Get story viewers
  Future<List<String>> getStoryViewers(String storyId);

  /// Get story likes
  Future<List<String>> getStoryLikes(String storyId);

  /// Upload story media
  Future<String> uploadStoryMedia(String filePath, StoryType type);

  /// Delete expired stories
  Future<void> deleteExpiredStories();
}

