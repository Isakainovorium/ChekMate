import 'package:flutter_chekmate/features/stories/data/datasources/story_remote_datasource.dart';
import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';
import 'package:flutter_chekmate/features/stories/domain/repositories/story_repository.dart';

/// Story Repository Implementation - Data Layer
///
/// Implements the StoryRepository interface using remote data sources.
///
/// Clean Architecture: Data Layer
class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl({
    required StoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final StoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<StoryUserEntity>> getFollowingStories() async {
    try {
      final stories = await _remoteDataSource.getFollowingStories();
      return stories.map((s) => s.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get following stories: $e');
    }
  }

  @override
  Future<List<StoryEntity>> getMyStories() async {
    try {
      final stories = await _remoteDataSource.getMyStories();
      return stories.map((s) => s.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get my stories: $e');
    }
  }

  @override
  Future<List<StoryEntity>> getUserStories(String userId) async {
    try {
      final stories = await _remoteDataSource.getUserStories(userId);
      return stories.map((s) => s.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get user stories: $e');
    }
  }

  @override
  Future<StoryEntity> createStory({
    required StoryType type,
    required String filePath,
    String? text,
    String? textColor,
    String? textPosition,
    int? duration,
  }) async {
    try {
      final story = await _remoteDataSource.createStory(
        type: type,
        filePath: filePath,
        text: text,
        textColor: textColor,
        textPosition: textPosition,
        duration: duration,
      );
      return story.toEntity();
    } catch (e) {
      throw Exception('Failed to create story: $e');
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    try {
      await _remoteDataSource.deleteStory(storyId);
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  @override
  Future<void> markAsViewed(String storyId) async {
    try {
      await _remoteDataSource.markAsViewed(storyId);
    } catch (e) {
      throw Exception('Failed to mark story as viewed: $e');
    }
  }

  @override
  Future<void> likeStory(String storyId) async {
    try {
      await _remoteDataSource.likeStory(storyId);
    } catch (e) {
      throw Exception('Failed to like story: $e');
    }
  }

  @override
  Future<void> unlikeStory(String storyId) async {
    try {
      await _remoteDataSource.unlikeStory(storyId);
    } catch (e) {
      throw Exception('Failed to unlike story: $e');
    }
  }

  @override
  Future<List<String>> getStoryViewers(String storyId) async {
    try {
      return await _remoteDataSource.getStoryViewers(storyId);
    } catch (e) {
      throw Exception('Failed to get story viewers: $e');
    }
  }

  @override
  Future<List<String>> getStoryLikes(String storyId) async {
    try {
      return await _remoteDataSource.getStoryLikes(storyId);
    } catch (e) {
      throw Exception('Failed to get story likes: $e');
    }
  }

  @override
  Future<String> uploadStoryMedia(String filePath, StoryType type) async {
    try {
      return await _remoteDataSource.uploadStoryMedia(filePath, type);
    } catch (e) {
      throw Exception('Failed to upload story media: $e');
    }
  }

  @override
  Future<void> deleteExpiredStories() async {
    try {
      await _remoteDataSource.deleteExpiredStories();
    } catch (e) {
      throw Exception('Failed to delete expired stories: $e');
    }
  }
}

