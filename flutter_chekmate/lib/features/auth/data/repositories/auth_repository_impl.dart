import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';

/// Auth Repository Implementation - Data Layer
///
/// Implements the AuthRepository interface defined in the domain layer.
/// Delegates all operations to the AuthRemoteDataSource.
/// Converts between data models and domain entities.
///
/// Clean Architecture: Data Layer
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _remoteDataSource.currentFirebaseUser;
    if (firebaseUser == null) {
      return null;
    }

    final userModel = await _remoteDataSource.getUserDocument(firebaseUser.uid);
    return userModel.toEntity();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      final userModel =
          await _remoteDataSource.getUserDocument(firebaseUser.uid);
      return userModel.toEntity();
    });
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    final userModel = await _remoteDataSource.signUpWithEmail(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final userModel = await _remoteDataSource.signInWithGoogle();
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> signInWithApple() async {
    final userModel = await _remoteDataSource.signInWithApple();
    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _remoteDataSource.updatePassword(newPassword);
  }

  @override
  Future<void> reauthenticate(String password) async {
    await _remoteDataSource.reauthenticate(password);
  }

  @override
  Future<void> deleteAccount() async {
    await _remoteDataSource.deleteAccount();
  }

  @override
  Future<void> updateUserProfile({
    bool? locationEnabled,
    GeoPoint? coordinates,
    String? geohash,
    double? searchRadiusKm,
    List<String>? interests,
  }) async {
    await _remoteDataSource.updateUserProfile(
      locationEnabled: locationEnabled,
      coordinates: coordinates,
      geohash: geohash,
      searchRadiusKm: searchRadiusKm,
      interests: interests,
    );
  }
}
