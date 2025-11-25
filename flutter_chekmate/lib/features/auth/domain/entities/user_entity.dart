import 'package:equatable/equatable.dart';

/// User Entity - Domain Layer
///
/// Represents a user in the ChekMate application.
/// This is the domain model used throughout the application.
///
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
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
    this.location,
    this.age,
    this.gender,
    this.interests = const [],
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
  final String? location;
  final int? age;
  final String? gender;
  final List<String> interests;

  /// Alias for uid (for compatibility)
  String get id => uid;

  /// Alias for displayName (for compatibility)
  String get name => displayName;

  /// Check if location is enabled (has location data)
  bool get locationEnabled => location != null && location!.isNotEmpty;

  /// Check if user has complete profile
  bool get hasCompleteProfile {
    return displayName.isNotEmpty &&
           bio.isNotEmpty &&
           avatar.isNotEmpty &&
           location != null;
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

  /// Create a copy with updated fields
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
    String? location,
    int? age,
    String? gender,
    List<String>? interests,
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
      location: location ?? this.location,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
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
      ];
}
