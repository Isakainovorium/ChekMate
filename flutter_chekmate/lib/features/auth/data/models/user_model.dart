import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';

/// User Model - Data Layer
///
/// Data transfer object for user data.
/// Converts between domain entities and Firestore documents.
/// Extends UserEntity to inherit business logic.
///
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.username,
    required super.displayName,
    super.bio = '',
    super.avatar = '',
    super.coverPhoto = '',
    super.followers = 0,
    super.following = 0,
    super.posts = 0,
    super.isVerified = false,
    super.isPremium = false,
    required super.createdAt,
    required super.updatedAt,
    super.location,
    super.age,
    super.gender,
    super.interests = const [],
  });

  /// Check if user has complete profile (has bio, avatar, location)
  @override
  bool get hasCompleteProfile {
    return bio.isNotEmpty &&
           avatar.isNotEmpty &&
           location != null &&
           location!.isNotEmpty;
  }

  /// Check if user can send messages (verified users or premium)
  @override
  bool get canSendMessages {
    return isVerified || isPremium;
  }

  /// Check if user can create posts (verified users or premium)
  @override
  bool get canCreatePosts {
    return isVerified || isPremium;
  }

  /// Get display name or username as fallback
  @override
  String get displayNameOrUsername {
    return displayName.isNotEmpty ? displayName : username;
  }

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      username: entity.username,
      displayName: entity.displayName,
      bio: entity.bio,
      avatar: entity.avatar,
      coverPhoto: entity.coverPhoto,
      followers: entity.followers,
      following: entity.following,
      posts: entity.posts,
      isVerified: entity.isVerified,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      location: entity.location,
      age: entity.age,
      gender: entity.gender,
      interests: entity.interests,
    );
  }

  /// Convert to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      username: username,
      displayName: displayName,
      bio: bio,
      avatar: avatar,
      coverPhoto: coverPhoto,
      followers: followers,
      following: following,
      posts: posts,
      isVerified: isVerified,
      isPremium: isPremium,
      createdAt: createdAt,
      updatedAt: updatedAt,
      location: location,
      age: age,
      gender: gender,
      interests: interests,
    );
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'avatar': avatar,
      'coverPhoto': coverPhoto,
      'followers': followers,
      'following': following,
      'posts': posts,
      'isVerified': isVerified,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location,
      'age': age,
      'gender': gender,
      'interests': interests,
    };
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      coverPhoto: json['coverPhoto'] as String? ?? '',
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      posts: json['posts'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      location: json['location'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Create a copy with updated fields
  @override
  UserModel copyWith({
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
    return UserModel(
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
}
