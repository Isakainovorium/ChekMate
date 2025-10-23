import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/core/utils/geohash_utils.dart';
import 'package:flutter_chekmate/features/posts/data/models/post_model.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Posts Remote Data Source - Data Layer
///
/// Handles all Firebase Firestore and Storage operations for posts.
/// This is the only class that directly interacts with Firebase.
///
/// Clean Architecture: Data Layer
class PostsRemoteDataSource {
  const PostsRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  static const String _postsCollection = 'posts';
  static const String _usersCollection = 'users';

  // ========== CREATE OPERATIONS ==========

  /// Create a new post
  Future<PostModel> createPost({
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
    try {
      developer.log(
        'Creating post for user: $userId',
        name: 'PostsRemoteDataSource',
      );

      final postId = _uuid.v4();
      final now = DateTime.now();
      final imageUrls = <String>[];
      String? videoUrl;
      String? thumbnailUrl;

      // Upload images if any
      if (images != null && images.isNotEmpty) {
        developer.log(
          'Uploading ${images.length} images',
          name: 'PostsRemoteDataSource',
        );
        for (var i = 0; i < images.length; i++) {
          final url = await _uploadImage(
            userId: userId,
            postId: postId,
            imageData: images[i],
            index: i,
          );
          imageUrls.add(url);
        }
      }

      // Upload video if any
      if (video != null) {
        developer.log('Uploading video', name: 'PostsRemoteDataSource');
        videoUrl = await _uploadVideo(
          userId: userId,
          postId: postId,
          videoData: video,
        );

        // Generate and upload thumbnail from video
        try {
          thumbnailUrl = await _generateAndUploadThumbnail(
            userId: userId,
            postId: postId,
            videoData: video,
          );
          developer.log(
            'Thumbnail generated successfully',
            name: 'PostsRemoteDataSource',
          );
        } on Exception catch (e) {
          developer.log(
            'Failed to generate thumbnail, continuing without it',
            name: 'PostsRemoteDataSource',
            error: e,
          );
          thumbnailUrl = null;
        }
      }

      // Generate geohash from coordinates if provided
      String? geohash;
      if (coordinates != null) {
        geohash = GeohashUtils.generateGeohash(
          coordinates.latitude,
          coordinates.longitude,
        );
        developer.log(
          'Generated geohash: $geohash for coordinates (${coordinates.latitude}, ${coordinates.longitude})',
          name: 'PostsRemoteDataSource',
        );
      }

      // Create post model
      final post = PostModel(
        id: postId,
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        content: content,
        images: imageUrls,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        likes: 0,
        comments: 0,
        shares: 0,
        cheks: 0,
        createdAt: now,
        updatedAt: now,
        location: location,
        tags: tags,
        coordinates: coordinates,
        geohash: geohash,
        isVerified: false,
        likedBy: [],
        bookmarkedBy: [],
      );

      // Save to Firestore
      await _firestore
          .collection(_postsCollection)
          .doc(postId)
          .set(post.toFirestore());

      // Update user's post count
      await _firestore.collection(_usersCollection).doc(userId).update({
        'posts': FieldValue.increment(1),
      });

      developer.log(
        'Post created successfully: $postId',
        name: 'PostsRemoteDataSource',
      );
      return post;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create post',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to create post: $e');
    }
  }

  // ========== READ OPERATIONS ==========

  /// Get a single post by ID
  Future<PostModel> getPost(String postId) async {
    try {
      developer.log('Getting post: $postId', name: 'PostsRemoteDataSource');

      final doc =
          await _firestore.collection(_postsCollection).doc(postId).get();

      if (!doc.exists) {
        throw Exception('Post not found');
      }

      return PostModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get post',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to get post: $e');
    }
  }

  /// Get posts feed stream
  Stream<List<PostModel>> getPosts({
    int limit = 20,
    String? userId,
  }) {
    try {
      developer.log(
        'Getting posts feed (limit: $limit, userId: $userId)',
        name: 'PostsRemoteDataSource',
      );

      Query<Map<String, dynamic>> query =
          _firestore.collection(_postsCollection);

      // Filter by user if specified
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);

      // Limit results
      query = query.limit(limit);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList();
      });
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get posts stream',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to get posts: $e');
    }
  }

  /// Get posts for a specific user
  Stream<List<PostModel>> getUserPosts({
    required String userId,
    int limit = 20,
  }) {
    return getPosts(limit: limit, userId: userId);
  }

  /// Get posts near a location using geohash
  ///
  /// Parameters:
  /// - center: GeoPoint representing the center location
  /// - radiusKm: Radius in kilometers to search within
  /// - limit: Maximum number of posts to retrieve (default: 20)
  ///
  /// Returns: Future<List<PostModel>> of posts within the specified radius
  ///
  /// Uses GeoFlutterFire Plus for efficient geospatial queries
  Future<List<PostModel>> getPostsNearLocation({
    required GeoPoint center,
    required double radiusKm,
    int limit = 20,
  }) async {
    try {
      developer.log(
        'Getting posts near location: (${center.latitude}, ${center.longitude}) within ${radiusKm}km',
        name: 'PostsRemoteDataSource',
      );

      // Create GeoFirePoint from center coordinates
      final geoFirePoint = GeoFirePoint(center);

      // Create geohash query collection reference
      final collectionRef = _firestore.collection(_postsCollection);

      // Perform geohash query using subscribeWithin and get first result
      final geoQuery = GeoCollectionReference(collectionRef).subscribeWithin(
        center: geoFirePoint,
        radiusInKm: radiusKm,
        field: 'geohash',
        geopointFrom: (data) {
          final geopoint = data['coordinates'] as GeoPoint?;
          return geopoint ??
              const GeoPoint(0, 0); // Fallback for posts without coordinates
        },
        strictMode: true,
      );

      // Get documents from the stream (take first emission)
      final posts = <PostModel>[];
      final snapshot = await geoQuery.first;

      for (final docSnapshot in snapshot) {
        if (docSnapshot.exists) {
          try {
            final post = PostModel.fromFirestore(docSnapshot);
            posts.add(post);

            // Stop if we've reached the limit
            if (posts.length >= limit) {
              break;
            }
          } on Exception catch (e) {
            developer.log(
              'Failed to parse post from document',
              name: 'PostsRemoteDataSource',
              error: e,
            );
          }
        }
      }

      // Sort by creation date (newest first)
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      developer.log(
        'Found ${posts.length} posts within ${radiusKm}km',
        name: 'PostsRemoteDataSource',
      );

      return posts;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get posts near location',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to get posts near location: $e');
    }
  }

  /// Get posts by user interests
  ///
  /// Retrieves posts that match any of the user's interests using Firestore
  /// array-contains-any query on the tags field.
  ///
  /// Parameters:
  /// - interests: List of user's interests to match
  /// - limit: Maximum number of posts to retrieve (default: 20)
  ///
  /// Returns: Future<List<PostModel>> of posts matching user interests
  ///
  /// Note: Firestore array-contains-any supports up to 10 values.
  /// If user has more than 10 interests, we'll use the first 10.
  Future<List<PostModel>> getPostsByInterests({
    required List<String> interests,
    int limit = 20,
  }) async {
    try {
      developer.log(
        'Getting posts by interests: ${interests.join(", ")}',
        name: 'PostsRemoteDataSource',
      );

      // Firestore array-contains-any supports up to 10 values
      final interestsToQuery = interests.take(10).toList();

      if (interestsToQuery.isEmpty) {
        developer.log(
          'No interests provided, returning empty list',
          name: 'PostsRemoteDataSource',
        );
        return [];
      }

      // Query posts where tags array contains any of the user's interests
      // Case-insensitive matching by converting to lowercase
      final interestsLower =
          interestsToQuery.map((e) => e.toLowerCase()).toList();

      final querySnapshot = await _firestore
          .collection(_postsCollection)
          .where('tags', arrayContainsAny: interestsLower)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final posts = <PostModel>[];
      for (final doc in querySnapshot.docs) {
        try {
          final post = PostModel.fromFirestore(doc);
          posts.add(post);
        } on Exception catch (e) {
          developer.log(
            'Failed to parse post from document',
            name: 'PostsRemoteDataSource',
            error: e,
          );
        }
      }

      developer.log(
        'Found ${posts.length} posts matching interests',
        name: 'PostsRemoteDataSource',
      );

      return posts;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get posts by interests',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to get posts by interests: $e');
    }
  }

  // ========== UPDATE OPERATIONS ==========

  /// Like a post
  Future<void> likePost({
    required String postId,
    required String userId,
  }) async {
    try {
      developer.log(
        'Liking post: $postId by user: $userId',
        name: 'PostsRemoteDataSource',
      );

      await _firestore.collection(_postsCollection).doc(postId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });

      developer.log('Post liked successfully', name: 'PostsRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to like post',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to like post: $e');
    }
  }

  /// Unlike a post
  Future<void> unlikePost({
    required String postId,
    required String userId,
  }) async {
    try {
      developer.log(
        'Unliking post: $postId by user: $userId',
        name: 'PostsRemoteDataSource',
      );

      await _firestore.collection(_postsCollection).doc(postId).update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });

      developer.log('Post unliked successfully', name: 'PostsRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to unlike post',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to unlike post: $e');
    }
  }

  /// Bookmark a post
  Future<void> bookmarkPost({
    required String postId,
    required String userId,
  }) async {
    try {
      developer.log(
        'Bookmarking post: $postId by user: $userId',
        name: 'PostsRemoteDataSource',
      );

      await _firestore.collection(_postsCollection).doc(postId).update({
        'bookmarkedBy': FieldValue.arrayUnion([userId]),
      });

      developer.log(
        'Post bookmarked successfully',
        name: 'PostsRemoteDataSource',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to bookmark post',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to bookmark post: $e');
    }
  }

  /// Remove bookmark from a post
  Future<void> unbookmarkPost({
    required String postId,
    required String userId,
  }) async {
    try {
      developer.log(
        'Unbookmarking post: $postId by user: $userId',
        name: 'PostsRemoteDataSource',
      );

      await _firestore.collection(_postsCollection).doc(postId).update({
        'bookmarkedBy': FieldValue.arrayRemove([userId]),
      });

      developer.log(
        'Post unbookmarked successfully',
        name: 'PostsRemoteDataSource',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to unbookmark post',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to unbookmark post: $e');
    }
  }

  /// Share a post
  Future<void> sharePost({
    required String postId,
    required String userId,
  }) async {
    try {
      developer.log(
        'Sharing post: $postId by user: $userId',
        name: 'PostsRemoteDataSource',
      );

      await _firestore.collection(_postsCollection).doc(postId).update({
        'shares': FieldValue.increment(1),
      });

      developer.log('Post shared successfully', name: 'PostsRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to share post',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to share post: $e');
    }
  }

  /// Update a post
  Future<PostModel> updatePost({
    required String postId,
    required String userId,
    String? content,
    String? location,
    List<String>? tags,
  }) async {
    try {
      developer.log(
        'Updating post: $postId by user: $userId',
        name: 'PostsRemoteDataSource',
      );

      // Get the post to verify ownership
      final post = await getPost(postId);
      if (post.userId != userId) {
        throw Exception('User is not authorized to update this post');
      }

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (content != null) updates['content'] = content;
      if (location != null) updates['location'] = location;
      if (tags != null) updates['tags'] = tags;

      await _firestore.collection(_postsCollection).doc(postId).update(updates);

      // Get updated post
      return await getPost(postId);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update post',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update post: $e');
    }
  }

  // ========== DELETE OPERATIONS ==========

  /// Delete a post
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      developer.log(
        'Deleting post: $postId by user: $userId',
        name: 'PostsRemoteDataSource',
      );

      // Get the post to verify ownership and get media URLs
      final post = await getPost(postId);
      if (post.userId != userId) {
        throw Exception('User is not authorized to delete this post');
      }

      // Delete media from Storage
      if (post.images.isNotEmpty) {
        for (final imageUrl in post.images) {
          try {
            final ref = _storage.refFromURL(imageUrl);
            await ref.delete();
          } on Exception catch (e) {
            developer.log(
              'Failed to delete image: $imageUrl',
              name: 'PostsRemoteDataSource',
              error: e,
            );
          }
        }
      }

      if (post.videoUrl != null) {
        try {
          final ref = _storage.refFromURL(post.videoUrl!);
          await ref.delete();
        } on Exception catch (e) {
          developer.log(
            'Failed to delete video',
            name: 'PostsRemoteDataSource',
            error: e,
          );
        }
      }

      // Delete post document
      await _firestore.collection(_postsCollection).doc(postId).delete();

      // Update user's post count
      await _firestore.collection(_usersCollection).doc(userId).update({
        'posts': FieldValue.increment(-1),
      });

      developer.log('Post deleted successfully', name: 'PostsRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete post',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to delete post: $e');
    }
  }

  // ========== QUERY OPERATIONS ==========

  /// Check if a user has liked a post
  Future<bool> hasLikedPost({
    required String postId,
    required String userId,
  }) async {
    try {
      final post = await getPost(postId);
      return post.likedBy.contains(userId);
    } on Exception catch (e) {
      developer.log(
        'Failed to check like status',
        name: 'PostsRemoteDataSource',
        error: e,
      );
      return false;
    }
  }

  /// Check if a user has bookmarked a post
  Future<bool> hasBookmarkedPost({
    required String postId,
    required String userId,
  }) async {
    try {
      final post = await getPost(postId);
      return post.bookmarkedBy.contains(userId);
    } on Exception catch (e) {
      developer.log(
        'Failed to check bookmark status',
        name: 'PostsRemoteDataSource',
        error: e,
      );
      return false;
    }
  }

  // ========== HELPER METHODS ==========

  /// Upload an image to Firebase Storage
  Future<String> _uploadImage({
    required String userId,
    required String postId,
    required Uint8List imageData,
    required int index,
  }) async {
    final fileName = 'post_${postId}_image_$index.jpg';
    final ref = _storage.ref().child('posts/$userId/$postId/$fileName');

    await ref.putData(
      imageData,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return ref.getDownloadURL();
  }

  /// Upload a video to Firebase Storage
  Future<String> _uploadVideo({
    required String userId,
    required String postId,
    required Uint8List videoData,
  }) async {
    final fileName = 'post_${postId}_video.mp4';
    final ref = _storage.ref().child('posts/$userId/$postId/$fileName');

    await ref.putData(
      videoData,
      SettableMetadata(contentType: 'video/mp4'),
    );

    return ref.getDownloadURL();
  }

  /// Generate thumbnail from video and upload to Firebase Storage
  ///
  /// Parameters:
  /// - userId: ID of the user
  /// - postId: ID of the post
  /// - videoData: Video data as bytes
  ///
  /// Returns: Download URL of the uploaded thumbnail
  Future<String> _generateAndUploadThumbnail({
    required String userId,
    required String postId,
    required Uint8List videoData,
  }) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final videoPath = '${tempDir.path}/temp_video_$postId.mp4';
      final thumbnailPath = '${tempDir.path}/thumbnail_$postId.jpg';

      // Save video to temporary file (required for FFmpeg)
      final videoFile = File(videoPath);
      await videoFile.writeAsBytes(videoData);

      // Generate thumbnail using FFmpeg
      // Extract frame at 1 second mark
      final command =
          '-i "$videoPath" -ss 00:00:01 -vframes 1 -q:v 2 "$thumbnailPath"';

      developer.log(
        'Generating thumbnail with FFmpeg',
        name: 'PostsRemoteDataSource',
      );

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        throw Exception('FFmpeg failed to generate thumbnail');
      }

      // Read thumbnail file
      final thumbnailFile = File(thumbnailPath);
      if (!thumbnailFile.existsSync()) {
        throw Exception('Thumbnail file was not created');
      }

      final thumbnailData = await thumbnailFile.readAsBytes();

      // Upload thumbnail to Firebase Storage
      final thumbnailUrl = await _uploadThumbnail(
        userId: userId,
        postId: postId,
        thumbnailData: thumbnailData,
      );

      // Cleanup temporary files
      try {
        await videoFile.delete();
        await thumbnailFile.delete();
      } on Exception catch (e) {
        developer.log(
          'Failed to cleanup temp files',
          name: 'PostsRemoteDataSource',
          error: e,
        );
      }

      return thumbnailUrl;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate thumbnail',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Upload thumbnail to Firebase Storage
  ///
  /// Parameters:
  /// - userId: ID of the user
  /// - postId: ID of the post
  /// - thumbnailData: Thumbnail image data as bytes
  ///
  /// Returns: Download URL of the uploaded thumbnail
  Future<String> _uploadThumbnail({
    required String userId,
    required String postId,
    required Uint8List thumbnailData,
  }) async {
    try {
      final fileName = 'post_${postId}_thumbnail.jpg';
      final ref = _storage.ref().child('posts/$userId/$postId/$fileName');

      await ref.putData(
        thumbnailData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return ref.getDownloadURL();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to upload thumbnail',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to upload thumbnail: $e');
    }
  }

  // ========== ENGAGEMENT TRACKING ==========

  /// Update post engagement metrics
  ///
  /// Updates view count, viewedBy list, engagement score, and lastEngagementUpdate timestamp.
  ///
  /// Parameters:
  /// - postId: ID of the post to update
  /// - views: New view count
  /// - viewedBy: Updated list of user IDs who viewed the post
  /// - engagementScore: Calculated engagement score
  ///
  /// Returns: Updated PostModel
  ///
  /// Throws:
  /// - Exception if update fails
  Future<PostModel> updatePostEngagement({
    required String postId,
    required int views,
    required List<String> viewedBy,
    required double engagementScore,
  }) async {
    try {
      developer.log(
        'Updating engagement for post: $postId (views: $views, score: $engagementScore)',
        name: 'PostsRemoteDataSource',
      );

      final now = DateTime.now();

      // Update Firestore document
      await _firestore.collection(_postsCollection).doc(postId).update({
        'views': views,
        'viewedBy': viewedBy,
        'engagementScore': engagementScore,
        'lastEngagementUpdate': Timestamp.fromDate(now),
      });

      // Fetch and return updated post
      final doc =
          await _firestore.collection(_postsCollection).doc(postId).get();

      if (!doc.exists) {
        throw Exception('Post not found after update');
      }

      return PostModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update post engagement',
        name: 'PostsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update post engagement: $e');
    }
  }
}
