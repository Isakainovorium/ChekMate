import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/explore/domain/entities/explore_content_entity.dart';
import 'package:flutter_chekmate/features/explore/domain/repositories/explore_repository.dart';
import 'package:flutter_chekmate/features/posts/data/models/post_model.dart';

/// Explore Repository Implementation
/// Implements the ExploreRepository interface
class ExploreRepositoryImpl implements ExploreRepository {
  ExploreRepositoryImpl() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _postsCollection = 'posts';
  static const String _usersCollection = 'users';

  /// Convert PostModel to ExploreContentEntity
  ExploreContentEntity _postModelToExploreContent(PostModel post, {bool isTrending = false, bool isPopular = false}) {
    return ExploreContentEntity(
      id: post.id,
      type: post.videoUrl != null ? ExploreContentType.video : ExploreContentType.image,
      title: post.content.length > 50 ? '${post.content.substring(0, 50)}...' : post.content,
      description: post.content,
      imageUrl: post.images.isNotEmpty ? post.images.first : '',
      videoUrl: post.videoUrl,
      thumbnailUrl: post.thumbnailUrl,
      authorId: post.userId,
      authorName: post.username,
      authorAvatar: post.userAvatar,
      likes: post.likes,
      comments: post.comments,
      shares: post.shares,
      createdAt: post.createdAt,
      hashtags: post.tags,
      location: post.location,
      category: _determineCategoryFromTags(post.tags),
      isTrending: isTrending,
      isPopular: isPopular,
      engagementScore: _calculateEngagementScore(post).round(),
    );
  }

  /// Determine category from hashtags
  String _determineCategoryFromTags(List<String> tags) {
    final categories = {
      'Technology': ['tech', 'coding', 'programming', 'software', 'app', 'mobile', 'web'],
      'Art': ['art', 'design', 'photography', 'drawing', 'painting', 'creative'],
      'Sports': ['sports', 'fitness', 'workout', 'gym', 'running', 'football', 'basketball'],
      'Food': ['food', 'cooking', 'recipe', 'restaurant', 'eat', 'delicious'],
      'Travel': ['travel', 'vacation', 'trip', 'adventure', 'explore', 'nature'],
      'Music': ['music', 'song', 'band', 'concert', 'singer', 'instrument'],
      'Fashion': ['fashion', 'style', 'clothes', 'outfit', 'beauty', 'makeup'],
      'Business': ['business', 'startup', 'entrepreneur', 'money', 'finance', 'career'],
    };

    for (final tag in tags) {
      final lowercaseTag = tag.toLowerCase();
      for (final entry in categories.entries) {
        if (entry.value.any((keyword) => lowercaseTag.contains(keyword))) {
          return entry.key;
        }
      }
    }

    return 'General';
  }

  /// Calculate engagement score for content
  double _calculateEngagementScore(PostModel post) {
    final likes = post.likes.toDouble();
    final comments = post.comments.toDouble();
    final shares = post.shares.toDouble();

    // Simple engagement formula: likes * 1 + comments * 2 + shares * 3
    return likes + (comments * 2) + (shares * 3);
  }

  @override
  Future<List<ExploreContentEntity>> getTrendingContent({
    int limit = 20,
    String? category,
  }) async {
    try {
      // Get posts from last 24 hours with high engagement (likes, comments, shares)
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));

      Query<Map<String, dynamic>> query = _firestore.collection(_postsCollection)
          .where('createdAt', isGreaterThan: yesterday)
          .orderBy('createdAt', descending: true)
          .orderBy('likes', descending: true)
          .limit(limit * 2); // Get more to filter by engagement

      // Apply category filter if specified
      if (category != null && category != 'All') {
        // Note: Firestore doesn't support complex text search in arrays easily
        // For now, we'll get trending posts and filter client-side
        // In production, consider storing categories as a separate field
      }

      final snapshot = await query.get();

      final posts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .where((post) {
            // Filter by category if specified
            if (category != null && category != 'All') {
              final postCategory = _determineCategoryFromTags(post.tags);
              return postCategory == category;
            }
            return true;
          })
          .take(limit)
          .toList();

      return posts.map((post) => _postModelToExploreContent(post, isTrending: true)).toList();
    } catch (e) {
      // Fallback to mock data if Firestore query fails
      return _getMockContent(limit, isTrending: true, category: category);
    }
  }

  @override
  Future<List<ExploreContentEntity>> getPopularContent({
    int limit = 20,
    String? category,
  }) async {
    try {
      // Get posts with highest engagement scores (likes + comments*2 + shares*3)
      Query<Map<String, dynamic>> query = _firestore.collection(_postsCollection)
          .orderBy('likes', descending: true)
          .orderBy('comments', descending: true)
          .limit(limit * 3); // Get more to ensure good variety

      final snapshot = await query.get();

      final posts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .where((post) {
            // Filter by category if specified
            if (category != null && category != 'All') {
              final postCategory = _determineCategoryFromTags(post.tags);
              return postCategory == category;
            }
            return true;
          })
          .toList();

      // Sort by calculated engagement score
      posts.sort((a, b) => _calculateEngagementScore(b).compareTo(_calculateEngagementScore(a)));

      return posts.take(limit)
          .map((post) => _postModelToExploreContent(post, isPopular: true))
          .toList();
    } catch (e) {
      // Fallback to mock data if Firestore query fails
      return _getMockContent(limit, isPopular: true, category: category);
    }
  }

  @override
  Future<List<HashtagEntity>> getTrendingHashtags({
    int limit = 10,
  }) async {
    try {
      // Get recent posts to aggregate hashtags
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));

      final snapshot = await _firestore.collection(_postsCollection)
          .where('createdAt', isGreaterThan: weekAgo)
          .limit(200) // Sample recent posts
          .get();

      // Aggregate hashtag usage
      final hashtagCounts = <String, int>{};

      for (final doc in snapshot.docs) {
        final post = PostModel.fromFirestore(doc);
        for (final tag in post.tags) {
          final normalizedTag = tag.toLowerCase();
          hashtagCounts[normalizedTag] = (hashtagCounts[normalizedTag] ?? 0) + 1;
        }
      }

      // Convert to HashtagEntity list
      final hashtags = hashtagCounts.entries
          .map((entry) => HashtagEntity(
                name: entry.key,
                count: entry.value,
                isTrending: entry.value > 10, // Consider trending if used more than 10 times
                createdAt: DateTime.now(), // Not accurate, but required by entity
              ))
          .toList();

      // Sort by count descending
      hashtags.sort((a, b) => b.count.compareTo(a.count));

      return hashtags.take(limit).toList();
    } catch (e) {
      // Fallback to mock data if Firestore query fails
      return _getMockHashtags(limit);
    }
  }

  @override
  Future<List<SuggestedUserEntity>> getSuggestedUsers({
    int limit = 10,
    String? forUserId,
  }) async {
    try {
      // Get users with most followers (excluding current user if provided)
      Query<Map<String, dynamic>> query = _firestore.collection(_usersCollection)
          .orderBy('followers', descending: true)
          .limit(limit + (forUserId != null ? 1 : 0)); // Get one extra if we need to exclude current user

      final snapshot = await query.get();

      final users = snapshot.docs
          .where((doc) => forUserId == null || doc.id != forUserId) // Exclude current user
          .map((doc) {
            final data = doc.data();
            return SuggestedUserEntity(
              uid: doc.id,
              username: data['username'] ?? '',
              displayName: data['displayName'] ?? '',
              avatar: data['avatar'] ?? '',
              bio: data['bio'] ?? '',
              followers: data['followers'] ?? 0,
              isVerified: data['isVerified'] ?? false,
              mutualFriends: 0, // Would need following relationships to calculate
              reason: 'Popular user',
            );
          })
          .take(limit)
          .toList();

      return users;
    } catch (e) {
      // Fallback to mock data if Firestore query fails
      return _getMockSuggestedUsers(limit);
    }
  }

  @override
  Future<List<ExploreContentEntity>> getContentByHashtag(
    String hashtag, {
    int limit = 20,
  }) async {
    try {
      // Normalize hashtag (remove # if present)
      final normalizedHashtag = hashtag.startsWith('#') ? hashtag.substring(1) : hashtag;

      // Use array-contains query to find posts with this hashtag
      final snapshot = await _firestore.collection(_postsCollection)
          .where('tags', arrayContains: normalizedHashtag)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final posts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();

      return posts.map((post) => _postModelToExploreContent(post)).toList();
    } catch (e) {
      // Fallback to mock data if Firestore query fails
      final content = _getMockContent(limit);
      return content.where((item) => item.hashtags.contains(hashtag)).toList();
    }
  }

  @override
  Future<List<ExploreContentEntity>> getContentByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      // Get posts and filter by category on client side
      // In production, consider adding a category field to posts for better performance
      final snapshot = await _firestore.collection(_postsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit * 3) // Get more to filter
          .get();

      final posts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .where((post) => _determineCategoryFromTags(post.tags) == category)
          .take(limit)
          .toList();

      return posts.map((post) => _postModelToExploreContent(post)).toList();
    } catch (e) {
      // Fallback to mock data if Firestore query fails
      final content = _getMockContent(limit);
      return content.where((item) => item.category == category).toList();
    }
  }

  @override
  Future<List<ExploreContentEntity>> searchContent(
    String query, {
    int limit = 20,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      // For now, implement client-side search due to Firestore limitations
      // In production, consider using Algolia or Elasticsearch for better search
      final snapshot = await _firestore.collection(_postsCollection)
          .orderBy('createdAt', descending: true)
          .limit(100) // Search through recent posts
          .get();

      final lowercaseQuery = query.toLowerCase();

      final matchingPosts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .where((post) {
            return post.content.toLowerCase().contains(lowercaseQuery) ||
                   post.username.toLowerCase().contains(lowercaseQuery) ||
                   post.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
                   (post.location?.toLowerCase().contains(lowercaseQuery) ?? false);
          })
          .take(limit)
          .toList();

      return matchingPosts.map((post) => _postModelToExploreContent(post)).toList();
    } catch (e) {
      // Fallback to mock data search if Firestore query fails
      final content = _getMockContent(limit);
      final lowercaseQuery = query.toLowerCase();
      return content.where((item) {
        return item.title.toLowerCase().contains(lowercaseQuery) ||
               item.description.toLowerCase().contains(lowercaseQuery) ||
               item.authorName.toLowerCase().contains(lowercaseQuery) ||
               item.hashtags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    }
  }

  @override
  Future<Map<String, dynamic>> getExploreStats() async {
    try {
      // Get counts from Firestore collections
      final postsSnapshot = await _firestore.collection(_postsCollection).count().get();
      final usersSnapshot = await _firestore.collection(_usersCollection).count().get();

      // Get active users today (users who posted today)
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final activeUsersSnapshot = await _firestore.collection(_postsCollection)
          .where('createdAt', isGreaterThan: startOfDay)
          .get();

      // Count unique users who posted today
      final activeUserIds = activeUsersSnapshot.docs
          .map((doc) => doc.data()['userId'] as String?)
          .where((id) => id != null)
          .toSet();

      // Aggregate hashtags from recent posts
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentPostsSnapshot = await _firestore.collection(_postsCollection)
          .where('createdAt', isGreaterThan: weekAgo)
          .limit(500)
          .get();

      final hashtagSet = <String>{};
      for (final doc in recentPostsSnapshot.docs) {
        final tags = List<String>.from(doc.data()['tags'] ?? []);
        hashtagSet.addAll(tags);
      }

      return {
        'totalPosts': postsSnapshot.count,
        'totalHashtags': hashtagSet.length,
        'totalUsers': usersSnapshot.count,
        'activeUsersToday': activeUserIds.length,
        'trendingTopicsCount': hashtagSet.length, // Same as total hashtags for now
      };
    } catch (e) {
      // Fallback to mock stats if Firestore queries fail
      return {
        'totalPosts': 125000,
        'totalHashtags': 150,
        'totalUsers': 25000,
        'activeUsersToday': 5200,
        'trendingTopicsCount': 150,
      };
    }
  }

  // Mock data generators
  List<ExploreContentEntity> _getMockContent(
    int limit, {
    bool isTrending = false,
    bool isPopular = false,
    String? category,
  }) {
    final content = <ExploreContentEntity>[];

    for (int i = 0; i < limit; i++) {
      content.add(ExploreContentEntity(
        id: 'content_$i',
        type: ExploreContentType.values[i % ExploreContentType.values.length],
        title: 'Sample Content ${i + 1}',
        description: 'This is a sample description for content ${i + 1}',
        imageUrl: 'https://example.com/image_$i.jpg',
        authorId: 'user_$i',
        authorName: 'User ${i + 1}',
        authorAvatar: 'https://example.com/avatar_$i.jpg',
        likes: 100 + (i * 10),
        comments: 20 + (i * 2),
        shares: 5 + i,
        createdAt: DateTime.now().subtract(Duration(hours: i)),
        hashtags: const ['#sample', '#content', '#explore'],
        category: category ?? const ['Technology', 'Art', 'Sports', 'Food'][i % 4],
        isTrending: isTrending,
        isPopular: isPopular,
        engagementScore: 100 + (i * 15),
      ));
    }

    return content;
  }

  List<HashtagEntity> _getMockHashtags(int limit) {
    final hashtags = <HashtagEntity>[];

    final hashtagNames = [
      'flutter',
      'dart',
      'mobile',
      'coding',
      'technology',
      'design',
      'photography',
      'travel',
      'food',
      'fitness',
    ];

    for (int i = 0; i < limit && i < hashtagNames.length; i++) {
      hashtags.add(HashtagEntity(
        name: hashtagNames[i],
        count: 1000 + (i * 100),
        isTrending: i < 5,
        createdAt: DateTime.now().subtract(Duration(days: i)),
      ));
    }

    return hashtags;
  }

  List<SuggestedUserEntity> _getMockSuggestedUsers(int limit) {
    final users = <SuggestedUserEntity>[];

    for (int i = 0; i < limit; i++) {
      users.add(SuggestedUserEntity(
        uid: 'user_$i',
        username: 'user${i + 1}',
        displayName: 'User ${i + 1}',
        avatar: 'https://example.com/avatar_$i.jpg',
        bio: 'Sample bio for user ${i + 1}',
        followers: 100 + (i * 50),
        isVerified: i % 5 == 0,
        mutualFriends: i % 3,
        reason: i % 2 == 0 ? 'Follows you' : 'Popular in your area',
      ));
    }

    return users;
  }
}
