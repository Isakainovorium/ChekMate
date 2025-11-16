import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Posts Remote Datasource Provider
final postsRemoteDatasourceProvider = Provider<PostsRemoteDataSource>((ref) {
  return PostsRemoteDataSource(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

/// Feed Posts Provider
/// Provides a stream of posts for the main feed
final feedPostsProvider =
    StreamProvider.family<List<PostEntity>, String>((ref, userId) {
  final datasource = ref.watch(postsRemoteDatasourceProvider);
  return datasource.getFeedPosts(userId: userId, limit: 20);
});

/// User Posts Provider
/// Provides posts for a specific user
final userPostsProvider =
    StreamProvider.family<List<PostEntity>, String>((ref, userId) {
  final datasource = ref.watch(postsRemoteDatasourceProvider);
  return datasource.getUserPosts(userId: userId, limit: 20);
});

/// Single Post Provider
/// Provides a specific post by ID
final postProvider =
    FutureProvider.family<PostEntity, String>((ref, postId) async {
  final datasource = ref.watch(postsRemoteDatasourceProvider);
  return await datasource.getPostById(postId);
});

/// Trending Posts Provider
/// Provides trending posts based on engagement
final trendingPostsProvider = StreamProvider<List<PostEntity>>((ref) {
  final datasource = ref.watch(postsRemoteDatasourceProvider);
  return datasource.getTrendingPosts(limit: 20);
});

/// Following Posts Provider
/// Provides posts from users the current user follows
final followingPostsProvider =
    StreamProvider.family<List<PostEntity>, String>((ref, userId) {
  final datasource = ref.watch(postsRemoteDatasourceProvider);
  return datasource.getFollowingPosts(userId: userId, limit: 20);
});

/// Explore Posts Provider
/// Provides posts for the explore page based on user interests
final explorePostsProvider =
    FutureProvider.family<List<PostEntity>, List<String>>(
        (ref, interests) async {
  final datasource = ref.watch(postsRemoteDatasourceProvider);
  return await datasource.getExplorePostsByInterests(
      interests: interests, limit: 20);
});

/// Bookmarked Posts Provider
/// Provides bookmarked posts for a user
final bookmarkedPostsProvider =
    StreamProvider.family<List<PostEntity>, String>((ref, userId) {
  final datasource = ref.watch(postsRemoteDatasourceProvider);
  return datasource.getBookmarkedPosts(userId: userId, limit: 20);
});

/// Posts State Notifier
/// Manages posts state and operations
class PostsNotifier extends StateNotifier<AsyncValue<List<PostEntity>>> {
  final PostsRemoteDataSource _datasource;

  PostsNotifier(this._datasource) : super(const AsyncValue.loading());

  /// Load feed posts
  Future<void> loadFeedPosts(String userId) async {
    state = const AsyncValue.loading();
    try {
      final posts =
          await _datasource.getFeedPosts(userId: userId, limit: 20).first;
      state = AsyncValue.data(posts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    try {
      await _datasource.likePost(postId: postId, userId: userId);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _datasource.unlikePost(postId: postId, userId: userId);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Bookmark a post
  Future<void> bookmarkPost(String postId, String userId) async {
    try {
      await _datasource.bookmarkPost(postId: postId, userId: userId);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Remove bookmark from a post
  Future<void> removeBookmark(String postId, String userId) async {
    try {
      await _datasource.removeBookmark(postId: postId, userId: userId);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Share a post
  Future<void> sharePost(String postId, String userId) async {
    try {
      await _datasource.sharePost(postId: postId, userId: userId);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Chek a post (ChekMate's unique interaction for rating/verifying dating experiences)
  Future<void> chekPost(String postId, String userId) async {
    try {
      await _datasource.chekPost(postId: postId, userId: userId);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Create a new post
  Future<void> createPost({
    required String userId,
    required String username,
    required String userAvatar,
    required String content,
    List<Uint8List>? images,
    Uint8List? video,
    String? location,
    List<String>? tags,
  }) async {
    try {
      await _datasource.createPost(
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        content: content,
        images: images,
        video: video,
        location: location,
        tags: tags,
      );
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId, String userId) async {
    try {
      await _datasource.deletePost(postId: postId, userId: userId);
      // Reload posts after deletion
      await loadFeedPosts(userId);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Report a post
  Future<void> reportPost(String postId, String userId, String reason) async {
    try {
      await _datasource.reportPost(
          postId: postId, userId: userId, reason: reason);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
}

/// Posts Notifier Provider
final postsNotifierProvider =
    StateNotifierProvider<PostsNotifier, AsyncValue<List<PostEntity>>>((ref) {
  final datasource = ref.watch(postsRemoteDatasourceProvider);
  return PostsNotifier(datasource);
});

/// Post Likes Count Provider
/// Provides the number of likes for a post
final postLikesCountProvider =
    StreamProvider.family<int, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return 0;
    final data = snapshot.data();
    return (data?['likes'] as List?)?.length ?? 0;
  });
});

/// Post Comments Count Provider
/// Provides the number of comments for a post
final postCommentsCountProvider =
    StreamProvider.family<int, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return 0;
    final data = snapshot.data();
    return data?['commentsCount'] as int? ?? 0;
  });
});

/// Is Post Liked Provider
/// Checks if a post is liked by the current user
final isPostLikedProvider =
    StreamProvider.family<bool, ({String postId, String userId})>(
        (ref, params) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(params.postId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return false;
    final data = snapshot.data();
    final likes = (data?['likes'] as List?)?.cast<String>() ?? [];
    return likes.contains(params.userId);
  });
});

/// Is Post Bookmarked Provider
/// Checks if a post is bookmarked by the current user
final isPostBookmarkedProvider =
    StreamProvider.family<bool, ({String postId, String userId})>(
        (ref, params) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(params.userId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return false;
    final data = snapshot.data();
    final bookmarks = (data?['bookmarkedPosts'] as List?)?.cast<String>() ?? [];
    return bookmarks.contains(params.postId);
  });
});
