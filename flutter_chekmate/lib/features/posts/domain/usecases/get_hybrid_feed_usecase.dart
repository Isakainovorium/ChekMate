import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/utils/geohash_utils.dart';
import 'package:flutter_chekmate/core/utils/interest_matching_utils.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Get Hybrid Feed Use Case - Domain Layer
///
/// Combines location-based and interest-based feeds with a 60/40 split.
///
/// Algorithm:
/// 1. Get location-based posts (60% of limit)
/// 2. Get interest-based posts (40% of limit)
/// 3. Merge and deduplicate by post ID
/// 4. Calculate hybrid score for each post:
///    - 50% location match (distance-based)
///    - 50% interest match (relevance-based)
///    - Engagement boost
/// 5. Sort by hybrid score (highest first)
/// 6. Return top N posts
///
/// Hybrid Scoring:
/// - Location score: 100 - (distance in km) (max 100, min 0)
/// - Interest score: Relevance score from InterestMatchingUtils
/// - Engagement boost: engagementScore × 10
/// - Final score = (locationScore × 0.5) + (interestScore × 0.5) + engagementBoost
///
/// Clean Architecture: Domain Layer
class GetHybridFeedUseCase {
  const GetHybridFeedUseCase({
    required PostsRepository postsRepository,
    required AuthRepository authRepository,
  })  : _postsRepository = postsRepository,
        _authRepository = authRepository;

  final PostsRepository _postsRepository;
  final AuthRepository _authRepository;

  /// Execute the hybrid feed use case
  ///
  /// Parameters:
  /// - limit: Maximum number of posts to return (default: 20)
  /// - locationWeight: Weight for location score (default: 0.5)
  /// - interestWeight: Weight for interest score (default: 0.5)
  ///
  /// Returns:
  /// - List of posts sorted by hybrid score (highest first)
  ///
  /// Throws:
  /// - Exception if user not authenticated
  /// - Exception if query fails
  Future<List<PostEntity>> call({
    int limit = 20,
    double locationWeight = 0.5,
    double interestWeight = 0.5,
  }) async {
    try {
      developer.log(
        'Getting hybrid feed (limit: $limit, locationWeight: $locationWeight, interestWeight: $interestWeight)',
        name: 'GetHybridFeedUseCase',
      );

      // Validate inputs
      if (limit <= 0) {
        throw Exception('Limit must be greater than 0');
      }

      if (limit > 100) {
        throw Exception('Limit cannot exceed 100 posts');
      }

      // Get current user
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Calculate split (60% location, 40% interests)
      final locationLimit = (limit * 0.6).ceil();
      final interestLimit = (limit * 0.4).ceil();

      developer.log(
        'Fetching $locationLimit location-based posts and $interestLimit interest-based posts',
        name: 'GetHybridFeedUseCase',
      );

      // Fetch location-based posts
      final locationPosts = <PostEntity>[];
      if (user.locationEnabled && user.coordinates != null) {
        locationPosts.addAll(
          await _getLocationBasedPosts(
            userLocation: user.coordinates!,
            limit: locationLimit,
          ),
        );
        developer.log(
          'Fetched ${locationPosts.length} location-based posts',
          name: 'GetHybridFeedUseCase',
        );
      } else {
        developer.log(
          'Location disabled or no coordinates, skipping location-based posts',
          name: 'GetHybridFeedUseCase',
        );
      }

      // Fetch interest-based posts
      final interestPosts = <PostEntity>[];
      if (user.interests != null && user.interests!.isNotEmpty) {
        interestPosts.addAll(
          await _getInterestBasedPosts(
            userInterests: user.interests!,
            limit: interestLimit,
          ),
        );
        developer.log(
          'Fetched ${interestPosts.length} interest-based posts',
          name: 'GetHybridFeedUseCase',
        );
      } else {
        developer.log(
          'No interests selected, skipping interest-based posts',
          name: 'GetHybridFeedUseCase',
        );
      }

      // Merge and deduplicate posts
      final allPosts = _mergeAndDeduplicate(locationPosts, interestPosts);
      developer.log(
        'Merged to ${allPosts.length} unique posts',
        name: 'GetHybridFeedUseCase',
      );

      // If no posts found, fallback to chronological feed
      if (allPosts.isEmpty) {
        developer.log(
          'No posts found, falling back to chronological feed',
          name: 'GetHybridFeedUseCase',
        );
        return await _postsRepository.getPosts(limit: limit).first;
      }

      // Calculate hybrid scores
      final postsWithScores = allPosts.map((post) {
        final score = _calculateHybridScore(
          post: post,
          userLocation: user.coordinates,
          userInterests: user.interests,
          locationWeight: locationWeight,
          interestWeight: interestWeight,
        );
        return _PostWithScore(post: post, score: score);
      }).toList();

      // Sort by hybrid score (highest first)
      postsWithScores.sort((a, b) => b.score.compareTo(a.score));

      // Return top N posts
      final result = postsWithScores.take(limit).map((e) => e.post).toList();

      developer.log(
        'Returning ${result.length} hybrid feed posts',
        name: 'GetHybridFeedUseCase',
      );

      return result;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to get hybrid feed',
        name: 'GetHybridFeedUseCase',
        error: e,
        stackTrace: stackTrace,
      );

      // Fallback to chronological feed on error
      developer.log(
        'Falling back to chronological feed due to error',
        name: 'GetHybridFeedUseCase',
      );
      return _postsRepository.getPosts(limit: limit).first;
    }
  }

  /// Get location-based posts with expanding radius
  Future<List<PostEntity>> _getLocationBasedPosts({
    required GeoPoint userLocation,
    required int limit,
  }) async {
    var radiusKm = 5.0; // Start with 5km
    const maxRadiusKm = 100.0; // Max 100km
    var posts = <PostEntity>[];

    // Expand radius until we have enough posts
    while (posts.length < limit && radiusKm <= maxRadiusKm) {
      posts = await _postsRepository.getPostsNearLocation(
        center: userLocation,
        radiusKm: radiusKm,
        limit: limit,
      );

      if (posts.length < limit) {
        radiusKm *= 2; // Double the radius
        if (radiusKm > maxRadiusKm) {
          radiusKm = maxRadiusKm;
          if (posts.isNotEmpty) break;
        }
      }
    }

    return posts;
  }

  /// Get interest-based posts
  Future<List<PostEntity>> _getInterestBasedPosts({
    required List<String> userInterests,
    required int limit,
  }) async {
    final posts = await _postsRepository.getPostsByInterests(
      interests: userInterests,
      limit: limit * 2, // Fetch 2x to allow for filtering
    );

    // Filter and sort by relevance
    final relevantPosts = InterestMatchingUtils.filterByRelevance(
      userInterests: userInterests,
      posts: posts,
    );

    final sortedPosts = InterestMatchingUtils.sortByRelevance(
      userInterests: userInterests,
      posts: relevantPosts,
    );

    return sortedPosts.take(limit).toList();
  }

  /// Merge and deduplicate posts by ID
  List<PostEntity> _mergeAndDeduplicate(
    List<PostEntity> locationPosts,
    List<PostEntity> interestPosts,
  ) {
    final postMap = <String, PostEntity>{};

    // Add location posts
    for (final post in locationPosts) {
      postMap[post.id] = post;
    }

    // Add interest posts (won't overwrite if already exists)
    for (final post in interestPosts) {
      postMap.putIfAbsent(post.id, () => post);
    }

    return postMap.values.toList();
  }

  /// Calculate hybrid score for a post
  double _calculateHybridScore({
    required PostEntity post,
    required GeoPoint? userLocation,
    required List<String>? userInterests,
    required double locationWeight,
    required double interestWeight,
  }) {
    // Calculate location score (0-100)
    var locationScore = 0.0;
    if (userLocation != null && post.coordinates != null) {
      final distance = GeohashUtils.calculateDistance(
        userLocation,
        post.coordinates!,
      );
      // Score decreases with distance (100 at 0km, 0 at 100km+)
      locationScore = (100 - distance).clamp(0.0, 100.0);
    }

    // Calculate interest score (0-100+)
    var interestScore = 0.0;
    if (userInterests != null && userInterests.isNotEmpty) {
      interestScore = InterestMatchingUtils.calculateRelevanceScore(
        userInterests: userInterests,
        post: post,
      );
    }

    // Calculate engagement boost (0-10)
    final engagementBoost = post.engagementScore * 10;

    // Calculate final hybrid score
    final hybridScore = (locationScore * locationWeight) +
        (interestScore * interestWeight) +
        engagementBoost;

    return hybridScore;
  }
}

/// Internal class to hold post with score
class _PostWithScore {
  const _PostWithScore({
    required this.post,
    required this.score,
  });

  final PostEntity post;
  final double score;
}
