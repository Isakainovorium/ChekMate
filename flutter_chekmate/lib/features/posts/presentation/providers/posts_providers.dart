import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:flutter_chekmate/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/bookmark_post_usecase.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/get_hybrid_feed_usecase.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/get_interest_based_feed_usecase.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/get_location_based_feed_usecase.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/get_posts_usecase.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/like_post_usecase.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/share_post_usecase.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/track_post_view_usecase.dart';
import 'package:flutter_chekmate/features/posts/presentation/controllers/posts_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Posts Providers - Presentation Layer
///
/// Riverpod dependency injection for the posts feature.
/// Provides all dependencies from infrastructure to presentation.
///
/// Clean Architecture: Presentation Layer

// ========== INFRASTRUCTURE PROVIDERS ==========

/// Firebase Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Storage instance provider
final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// ========== DATA LAYER PROVIDERS ==========

/// Posts Remote Data Source provider
final postsRemoteDataSourceProvider = Provider<PostsRemoteDataSource>((ref) {
  return PostsRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider),
  );
});

/// Posts Repository provider
final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepositoryImpl(
    ref.watch(postsRemoteDataSourceProvider),
  );
});

// ========== DOMAIN LAYER PROVIDERS (USE CASES) ==========

/// Create Post Use Case provider
final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  return CreatePostUseCase(ref.watch(postsRepositoryProvider));
});

/// Get Posts Use Case provider
final getPostsUseCaseProvider = Provider<GetPostsUseCase>((ref) {
  return GetPostsUseCase(ref.watch(postsRepositoryProvider));
});

/// Like Post Use Case provider
final likePostUseCaseProvider = Provider<LikePostUseCase>((ref) {
  return LikePostUseCase(ref.watch(postsRepositoryProvider));
});

/// Unlike Post Use Case provider
final unlikePostUseCaseProvider = Provider<UnlikePostUseCase>((ref) {
  return UnlikePostUseCase(ref.watch(postsRepositoryProvider));
});

/// Bookmark Post Use Case provider
final bookmarkPostUseCaseProvider = Provider<BookmarkPostUseCase>((ref) {
  return BookmarkPostUseCase(ref.watch(postsRepositoryProvider));
});

/// Unbookmark Post Use Case provider
final unbookmarkPostUseCaseProvider = Provider<UnbookmarkPostUseCase>((ref) {
  return UnbookmarkPostUseCase(ref.watch(postsRepositoryProvider));
});

/// Delete Post Use Case provider
final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  return DeletePostUseCase(ref.watch(postsRepositoryProvider));
});

/// Share Post Use Case provider
final sharePostUseCaseProvider = Provider<SharePostUseCase>((ref) {
  return SharePostUseCase(ref.watch(postsRepositoryProvider));
});

/// Get Location-Based Feed Use Case provider
final getLocationBasedFeedUseCaseProvider =
    Provider<GetLocationBasedFeedUseCase>((ref) {
  return GetLocationBasedFeedUseCase(
    postsRepository: ref.watch(postsRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// Get Interest-Based Feed Use Case provider
final getInterestBasedFeedUseCaseProvider =
    Provider<GetInterestBasedFeedUseCase>((ref) {
  return GetInterestBasedFeedUseCase(
    ref.watch(postsRepositoryProvider),
  );
});

/// Track Post View Use Case provider
final trackPostViewUseCaseProvider = Provider<TrackPostViewUseCase>((ref) {
  return TrackPostViewUseCase(
    ref.watch(postsRepositoryProvider),
  );
});

/// Get Hybrid Feed Use Case provider
final getHybridFeedUseCaseProvider = Provider<GetHybridFeedUseCase>((ref) {
  return GetHybridFeedUseCase(
    postsRepository: ref.watch(postsRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

// ========== PRESENTATION LAYER PROVIDERS ==========

/// Posts Controller provider
final postsControllerProvider =
    StateNotifierProvider<PostsController, PostsControllerState>((ref) {
  return PostsController(ref);
});

/// Posts Feed Stream provider
/// Returns a stream of posts for the main feed (chronological)
final postsFeedProvider = StreamProvider.autoDispose((ref) {
  final getPostsUseCase = ref.watch(getPostsUseCaseProvider);
  return getPostsUseCase();
});

/// Location-Based Feed Future provider
/// Returns posts near the user's location with expanding radius algorithm
final locationBasedFeedProvider =
    FutureProvider.autoDispose<List<PostEntity>>((ref) async {
  final getLocationBasedFeedUseCase =
      ref.watch(getLocationBasedFeedUseCaseProvider);
  return getLocationBasedFeedUseCase();
});

/// Interest-Based Feed Future provider
/// Returns posts matching user's interests with relevance scoring
final interestBasedFeedProvider =
    FutureProvider.autoDispose<List<PostEntity>>((ref) async {
  final getInterestBasedFeedUseCase =
      ref.watch(getInterestBasedFeedUseCaseProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  // Get current user to access their interests
  final currentUser = await authRepository.getCurrentUser();
  if (currentUser == null ||
      currentUser.interests == null ||
      currentUser.interests!.isEmpty) {
    return [];
  }

  return getInterestBasedFeedUseCase(
    userInterests: currentUser.interests!,
  );
});

/// Hybrid Feed Future provider
/// Returns posts combining location-based and interest-based feeds (60/40 split)
final hybridFeedProvider =
    FutureProvider.autoDispose<List<PostEntity>>((ref) async {
  final getHybridFeedUseCase = ref.watch(getHybridFeedUseCaseProvider);
  return getHybridFeedUseCase();
});

/// User Posts Stream provider
/// Returns a stream of posts for a specific user
final userPostsProvider =
    StreamProvider.autoDispose.family<List<dynamic>, String>((ref, userId) {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getUserPosts(userId: userId);
});

/// Has Liked Post provider
/// Checks if the current user has liked a specific post
final hasLikedPostProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, postId) async {
  final repository = ref.watch(postsRepositoryProvider);
  final controller = ref.watch(postsControllerProvider.notifier);
  final currentUserId = controller.currentUserId;

  if (currentUserId == null) return false;

  return repository.hasLikedPost(
    postId: postId,
    userId: currentUserId,
  );
});

/// Has Bookmarked Post provider
/// Checks if the current user has bookmarked a specific post
final hasBookmarkedPostProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, postId) async {
  final repository = ref.watch(postsRepositoryProvider);
  final controller = ref.watch(postsControllerProvider.notifier);
  final currentUserId = controller.currentUserId;

  if (currentUserId == null) return false;

  return repository.hasBookmarkedPost(
    postId: postId,
    userId: currentUserId,
  );
});
