/// OnboardingStateEntity - Domain Layer
///
/// Pure Dart class representing the state of user onboarding process.
/// Contains no framework dependencies - only business logic.
///
/// Clean Architecture: Domain Layer
class OnboardingStateEntity {
  // ========== FACTORY CONSTRUCTORS ==========

  /// Create initial onboarding state
  factory OnboardingStateEntity.initial() {
    return const OnboardingStateEntity(
      isCompleted: false,
      currentStep: 0,
      interestsSelected: false,
      locationEnabled: false,
      profilePhotoAdded: false,
      selectedInterests: [],
    );
  }

  /// Create completed onboarding state
  factory OnboardingStateEntity.completed({
    required List<String> interests,
    bool locationEnabled = false,
    bool profilePhotoAdded = false,
    String? locationName,
    int? age,
    String? gender,
  }) {
    return OnboardingStateEntity(
      isCompleted: true,
      currentStep: 4,
      interestsSelected: true,
      locationEnabled: locationEnabled,
      profilePhotoAdded: profilePhotoAdded,
      selectedInterests: interests,
      locationName: locationName,
      age: age,
      gender: gender,
    );
  }
  const OnboardingStateEntity({
    required this.isCompleted,
    required this.currentStep,
    required this.interestsSelected,
    required this.locationEnabled,
    required this.profilePhotoAdded,
    required this.selectedInterests,
    this.locationName,
    this.age,
    this.gender,
    this.searchRadiusKm = 100.0,
  });

  /// Whether onboarding has been completed
  final bool isCompleted;

  /// Current step in onboarding flow (0-4)
  /// 0: Welcome
  /// 1: Interests Selection
  /// 2: Location Permission
  /// 3: Profile Photo
  /// 4: Completion
  final int currentStep;

  /// Whether user has selected interests
  final bool interestsSelected;

  /// Whether user has enabled location services
  final bool locationEnabled;

  /// Whether user has added a profile photo
  final bool profilePhotoAdded;

  /// List of selected interest categories
  final List<String> selectedInterests;

  /// User's location name (city, country)
  final String? locationName;

  /// User's age
  final int? age;

  /// User's gender
  final String? gender;

  /// Search radius for location-based content (in kilometers)
  final double searchRadiusKm;

  // ========== BUSINESS LOGIC METHODS ==========

  /// Check if user can proceed to next step
  bool get canProceedToNextStep {
    switch (currentStep) {
      case 0: // Welcome screen - always can proceed
        return true;
      case 1: // Interests - need at least 3 interests
        return interestsSelected && selectedInterests.length >= 3;
      case 2: // Location - can skip, so always can proceed
        return true;
      case 3: // Profile photo - can skip, so always can proceed
        return true;
      case 4: // Completion - already at end
        return true;
      default:
        return false;
    }
  }

  /// Check if onboarding is ready to be marked as complete
  bool get isReadyToComplete {
    return currentStep >= 4 &&
        interestsSelected &&
        selectedInterests.length >= 3;
  }

  /// Get progress percentage (0.0 - 1.0)
  double get progressPercentage {
    return (currentStep + 1) / 5.0;
  }

  /// Get human-readable step name
  String get currentStepName {
    switch (currentStep) {
      case 0:
        return 'Welcome';
      case 1:
        return 'Select Interests';
      case 2:
        return 'Enable Location';
      case 3:
        return 'Add Profile Photo';
      case 4:
        return 'Complete';
      default:
        return 'Unknown';
    }
  }

  /// Check if user has completed minimum requirements
  /// (at least 3 interests selected)
  bool get hasMinimumRequirements {
    return selectedInterests.length >= 3;
  }

  /// Check if user has completed optional steps
  bool get hasCompletedOptionalSteps {
    return locationEnabled && profilePhotoAdded;
  }

  /// Get completion score (0-100)
  /// Based on required and optional steps completed
  int get completionScore {
    var score = 0;

    // Required: Interests (50 points)
    if (interestsSelected && selectedInterests.length >= 3) {
      score += 50;
    }

    // Optional: Location (25 points)
    if (locationEnabled) {
      score += 25;
    }

    // Optional: Profile Photo (25 points)
    if (profilePhotoAdded) {
      score += 25;
    }

    return score;
  }

  // ========== COPY WITH METHOD ==========

  /// Create a copy with updated fields
  OnboardingStateEntity copyWith({
    bool? isCompleted,
    int? currentStep,
    bool? interestsSelected,
    bool? locationEnabled,
    bool? profilePhotoAdded,
    List<String>? selectedInterests,
    String? locationName,
    int? age,
    String? gender,
    double? searchRadiusKm,
  }) {
    return OnboardingStateEntity(
      isCompleted: isCompleted ?? this.isCompleted,
      currentStep: currentStep ?? this.currentStep,
      interestsSelected: interestsSelected ?? this.interestsSelected,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      profilePhotoAdded: profilePhotoAdded ?? this.profilePhotoAdded,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      locationName: locationName ?? this.locationName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
    );
  }

  // ========== EQUALITY ==========

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OnboardingStateEntity &&
        other.isCompleted == isCompleted &&
        other.currentStep == currentStep &&
        other.interestsSelected == interestsSelected &&
        other.locationEnabled == locationEnabled &&
        other.profilePhotoAdded == profilePhotoAdded &&
        _listEquals(other.selectedInterests, selectedInterests) &&
        other.locationName == locationName &&
        other.age == age &&
        other.gender == gender &&
        other.searchRadiusKm == searchRadiusKm;
  }

  @override
  int get hashCode {
    return Object.hash(
      isCompleted,
      currentStep,
      interestsSelected,
      locationEnabled,
      profilePhotoAdded,
      Object.hashAll(selectedInterests),
      locationName,
      age,
      gender,
      searchRadiusKm,
    );
  }

  @override
  String toString() {
    return 'OnboardingStateEntity('
        'isCompleted: $isCompleted, '
        'currentStep: $currentStep, '
        'interestsSelected: $interestsSelected, '
        'locationEnabled: $locationEnabled, '
        'profilePhotoAdded: $profilePhotoAdded, '
        'selectedInterests: $selectedInterests, '
        'locationName: $locationName, '
        'age: $age, '
        'gender: $gender, '
        'searchRadiusKm: $searchRadiusKm)';
  }

  // Helper method for list equality
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
