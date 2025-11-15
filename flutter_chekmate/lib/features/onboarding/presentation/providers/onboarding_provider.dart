import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding State
class OnboardingState {
  final int currentStep;
  final String? profilePhotoUrl;
  final List<String> selectedInterests;
  final String? location;
  final bool isLocationEnabled;
  final bool isCompleted;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.currentStep = 0,
    this.profilePhotoUrl,
    this.selectedInterests = const [],
    this.location,
    this.isLocationEnabled = false,
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
  });

  /// Alias for isLocationEnabled
  bool get locationEnabled => isLocationEnabled;

  /// Get location name (alias for location)
  String? get locationName => location;

  /// Check if profile photo was added
  bool get profilePhotoAdded => profilePhotoUrl != null;

  /// Calculate completion score (0-100)
  int get completionScore {
    int score = 0;

    // Profile photo: 25 points
    if (profilePhotoUrl != null) score += 25;

    // Interests: 25 points (need at least 3)
    if (selectedInterests.length >= 3) score += 25;

    // Location: 25 points
    if (location != null || isLocationEnabled) score += 25;

    // Completion: 25 points
    if (isCompleted) score += 25;

    return score;
  }

  OnboardingState copyWith({
    int? currentStep,
    String? profilePhotoUrl,
    List<String>? selectedInterests,
    String? location,
    bool? isLocationEnabled,
    bool? isCompleted,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      location: location ?? this.location,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Check if user can proceed to next step
  bool get canProceed {
    switch (currentStep) {
      case 0: // Welcome screen
        return true;
      case 1: // Profile photo
        return profilePhotoUrl != null;
      case 2: // Interests
        return selectedInterests.length >= 3;
      case 3: // Location
        return location != null || isLocationEnabled;
      case 4: // Completion
        return true;
      default:
        return false;
    }
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progress {
    return (currentStep + 1) / 5;
  }
}

/// Onboarding State Notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final FirebaseFirestore _firestore;

  OnboardingNotifier(this._firestore) : super(const OnboardingState());

  /// Move to next step
  void nextStep() {
    if (state.canProceed && state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Move to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }

  /// Save profile photo URL
  Future<void> saveProfilePhoto(String photoUrl) async {
    state = state.copyWith(
      profilePhotoUrl: photoUrl,
      isLoading: false,
    );
  }

  /// Save selected interests
  Future<void> saveInterests(List<String> interests) async {
    state = state.copyWith(
      selectedInterests: interests,
      isLoading: false,
    );
  }

  /// Enable location with location name
  Future<void> enableLocation(String locationName) async {
    state = state.copyWith(
      location: locationName,
      isLocationEnabled: true,
      isLoading: false,
    );
  }

  /// Skip location step
  void skipLocation() {
    state = state.copyWith(
      isLocationEnabled: false,
      isLoading: false,
    );
  }

  /// Complete onboarding and save to Firestore
  Future<void> completeOnboarding(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Update user document in Firestore with onboarding data
      await _firestore.collection('users').doc(userId).update({
        'onboardingCompleted': true,
        'profilePhoto': state.profilePhotoUrl,
        'interests': state.selectedInterests,
        'location': state.location,
        'isLocationEnabled': state.isLocationEnabled,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(
        isCompleted: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Reset onboarding state
  void reset() {
    state = const OnboardingState();
  }

  /// Load onboarding state from Firestore
  Future<void> loadOnboardingState(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        state = state.copyWith(
          isCompleted: data['onboardingCompleted'] as bool? ?? false,
          profilePhotoUrl: data['profilePhoto'] as String?,
          selectedInterests:
              List<String>.from(data['interests'] as List? ?? []),
          location: data['location'] as String?,
          isLocationEnabled: data['isLocationEnabled'] as bool? ?? false,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Onboarding State Provider
final onboardingStateProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(FirebaseFirestore.instance);
});

/// Is Onboarding Completed Provider
/// Checks if onboarding is completed for a user
final isOnboardingCompletedProvider =
    StreamProvider.family<bool, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return false;
    final data = snapshot.data();
    return data?['onboardingCompleted'] as bool? ?? false;
  });
});

/// Available Interests Provider
/// Provides the list of available interests for selection
final availableInterestsProvider = Provider<List<String>>((ref) {
  return [
    'Travel',
    'Fitness',
    'Music',
    'Movies',
    'Food',
    'Art',
    'Photography',
    'Sports',
    'Gaming',
    'Reading',
    'Cooking',
    'Dancing',
    'Yoga',
    'Hiking',
    'Fashion',
    'Technology',
    'Pets',
    'Coffee',
    'Wine',
    'Concerts',
    'Theater',
    'Museums',
    'Beach',
    'Mountains',
    'Volunteering',
  ];
});
