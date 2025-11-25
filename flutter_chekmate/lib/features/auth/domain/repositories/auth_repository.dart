import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';

/// Auth Repository Interface
/// Defines the contract for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  });

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle();

  /// Sign in with Apple
  Future<UserEntity> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<void> updateUserProfile(UserEntity user);

  /// Delete user account
  Future<void> deleteAccount();
}
