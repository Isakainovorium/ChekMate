import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
///
/// Failures represent errors in the domain layer.
/// They are used with Either<Failure, T> to handle errors functionally.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

/// Failure when a server error occurs
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Failure when a network error occurs
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'Network error occurred. Please check your internet connection.',
  ]);
}

/// Failure when a cache error occurs
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Failure when authentication fails
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication failed']);
}

/// Failure when authorization fails
class AuthorizationFailure extends Failure {
  const AuthorizationFailure([
    super.message =
        'Authorization failed. You do not have permission to perform this action.',
  ]);
}

/// Failure when a permission is denied
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

/// Failure when recording fails
class RecordingFailure extends Failure {
  const RecordingFailure([super.message = 'Recording failed']);
}

/// Failure when playback fails
class PlaybackFailure extends Failure {
  const PlaybackFailure([super.message = 'Playback failed']);
}

/// Failure when storage operation fails
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage operation failed']);
}

/// Failure when a resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Failure when an unexpected error occurs
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
