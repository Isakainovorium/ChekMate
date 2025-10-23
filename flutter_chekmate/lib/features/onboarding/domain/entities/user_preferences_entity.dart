/// UserPreferencesEntity - Domain Layer
///
/// Pure Dart class representing user preferences collected during onboarding.
/// This is separate from OnboardingStateEntity to represent the final preferences
/// that will be saved to Firestore.
///
/// Clean Architecture: Domain Layer
class UserPreferencesEntity {
  const UserPreferencesEntity({
    required this.interests,
    required this.locationEnabled,
    this.locationName,
    this.age,
    this.gender,
    this.searchRadiusKm = 100.0,
    this.notificationPreferences,
  });

  // ========== FACTORY CONSTRUCTORS ==========

  /// Create empty preferences
  factory UserPreferencesEntity.empty() {
    return const UserPreferencesEntity(
      interests: [],
      locationEnabled: false,
    );
  }

  /// List of user's selected interest categories
  final List<String> interests;

  /// Whether user has enabled location services
  final bool locationEnabled;

  /// User's location name (city, country)
  final String? locationName;

  /// User's age
  final int? age;

  /// User's gender
  final String? gender;

  /// Search radius for location-based content (in kilometers)
  final double searchRadiusKm;

  /// Notification preferences (optional, can be set later)
  final NotificationPreferences? notificationPreferences;

  // ========== BUSINESS LOGIC METHODS ==========

  /// Check if preferences are valid (minimum requirements met)
  bool get isValid => interests.isNotEmpty && interests.length >= 3;

  /// Check if user has provided optional information
  bool get hasOptionalInfo {
    return age != null && gender != null && locationName != null;
  }

  /// Get completion percentage (0.0 - 1.0)
  double get completionPercentage {
    var completed = 0;
    const total = 5;

    // Required: Interests
    if (interests.isNotEmpty) completed++;

    // Optional fields
    if (locationEnabled) completed++;
    if (age != null) completed++;
    if (gender != null) completed++;
    if (notificationPreferences != null) completed++;

    return completed / total;
  }

  // ========== COPY WITH METHOD ==========

  /// Create a copy with updated fields
  UserPreferencesEntity copyWith({
    List<String>? interests,
    bool? locationEnabled,
    String? locationName,
    int? age,
    String? gender,
    double? searchRadiusKm,
    NotificationPreferences? notificationPreferences,
  }) {
    return UserPreferencesEntity(
      interests: interests ?? this.interests,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      locationName: locationName ?? this.locationName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }

  // ========== EQUALITY ==========

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserPreferencesEntity &&
        _listEquals(other.interests, interests) &&
        other.locationEnabled == locationEnabled &&
        other.locationName == locationName &&
        other.age == age &&
        other.gender == gender &&
        other.searchRadiusKm == searchRadiusKm &&
        other.notificationPreferences == notificationPreferences;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(interests),
      locationEnabled,
      locationName,
      age,
      gender,
      searchRadiusKm,
      notificationPreferences,
    );
  }

  @override
  String toString() {
    return 'UserPreferencesEntity('
        'interests: $interests, '
        'locationEnabled: $locationEnabled, '
        'locationName: $locationName, '
        'age: $age, '
        'gender: $gender, '
        'searchRadiusKm: $searchRadiusKm, '
        'notificationPreferences: $notificationPreferences)';
  }

  // Helper method for list equality
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final i in List.generate(a.length, (index) => index)) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// NotificationPreferences - Nested entity for notification settings
class NotificationPreferences {
  const NotificationPreferences({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.newFollowers = true,
    this.newLikes = true,
    this.newComments = true,
    this.newMessages = true,
    this.nearbyPosts = true,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool newFollowers;
  final bool newLikes;
  final bool newComments;
  final bool newMessages;
  final bool nearbyPosts;

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? newFollowers,
    bool? newLikes,
    bool? newComments,
    bool? newMessages,
    bool? nearbyPosts,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      newFollowers: newFollowers ?? this.newFollowers,
      newLikes: newLikes ?? this.newLikes,
      newComments: newComments ?? this.newComments,
      newMessages: newMessages ?? this.newMessages,
      nearbyPosts: nearbyPosts ?? this.nearbyPosts,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationPreferences &&
        other.pushEnabled == pushEnabled &&
        other.emailEnabled == emailEnabled &&
        other.newFollowers == newFollowers &&
        other.newLikes == newLikes &&
        other.newComments == newComments &&
        other.newMessages == newMessages &&
        other.nearbyPosts == nearbyPosts;
  }

  @override
  int get hashCode {
    return Object.hash(
      pushEnabled,
      emailEnabled,
      newFollowers,
      newLikes,
      newComments,
      newMessages,
      nearbyPosts,
    );
  }

  @override
  String toString() {
    return 'NotificationPreferences('
        'pushEnabled: $pushEnabled, '
        'emailEnabled: $emailEnabled, '
        'newFollowers: $newFollowers, '
        'newLikes: $newLikes, '
        'newComments: $newComments, '
        'newMessages: $newMessages, '
        'nearbyPosts: $nearbyPosts)';
  }
}
