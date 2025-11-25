import 'package:equatable/equatable.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';

/// Profile Entity - Domain Layer
///
/// Represents a user profile in the ChekMate application.
/// Extends basic user information with profile-specific features.
///
class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.email,
    this.bio = '',
    this.avatar = '',
    this.coverPhoto = '',
    this.followers = 0,
    this.following = 0,
    this.posts = 0,
    this.isVerified = false,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
    this.age,
    this.gender,
    this.location,
    this.interests = const [],
    this.voicePrompts = const [],
    this.videoIntroUrl,
    required this.stats,
  });

  final String uid;
  final String username;
  final String displayName;
  final String email;
  final String bio;
  final String avatar;
  final String coverPhoto;
  final int followers;
  final int following;
  final int posts;
  final bool isVerified;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? age;
  final String? gender;
  final String? location;
  final List<String> interests;
  final List<VoicePromptEntity> voicePrompts;
  final String? videoIntroUrl;
  final ProfileStats stats;

  /// Alias for uid (for compatibility)
  String get id => uid;

  /// Alias for displayName (for compatibility)
  String get name => displayName;

  /// Check if location is enabled (has location data)
  bool get locationEnabled => location != null && location!.isNotEmpty;

  /// Check if profile is complete (has all required information)
  bool get isComplete {
    return displayName.isNotEmpty &&
           bio.isNotEmpty &&
           avatar.isNotEmpty &&
           location != null &&
           location!.isNotEmpty &&
           interests.isNotEmpty;
  }

  /// Check if user has complete profile (has bio, avatar, location)
  bool get hasCompleteProfile {
    return bio.isNotEmpty &&
           avatar.isNotEmpty &&
           location != null &&
           location!.isNotEmpty;
  }

  /// Check if user can send messages (verified users or premium)
  bool get canSendMessages {
    return isVerified || isPremium;
  }

  /// Check if user can create posts (verified users or premium)
  bool get canCreatePosts {
    return isVerified || isPremium;
  }

  /// Get display name or username as fallback
  String get displayNameOrUsername {
    return displayName.isNotEmpty ? displayName : username;
  }

  /// Get formatted followers count (e.g., "1.2K", "3.5M")
  String get formattedFollowers {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    } else {
      return followers.toString();
    }
  }

  /// Get formatted following count (e.g., "1.2K", "3.5M")
  String get formattedFollowing {
    if (following >= 1000000) {
      return '${(following / 1000000).toStringAsFixed(1)}M';
    } else if (following >= 1000) {
      return '${(following / 1000).toStringAsFixed(1)}K';
    } else {
      return following.toString();
    }
  }

  /// Check if profile has voice prompts
  bool get hasVoicePrompts => voicePrompts.isNotEmpty;

  /// Check if profile has video intro
  bool get hasVideoIntro => videoIntroUrl != null && videoIntroUrl!.isNotEmpty;

  /// Get most recent voice prompt
  VoicePromptEntity? get mostRecentVoicePrompt {
    if (voicePrompts.isEmpty) return null;
    return voicePrompts.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }

  /// Get public voice prompts only
  List<VoicePromptEntity> get publicVoicePrompts {
    return voicePrompts.where((prompt) => prompt.isPublic).toList();
  }

  /// Get engagement rate (likes + comments + shares per post)
  double get engagementRate {
    if (posts == 0) return 0.0;
    final totalEngagement = stats.totalLikes + stats.totalComments + stats.totalShares;
    return totalEngagement / posts;
  }

  /// Get profile completion percentage
  int get completionPercentage {
    int completed = 0;
    int total = 6; // displayName, bio, avatar, location, interests, voicePrompts

    if (displayName.isNotEmpty) completed++;
    if (bio.isNotEmpty) completed++;
    if (avatar.isNotEmpty) completed++;
    if (location != null && location!.isNotEmpty) completed++;
    if (interests.isNotEmpty) completed++;
    if (voicePrompts.isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }

  /// Check if profile can be messaged (has messaging enabled)
  bool get canBeMessaged {
    // For now, all verified users can be messaged
    // This could be extended with privacy settings
    return isVerified;
  }

  /// Create a copy with updated fields
  ProfileEntity copyWith({
    String? uid,
    String? username,
    String? displayName,
    String? email,
    String? bio,
    String? avatar,
    String? coverPhoto,
    int? followers,
    int? following,
    int? posts,
    bool? isVerified,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? age,
    String? gender,
    String? location,
    List<String>? interests,
    List<VoicePromptEntity>? voicePrompts,
    String? videoIntroUrl,
    ProfileStats? stats,
  }) {
    return ProfileEntity(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      posts: posts ?? this.posts,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      voicePrompts: voicePrompts ?? this.voicePrompts,
      videoIntroUrl: videoIntroUrl ?? this.videoIntroUrl,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        username,
        displayName,
        email,
        bio,
        avatar,
        coverPhoto,
        followers,
        following,
        posts,
        isVerified,
        isPremium,
        createdAt,
        updatedAt,
        age,
        gender,
        location,
        interests,
        voicePrompts,
        videoIntroUrl,
        stats,
      ];
}

/// Profile Statistics
class ProfileStats extends Equatable {
  const ProfileStats({
    required this.totalPosts,
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
    required this.totalViews,
    this.postsData = const [],
    this.followersData = const [],
    this.likesData = const [],
  });

  final int totalPosts;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalViews;
  final List<int> postsData;
  final List<int> followersData;
  final List<int> likesData;

  /// Get total engagement
  int get totalEngagement => totalLikes + totalComments + totalShares;

  /// Get engagement rate per post
  double get engagementRatePerPost {
    if (totalPosts == 0) return 0.0;
    return totalEngagement / totalPosts;
  }

  /// Get formatted total engagement
  String get formattedTotalEngagement {
    final total = totalEngagement;
    if (total >= 1000000) {
      return '${(total / 1000000).toStringAsFixed(1)}M';
    } else if (total >= 1000) {
      return '${(total / 1000).toStringAsFixed(1)}K';
    } else {
      return total.toString();
    }
  }

  /// Get formatted total views
  String get formattedTotalViews {
    if (totalViews >= 1000000) {
      return '${(totalViews / 1000000).toStringAsFixed(1)}M';
    } else if (totalViews >= 1000) {
      return '${(totalViews / 1000).toStringAsFixed(1)}K';
    } else {
      return totalViews.toString();
    }
  }


  @override
  List<Object?> get props => [
        totalPosts,
        totalLikes,
        totalComments,
        totalShares,
        totalViews,
        postsData,
        followersData,
        likesData,
      ];
}
