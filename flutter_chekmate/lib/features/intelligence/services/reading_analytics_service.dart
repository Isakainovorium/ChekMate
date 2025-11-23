import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/reading_event_model.dart';

/// ReadingAnalyticsService logs user reading interactions to Firestore.
class ReadingAnalyticsService {
  ReadingAnalyticsService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Log a reading event when user interacts with educational content
  Future<void> logReadingEvent({
    required String userId,
    required String contentId,
    required List<String> tags,
    required int timeSpentMs,
    required double completionPercent,
    double sentiment = 0.0,
  }) async {
    try {
      final event = ReadingEventModel(
        id: '', // Will be set by Firestore
        userId: userId,
        contentId: contentId,
        tags: tags,
        timeSpentMs: timeSpentMs,
        completionPercent: completionPercent,
        sentiment: sentiment,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('userReadingEvents')
          .doc(userId)
          .collection('events')
          .add(event.toJson());

      debugPrint(
          'Logged reading event: $contentId for user $userId (${timeSpentMs}ms, $completionPercent% complete)');
    } catch (e) {
      debugPrint('Error logging reading event: $e');
    }
  }

  /// Start tracking a reading session (returns session ID)
  String startReadingSession({
    required String userId,
    required String contentId,
    required List<String> tags,
  }) {
    final sessionId =
        '${userId}_${contentId}_${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('Started reading session: $sessionId');
    return sessionId;
  }

  /// End tracking and log the complete reading event
  Future<void> endReadingSession({
    required String sessionId,
    required String userId,
    required String contentId,
    required List<String> tags,
    required int timeSpentMs,
    required double completionPercent,
    double sentiment = 0.0,
  }) async {
    await logReadingEvent(
      userId: userId,
      contentId: contentId,
      tags: tags,
      timeSpentMs: timeSpentMs,
      completionPercent: completionPercent,
      sentiment: sentiment,
    );
    debugPrint('Ended reading session: $sessionId');
  }

  /// Get recent reading events for a user
  Stream<List<ReadingEventModel>> getUserReadingEvents(String userId,
      {int limit = 50}) {
    return _firestore
        .collection('userReadingEvents')
        .doc(userId)
        .collection('events')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReadingEventModel.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  /// Clear old reading events (for privacy/cleanup)
  Future<void> clearOldEvents(String userId, {int daysToKeep = 90}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final oldEvents = await _firestore
          .collection('userReadingEvents')
          .doc(userId)
          .collection('events')
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (final doc in oldEvents.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint(
          'Cleared ${oldEvents.docs.length} old reading events for user $userId');
    } catch (e) {
      debugPrint('Error clearing old events: $e');
    }
  }
}
