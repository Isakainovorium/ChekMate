import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/providers/providers.dart';
import 'package:flutter_chekmate/features/stories/models/story_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stories Providers - Real Firebase Implementation
/// Fetches stories from Firestore with proper filtering and sorting

/// Firestore stories collection reference
final _storiesCollection = FirebaseFirestore.instance.collection('stories');

/// Stream of all active stories (not expired, from followed users + trending)
final storiesProvider = StreamProvider<List<StoryUser>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider).value;
  
  // Get stories from last 24 hours that haven't expired
  final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));
  
  return _storiesCollection
      .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
      .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
      .orderBy('expiresAt')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
        // Group stories by user
        final Map<String, List<StoryModel>> storiesByUser = {};
        
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final story = StoryModel(
            id: doc.id,
            userId: data['userId'] as String,
            username: data['username'] as String? ?? '',
            userAvatar: data['userAvatar'] as String? ?? '',
            mediaUrl: data['mediaUrl'] as String,
            mediaType: data['mediaType'] as String? ?? 'image',
            timestamp: (data['createdAt'] as Timestamp).toDate(),
            expiresAt: (data['expiresAt'] as Timestamp).toDate(),
            views: data['views'] as int? ?? 0,
            isViewed: _isStoryViewed(data, currentUserId),
          );
          
          storiesByUser.putIfAbsent(story.userId, () => []).add(story);
        }
        
        // Convert to StoryUser list
        final storyUsers = <StoryUser>[];
        
        for (final entry in storiesByUser.entries) {
          final userId = entry.key;
          final userStories = entry.value;
          
          if (userStories.isEmpty) continue;
          
          // Get user info from first story
          final firstStory = userStories.first;
          final hasUnviewed = userStories.any((s) => !s.isViewed);
          
          storyUsers.add(StoryUser(
            id: userId,
            username: firstStory.username,
            avatar: firstStory.userAvatar,
            hasUnviewedStories: hasUnviewed,
            stories: userStories,
          ));
        }
        
        // Sort: unviewed first, then by most recent story
        storyUsers.sort((a, b) {
          if (a.hasUnviewedStories && !b.hasUnviewedStories) return -1;
          if (!a.hasUnviewedStories && b.hasUnviewedStories) return 1;
          return b.stories.first.timestamp.compareTo(a.stories.first.timestamp);
        });
        
        return storyUsers;
      });
});

/// Check if current user has viewed this story
bool _isStoryViewed(Map<String, dynamic> data, String? currentUserId) {
  if (currentUserId == null) return false;
  final viewedBy = data['viewedBy'] as List<dynamic>? ?? [];
  return viewedBy.contains(currentUserId);
}

/// Mark a story as viewed
final markStoryViewedProvider = Provider((ref) {
  return MarkStoryViewedUseCase(ref);
});

class MarkStoryViewedUseCase {
  MarkStoryViewedUseCase(this.ref);
  final Ref ref;

  Future<void> call(String storyId) async {
    final currentUserId = ref.read(currentUserIdProvider).value;
    if (currentUserId == null) return;

    await _storiesCollection.doc(storyId).update({
      'viewedBy': FieldValue.arrayUnion([currentUserId]),
      'views': FieldValue.increment(1),
    });
  }
}

/// Create a new story
final createStoryProvider = Provider((ref) {
  return CreateStoryUseCase(ref);
});

class CreateStoryUseCase {
  CreateStoryUseCase(this.ref);
  final Ref ref;

  Future<String> call({
    required String mediaUrl,
    required String mediaType,
    String? text,
  }) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 24));

    final docRef = await _storiesCollection.add({
      'userId': currentUser.uid,
      'username': currentUser.displayName,
      'userAvatar': currentUser.avatar,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'views': 0,
      'viewedBy': [],
    });

    return docRef.id;
  }
}

/// Delete a story
final deleteStoryProvider = Provider((ref) {
  return DeleteStoryUseCase();
});

class DeleteStoryUseCase {
  Future<void> call(String storyId) async {
    await _storiesCollection.doc(storyId).delete();
  }
}

/// Get stories for a specific user
final userStoriesProvider = StreamProvider.family<List<StoryModel>, String>((ref, userId) {
  final currentUserId = ref.watch(currentUserIdProvider).value;
  
  return _storiesCollection
      .where('userId', isEqualTo: userId)
      .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
      .orderBy('expiresAt')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return StoryModel(
            id: doc.id,
            userId: data['userId'] as String,
            username: data['username'] as String? ?? '',
            userAvatar: data['userAvatar'] as String? ?? '',
            mediaUrl: data['mediaUrl'] as String,
            mediaType: data['mediaType'] as String? ?? 'image',
            timestamp: (data['createdAt'] as Timestamp).toDate(),
            expiresAt: (data['expiresAt'] as Timestamp).toDate(),
            views: data['views'] as int? ?? 0,
            isViewed: _isStoryViewed(data, currentUserId),
          );
        }).toList();
      });
});
