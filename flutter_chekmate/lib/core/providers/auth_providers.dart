import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chekmate/core/models/user_model.dart';
import 'package:flutter_chekmate/core/providers/service_providers.dart';
import 'package:flutter_chekmate/core/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth State Provider
/// Provides the current Firebase Auth user
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current User ID Provider
/// Provides the current user's ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.uid;
});

/// Current User Provider
/// Provides the current user's full profile from Firestore
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }

  final userService = ref.watch(userServiceProvider);
  return userService.getUserStream(userId);
});

/// Is Authenticated Provider
/// Simple boolean to check if user is logged in
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value != null;
});

/// Auth Controller Provider
/// Handles authentication actions
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

/// Auth Controller
/// Manages authentication state and actions
class AuthController {
  AuthController(this.ref);
  final Ref ref;

  AuthService get _authService => ref.read(authServiceProvider);

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    await _authService.signUpWithEmail(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _authService.signInWithEmail(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      // Handle authentication errors (including UnimplementedError)
      if (e is UnimplementedError) {
        throw Exception('Google Sign-In is not available: ${e.message}');
      } else {
        throw Exception('Google Sign-In failed: $e');
      }
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      await _authService.signInWithApple();
    } catch (e) {
      // Handle authentication errors (including UnimplementedError)
      if (e is UnimplementedError) {
        throw Exception('Apple Sign-In is not available: ${e.message}');
      } else {
        throw Exception('Apple Sign-In failed: $e');
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  /// Update email
  Future<void> updateEmail(String newEmail) async {
    await _authService.updateEmail(newEmail);
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    await _authService.updatePassword(newPassword);
  }

  /// Delete account
  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
  }

  /// Re-authenticate
  Future<void> reauthenticate(String password) async {
    await _authService.reauthenticate(password);
  }
}
