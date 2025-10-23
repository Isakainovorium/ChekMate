import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:flutter_chekmate/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_chekmate/features/profile/domain/usecases/follow_user_usecase.dart';
import 'package:flutter_chekmate/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_chekmate/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_chekmate/features/profile/domain/usecases/upload_media_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Firebase Firestore Provider
@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// Firebase Auth Provider
@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

/// Firebase Storage Provider
@riverpod
FirebaseStorage firebaseStorage(FirebaseStorageRef ref) {
  return FirebaseStorage.instance;
}

/// Profile Remote Data Source Provider
@riverpod
ProfileRemoteDataSource profileRemoteDataSource(
  ProfileRemoteDataSourceRef ref,
) {
  return ProfileRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
    storage: ref.watch(firebaseStorageProvider),
  );
}

/// Profile Repository Provider
@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  );
}

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

/// Get Profile Use Case Provider
@riverpod
GetProfileUsecase getProfileUsecase(GetProfileUsecaseRef ref) {
  return GetProfileUsecase(ref.watch(profileRepositoryProvider));
}

/// Get Current User Profile Use Case Provider
@riverpod
GetCurrentUserProfileUsecase getCurrentUserProfileUsecase(
  GetCurrentUserProfileUsecaseRef ref,
) {
  return GetCurrentUserProfileUsecase(ref.watch(profileRepositoryProvider));
}

/// Update Profile Use Case Provider
@riverpod
UpdateProfileUsecase updateProfileUsecase(UpdateProfileUsecaseRef ref) {
  return UpdateProfileUsecase(ref.watch(profileRepositoryProvider));
}

/// Update Profile Field Use Case Provider
@riverpod
UpdateProfileFieldUsecase updateProfileFieldUsecase(
  UpdateProfileFieldUsecaseRef ref,
) {
  return UpdateProfileFieldUsecase(ref.watch(profileRepositoryProvider));
}

/// Follow User Use Case Provider
@riverpod
FollowUserUsecase followUserUsecase(FollowUserUsecaseRef ref) {
  return FollowUserUsecase(ref.watch(profileRepositoryProvider));
}

/// Unfollow User Use Case Provider
@riverpod
UnfollowUserUsecase unfollowUserUsecase(UnfollowUserUsecaseRef ref) {
  return UnfollowUserUsecase(ref.watch(profileRepositoryProvider));
}

/// Is Following Use Case Provider
@riverpod
IsFollowingUsecase isFollowingUsecase(IsFollowingUsecaseRef ref) {
  return IsFollowingUsecase(ref.watch(profileRepositoryProvider));
}

/// Upload Avatar Use Case Provider
@riverpod
UploadAvatarUsecase uploadAvatarUsecase(UploadAvatarUsecaseRef ref) {
  return UploadAvatarUsecase(ref.watch(profileRepositoryProvider));
}

/// Upload Cover Photo Use Case Provider
@riverpod
UploadCoverPhotoUsecase uploadCoverPhotoUsecase(
  UploadCoverPhotoUsecaseRef ref,
) {
  return UploadCoverPhotoUsecase(ref.watch(profileRepositoryProvider));
}

/// Upload Video Intro Use Case Provider
@riverpod
UploadVideoIntroUsecase uploadVideoIntroUsecase(
  UploadVideoIntroUsecaseRef ref,
) {
  return UploadVideoIntroUsecase(ref.watch(profileRepositoryProvider));
}

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// Current User Profile Provider
@riverpod
class CurrentUserProfile extends _$CurrentUserProfile {
  @override
  Future<ProfileEntity?> build() async {
    final usecase = ref.watch(getCurrentUserProfileUsecaseProvider);
    return usecase();
  }

  /// Refresh current user profile
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(getCurrentUserProfileUsecaseProvider);
      return usecase();
    });
  }

  /// Update profile
  Future<void> updateProfile(ProfileEntity profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(updateProfileUsecaseProvider);
      await usecase(profile);
      return profile;
    });
  }
}

/// User Profile Provider (by ID)
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<ProfileEntity?> build(String userId) async {
    final usecase = ref.watch(getProfileUsecaseProvider);
    return usecase(userId);
  }

  /// Refresh user profile
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(getProfileUsecaseProvider);
      return usecase(userId);
    });
  }
}

/// Is Following Provider (by user ID)
@riverpod
class IsFollowingUser extends _$IsFollowingUser {
  @override
  Future<bool> build(String userId) async {
    final usecase = ref.watch(isFollowingUsecaseProvider);
    return usecase(userId);
  }

  /// Follow user
  Future<void> follow() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(followUserUsecaseProvider);
      await usecase(userId);
      return true;
    });
  }

  /// Unfollow user
  Future<void> unfollow() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final usecase = ref.read(unfollowUserUsecaseProvider);
      await usecase(userId);
      return false;
    });
  }

  /// Toggle follow status
  Future<void> toggle() async {
    final currentState = state.value ?? false;
    if (currentState) {
      await unfollow();
    } else {
      await follow();
    }
  }
}

/// Profile Stats Provider (by user ID)
@riverpod
Future<ProfileStats> profileStats(ProfileStatsRef ref, String userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfileStats(userId);
}

/// Search Profiles Provider
@riverpod
Future<List<ProfileEntity>> searchProfiles(
  SearchProfilesRef ref,
  String query,
) async {
  if (query.isEmpty) return [];
  final repository = ref.watch(profileRepositoryProvider);
  return repository.searchProfiles(query);
}

/// Suggested Profiles Provider
@riverpod
Future<List<ProfileEntity>> suggestedProfiles(SuggestedProfilesRef ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getSuggestedProfiles();
}

/// User Followers Provider
@riverpod
Future<List<ProfileEntity>> userFollowers(
  UserFollowersRef ref,
  String userId,
) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getFollowers(userId);
}

/// User Following Provider
@riverpod
Future<List<ProfileEntity>> userFollowing(
  UserFollowingRef ref,
  String userId,
) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getFollowing(userId);
}
