import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/providers/providers.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Hybrid Feed Provider
/// Combines multiple feed sources (following, trending, interest-based)
final hybridFeedProvider = StreamProvider<List<PostEntity>>((ref) {
  return Stream.fromFuture(_createHybridFeed(ref));
});

Future<List<PostEntity>> _createHybridFeed(Ref ref) async {
  try {
    // Get current user information
    final currentUserIdAsync = ref.watch(currentUserIdProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    // Get the current values
    final currentUserId = currentUserIdAsync.value;
    final currentUser = currentUserAsync.value;

    if (currentUserId == null) {
      // User not authenticated, return trending posts only
      return ref.watch(trendingPostsProvider).when(
        data: (data) => data,
        error: (_, __) => [],
        loading: () => [],
      );
    }

    // Collect posts from different sources
    final allPosts = <PostEntity>[];
    final seenIds = <String>{};

    // Add following posts (highest priority)
    final followingPosts = await ref.watch(followingPostsProvider(currentUserId).future);
    for (final post in followingPosts) {
      if (!seenIds.contains(post.id)) {
        allPosts.add(post);
        seenIds.add(post.id);
      }
    }

    // Add trending posts
    final trendingPosts = await ref.watch(trendingPostsProvider.future);
    for (final post in trendingPosts) {
      if (!seenIds.contains(post.id)) {
        allPosts.add(post);
        seenIds.add(post.id);
      }
    }

    // Add interest-based posts if user has interests
    if (currentUser != null && currentUser.interests.isNotEmpty) {
      try {
        final interestPosts = await ref.watch(explorePostsProvider(currentUser.interests).future);
        for (final post in interestPosts) {
          if (!seenIds.contains(post.id)) {
            allPosts.add(post);
            seenIds.add(post.id);
          }
        }
      } catch (e) {
        // Skip interest posts if there's an error
      }
    }

    // Sort by priority: following posts first, then by engagement score
    allPosts.sort((a, b) {
      // Check if post is from a followed user (would need following relationship data)
      // For now, prioritize recent posts from different users
      final aRecent = a.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 24)));
      final bRecent = b.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 24)));

      if (aRecent && !bRecent) return -1;
      if (!aRecent && bRecent) return 1;

      // Then sort by engagement score (likes + comments*2 + shares*3)
      final aScore = (a.likes * 1) + (a.comments * 2) + (a.shares * 3);
      final bScore = (b.likes * 1) + (b.comments * 2) + (b.shares * 3);

      return bScore.compareTo(aScore);
    });

    // Limit to prevent overwhelming the feed
    return allPosts.take(50).toList();

  } catch (e) {
    // Fallback to trending posts if hybrid logic fails
    return ref.watch(trendingPostsProvider).when(
      data: (data) => data,
      error: (_, __) => [],
      loading: () => [],
    );
  }
}

/// Posts Feed Provider
/// Provides posts from followed users
final postsFeedProvider = StreamProvider<List<PostEntity>>((ref) {
  // Get current user ID
  final currentUserIdAsync = ref.watch(currentUserIdProvider);

  return currentUserIdAsync.when(
    data: (currentUserId) {
      if (currentUserId == null) {
        // User not authenticated, return empty list
        return Stream.value(<PostEntity>[]);
      }

      // Return posts from followed users
      final followingPostsAsync = ref.watch(followingPostsProvider(currentUserId));
      return followingPostsAsync.when(
        data: (posts) => Stream.value(posts),
        loading: () => Stream.value(<PostEntity>[]),
        error: (_, __) => Stream.value(<PostEntity>[]),
      );
    },
    loading: () => Stream.value(<PostEntity>[]),
    error: (_, __) => Stream.value(<PostEntity>[]),
  );
});

/// Location-Based Feed Provider
/// Provides posts from nearby users
final locationBasedFeedProvider = StreamProvider<List<PostEntity>>((ref) {
  return Stream.fromFuture(_createLocationBasedFeed(ref));
});

Future<List<PostEntity>> _createLocationBasedFeed(Ref ref) async {
  try {
    // Check location permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // No permission, request it
      final requestedPermission = await Geolocator.requestPermission();
      if (requestedPermission == LocationPermission.denied ||
          requestedPermission == LocationPermission.deniedForever) {
        // Permission denied, fall back to trending posts
        return ref.watch(trendingPostsProvider).when(
          data: (data) => data,
          error: (_, __) => [],
          loading: () => [],
        );
      }
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );

    // Create GeoPoint for location query
    final center = GeoPoint(position.latitude, position.longitude);
    const radiusKm = 25.0; // 25km radius for local content

    // Get posts near location
    final datasource = ref.watch(postsRemoteDatasourceProvider);
    final nearbyPosts = await datasource.getPostsNearLocation(
      center: center,
      radiusKm: radiusKm,
      limit: 20,
    );

    return nearbyPosts;
  } catch (e) {
    // Any error (timeout, location unavailable, etc.), fall back to trending posts
    return ref.watch(trendingPostsProvider).when(
      data: (data) => data,
      error: (_, __) => [],
      loading: () => [],
    );
  }
}

/// Interest-Based Feed Provider
/// Provides posts based on user interests
final interestBasedFeedProvider = StreamProvider<List<PostEntity>>((ref) {
  // Get current user information
  final currentUserAsync = ref.watch(currentUserProvider);

  return currentUserAsync.when(
    data: (currentUser) {
      if (currentUser == null) {
        // User not authenticated, return trending posts
        final trendingAsync = ref.watch(trendingPostsProvider);
        return trendingAsync.when(
          data: (posts) => Stream.value(posts),
          loading: () => Stream.value(<PostEntity>[]),
          error: (_, __) => Stream.value(<PostEntity>[]),
        );
      }

      if (currentUser.interests.isEmpty) {
        // User has no interests set, return trending posts
        final trendingAsync = ref.watch(trendingPostsProvider);
        return trendingAsync.when(
          data: (posts) => Stream.value(posts),
          loading: () => Stream.value(<PostEntity>[]),
          error: (_, __) => Stream.value(<PostEntity>[]),
        );
      }

      // Get posts based on user interests
      final interestPostsAsync = ref.watch(explorePostsProvider(currentUser.interests));
      return interestPostsAsync.when(
        data: (posts) => Stream.value(posts),
        loading: () => Stream.value(<PostEntity>[]),
        error: (_, __) {
          // Fallback to trending posts on error
          final trendingAsync = ref.watch(trendingPostsProvider);
          return trendingAsync.when(
            data: (posts) => Stream.value(posts),
            loading: () => Stream.value(<PostEntity>[]),
            error: (_, __) => Stream.value(<PostEntity>[]),
          );
        },
      );
    },
    loading: () => Stream.value(<PostEntity>[]),
    error: (_, __) {
      // Fallback to trending posts on error
      final trendingAsync = ref.watch(trendingPostsProvider);
      return trendingAsync.when(
        data: (posts) => Stream.value(posts),
        loading: () => Stream.value(<PostEntity>[]),
        error: (_, __) => Stream.value(<PostEntity>[]),
      );
    },
  );
});

/// Track Post View Use Case Provider
/// Tracks when a user views a post
final trackPostViewUseCaseProvider = Provider((ref) {
  return TrackPostViewUseCase();
});

/// Track Post View Use Case
class TrackPostViewUseCase {
  /// Track a post view
  Future<void> call({
    required String postId,
    required String userId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get current post data
      final postDoc = await firestore.collection('posts').doc(postId).get();

      if (!postDoc.exists) {
        // Post doesn't exist, nothing to track
        return;
      }

      final postData = postDoc.data()!;
      final currentViews = postData['views'] as int? ?? 0;
      final currentViewedBy = List<String>.from(postData['viewedBy'] ?? []);

      // Check if user has already viewed this post
      if (currentViewedBy.contains(userId)) {
        // User already viewed this post, don't count again
        return;
      }

      // Add user to viewedBy list and increment view count
      final updatedViewedBy = [...currentViewedBy, userId];
      final updatedViews = currentViews + 1;

      // Calculate updated engagement score
      // Engagement score = likes + comments*2 + shares*3 + views*0.1
      final likes = postData['likes'] as int? ?? 0;
      final comments = postData['comments'] as int? ?? 0;
      final shares = postData['shares'] as int? ?? 0;
      final engagementScore = likes + (comments * 2) + (shares * 3) + (updatedViews * 0.1);

      // Update the post with new view data
      await firestore.collection('posts').doc(postId).update({
        'views': updatedViews,
        'viewedBy': updatedViewedBy,
        'engagementScore': engagementScore,
        'lastEngagementUpdate': FieldValue.serverTimestamp(),
      });

      // Log the view for analytics (optional)
      // You could also send this to an analytics service
      // await _analyticsService.trackEvent('post_view', {'postId': postId, 'userId': userId});

    } catch (e) {
      // Log error but don't throw - view tracking shouldn't break the app
      // In a production app, you might want to log this to an error reporting service
      developer.log(
        'Error tracking post view for post $postId by user $userId',
        name: 'TrackPostViewUseCase',
        error: e,
      );
    }
  }
}

/// Posts Controller Provider
/// Provides controller for post actions
final postsControllerProvider = Provider((ref) {
  return PostsController(ref);
});

/// Posts Controller
class PostsController {
  PostsController(this.ref);

  final Ref ref;

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    final notifier = ref.read(postsNotifierProvider.notifier);
    await notifier.likePost(postId, userId);
  }

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    final notifier = ref.read(postsNotifierProvider.notifier);
    await notifier.unlikePost(postId, userId);
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId) async {
    final currentUserIdAsync = ref.watch(currentUserIdProvider);
    final currentUserId = currentUserIdAsync.when(
      data: (userId) => userId,
      loading: () => null,
      error: (_, __) => null,
    );

    if (currentUserId == null) {
      throw Exception('User must be authenticated to like posts');
    }

    final hasLiked = await ref.read(hasLikedPostProvider(postId).future);
    if (hasLiked) {
      await unlikePost(postId, currentUserId);
    } else {
      await likePost(postId, currentUserId);
    }
  }

  /// Share a post
  Future<void> sharePost(String postId, [String? userId]) async {
    final notifier = ref.read(postsNotifierProvider.notifier);
    final currentUserId = userId ?? ref.watch(currentUserIdProvider).when(
      data: (id) => id,
      loading: () => null,
      error: (_, __) => null,
    );

    if (currentUserId == null) {
      throw Exception('User must be authenticated to share posts');
    }

    await notifier.sharePost(postId, currentUserId);
  }

  /// Chek a post (ChekMate's unique interaction)
  /// This is ChekMate's unique interaction for rating/verifying dating experiences
  Future<void> chekPost(String postId) async {
    final currentUserIdAsync = ref.watch(currentUserIdProvider);
    final currentUserId = currentUserIdAsync.when(
      data: (userId) => userId,
      loading: () => null,
      error: (_, __) => null,
    );

    if (currentUserId == null) {
      throw Exception('User must be authenticated to chek posts');
    }

    final notifier = ref.read(postsNotifierProvider.notifier);
    await notifier.chekPost(postId, currentUserId);
  }

  /// Delete a post
  Future<void> deletePost(String postId, String userId) async {
    final notifier = ref.read(postsNotifierProvider.notifier);
    await notifier.deletePost(postId, userId);
  }
}

/// Has Liked Post Provider
/// Checks if the current user has liked a specific post
final hasLikedPostProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  // Get current user ID
  final currentUserIdAsync = ref.watch(currentUserIdProvider);
  final currentUserId = currentUserIdAsync.when(
    data: (userId) => userId,
    loading: () => null,
    error: (_, __) => null,
  );

  // If no authenticated user, they haven't liked the post
  if (currentUserId == null) {
    return false;
  }

  // Get the post data
  final postAsync = await ref.watch(postProvider(postId).future);

  // Check if the current user is in the likedBy list
  return postAsync.isLikedBy(currentUserId);
});
