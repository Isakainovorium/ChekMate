import 'package:shared_preferences/shared_preferences.dart';

/// PreferencesLocalDatasource - Data Layer
///
/// Handles local storage of user preferences and onboarding state using SharedPreferences.
/// Follows the same pattern as SearchRepositoryImpl for consistency.
///
/// Clean Architecture: Data Layer
class PreferencesLocalDatasource {
  PreferencesLocalDatasource({SharedPreferences? prefs}) : _prefs = prefs;

  final SharedPreferences? _prefs;

  // Keys for SharedPreferences
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _interestsKey = 'user_interests';
  static const String _locationEnabledKey = 'location_enabled';
  static const String _currentStepKey = 'onboarding_current_step';
  static const String _profilePhotoAddedKey = 'profile_photo_added';
  static const String _ageKey = 'user_age';
  static const String _genderKey = 'user_gender';
  static const String _locationNameKey = 'user_location_name';
  static const String _searchRadiusKey = 'search_radius_km';

  // ========== ONBOARDING STATE METHODS ==========

  /// Check if user has completed onboarding
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      throw Exception('Failed to check onboarding status: $e');
    }
  }

  /// Set onboarding completion status
  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, completed);
    } catch (e) {
      throw Exception('Failed to set onboarding status: $e');
    }
  }

  /// Get current onboarding step (0-4)
  Future<int> getCurrentStep() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getInt(_currentStepKey) ?? 0;
    } catch (e) {
      throw Exception('Failed to get current step: $e');
    }
  }

  /// Set current onboarding step
  Future<void> setCurrentStep(int step) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setInt(_currentStepKey, step);
    } catch (e) {
      throw Exception('Failed to set current step: $e');
    }
  }

  // ========== INTERESTS METHODS ==========

  /// Get user's selected interests
  Future<List<String>> getInterests() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getStringList(_interestsKey) ?? [];
    } catch (e) {
      throw Exception('Failed to get interests: $e');
    }
  }

  /// Save user's selected interests
  Future<void> saveInterests(List<String> interests) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setStringList(_interestsKey, interests);
    } catch (e) {
      throw Exception('Failed to save interests: $e');
    }
  }

  /// Clear user's interests
  Future<void> clearInterests() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_interestsKey);
    } catch (e) {
      throw Exception('Failed to clear interests: $e');
    }
  }

  // ========== LOCATION METHODS ==========

  /// Check if location is enabled
  Future<bool> isLocationEnabled() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getBool(_locationEnabledKey) ?? false;
    } catch (e) {
      throw Exception('Failed to check location status: $e');
    }
  }

  /// Set location enabled status
  Future<void> setLocationEnabled(bool enabled) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_locationEnabledKey, enabled);
    } catch (e) {
      throw Exception('Failed to set location status: $e');
    }
  }

  /// Get user's location name (city, country)
  Future<String?> getLocationName() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getString(_locationNameKey);
    } catch (e) {
      throw Exception('Failed to get location name: $e');
    }
  }

  /// Save user's location name
  Future<void> saveLocationName(String locationName) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_locationNameKey, locationName);
    } catch (e) {
      throw Exception('Failed to save location name: $e');
    }
  }

  /// Get search radius in kilometers (default: 100km)
  Future<double> getSearchRadius() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getDouble(_searchRadiusKey) ?? 100.0;
    } catch (e) {
      throw Exception('Failed to get search radius: $e');
    }
  }

  /// Set search radius in kilometers
  Future<void> setSearchRadius(double radiusKm) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setDouble(_searchRadiusKey, radiusKm);
    } catch (e) {
      throw Exception('Failed to set search radius: $e');
    }
  }

  // ========== PROFILE METHODS ==========

  /// Check if profile photo has been added
  Future<bool> isProfilePhotoAdded() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getBool(_profilePhotoAddedKey) ?? false;
    } catch (e) {
      throw Exception('Failed to check profile photo status: $e');
    }
  }

  /// Set profile photo added status
  Future<void> setProfilePhotoAdded(bool added) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_profilePhotoAddedKey, added);
    } catch (e) {
      throw Exception('Failed to set profile photo status: $e');
    }
  }

  /// Get user's age
  Future<int?> getAge() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getInt(_ageKey);
    } catch (e) {
      throw Exception('Failed to get age: $e');
    }
  }

  /// Save user's age
  Future<void> saveAge(int age) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setInt(_ageKey, age);
    } catch (e) {
      throw Exception('Failed to save age: $e');
    }
  }

  /// Get user's gender
  Future<String?> getGender() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getString(_genderKey);
    } catch (e) {
      throw Exception('Failed to get gender: $e');
    }
  }

  /// Save user's gender
  Future<void> saveGender(String gender) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_genderKey, gender);
    } catch (e) {
      throw Exception('Failed to save gender: $e');
    }
  }

  // ========== UTILITY METHODS ==========

  /// Clear all onboarding preferences (useful for testing or reset)
  Future<void> clearAllPreferences() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);
      await prefs.remove(_interestsKey);
      await prefs.remove(_locationEnabledKey);
      await prefs.remove(_currentStepKey);
      await prefs.remove(_profilePhotoAddedKey);
      await prefs.remove(_ageKey);
      await prefs.remove(_genderKey);
      await prefs.remove(_locationNameKey);
      await prefs.remove(_searchRadiusKey);
    } catch (e) {
      throw Exception('Failed to clear preferences: $e');
    }
  }

  /// Get all preferences as a map (useful for debugging)
  Future<Map<String, dynamic>> getAllPreferences() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return {
        'onboardingCompleted': prefs.getBool(_onboardingCompletedKey) ?? false,
        'interests': prefs.getStringList(_interestsKey) ?? [],
        'locationEnabled': prefs.getBool(_locationEnabledKey) ?? false,
        'currentStep': prefs.getInt(_currentStepKey) ?? 0,
        'profilePhotoAdded': prefs.getBool(_profilePhotoAddedKey) ?? false,
        'age': prefs.getInt(_ageKey),
        'gender': prefs.getString(_genderKey),
        'locationName': prefs.getString(_locationNameKey),
        'searchRadiusKm': prefs.getDouble(_searchRadiusKey) ?? 100.0,
      };
    } catch (e) {
      throw Exception('Failed to get all preferences: $e');
    }
  }
}

