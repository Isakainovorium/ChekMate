import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chekmate/core/providers/providers.dart';
import 'package:flutter_chekmate/features/live/data/datasources/live_stream_remote_datasource.dart';
import 'package:flutter_chekmate/features/live/domain/entities/live_stream_entity.dart';
import 'package:flutter_chekmate/features/live/services/agora_service.dart';
import 'package:uuid/uuid.dart';

/// Live stream data source provider
final liveStreamDataSourceProvider = Provider<LiveStreamRemoteDataSource>((ref) {
  return LiveStreamRemoteDataSourceImpl();
});

/// Live stream service provider (FREE WebRTC + Firebase signaling)
final liveStreamServiceProvider = Provider<LiveStreamService>((ref) {
  return LiveStreamService.instance;
});

/// Active streams provider
final activeStreamsProvider = StreamProvider<List<LiveStreamEntity>>((ref) {
  final dataSource = ref.watch(liveStreamDataSourceProvider);
  return dataSource.getActiveStreams();
});

/// Streams by category provider
final streamsByCategoryProvider = StreamProvider.family<List<LiveStreamEntity>, LiveStreamCategory>((ref, category) {
  final dataSource = ref.watch(liveStreamDataSourceProvider);
  return dataSource.getStreamsByCategory(category);
});

/// Trending streams provider
final trendingStreamsProvider = StreamProvider<List<LiveStreamEntity>>((ref) {
  final dataSource = ref.watch(liveStreamDataSourceProvider);
  return dataSource.getTrendingStreams(limit: 10);
});

/// Single stream provider
final streamProvider = FutureProvider.family<LiveStreamEntity?, String>((ref, streamId) async {
  final dataSource = ref.watch(liveStreamDataSourceProvider);
  return dataSource.getStream(streamId);
});

/// Stream chat provider
final streamChatProvider = StreamProvider.family<List<LiveChatMessage>, String>((ref, streamId) {
  final dataSource = ref.watch(liveStreamDataSourceProvider);
  return dataSource.getStreamChat(streamId);
});

/// Current user's streams provider
final myStreamsProvider = StreamProvider<List<LiveStreamEntity>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider).value;
  if (currentUserId == null) {
    return Stream.value([]);
  }
  final dataSource = ref.watch(liveStreamDataSourceProvider);
  return dataSource.getStreamsByHost(currentUserId);
});

/// Live stream controller provider
final liveStreamControllerProvider = Provider((ref) {
  return LiveStreamController(ref);
});

/// Live stream controller
class LiveStreamController {
  LiveStreamController(this.ref);

  final Ref ref;

  /// Create and start a new live stream
  Future<LiveStreamEntity> goLive({
    required String title,
    required String description,
    required LiveStreamCategory category,
    String? thumbnailUrl,
    List<String> tags = const [],
  }) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw Exception('User must be authenticated to go live');
    }

    final dataSource = ref.read(liveStreamDataSourceProvider);
    final streamService = ref.read(liveStreamServiceProvider);

    // Generate unique channel name
    final channelName = 'chekmate_${const Uuid().v4().substring(0, 8)}';

    // Create stream in Firestore
    final stream = await dataSource.createStream(
      hostId: currentUser.id,
      hostName: currentUser.displayName,
      hostUsername: currentUser.username,
      hostAvatarUrl: currentUser.avatar,
      title: title,
      description: description,
      category: category,
      channelName: channelName,
      thumbnailUrl: thumbnailUrl,
      tags: tags,
      isHostVerified: currentUser.isVerified,
    );

    // Initialize WebRTC and start broadcast (FREE - no paid services)
    await streamService.initialize();
    await streamService.startBroadcast(streamId: stream.id);

    // Mark stream as live
    await dataSource.startStream(stream.id);

    return stream.copyWith(status: LiveStreamStatus.live);
  }

  /// End the current live stream
  Future<void> endStream(String streamId) async {
    final dataSource = ref.read(liveStreamDataSourceProvider);
    final streamService = ref.read(liveStreamServiceProvider);

    // Leave WebRTC stream
    await streamService.leaveStream();

    // Update stream status in Firestore
    await dataSource.endStream(streamId);
  }

  /// Join a stream as viewer
  Future<void> joinStream(String streamId) async {
    final currentUserId = ref.read(currentUserIdProvider).value;
    if (currentUserId == null) {
      throw Exception('User must be authenticated to join stream');
    }

    final dataSource = ref.read(liveStreamDataSourceProvider);
    final streamService = ref.read(liveStreamServiceProvider);

    // Get stream details
    final stream = await dataSource.getStream(streamId);
    if (stream == null) {
      throw Exception('Stream not found');
    }

    if (stream.status != LiveStreamStatus.live) {
      throw Exception('Stream is not live');
    }

    // Initialize WebRTC and join as viewer (FREE - no paid services)
    await streamService.initialize();
    await streamService.joinAsViewer(streamId: streamId);

    // Add viewer to stream
    await dataSource.joinStream(streamId, currentUserId);
  }

  /// Leave a stream as viewer
  Future<void> leaveStream(String streamId) async {
    final currentUserId = ref.read(currentUserIdProvider).value;
    if (currentUserId == null) return;

    final dataSource = ref.read(liveStreamDataSourceProvider);
    final streamService = ref.read(liveStreamServiceProvider);

    // Leave WebRTC stream
    await streamService.leaveStream();

    // Remove viewer from stream
    await dataSource.leaveStream(streamId, currentUserId);
  }

  /// Send a chat message
  Future<void> sendChatMessage({
    required String streamId,
    required String message,
  }) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw Exception('User must be authenticated to send messages');
    }

    final stream = await ref.read(liveStreamDataSourceProvider).getStream(streamId);
    final isHost = stream?.hostId == currentUser.id;

    await ref.read(liveStreamDataSourceProvider).sendChatMessage(
      streamId: streamId,
      userId: currentUser.id,
      userName: currentUser.displayName,
      userAvatarUrl: currentUser.avatar,
      message: message,
      isHost: isHost,
      isVerified: currentUser.isVerified,
    );
  }

  /// Like a stream
  Future<void> likeStream(String streamId) async {
    await ref.read(liveStreamDataSourceProvider).incrementLikeCount(streamId);
  }

  /// Toggle camera
  Future<void> toggleCamera(bool enabled) async {
    await ref.read(liveStreamServiceProvider).toggleVideo(enabled);
  }

  /// Toggle microphone
  Future<void> toggleMicrophone(bool enabled) async {
    await ref.read(liveStreamServiceProvider).toggleAudio(enabled);
  }

  /// Switch camera
  Future<void> switchCamera() async {
    await ref.read(liveStreamServiceProvider).switchCamera();
  }
}

/// Selected category provider
final selectedCategoryProvider = StateProvider<LiveStreamCategory>((ref) {
  return LiveStreamCategory.all;
});

/// Current stream ID provider (for active viewing/broadcasting)
final currentStreamIdProvider = StateProvider<String?>((ref) {
  return null;
});

/// Is broadcasting provider
final isBroadcastingProvider = StateProvider<bool>((ref) {
  return false;
});

/// Is viewing provider
final isViewingProvider = StateProvider<bool>((ref) {
  return false;
});
