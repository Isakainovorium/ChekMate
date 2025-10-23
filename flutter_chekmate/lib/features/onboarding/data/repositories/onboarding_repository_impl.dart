import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/onboarding/data/datasources/preferences_local_datasource.dart';
import 'package:flutter_chekmate/features/onboarding/domain/entities/onboarding_state_entity.dart';
import 'package:flutter_chekmate/features/onboarding/domain/entities/user_preferences_entity.dart';
import 'package:flutter_chekmate/features/onboarding/domain/repositories/onboarding_repository.dart';

/// OnboardingRepositoryImpl - Data Layer
///
/// Concrete implementation of OnboardingRepository.
/// Handles data operations using PreferencesLocalDatasource and Firestore.
///
/// Clean Architecture: Data Layer
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required PreferencesLocalDatasource localDatasource,
    FirebaseFirestore? firestore,
  })  : _localDatasource = localDatasource,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final PreferencesLocalDatasource _localDatasource;
  final FirebaseFirestore _firestore;

  // ========== ONBOARDING STATE METHODS ==========

  @override
  Future<OnboardingStateEntity> getOnboardingState() async {
    try {
      final isCompleted = await _localDatasource.isOnboardingCompleted();
      final currentStep = await _localDatasource.getCurrentStep();
      final interests = await _localDatasource.getInterests();
      final locationEnabled = await _localDatasource.isLocationEnabled();
      final profilePhotoAdded = await _localDatasource.isProfilePhotoAdded();
      final locationName = await _localDatasource.getLocationName();
      final age = await _localDatasource.getAge();
      final gender = await _localDatasource.getGender();
      final searchRadiusKm = await _localDatasource.getSearchRadius();

      return OnboardingStateEntity(
        isCompleted: isCompleted,
        currentStep: currentStep,
        interestsSelected: interests.isNotEmpty,
        locationEnabled: locationEnabled,
        profilePhotoAdded: profilePhotoAdded,
        selectedInterests: interests,
        locationName: locationName,
        age: age,
        gender: gender,
        searchRadiusKm: searchRadiusKm,
      );
    } catch (e) {
      throw Exception('Failed to get onboarding state: $e');
    }
  }

  @override
  Future<void> saveOnboardingState(OnboardingStateEntity state) async {
    try {
      await _localDatasource.setOnboardingCompleted(state.isCompleted);
      await _localDatasource.setCurrentStep(state.currentStep);
      await _localDatasource.saveInterests(state.selectedInterests);
      await _localDatasource.setLocationEnabled(state.locationEnabled);
      await _localDatasource.setProfilePhotoAdded(state.profilePhotoAdded);

      if (state.locationName != null) {
        await _localDatasource.saveLocationName(state.locationName!);
      }

      if (state.age != null) {
        await _localDatasource.saveAge(state.age!);
      }

      if (state.gender != null) {
        await _localDatasource.saveGender(state.gender!);
      }

      await _localDatasource.setSearchRadius(state.searchRadiusKm);
    } catch (e) {
      throw Exception('Failed to save onboarding state: $e');
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await _localDatasource.setOnboardingCompleted(true);
      await _localDatasource.setCurrentStep(4);
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  @override
  Future<void> resetOnboarding() async {
    try {
      await _localDatasource.clearAllPreferences();
    } catch (e) {
      throw Exception('Failed to reset onboarding: $e');
    }
  }

  // ========== USER PREFERENCES METHODS ==========

  @override
  Future<UserPreferencesEntity> getUserPreferences() async {
    try {
      final interests = await _localDatasource.getInterests();
      final locationEnabled = await _localDatasource.isLocationEnabled();
      final locationName = await _localDatasource.getLocationName();
      final age = await _localDatasource.getAge();
      final gender = await _localDatasource.getGender();
      final searchRadiusKm = await _localDatasource.getSearchRadius();

      return UserPreferencesEntity(
        interests: interests,
        locationEnabled: locationEnabled,
        locationName: locationName,
        age: age,
        gender: gender,
        searchRadiusKm: searchRadiusKm,
      );
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferencesEntity preferences) async {
    try {
      await _localDatasource.saveInterests(preferences.interests);
      await _localDatasource.setLocationEnabled(preferences.locationEnabled);

      if (preferences.locationName != null) {
        await _localDatasource.saveLocationName(preferences.locationName!);
      }

      if (preferences.age != null) {
        await _localDatasource.saveAge(preferences.age!);
      }

      if (preferences.gender != null) {
        await _localDatasource.saveGender(preferences.gender!);
      }

      await _localDatasource.setSearchRadius(preferences.searchRadiusKm);
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  @override
  Future<void> syncPreferencesToFirestore(
    String userId,
    UserPreferencesEntity preferences,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'interests': preferences.interests,
        'locationEnabled': preferences.locationEnabled,
        if (preferences.locationName != null)
          'location': preferences.locationName,
        if (preferences.age != null) 'age': preferences.age,
        if (preferences.gender != null) 'gender': preferences.gender,
        'searchRadiusKm': preferences.searchRadiusKm,
        'onboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to sync preferences to Firestore: $e');
    }
  }

  // ========== STEP NAVIGATION METHODS ==========

  @override
  Future<void> nextStep() async {
    try {
      final currentStep = await _localDatasource.getCurrentStep();
      if (currentStep < 4) {
        await _localDatasource.setCurrentStep(currentStep + 1);
      }
    } catch (e) {
      throw Exception('Failed to go to next step: $e');
    }
  }

  @override
  Future<void> previousStep() async {
    try {
      final currentStep = await _localDatasource.getCurrentStep();
      if (currentStep > 0) {
        await _localDatasource.setCurrentStep(currentStep - 1);
      }
    } catch (e) {
      throw Exception('Failed to go to previous step: $e');
    }
  }

  @override
  Future<void> goToStep(int step) async {
    try {
      if (step >= 0 && step <= 4) {
        await _localDatasource.setCurrentStep(step);
      } else {
        throw Exception('Invalid step: $step. Must be between 0 and 4.');
      }
    } catch (e) {
      throw Exception('Failed to go to step $step: $e');
    }
  }

  // ========== INTERESTS METHODS ==========

  @override
  Future<void> saveInterests(List<String> interests) async {
    try {
      await _localDatasource.saveInterests(interests);
    } catch (e) {
      throw Exception('Failed to save interests: $e');
    }
  }

  @override
  Future<List<String>> getInterests() async {
    try {
      return await _localDatasource.getInterests();
    } catch (e) {
      throw Exception('Failed to get interests: $e');
    }
  }

  // ========== LOCATION METHODS ==========

  @override
  Future<void> enableLocation(String? locationName) async {
    try {
      await _localDatasource.setLocationEnabled(true);
      if (locationName != null) {
        await _localDatasource.saveLocationName(locationName);
      }
    } catch (e) {
      throw Exception('Failed to enable location: $e');
    }
  }

  @override
  Future<void> disableLocation() async {
    try {
      await _localDatasource.setLocationEnabled(false);
    } catch (e) {
      throw Exception('Failed to disable location: $e');
    }
  }

  @override
  Future<bool> isLocationEnabled() async {
    try {
      return await _localDatasource.isLocationEnabled();
    } catch (e) {
      throw Exception('Failed to check location status: $e');
    }
  }

  // ========== PROFILE METHODS ==========

  @override
  Future<void> setProfilePhotoAdded(bool added) async {
    try {
      await _localDatasource.setProfilePhotoAdded(added);
    } catch (e) {
      throw Exception('Failed to set profile photo status: $e');
    }
  }

  @override
  Future<void> saveAge(int age) async {
    try {
      await _localDatasource.saveAge(age);
    } catch (e) {
      throw Exception('Failed to save age: $e');
    }
  }

  @override
  Future<void> saveGender(String gender) async {
    try {
      await _localDatasource.saveGender(gender);
    } catch (e) {
      throw Exception('Failed to save gender: $e');
    }
  }
}

