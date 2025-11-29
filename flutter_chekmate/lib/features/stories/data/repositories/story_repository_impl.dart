import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';
import 'package:flutter_chekmate/features/stories/domain/repositories/story_repository.dart';
import 'package:uuid/uuid.dart';

/// Story Repository Implementation
/// Handles story data operations with Firebase
class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    required this.currentUserId,
    required this.currentUsername,
    required this.currentUserAvatar,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String currentUserId;
  final String currentUsername;
  final String currentUserAvatar;

  CollectionReference<Map<String, dynamic>> get _storiesCollection =>
      _firestore.collection('stories');

  @override
  Future<StoryEntity> createStory({
    required StoryType type,
    required String filePath,
    int? duration,
    String? text,
  }) async {
    try {
      final storyId = const Uuid().v4();
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 24));

      // Upload file to Firebase Storage
      final file = File(filePath);
      final extension = type == StoryType.video ? 'mp4' : 'jpg';
      final storagePath = 'stories/$currentUserId/$storyId.$extension';
      
      final uploadTask = await _storage.ref(storagePath).putFile(
        file,
        SettableMetadata(
          contentType: type == StoryType.video ? 'video/mp4' : 'image/jpeg',
        ),
      );
      
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Create story document
      final storyData = {
        'id': storyId,
        'userId': currentUserId,
        'username': currentUsername,
        'userAvatar': currentUserAvatar,
        'type': type == StoryType.video ? 'video' : 'image',
        'url': downloadUrl,
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'views': 0,
        'likes': 0,
        'duration': duration,
        'text': text,
        'viewers': <String>[],
        'likers': <String>[],
      };

      await _storiesCollection.doc(storyId).set(storyData);

      return StoryEntity(
        id: storyId,
        userId: currentUserId,
        username: currentUsername,
        userAvatar: currentUserAvatar,
        type: type,
        url: downloadUrl,
        createdAt: now,
        expiresAt: expiresAt,
        views: 0,
        likes: 0,
        duration: duration,
      );
    } catch (e) {
      debugPrint('Error creating story: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    try {
      // Get story to find storage path
      final doc = await _storiesCollection.doc(storyId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final userId = data['userId'] as String;
        final type = data['type'] as String;
        final extension = type == 'video' ? 'mp4' : 'jpg';
        
        // Delete from storage
        try {
          await _storage.ref('stories/$userId/$storyId.$extension').delete();
        } catch (e) {
          debugPrint('Error deleting story file: $e');
        }
      }

      // Delete from Firestore
      await _storiesCollection.doc(storyId).delete();
    } catch (e) {
      debugPrint('Error deleting story: $e');
      rethrow;
    }
  }

  @override
  Future<List<StoryEntity>> getUserStories(String userId) async {
    try {
      final now = DateTime.now();
      final query = await _storiesCollection
          .where('userId', isEqualTo: userId)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => _storyFromDoc(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting user stories: $e');
      return [];
    }
  }

  @override
  Future<List<StoryEntity>> getStories() async {
    try {
      final now = DateTime.now();
      
      // Get stories from followed users and own stories
      final query = await _storiesCollection
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return query.docs.map((doc) => _storyFromDoc(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting stories: $e');
      return [];
    }
  }

  @override
  Future<void> markStoryViewed(String storyId, String userId) async {
    try {
      await _storiesCollection.doc(storyId).update({
        'viewers': FieldValue.arrayUnion([userId]),
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error marking story viewed: $e');
    }
  }

  @override
  Future<void> likeStory(String storyId, String userId) async {
    try {
      await _storiesCollection.doc(storyId).update({
        'likers': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error liking story: $e');
    }
  }

  @override
  Future<void> unlikeStory(String storyId, String userId) async {
    try {
      await _storiesCollection.doc(storyId).update({
        'likers': FieldValue.arrayRemove([userId]),
        'likes': FieldValue.increment(-1),
      });
    } catch (e) {
      debugPrint('Error unliking story: $e');
    }
  }

  @override
  Future<List<String>> getStoryViewers(String storyId) async {
    try {
      final doc = await _storiesCollection.doc(storyId).get();
      if (doc.exists) {
        final viewers = doc.data()?['viewers'] as List<dynamic>?;
        return viewers?.cast<String>() ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Error getting story viewers: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getStoryLikers(String storyId) async {
    try {
      final doc = await _storiesCollection.doc(storyId).get();
      if (doc.exists) {
        final likers = doc.data()?['likers'] as List<dynamic>?;
        return likers?.cast<String>() ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Error getting story likers: $e');
      return [];
    }
  }

  StoryEntity _storyFromDoc(Map<String, dynamic> data) {
    return StoryEntity(
      id: data['id'] as String,
      userId: data['userId'] as String,
      username: data['username'] as String,
      userAvatar: data['userAvatar'] as String? ?? '',
      type: data['type'] == 'video' ? StoryType.video : StoryType.image,
      url: data['url'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      views: data['views'] as int? ?? 0,
      likes: data['likes'] as int? ?? 0,
      duration: data['duration'] as int?,
      isViewed: (data['viewers'] as List<dynamic>?)?.contains(currentUserId) ?? false,
    );
  }
}
