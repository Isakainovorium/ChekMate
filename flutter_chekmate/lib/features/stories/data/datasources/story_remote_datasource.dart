import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/stories/data/models/story_model.dart';
import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';

/// Story Remote Data Source - Data Layer
///
/// Handles all remote data operations for stories using Firebase.
///
/// Clean Architecture: Data Layer
abstract class StoryRemoteDataSource {
  Future<List<StoryUserModel>> getFollowingStories();
  Future<List<StoryModel>> getMyStories();
  Future<List<StoryModel>> getUserStories(String userId);
  Future<StoryModel> createStory({
    required StoryType type,
    required String filePath,
    String? text,
    String? textColor,
    String? textPosition,
    int? duration,
  });
  Future<void> deleteStory(String storyId);
  Future<void> markAsViewed(String storyId);
  Future<void> likeStory(String storyId);
  Future<void> unlikeStory(String storyId);
  Future<List<String>> getStoryViewers(String storyId);
  Future<List<String>> getStoryLikes(String storyId);
  Future<String> uploadStoryMedia(String filePath, StoryType type);
  Future<void> deleteExpiredStories();
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  StoryRemoteDataSourceImpl({
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
  Future<List<StoryUserModel>> getFollowingStories() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return [];

      // Get following users
      final followingSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .get();

      final followingIds = followingSnapshot.docs
          .map((doc) => doc.data()['userId'] as String)
          .toList();

      // Add current user to get their stories too
      followingIds.insert(0, currentUserId);

      // Get stories for each user
      final storyUsers = <StoryUserModel>[];
      for (final userId in followingIds) {
        final stories = await getUserStories(userId);
        if (stories.isNotEmpty) {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          final userData = userDoc.data();

          storyUsers.add(
            StoryUserModel(
              userId: userId,
              username: userData?['username'] as String? ?? '',
              userAvatar: userData?['avatar'] as String? ?? '',
              stories: stories,
              isOwn: userId == currentUserId,
              isFollowing: userId != currentUserId,
            ),
          );
        }
      }

      return storyUsers;
    } catch (e) {
      throw Exception('Failed to get following stories: $e');
    }
  }

  @override
  Future<List<StoryModel>> getMyStories() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return [];

      return await getUserStories(currentUserId);
    } catch (e) {
      throw Exception('Failed to get my stories: $e');
    }
  }

  @override
  Future<List<StoryModel>> getUserStories(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => StoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user stories: $e');
    }
  }

  @override
  Future<StoryModel> createStory({
    required StoryType type,
    required String filePath,
    String? text,
    String? textColor,
    String? textPosition,
    int? duration,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      // Upload media
      final url = await uploadStoryMedia(filePath, type);

      // Get user data
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();

      // Create story
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 24));

      final storyData = {
        'userId': currentUser.uid,
        'username': userData?['username'] ?? '',
        'userAvatar': userData?['avatar'] ?? '',
        'type': type.name,
        'url': url,
        if (text != null) 'text': text,
        if (textColor != null) 'textColor': textColor,
        if (textPosition != null) 'textPosition': textPosition,
        'duration': duration ?? 5,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'views': 0,
        'likes': 0,
      };

      final docRef = await _firestore.collection('stories').add(storyData);
      final doc = await docRef.get();

      return StoryModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create story: $e');
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    try {
      await _firestore.collection('stories').doc(storyId).delete();
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  @override
  Future<void> markAsViewed(String storyId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('stories').doc(storyId).update({
        'views': FieldValue.increment(1),
      });

      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('viewers')
          .doc(currentUserId)
          .set({
        'userId': currentUserId,
        'viewedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark story as viewed: $e');
    }
  }

  @override
  Future<void> likeStory(String storyId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('stories').doc(storyId).update({
        'likes': FieldValue.increment(1),
      });

      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('likes')
          .doc(currentUserId)
          .set({
        'userId': currentUserId,
        'likedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to like story: $e');
    }
  }

  @override
  Future<void> unlikeStory(String storyId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('stories').doc(storyId).update({
        'likes': FieldValue.increment(-1),
      });

      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('likes')
          .doc(currentUserId)
          .delete();
    } catch (e) {
      throw Exception('Failed to unlike story: $e');
    }
  }

  @override
  Future<List<String>> getStoryViewers(String storyId) async {
    try {
      final snapshot = await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('viewers')
          .get();

      return snapshot.docs.map((doc) => doc.data()['userId'] as String).toList();
    } catch (e) {
      throw Exception('Failed to get story viewers: $e');
    }
  }

  @override
  Future<List<String>> getStoryLikes(String storyId) async {
    try {
      final snapshot = await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('likes')
          .get();

      return snapshot.docs.map((doc) => doc.data()['userId'] as String).toList();
    } catch (e) {
      throw Exception('Failed to get story likes: $e');
    }
  }

  @override
  Future<String> uploadStoryMedia(String filePath, StoryType type) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('Not authenticated');

      final file = File(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = type == StoryType.image ? 'jpg' : 'mp4';
      final ref = _storage.ref().child(
            'stories/$currentUserId/$timestamp.$extension',
          );

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload story media: $e');
    }
  }

  @override
  Future<void> deleteExpiredStories() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('stories')
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete expired stories: $e');
    }
  }
}

