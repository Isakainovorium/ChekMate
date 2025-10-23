import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';

/// User Model - Data Layer
///
/// This class extends UserEntity and adds JSON serialization capabilities.
/// It knows how to convert between Firestore documents and domain entities.
///
/// Clean Architecture: Data Layer
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.username,
    required super.displayName,
    required super.bio,
    required super.avatar,
    required super.coverPhoto,
    required super.followers,
    required super.following,
    required super.posts,
    required super.isVerified,
    required super.isPremium,
    required super.createdAt,
    required super.updatedAt,
    super.onboardingCompleted = false,
    super.location,
    super.age,
    super.gender,
    super.interests,
    super.voicePrompts,
    super.videoIntroUrl,
    super.coordinates,
    super.geohash,
    super.locationEnabled = false,
    super.searchRadiusKm = 100.0,
  });

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
      onboardingCompleted: entity.onboardingCompleted,
      location: entity.location,
      age: entity.age,
      gender: entity.gender,
      interests: entity.interests,
      voicePrompts: entity.voicePrompts,
      videoIntroUrl: entity.videoIntroUrl,
      coordinates: entity.coordinates,
      geohash: entity.geohash,
      locationEnabled: entity.locationEnabled,
      searchRadiusKm: entity.searchRadiusKm,
    );
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      avatar: data['avatar'] as String? ?? '',
      coverPhoto: data['coverPhoto'] as String? ?? '',
      followers: data['followers'] as int? ?? 0,
      following: data['following'] as int? ?? 0,
      posts: data['posts'] as int? ?? 0,
      isVerified: data['isVerified'] as bool? ?? false,
      isPremium: data['isPremium'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      location: data['location'] as String?,
      age: data['age'] as int?,
      gender: data['gender'] as String?,
      interests: (data['interests'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      voicePrompts: (data['voicePrompts'] as List<dynamic>?)
          ?.map((e) => VoicePromptEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoIntroUrl: data['videoIntroUrl'] as String?,
      coordinates: data['coordinates'] as GeoPoint?,
      geohash: data['geohash'] as String?,
      locationEnabled: data['locationEnabled'] as bool? ?? false,
      searchRadiusKm: (data['searchRadiusKm'] as num?)?.toDouble() ?? 100.0,
    );
  }

  /// Create UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      coverPhoto: json['coverPhoto'] as String? ?? '',
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      posts: json['posts'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      location: json['location'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      voicePrompts: (json['voicePrompts'] as List<dynamic>?)
          ?.map((e) => VoicePromptEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoIntroUrl: json['videoIntroUrl'] as String?,
      coordinates: json['coordinates'] as GeoPoint?,
      geohash: json['geohash'] as String?,
      locationEnabled: json['locationEnabled'] as bool? ?? false,
      searchRadiusKm: (json['searchRadiusKm'] as num?)?.toDouble() ?? 100.0,
    );
  }

  /// Convert to JSON map
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'onboardingCompleted': onboardingCompleted,
      'locationEnabled': locationEnabled,
      'searchRadiusKm': searchRadiusKm,
      if (location != null) 'location': location,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (interests != null) 'interests': interests,
      if (voicePrompts != null)
        'voicePrompts': voicePrompts!.map((e) => e.toJson()).toList(),
      if (videoIntroUrl != null) 'videoIntroUrl': videoIntroUrl,
      if (coordinates != null) 'coordinates': coordinates,
      if (geohash != null) 'geohash': geohash,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toJson();
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
      onboardingCompleted: onboardingCompleted,
      location: location,
      age: age,
      gender: gender,
      interests: interests,
      voicePrompts: voicePrompts,
      coordinates: coordinates,
      geohash: geohash,
      locationEnabled: locationEnabled,
      searchRadiusKm: searchRadiusKm,
    );
  }

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
}
