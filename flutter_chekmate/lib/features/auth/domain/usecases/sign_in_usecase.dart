import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';

/// Sign In Use Case - Domain Layer
/// 
/// Encapsulates the business logic for signing in a user with email and password.
/// 
/// Clean Architecture: Domain Layer
class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  /// Execute the sign in use case
  /// 
  /// Parameters:
  /// - email: User's email address
  /// - password: User's password
  /// 
  /// Returns: UserEntity on successful sign in
  /// 
  /// Throws:
  /// - AuthException if credentials are invalid
  /// - NetworkException if network is unavailable
  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    // Business logic: Validate email format
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    // Business logic: Validate password length
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Delegate to repository
    return _repository.signInWithEmail(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

