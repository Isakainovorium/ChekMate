import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';
import 'package:flutter_chekmate/features/stories/domain/repositories/story_repository.dart';

/// Get Following Stories Use Case - Domain Layer
///
/// Retrieves stories from users that the current user follows.
///
/// Clean Architecture: Domain Layer
class GetFollowingStoriesUsecase {
  const GetFollowingStoriesUsecase(this._repository);

  final StoryRepository _repository;

  Future<List<StoryUserEntity>> call() async {
    final stories = await _repository.getFollowingStories();

    // Business logic: Filter out expired stories
    final activeStories = stories.map((userStory) {
      final activeUserStories = userStory.stories
          .where((story) => !story.isExpired)
          .toList();
      return userStory.copyWith(stories: activeUserStories);
    }).where((userStory) => userStory.hasStories).toList();

    // Business logic: Sort by unviewed first, then by most recent
    activeStories.sort((a, b) {
      // Own stories first
      if (a.isOwn && !b.isOwn) return -1;
      if (!a.isOwn && b.isOwn) return 1;

      // Unviewed stories before viewed
      if (!a.allViewed && b.allViewed) return -1;
      if (a.allViewed && !b.allViewed) return 1;

      // Most recent first
      final aRecent = a.mostRecentStory?.createdAt ?? DateTime(0);
      final bRecent = b.mostRecentStory?.createdAt ?? DateTime(0);
      return bRecent.compareTo(aRecent);
    });

    return activeStories;
  }
}

/// Get My Stories Use Case - Domain Layer
///
/// Retrieves the current user's stories.
///
/// Clean Architecture: Domain Layer
class GetMyStoriesUsecase {
  const GetMyStoriesUsecase(this._repository);

  final StoryRepository _repository;

  Future<List<StoryEntity>> call() async {
    final stories = await _repository.getMyStories();

    // Business logic: Filter out expired stories
    return stories.where((story) => !story.isExpired).toList();
  }
}

/// Get User Stories Use Case - Domain Layer
///
/// Retrieves stories for a specific user.
///
/// Clean Architecture: Domain Layer
class GetUserStoriesUsecase {
  const GetUserStoriesUsecase(this._repository);

  final StoryRepository _repository;

  Future<List<StoryEntity>> call(String userId) async {
    final stories = await _repository.getUserStories(userId);

    // Business logic: Filter out expired stories
    return stories.where((story) => !story.isExpired).toList();
  }
}

