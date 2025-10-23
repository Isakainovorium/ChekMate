import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chekmate/core/errors/app_exception.dart';
import 'package:flutter_chekmate/core/utils/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('Signing in with email: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Sign in failed');
      }

      Logger.info('Sign in successful');
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      Logger.error('Sign in failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('Unexpected sign in error', e);
      throw AuthException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  /// Sign up with email and password
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      Logger.info('Signing up with email: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Sign up failed');
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      Logger.info('Sign up successful');
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      Logger.error('Sign up failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('Unexpected sign up error', e);
      throw AuthException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  /// Sign in with Google
  Future<User> signInWithGoogle() async {
    try {
      Logger.info('Signing in with Google');

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(message: 'Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException(message: 'Google sign in failed');
      }

      Logger.info('Google sign in successful');
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      Logger.error('Google sign in failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('Unexpected Google sign in error', e);
      throw AuthException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      Logger.info('Signing out');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      Logger.info('Sign out successful');
    } catch (e) {
      Logger.error('Sign out failed', e);
      throw AuthException(
        message: 'Sign out failed',
        originalError: e,
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.info('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      Logger.info('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      Logger.error('Password reset failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('Unexpected password reset error', e);
      throw AuthException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      Logger.info('Deleting account');
      await currentUser?.delete();
      Logger.info('Account deleted');
    } on FirebaseAuthException catch (e) {
      Logger.error('Account deletion failed', e);
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('Unexpected account deletion error', e);
      throw AuthException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  /// Get user-friendly error message
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
        return 'Please log in again to continue';
      default:
        return 'Authentication error occurred';
    }
  }
}
