import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chekmate/core/models/user_model.dart';
import 'package:flutter_chekmate/core/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication Service Provider
/// Provides access to the AuthService singleton
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Authentication State Provider
/// Watches Firebase Auth state changes and provides the current Firebase User
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current User ID Provider
/// Provides the current authenticated user's ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Current User Provider
/// Provides the current authenticated Firebase User
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Current User Document Provider
/// Fetches the current user's Firestore document
final currentUserDocumentProvider = StreamProvider<UserModel?>((ref) async* {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    yield null;
    return;
  }

  final authService = ref.watch(authServiceProvider);
  yield* authService.getUserDocument(userId);
});

/// User Profile Provider (by ID)
/// Fetches a specific user's profile from Firestore
final userProfileProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  final authService = ref.watch(authServiceProvider);
  return authService.getUserDocument(userId);
});

/// Is Authenticated Provider
/// Simple boolean provider for authentication state
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

