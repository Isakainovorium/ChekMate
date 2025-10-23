import 'package:flutter_chekmate/features/onboarding/data/datasources/preferences_local_datasource.dart';
import 'package:flutter_chekmate/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:flutter_chekmate/features/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:flutter_chekmate/features/onboarding/domain/entities/user_preferences_entity.dart';
import 'package:flutter_chekmate/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ========== PROVIDERS ==========

/// Provider for PreferencesLocalDatasource
final preferencesLocalDatasourceProvider = Provider<PreferencesLocalDatasource>(
  (ref) => PreferencesLocalDatasource(),
);

/// Provider for OnboardingRepository
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(
    localDatasource: ref.watch(preferencesLocalDatasourceProvider),
  ),
);

/// Provider for OnboardingState
final onboardingStateProvider =
    StateNotifierProvider<OnboardingStateNotifier, OnboardingStateEntity>(
  (ref) => OnboardingStateNotifier(
    repository: ref.watch(onboardingRepositoryProvider),
  ),
);

// ========== STATE NOTIFIER ==========

/// OnboardingStateNotifier - Presentation Layer
///
/// Manages onboarding state using Riverpod StateNotifier.
/// Handles all onboarding flow logic and persistence.
///
/// Clean Architecture: Presentation Layer
class OnboardingStateNotifier extends StateNotifier<OnboardingStateEntity> {
  OnboardingStateNotifier({
    required OnboardingRepository repository,
  })  : _repository = repository,
        super(OnboardingStateEntity.initial()) {
    _loadState();
  }

  final OnboardingRepository _repository;

  /// Load onboarding state from local storage
  Future<void> _loadState() async {
    try {
      final loadedState = await _repository.getOnboardingState();
      state = loadedState;
    } on Exception {
      // If loading fails, keep initial state
      state = OnboardingStateEntity.initial();
    }
  }

  /// Refresh state from local storage
  Future<void> refreshState() async {
    await _loadState();
  }

  // ========== STEP NAVIGATION ==========

  /// Move to next step
  Future<void> nextStep() async {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
      await _repository.saveOnboardingState(state);
    }
  }

  /// Move to previous step
  Future<void> previousStep() async {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
      await _repository.saveOnboardingState(state);
    }
  }

  /// Jump to specific step
  Future<void> goToStep(int step) async {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
      await _repository.saveOnboardingState(state);
    }
  }

  // ========== INTERESTS ==========

  /// Save selected interests
  Future<void> saveInterests(List<String> interests) async {
    try {
      state = state.copyWith(
        selectedInterests: interests,
        interestsSelected: interests.isNotEmpty,
      );
      await _repository.saveInterests(interests);
      await _repository.saveOnboardingState(state);
    } catch (e) {
      throw Exception('Failed to save interests: $e');
    }
  }

  /// Add interest to selection
  Future<void> addInterest(String interest) async {
    final updatedInterests = [...state.selectedInterests, interest];
    await saveInterests(updatedInterests);
  }

  /// Remove interest from selection
  Future<void> removeInterest(String interest) async {
    final updatedInterests =
        state.selectedInterests.where((i) => i != interest).toList();
    await saveInterests(updatedInterests);
  }

  /// Toggle interest selection
  Future<void> toggleInterest(String interest) async {
    if (state.selectedInterests.contains(interest)) {
      await removeInterest(interest);
    } else {
      await addInterest(interest);
    }
  }

  // ========== LOCATION ==========

  /// Enable location services
  Future<void> enableLocation(String? locationName) async {
    try {
      state = state.copyWith(
        locationEnabled: true,
        locationName: locationName,
      );
      await _repository.enableLocation(locationName);
      await _repository.saveOnboardingState(state);
    } catch (e) {
      throw Exception('Failed to enable location: $e');
    }
  }

  /// Disable location services
  Future<void> disableLocation() async {
    try {
      state = state.copyWith(
        locationEnabled: false,
      );
      await _repository.disableLocation();
      await _repository.saveOnboardingState(state);
    } catch (e) {
      throw Exception('Failed to disable location: $e');
    }
  }

  /// Update search radius
  Future<void> updateSearchRadius(double radiusKm) async {
    try {
      state = state.copyWith(searchRadiusKm: radiusKm);
      await _repository.saveOnboardingState(state);
    } catch (e) {
      throw Exception('Failed to update search radius: $e');
    }
  }

  // ========== PROFILE ==========

  /// Set profile photo added status
  Future<void> setProfilePhotoAdded(bool added) async {
    try {
      state = state.copyWith(profilePhotoAdded: added);
      await _repository.setProfilePhotoAdded(added);
      await _repository.saveOnboardingState(state);
    } catch (e) {
      throw Exception('Failed to set profile photo status: $e');
    }
  }

  /// Save user age
  Future<void> saveAge(int age) async {
    try {
      state = state.copyWith(age: age);
      await _repository.saveAge(age);
      await _repository.saveOnboardingState(state);
    } catch (e) {
      throw Exception('Failed to save age: $e');
    }
  }

  /// Save user gender
  Future<void> saveGender(String gender) async {
    try {
      state = state.copyWith(gender: gender);
      await _repository.saveGender(gender);
      await _repository.saveOnboardingState(state);
    } catch (e) {
      throw Exception('Failed to save gender: $e');
    }
  }

  // ========== COMPLETION ==========

  /// Complete onboarding
  Future<void> completeOnboarding(String userId) async {
    try {
      // Mark as completed
      state = state.copyWith(isCompleted: true, currentStep: 4);
      await _repository.completeOnboarding();

      // Sync preferences to Firestore
      final preferences = UserPreferencesEntity(
        interests: state.selectedInterests,
        locationEnabled: state.locationEnabled,
        locationName: state.locationName,
        age: state.age,
        gender: state.gender,
        searchRadiusKm: state.searchRadiusKm,
      );

      await _repository.syncPreferencesToFirestore(userId, preferences);
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  /// Reset onboarding (useful for testing or re-onboarding)
  Future<void> resetOnboarding() async {
    try {
      await _repository.resetOnboarding();
      state = OnboardingStateEntity.initial();
    } catch (e) {
      throw Exception('Failed to reset onboarding: $e');
    }
  }

  // ========== VALIDATION ==========

  /// Check if current step can proceed
  bool canProceed() {
    return state.canProceedToNextStep;
  }

  /// Get validation error message for current step
  String? getValidationError() {
    switch (state.currentStep) {
      case 1: // Interests
        if (state.selectedInterests.length < 3) {
          return 'Please select at least 3 interests';
        }
        return null;
      default:
        return null;
    }
  }
}
