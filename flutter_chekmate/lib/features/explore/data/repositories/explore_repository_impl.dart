import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/explore/data/models/explore_content_model.dart';
import 'package:flutter_chekmate/features/explore/domain/entities/explore_content_entity.dart';
import 'package:flutter_chekmate/features/explore/domain/repositories/explore_repository.dart';

/// ExploreRepositoryImpl - Firebase Implementation of ExploreRepository
///
/// Handles all explore data operations with Firestore.
class ExploreRepositoryImpl implements ExploreRepository {
  ExploreRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<ExploreContentEntity>> getTrendingContent({
    int limit = 20,
    String? category,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .where('trendingScore', isGreaterThan: 0.5)
          .orderBy('trendingScore', descending: true)
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => ExploreContentModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get trending content: $e');
    }
  }

  @override
  Future<List<ExploreContentEntity>> getPopularContent({
    int limit = 20,
    String? category,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .orderBy('likes', descending: true)
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => ExploreContentModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get popular content: $e');
    }
  }

  @override
  Future<List<HashtagEntity>> getTrendingHashtags({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('hashtags')
          .orderBy('trendingScore', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => HashtagModel.fromJson({
              ...doc.data(),
              'tag': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get trending hashtags: $e');
    }
  }

  @override
  Future<List<SuggestedUserEntity>> getSuggestedUsers({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('isVerified', isEqualTo: true)
          .orderBy('followers', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => SuggestedUserModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get suggested users: $e');
    }
  }

  @override
  Future<List<ExploreContentEntity>> getContentByHashtag(
    String hashtag, {
    int limit = 20,
  }) async {
    try {
      final cleanHashtag = hashtag.replaceAll('#', '');

      final snapshot = await _firestore
          .collection('posts')
          .where('tags', arrayContains: cleanHashtag)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => ExploreContentModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get content by hashtag: $e');
    }
  }

  @override
  Future<List<ExploreContentEntity>> getContentByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => ExploreContentModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get content by category: $e');
    }
  }

  @override
  Future<List<ExploreContentEntity>> searchContent(
    String query, {
    int limit = 20,
  }) async {
    try {
      // Search in title and description
      final snapshot = await _firestore
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => ExploreContentModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search content: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getExploreStats() async {
    try {
      // Get trending posts count
      final trendingSnapshot = await _firestore
          .collection('posts')
          .where('trendingScore', isGreaterThan: 0.5)
          .count()
          .get();

      // Get total hashtags count
      final hashtagsSnapshot =
          await _firestore.collection('hashtags').count().get();

      // Get verified users count
      final usersSnapshot = await _firestore
          .collection('users')
          .where('isVerified', isEqualTo: true)
          .count()
          .get();

      return {
        'trendingPosts': trendingSnapshot.count ?? 0,
        'totalHashtags': hashtagsSnapshot.count ?? 0,
        'verifiedUsers': usersSnapshot.count ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get explore stats: $e');
    }
  }
}
