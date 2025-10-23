import 'package:equatable/equatable.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';

/// Profile Entity - Domain Layer
///
/// Represents a user's profile in the domain layer.
/// Contains all profile-related data and business logic.
///
/// Clean Architecture: Domain Layer
class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatar,
    required this.coverPhoto,
    required this.followers,
    required this.following,
    required this.posts,
    required this.isVerified,
    required this.isPremium,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.age,
    this.gender,
    this.interests,
    this.voicePrompts,
    this.videoIntroUrl,
    this.email,
    this.phoneNumber,
    this.website,
    this.socialLinks,
    this.stats,
  });

  final String uid;
  final String username;
  final String displayName;
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
  final String? location;
  final int? age;
  final String? gender;
  final List<String>? interests;
  final List<VoicePromptEntity>? voicePrompts;
  final String? videoIntroUrl;
  final String? email;
  final String? phoneNumber;
  final String? website;
  final Map<String, String>? socialLinks;
  final ProfileStats? stats;

  /// Business logic: Check if profile is complete
  bool get isComplete {
    return displayName.isNotEmpty &&
        bio.isNotEmpty &&
        avatar.isNotEmpty &&
        location != null &&
        age != null &&
        gender != null &&
        interests != null &&
        interests!.isNotEmpty;
  }

  /// Business logic: Check if profile has voice prompts
  bool get hasVoicePrompts {
    return voicePrompts != null && voicePrompts!.isNotEmpty;
  }

  /// Business logic: Check if profile has video intro
  bool get hasVideoIntro {
    return videoIntroUrl != null && videoIntroUrl!.isNotEmpty;
  }

  /// Business logic: Get completion percentage
  double get completionPercentage {
    var completed = 0;
    const total = 8;

    if (displayName.isNotEmpty) completed++;
    if (bio.isNotEmpty) completed++;
    if (avatar.isNotEmpty) completed++;
    if (location != null) completed++;
    if (age != null) completed++;
    if (gender != null) completed++;
    if (interests != null && interests!.isNotEmpty) completed++;
    if (voicePrompts != null && voicePrompts!.isNotEmpty) completed++;

    return completed / total;
  }

  /// Business logic: Check if user can be messaged
  bool get canBeMessaged {
    return !isPremium || isVerified;
  }

  ProfileEntity copyWith({
    String? uid,
    String? username,
    String? displayName,
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
    String? location,
    int? age,
    String? gender,
    List<String>? interests,
    List<VoicePromptEntity>? voicePrompts,
    String? videoIntroUrl,
    String? email,
    String? phoneNumber,
    String? website,
    Map<String, String>? socialLinks,
    ProfileStats? stats,
  }) {
    return ProfileEntity(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
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
      location: location ?? this.location,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      voicePrompts: voicePrompts ?? this.voicePrompts,
      videoIntroUrl: videoIntroUrl ?? this.videoIntroUrl,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      socialLinks: socialLinks ?? this.socialLinks,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        username,
        displayName,
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
        location,
        age,
        gender,
        interests,
        voicePrompts,
        videoIntroUrl,
        email,
        phoneNumber,
        website,
        socialLinks,
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
    this.postsData,
    this.followersData,
    this.likesData,
  });

  final int totalPosts;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalViews;
  final List<int>? postsData;
  final List<int>? followersData;
  final List<int>? likesData;

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

