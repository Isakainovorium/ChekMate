import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/constants/app_constants.dart';
import 'package:flutter_chekmate/core/data/models/post_model.dart';
import 'package:flutter_chekmate/core/data/models/user_model.dart';
import 'package:flutter_chekmate/core/errors/app_exception.dart';
import 'package:flutter_chekmate/core/utils/logger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(UserModel user) async {
    try {
      Logger.info('Creating user: ${user.id}');
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
      Logger.info('User created successfully');
    } catch (e) {
      Logger.error('Failed to create user', e);
      throw ServerException(
        message: 'Failed to create user',
        originalError: e,
      );
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      Logger.info('Fetching user: $userId');
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      Logger.error('Failed to fetch user', e);
      throw ServerException(
        message: 'Failed to fetch user',
        originalError: e,
      );
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      Logger.info('Updating user: $userId');
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Logger.info('User updated successfully');
    } catch (e) {
      Logger.error('Failed to update user', e);
      throw ServerException(
        message: 'Failed to update user',
        originalError: e,
      );
    }
  }

  Stream<UserModel?> watchUser(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Post operations
  Future<String> createPost(PostModel post) async {
    try {
      Logger.info('Creating post');
      final docRef = await _firestore
          .collection(AppConstants.postsCollection)
          .add(post.toFirestore());
      Logger.info('Post created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      Logger.error('Failed to create post', e);
      throw ServerException(
        message: 'Failed to create post',
        originalError: e,
      );
    }
  }

  Future<PostModel?> getPost(String postId) async {
    try {
      Logger.info('Fetching post: $postId');
      final doc = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return PostModel.fromFirestore(doc);
    } catch (e) {
      Logger.error('Failed to fetch post', e);
      throw ServerException(
        message: 'Failed to fetch post',
        originalError: e,
      );
    }
  }

  Stream<List<PostModel>> watchPosts({
    int limit = 20,
    String? lastPostId,
  }) {
    Query query = _firestore
        .collection(AppConstants.postsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastPostId != null) {
      query = query.startAfter([lastPostId]);
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      Logger.info('Liking post: $postId');
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'likesCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
      Logger.info('Post liked successfully');
    } catch (e) {
      Logger.error('Failed to like post', e);
      throw ServerException(
        message: 'Failed to like post',
        originalError: e,
      );
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      Logger.info('Unliking post: $postId');
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'likesCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
      Logger.info('Post unliked successfully');
    } catch (e) {
      Logger.error('Failed to unlike post', e);
      throw ServerException(
        message: 'Failed to unlike post',
        originalError: e,
      );
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      Logger.info('Deleting post: $postId');
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .delete();
      Logger.info('Post deleted successfully');
    } catch (e) {
      Logger.error('Failed to delete post', e);
      throw ServerException(
        message: 'Failed to delete post',
        originalError: e,
      );
    }
  }

  // Batch operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      Logger.info('Executing batch write');
      final batch = _firestore.batch();

      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String?;
        final data = operation['data'] as Map<String, dynamic>?;

        final docRef = docId != null
            ? _firestore.collection(collection).doc(docId)
            : _firestore.collection(collection).doc();

        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      Logger.info('Batch write completed');
    } catch (e) {
      Logger.error('Batch write failed', e);
      throw ServerException(
        message: 'Batch operation failed',
        originalError: e,
      );
    }
  }
}
