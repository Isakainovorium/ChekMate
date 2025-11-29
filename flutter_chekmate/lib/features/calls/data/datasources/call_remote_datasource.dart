import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/calls/domain/entities/call_entity.dart';

/// Remote data source for calls
abstract class CallRemoteDataSource {
  /// Create a new call
  Future<CallEntity> createCall({
    required String callerId,
    required String callerName,
    required String callerAvatarUrl,
    required String receiverId,
    required String receiverName,
    required String receiverAvatarUrl,
    required CallType type,
    required String channelId,
  });

  /// Get a call by ID
  Future<CallEntity?> getCall(String callId);

  /// Listen to call updates
  Stream<CallEntity?> watchCall(String callId);

  /// Listen for incoming calls for a user
  Stream<CallEntity?> watchIncomingCalls(String userId);

  /// Answer a call
  Future<void> answerCall(String callId);

  /// Decline a call
  Future<void> declineCall(String callId);

  /// End a call
  Future<void> endCall(String callId);

  /// Update call status
  Future<void> updateCallStatus(String callId, CallStatus status);

  /// Update mute status
  Future<void> updateMuteStatus(String callId, String oderId, bool isMuted);

  /// Update video status
  Future<void> updateVideoStatus(String callId, String userId, bool isVideoOff);

  /// Get call history for a user
  Stream<List<CallEntity>> getCallHistory(String oderId, {int limit = 50});

  /// Delete old calls (cleanup)
  Future<void> cleanupOldCalls({Duration olderThan = const Duration(days: 30)});
}

/// Firebase implementation of call data source
class CallRemoteDataSourceImpl implements CallRemoteDataSource {
  CallRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _callsCollection =>
      _firestore.collection('calls');

  @override
  Future<CallEntity> createCall({
    required String callerId,
    required String callerName,
    required String callerAvatarUrl,
    required String receiverId,
    required String receiverName,
    required String receiverAvatarUrl,
    required CallType type,
    required String channelId,
  }) async {
    final now = DateTime.now();
    final callData = {
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatarUrl': callerAvatarUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatarUrl': receiverAvatarUrl,
      'type': type.name,
      'status': CallStatus.ringing.name,
      'channelId': channelId,
      'createdAt': now.toIso8601String(),
      'answeredAt': null,
      'endedAt': null,
      'callerIsMuted': false,
      'callerVideoOff': false,
      'receiverIsMuted': false,
      'receiverVideoOff': false,
    };

    final docRef = await _callsCollection.add(callData);
    return CallEntity.fromJson({...callData, 'id': docRef.id});
  }

  @override
  Future<CallEntity?> getCall(String callId) async {
    final doc = await _callsCollection.doc(callId).get();
    if (!doc.exists) return null;
    return CallEntity.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Stream<CallEntity?> watchCall(String callId) {
    return _callsCollection.doc(callId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CallEntity.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  @override
  Stream<CallEntity?> watchIncomingCalls(String userId) {
    return _callsCollection
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: CallStatus.ringing.name)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return CallEntity.fromJson({...doc.data(), 'id': doc.id});
    });
  }

  @override
  Future<void> answerCall(String callId) async {
    await _callsCollection.doc(callId).update({
      'status': CallStatus.ongoing.name,
      'answeredAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> declineCall(String callId) async {
    await _callsCollection.doc(callId).update({
      'status': CallStatus.declined.name,
      'endedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> endCall(String callId) async {
    await _callsCollection.doc(callId).update({
      'status': CallStatus.ended.name,
      'endedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> updateCallStatus(String callId, CallStatus status) async {
    final updates = <String, dynamic>{
      'status': status.name,
    };

    if (status == CallStatus.ended ||
        status == CallStatus.declined ||
        status == CallStatus.missed) {
      updates['endedAt'] = DateTime.now().toIso8601String();
    }

    await _callsCollection.doc(callId).update(updates);
  }

  @override
  Future<void> updateMuteStatus(String callId, String userId, bool isMuted) async {
    final call = await getCall(callId);
    if (call == null) return;

    final field = call.callerId == userId ? 'callerIsMuted' : 'receiverIsMuted';
    await _callsCollection.doc(callId).update({field: isMuted});
  }

  @override
  Future<void> updateVideoStatus(String callId, String userId, bool isVideoOff) async {
    final call = await getCall(callId);
    if (call == null) return;

    final field = call.callerId == userId ? 'callerVideoOff' : 'receiverVideoOff';
    await _callsCollection.doc(callId).update({field: isVideoOff});
  }

  @override
  Stream<List<CallEntity>> getCallHistory(String userId, {int limit = 50}) {
    // Get calls where user is either caller or receiver
    return _callsCollection
        .where(Filter.or(
          Filter('callerId', isEqualTo: userId),
          Filter('receiverId', isEqualTo: userId),
        ))
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CallEntity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<void> cleanupOldCalls({Duration olderThan = const Duration(days: 30)}) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final oldCalls = await _callsCollection
        .where('createdAt', isLessThan: cutoff.toIso8601String())
        .get();

    final batch = _firestore.batch();
    for (final doc in oldCalls.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
