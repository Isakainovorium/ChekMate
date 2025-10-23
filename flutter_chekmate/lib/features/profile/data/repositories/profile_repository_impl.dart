import 'package:flutter_chekmate/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:flutter_chekmate/features/profile/data/models/profile_model.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/repositories/profile_repository.dart';

/// Profile Repository Implementation - Data Layer
///
/// Implements the ProfileRepository interface using remote data sources.
///
/// Clean Architecture: Data Layer
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<ProfileEntity?> getProfile(String userId) async {
    try {
      final profile = await _remoteDataSource.getProfile(userId);
      return profile?.toEntity();
    } on Exception catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<ProfileEntity?> getCurrentUserProfile() async {
    try {
      final profile = await _remoteDataSource.getCurrentUserProfile();
      return profile?.toEntity();
    } on Exception catch (e) {
      throw Exception('Failed to get current user profile: $e');
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      final profileModel = ProfileModel(
        uid: profile.uid,
        username: profile.username,
        displayName: profile.displayName,
        bio: profile.bio,
        avatar: profile.avatar,
        coverPhoto: profile.coverPhoto,
        followers: profile.followers,
        following: profile.following,
        posts: profile.posts,
        isVerified: profile.isVerified,
        isPremium: profile.isPremium,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
        location: profile.location,
        age: profile.age,
        gender: profile.gender,
        interests: profile.interests,
        voicePrompts: profile.voicePrompts,
        videoIntroUrl: profile.videoIntroUrl,
        email: profile.email,
        phoneNumber: profile.phoneNumber,
        website: profile.website,
        socialLinks: profile.socialLinks,
        stats: profile.stats,
      );

      await _remoteDataSource.updateProfile(profileModel);
    } on Exception catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> updateProfileField(
    String userId,
    String field,
    dynamic value,
  ) async {
    try {
      await _remoteDataSource.updateProfileField(userId, field, value);
    } on Exception catch (e) {
      throw Exception('Failed to update profile field: $e');
    }
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      return await _remoteDataSource.uploadAvatar(userId, filePath);
    } on Exception catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  @override
  Future<String> uploadCoverPhoto(String userId, String filePath) async {
    try {
      return await _remoteDataSource.uploadCoverPhoto(userId, filePath);
    } on Exception catch (e) {
      throw Exception('Failed to upload cover photo: $e');
    }
  }

  @override
  Future<String> uploadVideoIntro(String userId, String filePath) async {
    try {
      return await _remoteDataSource.uploadVideoIntro(userId, filePath);
    } on Exception catch (e) {
      throw Exception('Failed to upload video intro: $e');
    }
  }

  @override
  Future<void> addVoicePrompt(
    String userId,
    VoicePromptEntity voicePrompt,
  ) async {
    try {
      await _remoteDataSource.addVoicePrompt(userId, voicePrompt);
    } on Exception catch (e) {
      throw Exception('Failed to add voice prompt: $e');
    }
  }

  @override
  Future<void> deleteVoicePrompt(String userId, String promptId) async {
    try {
      await _remoteDataSource.deleteVoicePrompt(userId, promptId);
    } on Exception catch (e) {
      throw Exception('Failed to delete voice prompt: $e');
    }
  }

  @override
  Future<void> followUser(String userId) async {
    try {
      await _remoteDataSource.followUser(userId);
    } on Exception catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    try {
      await _remoteDataSource.unfollowUser(userId);
    } on Exception catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  @override
  Future<bool> isFollowing(String userId) async {
    try {
      return await _remoteDataSource.isFollowing(userId);
    } on Exception {
      return false;
    }
  }

  @override
  Future<List<ProfileEntity>> getFollowers(String userId) async {
    try {
      final profiles = await _remoteDataSource.getFollowers(userId);
      return profiles.map((p) => p.toEntity()).toList();
    } on Exception catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  @override
  Future<List<ProfileEntity>> getFollowing(String userId) async {
    try {
      final profiles = await _remoteDataSource.getFollowing(userId);
      return profiles.map((p) => p.toEntity()).toList();
    } on Exception catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  @override
  Future<ProfileStats> getProfileStats(String userId) async {
    try {
      final profile = await _remoteDataSource.getProfile(userId);
      if (profile == null || profile.stats == null) {
        return const ProfileStats(
          totalPosts: 0,
          totalLikes: 0,
          totalComments: 0,
          totalShares: 0,
          totalViews: 0,
        );
      }
      return profile.stats!;
    } on Exception catch (e) {
      throw Exception('Failed to get profile stats: $e');
    }
  }

  @override
  Future<List<ProfileEntity>> searchProfiles(String query) async {
    try {
      final profiles = await _remoteDataSource.searchProfiles(query);
      return profiles.map((p) => p.toEntity()).toList();
    } on Exception catch (e) {
      throw Exception('Failed to search profiles: $e');
    }
  }

  @override
  Future<List<ProfileEntity>> getSuggestedProfiles() async {
    try {
      final profiles = await _remoteDataSource.getSuggestedProfiles();
      return profiles.map((p) => p.toEntity()).toList();
    } on Exception catch (e) {
      throw Exception('Failed to get suggested profiles: $e');
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    try {
      await _remoteDataSource.blockUser(userId);
    } on Exception catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    try {
      await _remoteDataSource.unblockUser(userId);
    } on Exception catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  @override
  Future<void> reportUser(String userId, String reason) async {
    try {
      await _remoteDataSource.reportUser(userId, reason);
    } on Exception catch (e) {
      throw Exception('Failed to report user: $e');
    }
  }
}
