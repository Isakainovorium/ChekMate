import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';

/// Sign Out Use Case - Domain Layer
/// 
/// Encapsulates the business logic for signing out the current user.
/// 
/// Clean Architecture: Domain Layer
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  /// Execute the sign out use case
  /// 
  /// Throws:
  /// - AuthException if sign out fails
  Future<void> call() async {
    await _repository.signOut();
  }
}

