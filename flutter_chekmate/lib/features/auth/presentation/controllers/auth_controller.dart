import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chekmate/core/services/auth_service.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication State
class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

/// Authentication Controller
/// Manages authentication state and operations
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState());

  /// Sign up with email and password
  Future<User> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      state = state.copyWith(
        isLoading: false,
        user: credential.user,
      );

      return credential.user!;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        user: credential.user,
      );

      return credential.user!;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in with Google
  Future<User> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _authService.signInWithGoogle();

      state = state.copyWith(
        isLoading: false,
        user: credential.user,
      );

      return credential.user!;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<User> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _authService.signInWithApple();

      state = state.copyWith(
        isLoading: false,
        user: credential.user,
      );

      return credential.user!;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signOut();

      state = state.copyWith(
        isLoading: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.sendPasswordResetEmail(email);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Send password reset email (alias for resetPassword)
  Future<void> sendPasswordResetEmail(String email) async {
    return resetPassword(email);
  }

  /// Update location settings
  Future<void> updateLocationSettings({
    bool? locationEnabled,
    String? locationName,
    double? latitude,
    double? longitude,
    double? searchRadiusKm,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Update user document in Firestore with location settings
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (locationEnabled != null) updates['locationEnabled'] = locationEnabled;
      if (locationName != null) updates['locationName'] = locationName;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (searchRadiusKm != null) updates['searchRadiusKm'] = searchRadiusKm;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updates);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update email
  Future<void> updateEmail(String newEmail) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.updateEmail(newEmail);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.updatePassword(newPassword);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.deleteAccount();

      state = state.copyWith(
        isLoading: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Re-authenticate user
  Future<void> reauthenticate(String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.reauthenticate(password);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

/// Authentication Controller Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});
