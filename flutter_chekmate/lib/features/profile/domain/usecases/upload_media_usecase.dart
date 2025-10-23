import 'package:flutter_chekmate/features/profile/domain/repositories/profile_repository.dart';

/// Upload Avatar Use Case - Domain Layer
///
/// Uploads a new profile avatar.
///
/// Clean Architecture: Domain Layer
class UploadAvatarUsecase {
  const UploadAvatarUsecase(this._repository);

  final ProfileRepository _repository;

  Future<String> call(String userId, String filePath) async {
    // Business logic: Validate file path
    if (filePath.isEmpty) {
      throw Exception('File path cannot be empty');
    }

    return _repository.uploadAvatar(userId, filePath);
  }
}

/// Upload Cover Photo Use Case - Domain Layer
///
/// Uploads a new cover photo.
///
/// Clean Architecture: Domain Layer
class UploadCoverPhotoUsecase {
  const UploadCoverPhotoUsecase(this._repository);

  final ProfileRepository _repository;

  Future<String> call(String userId, String filePath) async {
    // Business logic: Validate file path
    if (filePath.isEmpty) {
      throw Exception('File path cannot be empty');
    }

    return _repository.uploadCoverPhoto(userId, filePath);
  }
}

/// Upload Video Intro Use Case - Domain Layer
///
/// Uploads a new video introduction.
///
/// Clean Architecture: Domain Layer
class UploadVideoIntroUsecase {
  const UploadVideoIntroUsecase(this._repository);

  final ProfileRepository _repository;

  Future<String> call(String userId, String filePath) async {
    // Business logic: Validate file path
    if (filePath.isEmpty) {
      throw Exception('File path cannot be empty');
    }

    return _repository.uploadVideoIntro(userId, filePath);
  }
}

