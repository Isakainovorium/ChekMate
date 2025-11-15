import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/models/user_model.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explore State
class ExploreState {
  const ExploreState({
    this.selectedCategory = 'All',
    this.isLoading = false,
    this.error,
    this.followedUsers = const [],
  });

  final String selectedCategory;
  final bool isLoading;
  final String? error;
  final List<String> followedUsers;

  ExploreState copyWith({
    String? selectedCategory,
    bool? isLoading,
    String? error,
    List<String>? followedUsers,
  }) {
    return ExploreState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      followedUsers: followedUsers ?? this.followedUsers,
    );
  }
}

/// Explore State Provider
final exploreStateProvider =
    StateNotifierProvider<ExploreStateNotifier, ExploreState>((ref) {
  return ExploreStateNotifier();
});

/// Explore State Notifier
class ExploreStateNotifier extends StateNotifier<ExploreState> {
  ExploreStateNotifier() : super(const ExploreState());

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Toggle follow/unfollow for a user
  Future<void> toggleFollowUser(String userId) async {
    try {
      final followedUsers = List<String>.from(state.followedUsers);

      if (followedUsers.contains(userId)) {
        // Unfollow
        followedUsers.remove(userId);

        // TODO: Update Firestore to remove follow relationship
        await FirebaseFirestore.instance
            .collection('follows')
            .where('followerId',
                isEqualTo: 'currentUserId') // TODO: Get actual current user ID
            .where('followingId', isEqualTo: userId)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
      } else {
        // Follow
        followedUsers.add(userId);

        // TODO: Update Firestore to add follow relationship
        await FirebaseFirestore.instance.collection('follows').add({
          'followerId': 'currentUserId', // TODO: Get actual current user ID
          'followingId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      state = state.copyWith(followedUsers: followedUsers);
    } catch (e) {
      setError('Failed to toggle follow: $e');
    }
  }
}

/// Suggested Users Provider
/// Provides a list of suggested users to follow
final suggestedUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .orderBy('followers', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  });
});

/// Popular Content Provider
/// Provides popular posts based on engagement
final popularContentProvider = StreamProvider<List<PostEntity>>((ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('posts')
      .orderBy('likes', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PostEntity(
        id: doc.id,
        userId: data['userId'] as String,
        username: data['username'] as String,
        userAvatar: data['userAvatar'] as String? ?? '',
        content: data['content'] as String,
        images: (data['images'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        videoUrl: data['videoUrl'] as String?,
        thumbnailUrl: data['thumbnailUrl'] as String?,
        likes: data['likes'] as int? ?? 0,
        comments: data['comments'] as int? ?? 0,
        shares: data['shares'] as int? ?? 0,
        cheks: data['cheks'] as int? ?? 0,
        likedBy: (data['likedBy'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        bookmarkedBy: (data['bookmarkedBy'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        tags: (data['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        location: data['location'] as String?,
        coordinates: data['coordinates'] as GeoPoint?,
        geohash: data['geohash'] as String?,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        isVerified: data['isVerified'] as bool? ?? false,
      );
    }).toList();
  });
});

/// Trending Content Provider
/// Provides trending posts based on recent engagement
final trendingContentProvider = StreamProvider<List<PostEntity>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final oneDayAgo = now.subtract(const Duration(days: 1));

  return firestore
      .collection('posts')
      .where('createdAt', isGreaterThan: Timestamp.fromDate(oneDayAgo))
      .orderBy('createdAt', descending: true)
      .orderBy('likes', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PostEntity(
        id: doc.id,
        userId: data['userId'] as String,
        username: data['username'] as String,
        userAvatar: data['userAvatar'] as String? ?? '',
        content: data['content'] as String,
        images: (data['images'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        videoUrl: data['videoUrl'] as String?,
        thumbnailUrl: data['thumbnailUrl'] as String?,
        likes: data['likes'] as int? ?? 0,
        comments: data['comments'] as int? ?? 0,
        shares: data['shares'] as int? ?? 0,
        cheks: data['cheks'] as int? ?? 0,
        likedBy: (data['likedBy'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        bookmarkedBy: (data['bookmarkedBy'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        tags: (data['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        location: data['location'] as String?,
        coordinates: data['coordinates'] as GeoPoint?,
        geohash: data['geohash'] as String?,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        isVerified: data['isVerified'] as bool? ?? false,
      );
    }).toList();
  });
});

/// Explore Categories
const List<String> exploreCategories = [
  'All',
  'Dating',
  'Relationships',
  'Experiences',
  'Advice',
  'Stories',
  'Reviews',
];
