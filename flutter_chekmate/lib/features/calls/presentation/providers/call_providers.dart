import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chekmate/core/providers/providers.dart';
import 'package:flutter_chekmate/features/calls/data/datasources/call_remote_datasource.dart';
import 'package:flutter_chekmate/features/calls/domain/entities/call_entity.dart';
import 'package:flutter_chekmate/features/calls/services/call_service.dart';
import 'package:uuid/uuid.dart';

/// Call data source provider
final callDataSourceProvider = Provider<CallRemoteDataSource>((ref) {
  return CallRemoteDataSourceImpl();
});

/// Call service provider (FREE WebRTC + Firebase signaling)
final callServiceProvider = Provider<CallService>((ref) {
  return CallService.instance;
});

/// Current call provider
final currentCallProvider = StreamProvider<CallEntity?>((ref) {
  final callId = ref.watch(activeCallIdProvider);
  if (callId == null) return Stream.value(null);
  
  final dataSource = ref.watch(callDataSourceProvider);
  return dataSource.watchCall(callId);
});

/// Incoming call provider - watches for incoming calls
final incomingCallProvider = StreamProvider<CallEntity?>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider).value;
  if (currentUserId == null) return Stream.value(null);
  
  final dataSource = ref.watch(callDataSourceProvider);
  return dataSource.watchIncomingCalls(currentUserId);
});

/// Call history provider
final callHistoryProvider = StreamProvider<List<CallEntity>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider).value;
  if (currentUserId == null) return Stream.value([]);
  
  final dataSource = ref.watch(callDataSourceProvider);
  return dataSource.getCallHistory(currentUserId);
});

/// Active call ID provider
final activeCallIdProvider = StateProvider<String?>((ref) => null);

/// Is in call provider
final isInCallProvider = StateProvider<bool>((ref) => false);

/// Call controller provider
final callControllerProvider = Provider((ref) {
  return CallController(ref);
});

/// Call controller
class CallController {
  CallController(this.ref);

  final Ref ref;

  /// Start a voice call
  Future<CallEntity> startVoiceCall({
    required String receiverId,
    required String receiverName,
    required String receiverAvatarUrl,
  }) async {
    return _startCall(
      receiverId: receiverId,
      receiverName: receiverName,
      receiverAvatarUrl: receiverAvatarUrl,
      type: CallType.voice,
    );
  }

  /// Start a video call
  Future<CallEntity> startVideoCall({
    required String receiverId,
    required String receiverName,
    required String receiverAvatarUrl,
  }) async {
    return _startCall(
      receiverId: receiverId,
      receiverName: receiverName,
      receiverAvatarUrl: receiverAvatarUrl,
      type: CallType.video,
    );
  }

  Future<CallEntity> _startCall({
    required String receiverId,
    required String receiverName,
    required String receiverAvatarUrl,
    required CallType type,
  }) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw Exception('User must be authenticated to make calls');
    }

    final dataSource = ref.read(callDataSourceProvider);
    final callService = ref.read(callServiceProvider);

    // Generate unique channel ID
    final channelId = 'call_${const Uuid().v4().substring(0, 8)}';

    // Create call in Firestore
    final call = await dataSource.createCall(
      callerId: currentUser.id,
      callerName: currentUser.displayName,
      callerAvatarUrl: currentUser.avatar,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverAvatarUrl: receiverAvatarUrl,
      type: type,
      channelId: channelId,
    );

    // Set active call
    ref.read(activeCallIdProvider.notifier).state = call.id;
    ref.read(isInCallProvider.notifier).state = true;

    // Initialize WebRTC and start call
    await callService.initialize(video: type == CallType.video);
    await callService.startCall(callId: call.id, isVideo: type == CallType.video);

    return call;
  }

  /// Answer an incoming call
  Future<void> answerCall(String callId) async {
    final dataSource = ref.read(callDataSourceProvider);
    final callService = ref.read(callServiceProvider);

    // Get call details
    final call = await dataSource.getCall(callId);
    if (call == null) {
      throw Exception('Call not found');
    }

    // Update call status
    await dataSource.answerCall(callId);

    // Set active call
    ref.read(activeCallIdProvider.notifier).state = callId;
    ref.read(isInCallProvider.notifier).state = true;

    // Initialize WebRTC and answer call
    await callService.initialize(video: call.isVideoCall);
    await callService.answerCall(callId: callId, isVideo: call.isVideoCall);
  }

  /// Decline an incoming call
  Future<void> declineCall(String callId) async {
    final dataSource = ref.read(callDataSourceProvider);
    await dataSource.declineCall(callId);
  }

  /// End the current call
  Future<void> endCall() async {
    final callId = ref.read(activeCallIdProvider);
    if (callId == null) return;

    final dataSource = ref.read(callDataSourceProvider);
    final callService = ref.read(callServiceProvider);

    // End WebRTC call
    await callService.endCall();

    // Update call status in Firestore
    await dataSource.endCall(callId);

    // Clear active call
    ref.read(activeCallIdProvider.notifier).state = null;
    ref.read(isInCallProvider.notifier).state = false;
  }

  /// Toggle mute
  void toggleMute(bool muted) {
    final callService = ref.read(callServiceProvider);
    callService.toggleMute(muted);

    // Update in Firestore
    final callId = ref.read(activeCallIdProvider);
    final currentUserId = ref.read(currentUserIdProvider).value;
    if (callId != null && currentUserId != null) {
      ref.read(callDataSourceProvider).updateMuteStatus(callId, currentUserId, muted);
    }
  }

  /// Toggle video
  void toggleVideo(bool videoOff) {
    final callService = ref.read(callServiceProvider);
    callService.toggleVideo(videoOff);

    // Update in Firestore
    final callId = ref.read(activeCallIdProvider);
    final currentUserId = ref.read(currentUserIdProvider).value;
    if (callId != null && currentUserId != null) {
      ref.read(callDataSourceProvider).updateVideoStatus(callId, currentUserId, videoOff);
    }
  }

  /// Switch camera
  Future<void> switchCamera() async {
    final callService = ref.read(callServiceProvider);
    await callService.switchCamera();
  }

  /// Toggle speaker
  Future<void> toggleSpeaker(bool speakerOn) async {
    final callService = ref.read(callServiceProvider);
    await callService.toggleSpeaker(speakerOn);
  }
}
