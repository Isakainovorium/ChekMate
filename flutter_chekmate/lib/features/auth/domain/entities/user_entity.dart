import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';

/// User Entity - Pure Dart Domain Model
///
/// This is a pure Dart class with no dependencies on Flutter or Firebase.
/// It represents the core business concept of a User in the ChekMate app.
///
/// Clean Architecture: Domain Layer
class UserEntity {
  const UserEntity({
    required this.uid,
    required this.email,
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
    this.onboardingCompleted = false,
    this.location,
    this.age,
    this.gender,
    this.interests,
    this.voicePrompts,
    this.videoIntroUrl,
    this.coordinates,
    this.geohash,
    this.locationEnabled = false,
    this.searchRadiusKm = 100.0,
  });

  final String uid;
  final String email;
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
  final bool onboardingCompleted;
  final String? location;
  final int? age;
  final String? gender;
  final List<String>? interests;
  final List<VoicePromptEntity>? voicePrompts;
  final String? videoIntroUrl;

  // Geolocation fields for location-based discovery
  final GeoPoint? coordinates;
  final String? geohash;
  final bool locationEnabled;
  final double searchRadiusKm;

  /// Business logic: Check if user has a complete profile
  bool get hasCompleteProfile {
    return displayName.isNotEmpty &&
        bio.isNotEmpty &&
        avatar.isNotEmpty &&
        location != null &&
        age != null &&
        gender != null &&
        interests != null &&
        interests!.isNotEmpty;
  }

  /// Business logic: Check if user can send messages
  bool get canSendMessages {
    return isVerified || isPremium;
  }

  /// Business logic: Check if user can create posts
  bool get canCreatePosts {
    return hasCompleteProfile;
  }

  /// Business logic: Get user's full name or username
  String get displayNameOrUsername {
    return displayName.isNotEmpty ? displayName : username;
  }

  /// Copy with method for immutability
  UserEntity copyWith({
    String? uid,
    String? email,
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
    bool? onboardingCompleted,
    String? location,
    int? age,
    String? gender,
    List<String>? interests,
    List<VoicePromptEntity>? voicePrompts,
    String? videoIntroUrl,
    GeoPoint? coordinates,
    String? geohash,
    bool? locationEnabled,
    double? searchRadiusKm,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
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
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      location: location ?? this.location,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      voicePrompts: voicePrompts ?? this.voicePrompts,
      videoIntroUrl: videoIntroUrl ?? this.videoIntroUrl,
      coordinates: coordinates ?? this.coordinates,
      geohash: geohash ?? this.geohash,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserEntity(uid: $uid, username: $username, email: $email)';
  }
}
