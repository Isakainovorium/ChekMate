import 'package:flutter_chekmate/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/repositories/profile_repository.dart';

/// Get Profile Use Case - Domain Layer
///
/// Retrieves a user's profile by ID.
///
/// Clean Architecture: Domain Layer
class GetProfileUsecase {
  const GetProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity?> call(String userId) async {
    return _repository.getProfile(userId);
  }
}

/// Get Current User Profile Use Case - Domain Layer
///
/// Retrieves the current authenticated user's profile.
///
/// Clean Architecture: Domain Layer
class GetCurrentUserProfileUsecase {
  const GetCurrentUserProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity?> call() async {
    return _repository.getCurrentUserProfile();
  }
}

