import 'package:flutter_chekmate/features/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:flutter_chekmate/features/onboarding/domain/entities/user_preferences_entity.dart';

/// OnboardingRepository - Domain Layer
///
/// Abstract repository interface for onboarding operations.
/// Defines the contract that the data layer must implement.
///
/// Clean Architecture: Domain Layer
abstract class OnboardingRepository {
  // ========== ONBOARDING STATE METHODS ==========

  /// Get current onboarding state from local storage
  Future<OnboardingStateEntity> getOnboardingState();

  /// Save onboarding state to local storage
  Future<void> saveOnboardingState(OnboardingStateEntity state);

  /// Mark onboarding as completed
  Future<void> completeOnboarding();

  /// Reset onboarding (useful for testing or re-onboarding)
  Future<void> resetOnboarding();

  // ========== USER PREFERENCES METHODS ==========

  /// Get user preferences from local storage
  Future<UserPreferencesEntity> getUserPreferences();

  /// Save user preferences to local storage
  Future<void> saveUserPreferences(UserPreferencesEntity preferences);

  /// Save user preferences to Firestore (sync with backend)
  Future<void> syncPreferencesToFirestore(
    String userId,
    UserPreferencesEntity preferences,
  );

  // ========== STEP NAVIGATION METHODS ==========

  /// Move to next onboarding step
  Future<void> nextStep();

  /// Move to previous onboarding step
  Future<void> previousStep();

  /// Jump to specific step
  Future<void> goToStep(int step);

  // ========== INTERESTS METHODS ==========

  /// Save selected interests
  Future<void> saveInterests(List<String> interests);

  /// Get saved interests
  Future<List<String>> getInterests();

  // ========== LOCATION METHODS ==========

  /// Enable location services
  Future<void> enableLocation(String? locationName);

  /// Disable location services
  Future<void> disableLocation();

  /// Check if location is enabled
  Future<bool> isLocationEnabled();

  // ========== PROFILE METHODS ==========

  /// Mark profile photo as added
  Future<void> setProfilePhotoAdded(bool added);

  /// Save user age
  Future<void> saveAge(int age);

  /// Save user gender
  Future<void> saveGender(String gender);
}

