import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';

/// Auth Repository Interface - Domain Layer
///
/// This abstract class defines the contract for authentication operations.
/// It has no implementation details - only the interface that the domain layer expects.
///
/// The data layer will provide the concrete implementation.
///
/// Clean Architecture: Domain Layer
abstract class AuthRepository {
  /// Get current authenticated user
  /// Returns null if no user is authenticated
  Future<UserEntity?> getCurrentUser();

  /// Stream of authentication state changes
  /// Emits UserEntity when user signs in, null when user signs out
  Stream<UserEntity?> get authStateChanges;

  /// Sign in with email and password
  ///
  /// Throws:
  /// - AuthException if credentials are invalid
  /// - NetworkException if network is unavailable
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  ///
  /// Throws:
  /// - AuthException if email is already in use
  /// - NetworkException if network is unavailable
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  });

  /// Sign in with Google
  ///
  /// Throws:
  /// - AuthException if sign in is cancelled or fails
  /// - NetworkException if network is unavailable
  Future<UserEntity> signInWithGoogle();

  /// Sign in with Apple
  ///
  /// Throws:
  /// - AuthException if sign in is cancelled or fails
  /// - NetworkException if network is unavailable
  Future<UserEntity> signInWithApple();

  /// Sign out current user
  ///
  /// Throws:
  /// - AuthException if sign out fails
  Future<void> signOut();

  /// Send password reset email
  ///
  /// Throws:
  /// - AuthException if email is not found
  /// - NetworkException if network is unavailable
  Future<void> sendPasswordResetEmail(String email);

  /// Update user password
  ///
  /// Requires recent authentication
  ///
  /// Throws:
  /// - AuthException if password update fails
  /// - NetworkException if network is unavailable
  Future<void> updatePassword(String newPassword);

  /// Re-authenticate user with password
  ///
  /// Required before sensitive operations like password change
  ///
  /// Throws:
  /// - AuthException if password is incorrect
  Future<void> reauthenticate(String password);

  /// Delete user account
  ///
  /// Requires recent authentication
  ///
  /// Throws:
  /// - AuthException if deletion fails
  Future<void> deleteAccount();

  /// Update user profile
  ///
  /// Updates user profile fields in Firestore
  ///
  /// Parameters:
  /// - locationEnabled: Enable/disable location sharing
  /// - coordinates: GPS coordinates (GeoPoint)
  /// - geohash: Geohash string for geospatial queries
  /// - searchRadiusKm: Maximum search radius in kilometers
  /// - interests: List of user's selected interests
  ///
  /// Throws:
  /// - AuthException if update fails
  Future<void> updateUserProfile({
    bool? locationEnabled,
    GeoPoint? coordinates,
    String? geohash,
    double? searchRadiusKm,
    List<String>? interests,
  });
}
