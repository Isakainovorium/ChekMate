import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';

/// Sign Up Use Case - Domain Layer
/// 
/// Encapsulates the business logic for creating a new user account.
/// 
/// Clean Architecture: Domain Layer
class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  /// Execute the sign up use case
  /// 
  /// Parameters:
  /// - email: User's email address
  /// - password: User's password
  /// - username: Unique username
  /// - displayName: User's display name
  /// 
  /// Returns: UserEntity on successful sign up
  /// 
  /// Throws:
  /// - AuthException if email is already in use or validation fails
  /// - NetworkException if network is unavailable
  Future<UserEntity> call({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    // Business logic: Validate email format
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    // Business logic: Validate password strength
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }

    if (!_hasUpperCase(password)) {
      throw Exception('Password must contain at least one uppercase letter');
    }

    if (!_hasLowerCase(password)) {
      throw Exception('Password must contain at least one lowercase letter');
    }

    if (!_hasDigit(password)) {
      throw Exception('Password must contain at least one number');
    }

    // Business logic: Validate username
    if (username.length < 3) {
      throw Exception('Username must be at least 3 characters');
    }

    if (!_isValidUsername(username)) {
      throw Exception(
        'Username can only contain letters, numbers, and underscores',
      );
    }

    // Business logic: Validate display name
    if (displayName.isEmpty) {
      throw Exception('Display name is required');
    }

    // Delegate to repository
    return _repository.signUpWithEmail(
      email: email.trim().toLowerCase(),
      password: password,
      username: username.trim().toLowerCase(),
      displayName: displayName.trim(),
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate username format (alphanumeric and underscores only)
  bool _isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(username);
  }

  /// Check if password has uppercase letter
  bool _hasUpperCase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  /// Check if password has lowercase letter
  bool _hasLowerCase(String password) {
    return password.contains(RegExp(r'[a-z]'));
  }

  /// Check if password has digit
  bool _hasDigit(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }
}

