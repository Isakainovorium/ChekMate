import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Posts Controller State - Presentation Layer
///
/// Represents the state of the posts controller.
///
/// Clean Architecture: Presentation Layer
class PostsControllerState {
  const PostsControllerState({
    this.isLoading = false,
    this.error,
  });

  final bool isLoading;
  final String? error;

  PostsControllerState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return PostsControllerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Posts Controller - Presentation Layer
///
/// Handles posts actions and state management.
/// Uses use cases from the domain layer to perform operations.
///
/// Clean Architecture: Presentation Layer
class PostsController extends StateNotifier<PostsControllerState> {
  PostsController(this._ref) : super(const PostsControllerState());

  final Ref _ref;

  /// Get current user ID from auth state
  String? get currentUserId {
    final authState = _ref.read(authStateProvider);
    return authState.value?.uid;
  }

  /// Get current user from auth state
  UserEntity? get currentUser {
    return _ref.read(authStateProvider).value;
  }

  /// Create a new post
  Future<PostEntity> createPost({
    required String content,
    List<Uint8List>? images,
    Uint8List? video,
    String? location,
    List<String>? tags,
    GeoPoint? coordinates,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final createPostUseCase = _ref.read(createPostUseCaseProvider);
      final post = await createPostUseCase(
        userId: user.uid,
        username: user.username,
        userAvatar: user.avatar,
        content: content,
        images: images,
        video: video,
        location: location,
        tags: tags,
        coordinates: coordinates,
      );

      state = state.copyWith(isLoading: false);

      // Invalidate posts feed to refresh
      _ref.invalidate(postsFeedProvider);
      _ref.invalidate(userPostsProvider(user.uid));

      return post;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Like a post
  Future<void> likePost(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final likePostUseCase = _ref.read(likePostUseCaseProvider);
      await likePostUseCase(
        postId: postId,
        userId: userId,
      );

      // Invalidate like status
      _ref.invalidate(hasLikedPostProvider(postId));
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final unlikePostUseCase = _ref.read(unlikePostUseCaseProvider);
      await unlikePostUseCase(
        postId: postId,
        userId: userId,
      );

      // Invalidate like status
      _ref.invalidate(hasLikedPostProvider(postId));
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final repository = _ref.read(postsRepositoryProvider);
      final hasLiked = await repository.hasLikedPost(
        postId: postId,
        userId: userId,
      );

      if (hasLiked) {
        await unlikePost(postId);
      } else {
        await likePost(postId);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Bookmark a post
  Future<void> bookmarkPost(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final bookmarkPostUseCase = _ref.read(bookmarkPostUseCaseProvider);
      await bookmarkPostUseCase(
        postId: postId,
        userId: userId,
      );

      // Invalidate bookmark status
      _ref.invalidate(hasBookmarkedPostProvider(postId));
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Unbookmark a post
  Future<void> unbookmarkPost(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final unbookmarkPostUseCase = _ref.read(unbookmarkPostUseCaseProvider);
      await unbookmarkPostUseCase(
        postId: postId,
        userId: userId,
      );

      // Invalidate bookmark status
      _ref.invalidate(hasBookmarkedPostProvider(postId));
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Toggle bookmark on a post
  Future<void> toggleBookmark(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final repository = _ref.read(postsRepositoryProvider);
      final hasBookmarked = await repository.hasBookmarkedPost(
        postId: postId,
        userId: userId,
      );

      if (hasBookmarked) {
        await unbookmarkPost(postId);
      } else {
        await bookmarkPost(postId);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    state = state.copyWith(isLoading: true);

    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final deletePostUseCase = _ref.read(deletePostUseCaseProvider);
      await deletePostUseCase(
        postId: postId,
        userId: userId,
      );

      state = state.copyWith(isLoading: false);

      // Invalidate posts feed to refresh
      _ref.invalidate(postsFeedProvider);
      _ref.invalidate(userPostsProvider(userId));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Share a post
  Future<void> sharePost(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final sharePostUseCase = _ref.read(sharePostUseCaseProvider);
      await sharePostUseCase(
        postId: postId,
        userId: userId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Chek a post (ChekMate's unique interaction)
  Future<void> chekPost(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // For now, use the same logic as liking a post
      // This can be expanded later with ChekMate-specific logic
      await likePost(postId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Refresh posts feed
  void refreshPosts() {
    _ref.invalidate(postsFeedProvider);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith();
  }
}
