import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/stories/data/datasources/story_remote_datasource.dart';
import 'package:flutter_chekmate/features/stories/data/repositories/story_repository_impl.dart';
import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';
import 'package:flutter_chekmate/features/stories/domain/repositories/story_repository.dart';
import 'package:flutter_chekmate/features/stories/domain/usecases/create_story_usecase.dart';
import 'package:flutter_chekmate/features/stories/domain/usecases/get_stories_usecase.dart';
import 'package:flutter_chekmate/features/stories/domain/usecases/interact_story_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'story_providers.g.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Firebase Firestore Provider
@riverpod
FirebaseFirestore storyFirebaseFirestore(StoryFirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// Firebase Auth Provider
@riverpod
FirebaseAuth storyFirebaseAuth(StoryFirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

/// Firebase Storage Provider
@riverpod
FirebaseStorage storyFirebaseStorage(StoryFirebaseStorageRef ref) {
  return FirebaseStorage.instance;
}

/// Story Remote Data Source Provider
@riverpod
StoryRemoteDataSource storyRemoteDataSource(StoryRemoteDataSourceRef ref) {
  return StoryRemoteDataSourceImpl(
    firestore: ref.watch(storyFirebaseFirestoreProvider),
    auth: ref.watch(storyFirebaseAuthProvider),
    storage: ref.watch(storyFirebaseStorageProvider),
  );
}

/// Story Repository Provider
@riverpod
StoryRepository storyRepository(StoryRepositoryRef ref) {
  return StoryRepositoryImpl(
    remoteDataSource: ref.watch(storyRemoteDataSourceProvider),
  );
}

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

/// Get Following Stories Use Case Provider
@riverpod
GetFollowingStoriesUsecase getFollowingStoriesUsecase(
  GetFollowingStoriesUsecaseRef ref,
) {
  return GetFollowingStoriesUsecase(ref.watch(storyRepositoryProvider));
}

/// Get My Stories Use Case Provider
@riverpod
GetMyStoriesUsecase getMyStoriesUsecase(GetMyStoriesUsecaseRef ref) {
  return GetMyStoriesUsecase(ref.watch(storyRepositoryProvider));
}

/// Get User Stories Use Case Provider
@riverpod
GetUserStoriesUsecase getUserStoriesUsecase(GetUserStoriesUsecaseRef ref) {
  return GetUserStoriesUsecase(ref.watch(storyRepositoryProvider));
}

/// Create Story Use Case Provider
@riverpod
CreateStoryUsecase createStoryUsecase(CreateStoryUsecaseRef ref) {
  return CreateStoryUsecase(ref.watch(storyRepositoryProvider));
}

/// Delete Story Use Case Provider
@riverpod
DeleteStoryUsecase deleteStoryUsecase(DeleteStoryUsecaseRef ref) {
  return DeleteStoryUsecase(ref.watch(storyRepositoryProvider));
}

/// Mark Story As Viewed Use Case Provider
@riverpod
MarkStoryAsViewedUsecase markStoryAsViewedUsecase(
  MarkStoryAsViewedUsecaseRef ref,
) {
  return MarkStoryAsViewedUsecase(ref.watch(storyRepositoryProvider));
}

/// Like Story Use Case Provider
@riverpod
LikeStoryUsecase likeStoryUsecase(LikeStoryUsecaseRef ref) {
  return LikeStoryUsecase(ref.watch(storyRepositoryProvider));
}

/// Unlike Story Use Case Provider
@riverpod
UnlikeStoryUsecase unlikeStoryUsecase(UnlikeStoryUsecaseRef ref) {
  return UnlikeStoryUsecase(ref.watch(storyRepositoryProvider));
}

/// Get Story Viewers Use Case Provider
@riverpod
GetStoryViewersUsecase getStoryViewersUsecase(GetStoryViewersUsecaseRef ref) {
  return GetStoryViewersUsecase(ref.watch(storyRepositoryProvider));
}

/// Get Story Likes Use Case Provider
@riverpod
GetStoryLikesUsecase getStoryLikesUsecase(GetStoryLikesUsecaseRef ref) {
  return GetStoryLikesUsecase(ref.watch(storyRepositoryProvider));
}

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// Following Stories Provider
@riverpod
class FollowingStories extends _$FollowingStories {
  @override
  Future<List<StoryUserEntity>> build() async {
    final usecase = ref.watch(getFollowingStoriesUsecaseProvider);
    return usecase();
  }

  /// Refresh stories
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(getFollowingStoriesUsecaseProvider);
      return usecase();
    });
  }
}

/// My Stories Provider
@riverpod
class MyStories extends _$MyStories {
  @override
  Future<List<StoryEntity>> build() async {
    final usecase = ref.watch(getMyStoriesUsecaseProvider);
    return usecase();
  }

  /// Refresh my stories
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(getMyStoriesUsecaseProvider);
      return usecase();
    });
  }

  /// Create a new story
  Future<void> createStory({
    required StoryType type,
    required String filePath,
    String? text,
    String? textColor,
    String? textPosition,
    int? duration,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(createStoryUsecaseProvider);
      await usecase(
        type: type,
        filePath: filePath,
        text: text,
        textColor: textColor,
        textPosition: textPosition,
        duration: duration,
      );

      // Refresh stories after creating
      final getUsecase = ref.read(getMyStoriesUsecaseProvider);
      return getUsecase();
    });
  }

  /// Delete a story
  Future<void> deleteStory(String storyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(deleteStoryUsecaseProvider);
      await usecase(storyId);

      // Refresh stories after deleting
      final getUsecase = ref.read(getMyStoriesUsecaseProvider);
      return getUsecase();
    });
  }
}

/// User Stories Provider (by user ID)
@riverpod
class UserStories extends _$UserStories {
  @override
  Future<List<StoryEntity>> build(String userId) async {
    final usecase = ref.watch(getUserStoriesUsecaseProvider);
    return usecase(userId);
  }

  /// Refresh user stories
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(getUserStoriesUsecaseProvider);
      return usecase(userId);
    });
  }

  /// Mark story as viewed
  Future<void> markAsViewed(String storyId) async {
    final usecase = ref.read(markStoryAsViewedUsecaseProvider);
    await usecase(storyId);
    await refresh();
  }

  /// Like story
  Future<void> likeStory(String storyId) async {
    final usecase = ref.read(likeStoryUsecaseProvider);
    await usecase(storyId);
    await refresh();
  }

  /// Unlike story
  Future<void> unlikeStory(String storyId) async {
    final usecase = ref.read(unlikeStoryUsecaseProvider);
    await usecase(storyId);
    await refresh();
  }
}

/// Story Viewers Provider (by story ID)
@riverpod
Future<List<String>> storyViewers(StoryViewersRef ref, String storyId) async {
  final usecase = ref.watch(getStoryViewersUsecaseProvider);
  return usecase(storyId);
}

/// Story Likes Provider (by story ID)
@riverpod
Future<List<String>> storyLikes(StoryLikesRef ref, String storyId) async {
  final usecase = ref.watch(getStoryLikesUsecaseProvider);
  return usecase(storyId);
}
