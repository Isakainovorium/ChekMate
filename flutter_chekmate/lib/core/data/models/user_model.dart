import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // Constructors first
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.role,
    required this.subscriptionTier,
    this.metadata = const {},
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] as String,
      email: data['email'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      role: UserRole.fromString(data['role'] as String? ?? 'user'),
      subscriptionTier: SubscriptionTier.fromString(
        data['subscription_tier'] as String? ?? 'free',
      ),
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  // Fields
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final UserRole role;
  final SubscriptionTier subscriptionTier;
  final Map<String, dynamic> metadata;

  // Strategic getters that encapsulate business logic
  bool get isCreator => role == UserRole.creator || role == UserRole.admin;
  bool get isPremium => subscriptionTier.isPremiumTier;
  bool get canCreatePosts => isCreator || isPremium;
  bool get hasUnlimitedMatches =>
      subscriptionTier == SubscriptionTier.professional;

  // Feature flags based on role and subscription
  FeatureAccess get featureAccess => FeatureAccess(
        canCreatePosts: canCreatePosts,
        canViewAnalytics: isPremium,
        canSchedulePosts: role == UserRole.creator,
        maxDailyMatches: subscriptionTier.dailyMatchLimit,
      );

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'role': role.value,
      'subscription_tier': subscriptionTier.value,
      'metadata': metadata,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
    UserRole? role,
    SubscriptionTier? subscriptionTier,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Enum with business logic encapsulation
enum UserRole {
  user('user'),
  creator('creator'),
  moderator('moderator'),
  admin('admin');

  // Constructor first
  const UserRole(this.value);

  // Fields
  final String value;

  // Methods
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }
}

enum SubscriptionTier {
  free('free', 5),
  basic('basic', 20),
  premium('premium', 50),
  professional('professional', -1); // -1 represents unlimited

  // Constructor first
  const SubscriptionTier(this.value, this.dailyMatchLimit);

  // Fields
  final String value;
  final int dailyMatchLimit;

  // Getters and methods
  bool get isPremiumTier => this == premium || this == professional;

  static SubscriptionTier fromString(String value) {
    return SubscriptionTier.values.firstWhere(
      (tier) => tier.value == value,
      orElse: () => SubscriptionTier.free,
    );
  }
}

class FeatureAccess {
  // Constructor first
  const FeatureAccess({
    required this.canCreatePosts,
    required this.canViewAnalytics,
    required this.canSchedulePosts,
    required this.maxDailyMatches,
  });

  // Fields
  final bool canCreatePosts;
  final bool canViewAnalytics;
  final bool canSchedulePosts;
  final int maxDailyMatches;
}
