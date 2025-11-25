import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';

/// Sign Up Use Case
/// Handles user registration with email and password
class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  /// Execute sign up operation
  Future<UserEntity> call({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    // Validate password
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Validate username
    if (username.trim().isEmpty) {
      throw Exception('Username cannot be empty');
    }

    if (username.length < 3) {
      throw Exception('Username must be at least 3 characters');
    }

    // Validate display name
    if (displayName.trim().isEmpty) {
      throw Exception('Display name cannot be empty');
    }

    // Trim and lowercase email and username
    final cleanEmail = email.trim().toLowerCase();
    final cleanUsername = username.trim().toLowerCase();

    // Validate username format (alphanumeric and underscores only)
    if (!_isValidUsername(cleanUsername)) {
      throw Exception('Username can only contain letters, numbers, and underscores');
    }

    // Call repository
    return await _repository.signUpWithEmail(
      email: cleanEmail,
      password: password,
      username: cleanUsername,
      displayName: displayName.trim(),
    );
  }

  /// Validate email format using regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate username format
  bool _isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(username);
  }
}
