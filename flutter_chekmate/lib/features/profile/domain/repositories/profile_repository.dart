import 'package:flutter_chekmate/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';

/// Profile Repository Interface - Domain Layer
///
/// Defines the contract for profile data operations.
/// Implementations are in the data layer.
///
/// Clean Architecture: Domain Layer
abstract class ProfileRepository {
  /// Get profile by user ID
  Future<ProfileEntity?> getProfile(String userId);

  /// Get current user's profile
  Future<ProfileEntity?> getCurrentUserProfile();

  /// Update profile
  Future<void> updateProfile(ProfileEntity profile);

  /// Update profile field
  Future<void> updateProfileField(String userId, String field, dynamic value);

  /// Upload profile avatar
  Future<String> uploadAvatar(String userId, String filePath);

  /// Upload cover photo
  Future<String> uploadCoverPhoto(String userId, String filePath);

  /// Upload video intro
  Future<String> uploadVideoIntro(String userId, String filePath);

  /// Add voice prompt
  Future<void> addVoicePrompt(String userId, VoicePromptEntity voicePrompt);

  /// Delete voice prompt
  Future<void> deleteVoicePrompt(String userId, String promptId);

  /// Follow user
  Future<void> followUser(String userId);

  /// Unfollow user
  Future<void> unfollowUser(String userId);

  /// Check if following user
  Future<bool> isFollowing(String userId);

  /// Get user's followers
  Future<List<ProfileEntity>> getFollowers(String userId);

  /// Get user's following
  Future<List<ProfileEntity>> getFollowing(String userId);

  /// Get profile stats
  Future<ProfileStats> getProfileStats(String userId);

  /// Search profiles
  Future<List<ProfileEntity>> searchProfiles(String query);

  /// Get suggested profiles
  Future<List<ProfileEntity>> getSuggestedProfiles();

  /// Block user
  Future<void> blockUser(String userId);

  /// Unblock user
  Future<void> unblockUser(String userId);

  /// Report user
  Future<void> reportUser(String userId, String reason);
}

