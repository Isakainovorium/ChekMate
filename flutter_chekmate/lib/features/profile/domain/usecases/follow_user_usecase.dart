import 'package:flutter_chekmate/features/profile/domain/repositories/profile_repository.dart';

/// Follow User Use Case - Domain Layer
///
/// Follows a user.
///
/// Clean Architecture: Domain Layer
class FollowUserUsecase {
  const FollowUserUsecase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(String userId) async {
    // Business logic: Check if already following
    final isFollowing = await _repository.isFollowing(userId);
    if (isFollowing) {
      throw Exception('Already following this user');
    }

    await _repository.followUser(userId);
  }
}

/// Unfollow User Use Case - Domain Layer
///
/// Unfollows a user.
///
/// Clean Architecture: Domain Layer
class UnfollowUserUsecase {
  const UnfollowUserUsecase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(String userId) async {
    // Business logic: Check if following
    final isFollowing = await _repository.isFollowing(userId);
    if (!isFollowing) {
      throw Exception('Not following this user');
    }

    await _repository.unfollowUser(userId);
  }
}

/// Check If Following Use Case - Domain Layer
///
/// Checks if the current user is following another user.
///
/// Clean Architecture: Domain Layer
class IsFollowingUsecase {
  const IsFollowingUsecase(this._repository);

  final ProfileRepository _repository;

  Future<bool> call(String userId) async {
    return _repository.isFollowing(userId);
  }
}

