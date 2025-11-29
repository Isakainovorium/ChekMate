import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/live/domain/entities/live_stream_entity.dart';

/// Remote data source for live streams
abstract class LiveStreamRemoteDataSource {
  /// Get all active live streams
  Stream<List<LiveStreamEntity>> getActiveStreams();

  /// Get streams by category
  Stream<List<LiveStreamEntity>> getStreamsByCategory(LiveStreamCategory category);

  /// Get a single stream by ID
  Future<LiveStreamEntity?> getStream(String streamId);

  /// Create a new live stream
  Future<LiveStreamEntity> createStream({
    required String hostId,
    required String hostName,
    required String hostUsername,
    required String hostAvatarUrl,
    required String title,
    required String description,
    required LiveStreamCategory category,
    required String channelName,
    String? thumbnailUrl,
    List<String> tags,
    bool isHostVerified,
  });

  /// Start a stream (set status to live)
  Future<void> startStream(String streamId);

  /// End a stream
  Future<void> endStream(String streamId);

  /// Update viewer count
  Future<void> updateViewerCount(String streamId, int count);

  /// Increment like count
  Future<void> incrementLikeCount(String streamId);

  /// Join stream (add viewer)
  Future<void> joinStream(String streamId, String userId);

  /// Leave stream (remove viewer)
  Future<void> leaveStream(String streamId, String userId);

  /// Get stream chat messages
  Stream<List<LiveChatMessage>> getStreamChat(String streamId);

  /// Send chat message
  Future<void> sendChatMessage({
    required String streamId,
    required String userId,
    required String userName,
    required String userAvatarUrl,
    required String message,
    bool isHost,
    bool isVerified,
  });

  /// Pin a chat message
  Future<void> pinChatMessage(String streamId, String messageId);

  /// Delete a chat message
  Future<void> deleteChatMessage(String streamId, String messageId);

  /// Get trending streams
  Stream<List<LiveStreamEntity>> getTrendingStreams({int limit = 10});

  /// Get streams by host
  Stream<List<LiveStreamEntity>> getStreamsByHost(String hostId);
}

/// Firebase implementation of live stream data source
class LiveStreamRemoteDataSourceImpl implements LiveStreamRemoteDataSource {
  LiveStreamRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _streamsCollection =>
      _firestore.collection('live_streams');

  CollectionReference<Map<String, dynamic>> _chatCollection(String streamId) =>
      _streamsCollection.doc(streamId).collection('chat');

  CollectionReference<Map<String, dynamic>> _viewersCollection(String streamId) =>
      _streamsCollection.doc(streamId).collection('viewers');

  @override
  Stream<List<LiveStreamEntity>> getActiveStreams() {
    return _streamsCollection
        .where('status', isEqualTo: LiveStreamStatus.live.name)
        .orderBy('viewerCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LiveStreamEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<LiveStreamEntity>> getStreamsByCategory(LiveStreamCategory category) {
    if (category == LiveStreamCategory.all) {
      return getActiveStreams();
    }
    return _streamsCollection
        .where('status', isEqualTo: LiveStreamStatus.live.name)
        .where('category', isEqualTo: category.name)
        .orderBy('viewerCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LiveStreamEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<LiveStreamEntity?> getStream(String streamId) async {
    final doc = await _streamsCollection.doc(streamId).get();
    if (!doc.exists) return null;
    return LiveStreamEntity.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<LiveStreamEntity> createStream({
    required String hostId,
    required String hostName,
    required String hostUsername,
    required String hostAvatarUrl,
    required String title,
    required String description,
    required LiveStreamCategory category,
    required String channelName,
    String? thumbnailUrl,
    List<String> tags = const [],
    bool isHostVerified = false,
  }) async {
    final now = DateTime.now();
    final streamData = {
      'hostId': hostId,
      'hostName': hostName,
      'hostUsername': hostUsername,
      'hostAvatarUrl': hostAvatarUrl,
      'title': title,
      'description': description,
      'category': category.name,
      'status': LiveStreamStatus.scheduled.name,
      'channelName': channelName,
      'thumbnailUrl': thumbnailUrl,
      'viewerCount': 0,
      'likeCount': 0,
      'peakViewerCount': 0,
      'createdAt': now.toIso8601String(),
      'startedAt': null,
      'endedAt': null,
      'tags': tags,
      'isHostVerified': isHostVerified,
    };

    final docRef = await _streamsCollection.add(streamData);
    return LiveStreamEntity.fromJson({...streamData, 'id': docRef.id});
  }

  @override
  Future<void> startStream(String streamId) async {
    await _streamsCollection.doc(streamId).update({
      'status': LiveStreamStatus.live.name,
      'startedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> endStream(String streamId) async {
    await _streamsCollection.doc(streamId).update({
      'status': LiveStreamStatus.ended.name,
      'endedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> updateViewerCount(String streamId, int count) async {
    final doc = await _streamsCollection.doc(streamId).get();
    final currentPeak = doc.data()?['peakViewerCount'] as int? ?? 0;

    await _streamsCollection.doc(streamId).update({
      'viewerCount': count,
      if (count > currentPeak) 'peakViewerCount': count,
    });
  }

  @override
  Future<void> incrementLikeCount(String streamId) async {
    await _streamsCollection.doc(streamId).update({
      'likeCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> joinStream(String streamId, String userId) async {
    await _viewersCollection(streamId).doc(userId).set({
      'joinedAt': DateTime.now().toIso8601String(),
    });

    // Update viewer count
    final viewersSnapshot = await _viewersCollection(streamId).get();
    await updateViewerCount(streamId, viewersSnapshot.docs.length);
  }

  @override
  Future<void> leaveStream(String streamId, String userId) async {
    await _viewersCollection(streamId).doc(userId).delete();

    // Update viewer count
    final viewersSnapshot = await _viewersCollection(streamId).get();
    await updateViewerCount(streamId, viewersSnapshot.docs.length);
  }

  @override
  Stream<List<LiveChatMessage>> getStreamChat(String streamId) {
    return _chatCollection(streamId)
        .orderBy('createdAt', descending: false)
        .limitToLast(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LiveChatMessage.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<void> sendChatMessage({
    required String streamId,
    required String userId,
    required String userName,
    required String userAvatarUrl,
    required String message,
    bool isHost = false,
    bool isVerified = false,
  }) async {
    await _chatCollection(streamId).add({
      'streamId': streamId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(),
      'isHost': isHost,
      'isVerified': isVerified,
      'isPinned': false,
    });
  }

  @override
  Future<void> pinChatMessage(String streamId, String messageId) async {
    // Unpin all other messages first
    final pinnedMessages = await _chatCollection(streamId)
        .where('isPinned', isEqualTo: true)
        .get();
    
    for (final doc in pinnedMessages.docs) {
      await doc.reference.update({'isPinned': false});
    }

    // Pin the new message
    await _chatCollection(streamId).doc(messageId).update({'isPinned': true});
  }

  @override
  Future<void> deleteChatMessage(String streamId, String messageId) async {
    await _chatCollection(streamId).doc(messageId).delete();
  }

  @override
  Stream<List<LiveStreamEntity>> getTrendingStreams({int limit = 10}) {
    return _streamsCollection
        .where('status', isEqualTo: LiveStreamStatus.live.name)
        .orderBy('viewerCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LiveStreamEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Stream<List<LiveStreamEntity>> getStreamsByHost(String hostId) {
    return _streamsCollection
        .where('hostId', isEqualTo: hostId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LiveStreamEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
