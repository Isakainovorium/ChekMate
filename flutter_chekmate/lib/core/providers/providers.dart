import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/core/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firestore Provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firebase Storage Provider
final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Current User ID Provider
/// Provides the current authenticated user's ID
final currentUserIdProvider = StreamProvider<String?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges().map((user) => user?.uid);
});

/// Current User Provider
/// Provides the current authenticated user's data
final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);

  await for (final user in auth.authStateChanges()) {
    if (user == null) {
      yield null;
    } else {
      try {
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          yield UserModel.fromJson(doc.data()!);
        } else {
          yield null;
        }
      } catch (e) {
        yield null;
      }
    }
  }
});

/// User Controller Provider
/// Provides a controller for user-related operations like following/unfollowing users
final userControllerProvider = Provider((ref) {
  return UserController(ref);
});

/// User Controller
class UserController {
  UserController(this.ref);

  final Ref ref;

  /// Follow a user
  Future<void> followUser(String userId) async {
    final firestore = ref.read(firestoreProvider);
    final currentUserId = ref.read(currentUserIdProvider).value;

    if (currentUserId == null) return;

    await firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayUnion([userId]),
    });

    await firestore.collection('users').doc(userId).update({
      'followers': FieldValue.arrayUnion([currentUserId]),
    });
  }

  /// Unfollow a user
  Future<void> unfollowUser(String userId) async {
    final firestore = ref.read(firestoreProvider);
    final currentUserId = ref.read(currentUserIdProvider).value;

    if (currentUserId == null) return;

    await firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayRemove([userId]),
    });

    await firestore.collection('users').doc(userId).update({
      'followers': FieldValue.arrayRemove([currentUserId]),
    });
  }

  /// Toggle follow/unfollow a user
  Future<void> toggleFollow(String userId) async {
    final firestore = ref.read(firestoreProvider);
    final currentUserId = ref.read(currentUserIdProvider).value;

    if (currentUserId == null) return;

    final currentUserDoc =
        await firestore.collection('users').doc(currentUserId).get();
    final following =
        List<String>.from(currentUserDoc.data()?['following'] ?? []);

    if (following.contains(userId)) {
      await unfollowUser(userId);
    } else {
      await followUser(userId);
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final firestore = ref.read(firestoreProvider);
    final currentUserId = ref.read(currentUserIdProvider).value;

    if (currentUserId == null) return;

    await firestore.collection('users').doc(currentUserId).update(data);
  }
}
