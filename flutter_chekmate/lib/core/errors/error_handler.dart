import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chekmate/core/errors/app_exception.dart';
import 'package:flutter_chekmate/core/utils/logger.dart';

/// Global error handler for the app
class ErrorHandler {
  /// Handle and convert errors to user-friendly messages
  static String handleError(dynamic error) {
    Logger.error('Error occurred', error);

    if (error is AppException) {
      return error.message;
    }

    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error);
    }

    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }

    if (error is NetworkException) {
      return 'Network error. Please check your connection.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static String _handleFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please log in again to continue.';
      default:
        return error.message ?? 'Authentication error occurred.';
    }
  }

  static String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again.';
      case 'not-found':
        return 'The requested resource was not found.';
      case 'already-exists':
        return 'This resource already exists.';
      case 'resource-exhausted':
        return 'Resource limit exceeded. Please try again later.';
      case 'cancelled':
        return 'Operation was cancelled.';
      case 'data-loss':
        return 'Data loss occurred. Please contact support.';
      default:
        return error.message ?? 'A server error occurred.';
    }
  }
}
