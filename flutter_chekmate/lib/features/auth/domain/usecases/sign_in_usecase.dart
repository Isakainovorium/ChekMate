import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';

/// Sign In Use Case
/// Handles user authentication with email and password
class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  /// Execute sign in operation
  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    // Trim and lowercase email
    final cleanEmail = email.trim().toLowerCase();

    // Validate password
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Call repository
    return await _repository.signInWithEmail(
      email: cleanEmail,
      password: password,
    );
  }

  /// Validate email format using regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    return emailRegex.hasMatch(email.trim());
  }
}
