import 'package:flutter_chekmate/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/repositories/profile_repository.dart';

/// Update Profile Use Case - Domain Layer
///
/// Updates a user's profile information.
///
/// Clean Architecture: Domain Layer
class UpdateProfileUsecase {
  const UpdateProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(ProfileEntity profile) async {
    // Business logic: Validate profile before updating
    if (profile.username.isEmpty) {
      throw Exception('Username cannot be empty');
    }

    if (profile.displayName.isEmpty) {
      throw Exception('Display name cannot be empty');
    }

    await _repository.updateProfile(profile);
  }
}

/// Update Profile Field Use Case - Domain Layer
///
/// Updates a single field in a user's profile.
///
/// Clean Architecture: Domain Layer
class UpdateProfileFieldUsecase {
  const UpdateProfileFieldUsecase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(String userId, String field, dynamic value) async {
    // Business logic: Validate field updates
    if (field == 'username' && (value as String).isEmpty) {
      throw Exception('Username cannot be empty');
    }

    if (field == 'displayName' && (value as String).isEmpty) {
      throw Exception('Display name cannot be empty');
    }

    if (field == 'age' && (value as int) < 18) {
      throw Exception('User must be at least 18 years old');
    }

    await _repository.updateProfileField(userId, field, value);
  }
}

