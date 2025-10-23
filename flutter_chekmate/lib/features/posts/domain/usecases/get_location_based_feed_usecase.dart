import 'dart:developer' as developer;

import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Get Location-Based Feed Use Case - Domain Layer
///
/// Implements expanding radius algorithm for location-based content discovery.
/// Starts with a small radius (5km) and expands up to user's search radius
/// until enough posts are found.
///
/// Algorithm:
/// 1. Get current user's location and preferences
/// 2. Start with 5km radius
/// 3. Query posts within radius
/// 4. If not enough posts, double the radius and retry
/// 5. Continue until limit is reached or max radius is hit
///
/// Clean Architecture: Domain Layer
class GetLocationBasedFeedUseCase {
  const GetLocationBasedFeedUseCase({
    required PostsRepository postsRepository,
    required AuthRepository authRepository,
  })  : _postsRepository = postsRepository,
        _authRepository = authRepository;

  final PostsRepository _postsRepository;
  final AuthRepository _authRepository;

  /// Execute the location-based feed use case
  ///
  /// Parameters:
  /// - limit: Maximum number of posts to retrieve (default: 20)
  ///
  /// Returns: Future<List<PostEntity>> of posts near user's location
  ///
  /// Throws:
  /// - Exception if user is not authenticated
  /// - Exception if user has no location data
  /// - Exception if location services are disabled
  Future<List<PostEntity>> call({
    int limit = 20,
  }) async {
    try {
      developer.log(
        'Getting location-based feed (limit: $limit)',
        name: 'GetLocationBasedFeedUseCase',
      );

      // Business logic: Validate limit
      if (limit <= 0) {
        throw Exception('Limit must be greater than 0');
      }

      if (limit > 100) {
        throw Exception('Limit cannot exceed 100 posts');
      }

      // 1. Get current user
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 2. Check if user has location enabled
      if (!user.locationEnabled) {
        developer.log(
          'Location services disabled, falling back to chronological feed',
          name: 'GetLocationBasedFeedUseCase',
        );
        // Fallback to chronological feed
        return await _postsRepository.getPosts(limit: limit).first;
      }

      // 3. Check if user has coordinates
      if (user.coordinates == null) {
        developer.log(
          'User has no coordinates, falling back to chronological feed',
          name: 'GetLocationBasedFeedUseCase',
        );
        // Fallback to chronological feed
        return await _postsRepository.getPosts(limit: limit).first;
      }

      // 4. Start with small radius (5km)
      var radiusKm = 5.0;
      final maxRadiusKm = user.searchRadiusKm;
      var posts = <PostEntity>[];

      developer.log(
        'Starting location search at (${user.coordinates!.latitude}, ${user.coordinates!.longitude})',
        name: 'GetLocationBasedFeedUseCase',
      );

      // 5. Expand radius until we have enough posts
      while (posts.length < limit && radiusKm <= maxRadiusKm) {
        developer.log(
          'Searching within ${radiusKm}km radius',
          name: 'GetLocationBasedFeedUseCase',
        );

        posts = await _postsRepository.getPostsNearLocation(
          center: user.coordinates!,
          radiusKm: radiusKm,
          limit: limit,
        );

        developer.log(
          'Found ${posts.length} posts within ${radiusKm}km',
          name: 'GetLocationBasedFeedUseCase',
        );

        if (posts.length < limit) {
          // Double the radius for next iteration
          radiusKm *= 2;
          
          // Cap at max radius
          if (radiusKm > maxRadiusKm) {
            radiusKm = maxRadiusKm;
            
            // If we've already searched at max radius, break
            if (posts.isNotEmpty) {
              break;
            }
          }
        }
      }

      // 6. If still no posts, fallback to chronological feed
      if (posts.isEmpty) {
        developer.log(
          'No posts found within ${maxRadiusKm}km, falling back to chronological feed',
          name: 'GetLocationBasedFeedUseCase',
        );
        return await _postsRepository.getPosts(limit: limit).first;
      }

      developer.log(
        'Returning ${posts.length} location-based posts',
        name: 'GetLocationBasedFeedUseCase',
      );

      return posts;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to get location-based feed',
        name: 'GetLocationBasedFeedUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      
      // Fallback to chronological feed on error
      developer.log(
        'Falling back to chronological feed due to error',
        name: 'GetLocationBasedFeedUseCase',
      );
      return _postsRepository.getPosts(limit: limit).first;
    }
  }
}

