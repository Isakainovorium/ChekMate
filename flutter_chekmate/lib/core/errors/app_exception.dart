/// Base class for all app exceptions
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });
  final String message;
  final String? code;
  final dynamic originalError;

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Server exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalError,
  });
}
