import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';

/// Profile Model - Data Layer
///
/// Extends ProfileEntity with JSON serialization capabilities.
/// Handles conversion between Firestore documents and domain entities.
///
/// Clean Architecture: Data Layer
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
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
    super.location,
    super.age,
    super.gender,
    super.interests,
    super.voicePrompts,
    super.videoIntroUrl,
    super.email,
    super.phoneNumber,
    super.website,
    super.socialLinks,
    super.stats,
  });

  /// Create from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uid: json['uid'] as String,
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
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
      location: json['location'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      voicePrompts: (json['voicePrompts'] as List<dynamic>?)
          ?.map((e) => VoicePromptEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoIntroUrl: json['videoIntroUrl'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      socialLinks: (json['socialLinks'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as String)),
      stats: json['stats'] != null
          ? ProfileStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Create from Firestore document
  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileModel.fromJson({
      ...data,
      'uid': doc.id,
    });
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
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
      if (location != null) 'location': location,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (interests != null) 'interests': interests,
      if (voicePrompts != null)
        'voicePrompts': voicePrompts!.map((e) => e.toJson()).toList(),
      if (videoIntroUrl != null) 'videoIntroUrl': videoIntroUrl,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (website != null) 'website': website,
      if (socialLinks != null) 'socialLinks': socialLinks,
      if (stats != null) 'stats': (stats as ProfileStatsModel).toJson(),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Convert to ProfileEntity
  ProfileEntity toEntity() {
    return ProfileEntity(
      uid: uid,
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
      voicePrompts: voicePrompts,
      videoIntroUrl: videoIntroUrl,
      email: email,
      phoneNumber: phoneNumber,
      website: website,
      socialLinks: socialLinks,
      stats: stats,
    );
  }

  @override
  ProfileModel copyWith({
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
    return ProfileModel(
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
}

/// Profile Stats Model - Data Layer
class ProfileStatsModel extends ProfileStats {
  const ProfileStatsModel({
    required super.totalPosts,
    required super.totalLikes,
    required super.totalComments,
    required super.totalShares,
    required super.totalViews,
    super.postsData,
    super.followersData,
    super.likesData,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      totalPosts: json['totalPosts'] as int? ?? 0,
      totalLikes: json['totalLikes'] as int? ?? 0,
      totalComments: json['totalComments'] as int? ?? 0,
      totalShares: json['totalShares'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      postsData: (json['postsData'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      followersData: (json['followersData'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      likesData: (json['likesData'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPosts': totalPosts,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'totalShares': totalShares,
      'totalViews': totalViews,
      if (postsData != null) 'postsData': postsData,
      if (followersData != null) 'followersData': followersData,
      if (likesData != null) 'likesData': likesData,
    };
  }
}

