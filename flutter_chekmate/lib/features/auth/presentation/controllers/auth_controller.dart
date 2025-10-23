import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/utils/geohash_utils.dart';
import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth Controller - Presentation Layer
///
/// Handles authentication actions and state management.
/// Uses use cases from the domain layer to perform operations.
///
/// Clean Architecture: Presentation Layer

/// Auth Controller State
class AuthControllerState {
  const AuthControllerState({
    this.isLoading = false,
    this.error,
  });

  final bool isLoading;
  final String? error;

  AuthControllerState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthControllerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth Controller Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthControllerState>((ref) {
  return AuthController(ref);
});

/// Auth Controller
class AuthController extends StateNotifier<AuthControllerState> {
  AuthController(this._ref) : super(const AuthControllerState());

  final Ref _ref;

  /// Sign in with email and password
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final signInUseCase = _ref.read(signInUseCaseProvider);
      final user = await signInUseCase(
        email: email,
        password: password,
      );

      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final signUpUseCase = _ref.read(signUpUseCaseProvider);
      final user = await signUpUseCase(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(authRepositoryProvider);
      final user = await repository.signInWithGoogle();

      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<UserEntity> signInWithApple() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(authRepositoryProvider);
      final user = await repository.signInWithApple();

      state = state.copyWith(isLoading: false);
      return user;
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
    state = state.copyWith(isLoading: true);

    try {
      final signOutUseCase = _ref.read(signOutUseCaseProvider);
      await signOutUseCase();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.sendPasswordResetEmail(email);

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
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.updatePassword(newPassword);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Re-authenticate with password
  Future<void> reauthenticate(String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.reauthenticate(password);

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
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.deleteAccount();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update location settings
  /// Updates user's location preferences including coordinates, geohash, and search radius
  Future<void> updateLocationSettings({
    bool? locationEnabled,
    double? latitude,
    double? longitude,
    double? searchRadiusKm,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(authRepositoryProvider);
      final currentUser = await repository.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Generate geohash if coordinates are provided
      GeoPoint? coordinates;
      String? geohash;
      if (latitude != null && longitude != null) {
        coordinates = GeoPoint(latitude, longitude);
        geohash = GeohashUtils.generateGeohash(latitude, longitude);
      }

      // Update user document in Firestore
      await repository.updateUserProfile(
        locationEnabled: locationEnabled,
        coordinates: coordinates,
        geohash: geohash,
        searchRadiusKm: searchRadiusKm,
      );

      state = state.copyWith(isLoading: false);

      // Invalidate auth state to refresh user data
      _ref.invalidate(authStateProvider);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update user interests
  /// Updates user's selected interests for personalized content discovery
  Future<void> updateInterests(List<String> interests) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(authRepositoryProvider);
      final currentUser = await repository.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Update user document in Firestore
      await repository.updateUserProfile(
        interests: interests,
      );

      state = state.copyWith(isLoading: false);

      // Invalidate auth state to refresh user data
      _ref.invalidate(authStateProvider);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith();
  }
}
