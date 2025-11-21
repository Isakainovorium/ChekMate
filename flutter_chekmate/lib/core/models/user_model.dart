/// User Model - Core user data model
///
/// Represents a user in the ChekMate application.
class UserModel {
  UserModel({
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

  /// Get formatted posts count (e.g., "1.2K", "3.5M")
  String get formattedPosts {
    if (posts >= 1000000) {
      return '${(posts / 1000000).toStringAsFixed(1)}M';
    } else if (posts >= 1000) {
      return '${(posts / 1000).toStringAsFixed(1)}K';
    } else {
      return posts.toString();
    }
  }

  /// Convert UserModel to JSON for Firestore
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

  /// Create UserModel from JSON (Firestore document)
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


