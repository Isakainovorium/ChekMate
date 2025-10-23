import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';

/// Get Current User Use Case - Domain Layer
/// 
/// Encapsulates the business logic for retrieving the current authenticated user.
/// 
/// Clean Architecture: Domain Layer
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  /// Execute the get current user use case
  /// 
  /// Returns: UserEntity if user is authenticated, null otherwise
  Future<UserEntity?> call() async {
    return _repository.getCurrentUser();
  }
}

