import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/profile/data/models/profile_model.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';

/// Profile Remote Data Source - Data Layer
///
/// Handles all remote data operations for profiles using Firebase.
///
/// Clean Architecture: Data Layer
abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile(String userId);
  Future<ProfileModel?> getCurrentUserProfile();
  Future<void> updateProfile(ProfileModel profile);
  Future<void> updateProfileField(String userId, String field, dynamic value);
  Future<String> uploadAvatar(String userId, String filePath);
  Future<String> uploadCoverPhoto(String userId, String filePath);
  Future<String> uploadVideoIntro(String userId, String filePath);
  Future<void> addVoicePrompt(String userId, VoicePromptEntity voicePrompt);
  Future<void> deleteVoicePrompt(String userId, String promptId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<bool> isFollowing(String userId);
  Future<List<ProfileModel>> getFollowers(String userId);
  Future<List<ProfileModel>> getFollowing(String userId);
  Future<List<ProfileModel>> searchProfiles(String query);
  Future<List<ProfileModel>> getSuggestedProfiles();
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
  Future<void> reportUser(String userId, String reason);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _auth = auth,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return ProfileModel.fromFirestore(doc);
    } on Exception catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<ProfileModel?> getCurrentUserProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    return getProfile(currentUser.uid);
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _firestore.collection('users').doc(profile.uid).update(
            profile.toFirestore(),
          );
    } on Exception catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> updateProfileField(
    String userId,
    String field,
    dynamic value,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      throw Exception('Failed to update profile field: $e');
    }
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child('profiles/$userId/avatar.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      // Update profile with new avatar URL
      await updateProfileField(userId, 'avatar', url);

      return url;
    } on Exception catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  @override
  Future<String> uploadCoverPhoto(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child('profiles/$userId/cover.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      // Update profile with new cover photo URL
      await updateProfileField(userId, 'coverPhoto', url);

      return url;
    } on Exception catch (e) {
      throw Exception('Failed to upload cover photo: $e');
    }
  }

  @override
  Future<String> uploadVideoIntro(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child('profiles/$userId/intro.mp4');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      // Update profile with new video intro URL
      await updateProfileField(userId, 'videoIntroUrl', url);

      return url;
    } on Exception catch (e) {
      throw Exception('Failed to upload video intro: $e');
    }
  }

  @override
  Future<void> addVoicePrompt(
    String userId,
    VoicePromptEntity voicePrompt,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'voicePrompts': FieldValue.arrayUnion([voicePrompt.toJson()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      throw Exception('Failed to add voice prompt: $e');
    }
  }

  @override
  Future<void> deleteVoicePrompt(String userId, String promptId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return;

      final updatedPrompts = profile.voicePrompts
          ?.where((p) => p.id != promptId)
          .map((p) => p.toJson())
          .toList();

      await _firestore.collection('users').doc(userId).update({
        'voicePrompts': updatedPrompts ?? [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      throw Exception('Failed to delete voice prompt: $e');
    }
  }

  @override
  Future<void> followUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('Not authenticated');

      final batch = _firestore.batch();

      // Add to current user's following
      batch.update(_firestore.collection('users').doc(currentUserId), {
        'following': FieldValue.increment(1),
      });

      // Add to target user's followers
      batch.update(_firestore.collection('users').doc(userId), {
        'followers': FieldValue.increment(1),
      });

      // Create follow relationship
      batch.set(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(userId),
        {
          'userId': userId,
          'followedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } on Exception catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('Not authenticated');

      final batch = _firestore.batch();

      // Remove from current user's following
      batch.update(_firestore.collection('users').doc(currentUserId), {
        'following': FieldValue.increment(-1),
      });

      // Remove from target user's followers
      batch.update(_firestore.collection('users').doc(userId), {
        'followers': FieldValue.increment(-1),
      });

      // Delete follow relationship
      batch.delete(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(userId),
      );

      await batch.commit();
    } on Exception catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  @override
  Future<bool> isFollowing(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(userId)
          .get();

      return doc.exists;
    } on Exception {
      return false;
    }
  }

  @override
  Future<List<ProfileModel>> getFollowers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .get();

      final profiles = <ProfileModel>[];
      for (final doc in snapshot.docs) {
        final userId = doc.data()['userId'] as String;
        final profile = await getProfile(userId);
        if (profile != null) profiles.add(profile);
      }

      return profiles;
    } on Exception catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  @override
  Future<List<ProfileModel>> getFollowing(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      final profiles = <ProfileModel>[];
      for (final doc in snapshot.docs) {
        final userId = doc.data()['userId'] as String;
        final profile = await getProfile(userId);
        if (profile != null) profiles.add(profile);
      }

      return profiles;
    } on Exception catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  @override
  Future<List<ProfileModel>> searchProfiles(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => ProfileModel.fromFirestore(doc))
          .toList();
    } on Exception catch (e) {
      throw Exception('Failed to search profiles: $e');
    }
  }

  @override
  Future<List<ProfileModel>> getSuggestedProfiles() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('followers', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => ProfileModel.fromFirestore(doc))
          .toList();
    } on Exception catch (e) {
      throw Exception('Failed to get suggested profiles: $e');
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked')
          .doc(userId)
          .set({
        'userId': userId,
        'blockedAt': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('Not authenticated');

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked')
          .doc(userId)
          .delete();
    } on Exception catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  @override
  Future<void> reportUser(String userId, String reason) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('Not authenticated');

      await _firestore.collection('reports').add({
        'reportedBy': currentUserId,
        'reportedUser': userId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } on Exception catch (e) {
      throw Exception('Failed to report user: $e');
    }
  }
}
