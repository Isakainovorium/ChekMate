import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chekmate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_chekmate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_chekmate/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter_chekmate/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:flutter_chekmate/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:flutter_chekmate/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Auth Providers - Presentation Layer
/// 
/// Provides dependency injection for the auth feature using Riverpod.
/// Follows Clean Architecture dependency flow:
/// Presentation -> Domain -> Data
/// 
/// Clean Architecture: Presentation Layer

// ============================================================================
// INFRASTRUCTURE PROVIDERS (Firebase, Google Sign In)
// ============================================================================

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Google Sign In instance provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Auth Remote Data Source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

/// Auth Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
  );
});

// ============================================================================
// DOMAIN LAYER PROVIDERS (Use Cases)
// ============================================================================

/// Sign In Use Case provider
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

/// Sign Up Use Case provider
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

/// Sign Out Use Case provider
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

/// Get Current User Use Case provider
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

// ============================================================================
// PRESENTATION LAYER PROVIDERS (State)
// ============================================================================

/// Auth State provider
/// 
/// Provides a stream of the current authentication state.
/// Emits UserEntity when user is signed in, null when signed out.
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Current User provider
/// 
/// Provides the current authenticated user.
/// Returns null if no user is signed in.
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

/// Is Authenticated provider
/// 
/// Simple boolean to check if user is logged in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value != null;
});

/// Current User ID provider
/// 
/// Provides the current user's ID.
/// Returns null if no user is signed in.
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.uid;
});

