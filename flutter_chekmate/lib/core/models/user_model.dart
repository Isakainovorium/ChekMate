import 'package:cloud_firestore/cloud_firestore.dart';

/// User Model
/// Represents a user in the ChekMate app
class UserModel {
  UserModel({
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
    this.location,
    this.age,
    this.gender,
    this.interests,
    this.settings,
  });

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
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      location: json['location'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }
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
  final List<String>? interests;
  final Map<String, dynamic>? settings;

  /// Convert UserModel to JSON
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
      if (location != null) 'location': location,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (interests != null) 'interests': interests,
      if (settings != null) 'settings': settings,
    };
  }

  /// Create a copy with updated fields
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
    Map<String, dynamic>? settings,
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
      settings: settings ?? this.settings,
    );
  }
}
