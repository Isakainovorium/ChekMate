import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chekmate/core/errors/app_exception.dart';
import 'package:flutter_chekmate/core/utils/logger.dart';
import 'package:flutter_chekmate/features/auth/data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Auth Remote Data Source - Data Layer
///
/// Handles all Firebase Authentication and Firestore operations.
/// This is the only class that directly interacts with Firebase.
///
/// Clean Architecture: Data Layer
abstract class AuthRemoteDataSource {
  /// Get current Firebase user
  User? get currentFirebaseUser;

  /// Stream of Firebase auth state changes
  Stream<User?> get authStateChanges;

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  });

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign in with Apple
  Future<UserModel> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Update password
  Future<void> updatePassword(String newPassword);

  /// Re-authenticate with password
  Future<void> reauthenticate(String password);

  /// Delete account
  Future<void> deleteAccount();

  /// Get user document from Firestore
  Future<UserModel> getUserDocument(String uid);

  /// Update user profile
  Future<void> updateUserProfile({
    bool? locationEnabled,
    GeoPoint? coordinates,
    String? geohash,
    double? searchRadiusKm,
    List<String>? interests,
  });
}

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  User? get currentFirebaseUser => _auth.currentUser;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('AuthRemoteDataSource: Signing in with email: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Sign in failed');
      }

      Logger.info('AuthRemoteDataSource: Sign in successful');

      // Get user document from Firestore
      return await getUserDocument(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRemoteDataSource: Sign in failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('AuthRemoteDataSource: Unexpected sign in error', e);
      throw AuthException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      Logger.info('AuthRemoteDataSource: Signing up with email: $email');

      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Sign up failed');
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        username: username,
        displayName: displayName,
        bio: '',
        avatar: '',
        coverPhoto: '',
        followers: 0,
        following: 0,
        posts: 0,
        isVerified: false,
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      Logger.info('AuthRemoteDataSource: Sign up successful');

      return userModel;
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRemoteDataSource: Sign up failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('AuthRemoteDataSource: Unexpected sign up error', e);
      throw AuthException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      Logger.info('AuthRemoteDataSource: Signing in with Google');

      // Trigger Google Sign In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Google sign in cancelled');
      }

      // Obtain auth details
      final googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException(message: 'Google sign in failed');
      }

      // Check if user document exists, create if not
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          username: userCredential.user!.displayName ?? '',
          displayName: userCredential.user!.displayName ?? '',
          bio: '',
          avatar: userCredential.user!.photoURL ?? '',
          coverPhoto: '',
          followers: 0,
          following: 0,
          posts: 0,
          isVerified: false,
          isPremium: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toFirestore());

        Logger.info('AuthRemoteDataSource: Google sign in successful');
        return userModel;
      }

      return await getUserDocument(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRemoteDataSource: Google sign in failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('AuthRemoteDataSource: Unexpected Google sign in error', e);
      throw AuthException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      Logger.info('AuthRemoteDataSource: Signing in with Apple');

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        throw const AuthException(message: 'Apple sign in failed');
      }

      // Check if user document exists, create if not
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();

        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          username: appleCredential.givenName ??
              userCredential.user!.displayName ??
              '',
          displayName: displayName.isNotEmpty
              ? displayName
              : userCredential.user!.displayName ?? '',
          bio: '',
          avatar: '',
          coverPhoto: '',
          followers: 0,
          following: 0,
          posts: 0,
          isVerified: false,
          isPremium: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toFirestore());

        Logger.info('AuthRemoteDataSource: Apple sign in successful');
        return userModel;
      }

      return await getUserDocument(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRemoteDataSource: Apple sign in failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('AuthRemoteDataSource: Unexpected Apple sign in error', e);
      throw AuthException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      Logger.info('AuthRemoteDataSource: Signing out');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      Logger.info('AuthRemoteDataSource: Sign out successful');
    } catch (e) {
      Logger.error('AuthRemoteDataSource: Sign out failed', e);
      throw AuthException(
        message: 'Sign out failed',
        originalError: e,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.info(
        'AuthRemoteDataSource: Sending password reset email to: $email',
      );
      await _auth.sendPasswordResetEmail(email: email);
      Logger.info('AuthRemoteDataSource: Password reset email sent');
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRemoteDataSource: Password reset failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No user signed in');
      }

      Logger.info('AuthRemoteDataSource: Updating password');
      await user.updatePassword(newPassword);
      Logger.info('AuthRemoteDataSource: Password updated');
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRemoteDataSource: Password update failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthException(message: 'No user signed in');
      }

      Logger.info('AuthRemoteDataSource: Re-authenticating user');
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      Logger.info('AuthRemoteDataSource: Re-authentication successful');
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRemoteDataSource: Re-authentication failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No user signed in');
      }

      Logger.info('AuthRemoteDataSource: Deleting account');

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      Logger.info('AuthRemoteDataSource: Account deleted');
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRemoteDataSource: Account deletion failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<UserModel> getUserDocument(String uid) async {
    try {
      Logger.info('AuthRemoteDataSource: Getting user document for uid: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw const AuthException(message: 'User document not found');
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      Logger.error('AuthRemoteDataSource: Get user document failed', e);
      throw AuthException(
        message: 'Failed to get user data',
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateUserProfile({
    bool? locationEnabled,
    GeoPoint? coordinates,
    String? geohash,
    double? searchRadiusKm,
    List<String>? interests,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'User not authenticated');
      }

      final updates = <String, dynamic>{};
      if (locationEnabled != null) {
        updates['locationEnabled'] = locationEnabled;
      }
      if (coordinates != null) {
        updates['coordinates'] = coordinates;
      }
      if (geohash != null) {
        updates['geohash'] = geohash;
      }
      if (searchRadiusKm != null) {
        updates['searchRadiusKm'] = searchRadiusKm;
      }
      if (interests != null) {
        // Convert interests to lowercase for case-insensitive matching
        updates['interests'] = interests.map((e) => e.toLowerCase()).toList();
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(user.uid).update(updates);
        Logger.info('AuthRemoteDataSource: User profile updated successfully');
      }
    } catch (e) {
      Logger.error('AuthRemoteDataSource: Update user profile failed', e);
      throw AuthException(
        message: 'Failed to update user profile',
        originalError: e,
      );
    }
  }

  /// Get user-friendly error message from Firebase Auth error code
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      default:
        return 'An error occurred: $code';
    }
  }
}
