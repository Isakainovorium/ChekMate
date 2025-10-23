import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/core/models/user_model.dart';

/// User Service
/// Handles user-related operations with Firestore
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by username: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? location,
    int? age,
    String? gender,
    List<String>? interests,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;
      if (age != null) updates['age'] = age;
      if (gender != null) updates['gender'] = gender;
      if (interests != null) updates['interests'] = interests;

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture({
    required String uid,
    required Uint8List imageData,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$uid/$fileName');
      final uploadTask = await ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update user document
      await _firestore.collection('users').doc(uid).update({
        'avatar': downloadUrl,
        'updatedAt': Timestamp.now(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Upload cover photo
  Future<String> uploadCoverPhoto({
    required String uid,
    required Uint8List imageData,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('cover_photos/$uid/$fileName');
      final uploadTask = await ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update user document
      await _firestore.collection('users').doc(uid).update({
        'coverPhoto': downloadUrl,
        'updatedAt': Timestamp.now(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload cover photo: $e');
    }
  }

  /// Follow user
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Add to current user's following
      batch.set(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId),
        {
          'userId': targetUserId,
          'followedAt': Timestamp.now(),
        },
      );

      // Add to target user's followers
      batch.set(
        _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId),
        {
          'userId': currentUserId,
          'followedAt': Timestamp.now(),
        },
      );

      // Update counts
      batch.update(_firestore.collection('users').doc(currentUserId), {
        'following': FieldValue.increment(1),
      });
      batch.update(_firestore.collection('users').doc(targetUserId), {
        'followers': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  /// Unfollow user
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Remove from current user's following
      batch.delete(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId),
      );

      // Remove from target user's followers
      batch.delete(
        _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId),
      );

      // Update counts
      batch.update(_firestore.collection('users').doc(currentUserId), {
        'following': FieldValue.increment(-1),
      });
      batch.update(_firestore.collection('users').doc(targetUserId), {
        'followers': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  /// Check if following user
  Future<bool> isFollowing({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check following status: $e');
    }
  }

  /// Get followers
  Stream<List<UserModel>> getFollowers(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .snapshots()
        .asyncMap((snapshot) async {
      final userIds = snapshot.docs.map((doc) => doc.id).toList();
      if (userIds.isEmpty) return [];

      final users = await Future.wait(
        userIds.map((id) => getUserById(id)),
      );
      return users.whereType<UserModel>().toList();
    });
  }

  /// Get following
  Stream<List<UserModel>> getFollowing(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .asyncMap((snapshot) async {
      final userIds = snapshot.docs.map((doc) => doc.id).toList();
      if (userIds.isEmpty) return [];

      final users = await Future.wait(
        userIds.map((id) => getUserById(id)),
      );
      return users.whereType<UserModel>().toList();
    });
  }

  /// Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get user stream
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }
}
