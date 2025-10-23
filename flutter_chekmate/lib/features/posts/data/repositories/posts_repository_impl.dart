import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';

/// Posts Repository Implementation - Data Layer
///
/// Implements the PostsRepository interface defined in the domain layer.
/// Delegates all operations to the PostsRemoteDataSource.
/// Converts between data models and domain entities.
///
/// Clean Architecture: Data Layer
class PostsRepositoryImpl implements PostsRepository {
  const PostsRepositoryImpl(this._remoteDataSource);

  final PostsRemoteDataSource _remoteDataSource;

  @override
  Future<PostEntity> createPost({
    required String userId,
    required String username,
    required String userAvatar,
    required String content,
    List<Uint8List>? images,
    Uint8List? video,
    String? location,
    List<String>? tags,
    GeoPoint? coordinates,
  }) async {
    final postModel = await _remoteDataSource.createPost(
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      content: content,
      images: images,
      video: video,
      location: location,
      tags: tags,
      coordinates: coordinates,
    );
    return postModel.toEntity();
  }

  @override
  Future<PostEntity> getPost(String postId) async {
    final postModel = await _remoteDataSource.getPost(postId);
    return postModel.toEntity();
  }

  @override
  Stream<List<PostEntity>> getPosts({
    int limit = 20,
    String? userId,
  }) {
    return _remoteDataSource
        .getPosts(limit: limit, userId: userId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<PostEntity>> getUserPosts({
    required String userId,
    int limit = 20,
  }) {
    return _remoteDataSource
        .getUserPosts(userId: userId, limit: limit)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<List<PostEntity>> getPostsNearLocation({
    required GeoPoint center,
    required double radiusKm,
    int limit = 20,
  }) async {
    final postModels = await _remoteDataSource.getPostsNearLocation(
      center: center,
      radiusKm: radiusKm,
      limit: limit,
    );
    return postModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<PostEntity>> getPostsByInterests({
    required List<String> interests,
    int limit = 20,
  }) async {
    final postModels = await _remoteDataSource.getPostsByInterests(
      interests: interests,
      limit: limit,
    );
    return postModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> likePost({
    required String postId,
    required String userId,
  }) {
    return _remoteDataSource.likePost(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<void> unlikePost({
    required String postId,
    required String userId,
  }) {
    return _remoteDataSource.unlikePost(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<void> bookmarkPost({
    required String postId,
    required String userId,
  }) {
    return _remoteDataSource.bookmarkPost(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<void> unbookmarkPost({
    required String postId,
    required String userId,
  }) {
    return _remoteDataSource.unbookmarkPost(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) {
    return _remoteDataSource.deletePost(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<PostEntity> updatePost({
    required String postId,
    required String userId,
    String? content,
    String? location,
    List<String>? tags,
  }) async {
    final postModel = await _remoteDataSource.updatePost(
      postId: postId,
      userId: userId,
      content: content,
      location: location,
      tags: tags,
    );
    return postModel.toEntity();
  }

  @override
  Future<void> sharePost({
    required String postId,
    required String userId,
  }) {
    return _remoteDataSource.sharePost(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<bool> hasLikedPost({
    required String postId,
    required String userId,
  }) {
    return _remoteDataSource.hasLikedPost(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<bool> hasBookmarkedPost({
    required String postId,
    required String userId,
  }) {
    return _remoteDataSource.hasBookmarkedPost(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<PostEntity> updatePostEngagement({
    required String postId,
    required int views,
    required List<String> viewedBy,
    required double engagementScore,
  }) async {
    final postModel = await _remoteDataSource.updatePostEngagement(
      postId: postId,
      views: views,
      viewedBy: viewedBy,
      engagementScore: engagementScore,
    );
    return postModel.toEntity();
  }
}
