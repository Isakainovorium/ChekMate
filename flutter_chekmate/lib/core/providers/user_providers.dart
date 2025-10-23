import 'dart:typed_data';

import 'package:flutter_chekmate/core/models/user_model.dart';
import 'package:flutter_chekmate/core/providers/auth_providers.dart';
import 'package:flutter_chekmate/core/providers/service_providers.dart';
import 'package:flutter_chekmate/core/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User Profile Provider
/// Get any user's profile by ID
final userProfileProvider =
    StreamProvider.family<UserModel?, String>((ref, userId) {
  final userService = ref.watch(userServiceProvider);
  return userService.getUserStream(userId);
});

/// User by Username Provider
/// Get user by username
final userByUsernameProvider =
    FutureProvider.family<UserModel?, String>((ref, username) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getUserByUsername(username);
});

/// Followers Provider
/// Get followers for a user
final followersProvider =
    StreamProvider.family<List<UserModel>, String>((ref, userId) {
  final userService = ref.watch(userServiceProvider);
  return userService.getFollowers(userId);
});

/// Following Provider
/// Get users that a user is following
final followingProvider =
    StreamProvider.family<List<UserModel>, String>((ref, userId) {
  final userService = ref.watch(userServiceProvider);
  return userService.getFollowing(userId);
});

/// Is Following Provider
/// Check if current user is following another user
final isFollowingProvider =
    FutureProvider.family<bool, String>((ref, targetUserId) async {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) return false;

  final userService = ref.watch(userServiceProvider);
  return userService.isFollowing(
    currentUserId: currentUserId,
    targetUserId: targetUserId,
  );
});

/// Search Users Provider
/// Search for users by query
final searchUsersProvider =
    FutureProvider.family<List<UserModel>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final userService = ref.watch(userServiceProvider);
  return userService.searchUsers(query);
});

/// User Controller Provider
/// Handles user-related actions
final userControllerProvider = Provider<UserController>((ref) {
  return UserController(ref);
});

/// User Controller
/// Manages user state and actions
class UserController {
  UserController(this.ref);
  final Ref ref;

  UserService get _userService => ref.read(userServiceProvider);
  String? get _currentUserId => ref.read(currentUserIdProvider);

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? location,
    int? age,
    String? gender,
    List<String>? interests,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _userService.updateUserProfile(
      uid: _currentUserId!,
      displayName: displayName,
      bio: bio,
      location: location,
      age: age,
      gender: gender,
      interests: interests,
    );
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture({
    required Uint8List imageData,
    required String fileName,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _userService.uploadProfilePicture(
      uid: _currentUserId!,
      imageData: imageData,
      fileName: fileName,
    );
  }

  /// Upload cover photo
  Future<String> uploadCoverPhoto({
    required Uint8List imageData,
    required String fileName,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _userService.uploadCoverPhoto(
      uid: _currentUserId!,
      imageData: imageData,
      fileName: fileName,
    );
  }

  /// Follow user
  Future<void> followUser(String targetUserId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _userService.followUser(
      currentUserId: _currentUserId!,
      targetUserId: targetUserId,
    );

    // Invalidate following status
    ref.invalidate(isFollowingProvider(targetUserId));
  }

  /// Unfollow user
  Future<void> unfollowUser(String targetUserId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _userService.unfollowUser(
      currentUserId: _currentUserId!,
      targetUserId: targetUserId,
    );

    // Invalidate following status
    ref.invalidate(isFollowingProvider(targetUserId));
  }

  /// Toggle follow/unfollow
  Future<void> toggleFollow(String targetUserId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final isFollowing = await _userService.isFollowing(
      currentUserId: _currentUserId!,
      targetUserId: targetUserId,
    );

    if (isFollowing) {
      await unfollowUser(targetUserId);
    } else {
      await followUser(targetUserId);
    }
  }

  /// Search users
  Future<List<UserModel>> searchUsers(String query) async {
    return _userService.searchUsers(query);
  }
}
