import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/safety_report_model.dart';

/// Remote data source for safety reporting and pattern analysis
class SafetyRemoteDataSource {
  final FirebaseFirestore _firestore;

  SafetyRemoteDataSource(this._firestore);

  // Collection references
  CollectionReference get _safetyReports =>
      _firestore.collection('safety_reports');

  /// Create safety report
  Future<void> createSafetyReport(SafetyReportModel report) async {
    await _safetyReports.doc(report.id).set({
      ...report.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update safety report status
  Future<void> updateSafetyReport(String reportId, SafetyReportStatus newStatus,
      {String? reviewedBy, String? reviewNotes}) async {
    await _safetyReports.doc(reportId).update({
      'status': newStatus.index,
      'reviewedAt': newStatus != SafetyReportStatus.pending
          ? FieldValue.serverTimestamp()
          : null,
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get pending safety reports for moderation
  Future<List<SafetyReportModel>> getPendingSafetyReports(
      {int limit = 100}) async {
    final snapshot = await _safetyReports
        .where('status', isEqualTo: SafetyReportStatus.pending.index)
        .orderBy('timestamp', descending: false) // Oldest first for moderation
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) =>
            SafetyReportModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get active safety reports for pattern recognition
  Future<List<SafetyReportModel>> getActiveSafetyReports({
    DateTime? since,
    int? maxResults,
  }) async {
    Query query = _safetyReports
        .where('status', isEqualTo: SafetyReportStatus.active.index)
        .orderBy('timestamp', descending: true);

    if (since != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(since));
    }

    if (maxResults != null) {
      query = query.limit(maxResults);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) =>
            SafetyReportModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get safety reports for specific individual
  Future<List<SafetyReportModel>> getSafetyReportsForIndividual(
      String individualId) async {
    final snapshot = await _safetyReports
        .where('individualId', isEqualTo: individualId)
        .where('status', isEqualTo: SafetyReportStatus.active.index)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            SafetyReportModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get safety reports made by user
  Future<List<SafetyReportModel>> getUserSafetyReports(String userId) async {
    final snapshot = await _safetyReports
        .where('reporterId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            SafetyReportModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Search safety reports by location proximity
  Future<List<SafetyReportModel>> getSafetyReportsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    // Note: Firestore doesn't support geo queries natively
    // This would require geohashing or custom implementation
    // For now, return recent reports and filter client-side
    final recentReports = await getActiveSafetyReports(
      since: DateTime.now().subtract(const Duration(days: 90)),
      maxResults: 1000,
    );

    // Client-side filtering by distance
    return recentReports.where((report) {
      if (report.location == null) return false;

      final distance = _calculateDistance(
        latitude,
        longitude,
        report.location!.latitude,
        report.location!.longitude,
      );

      return distance <= radiusKm * 1000; // Convert km to meters
    }).toList();
  }

  /// Delete safety report (for GDPR compliance)
  Future<void> deleteSafetyReport(String reportId) async {
    await _safetyReports.doc(reportId).delete();
  }

  /// Batch update multiple safety reports (for admin moderation)
  Future<void> batchUpdateSafetyReports({
    required List<String> reportIds,
    required SafetyReportStatus newStatus,
    String? reviewedBy,
    String? reviewNotes,
  }) async {
    final batch = _firestore.batch();

    for (final reportId in reportIds) {
      final docRef = _safetyReports.doc(reportId);
      batch.update(docRef, {
        'status': newStatus.index,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': reviewedBy,
        'reviewNotes': reviewNotes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Get safety statistics for user (how many reports they've filed, etc.)
  Future<Map<String, dynamic>> getSafetyStatistics(String userId) async {
    final reports = await getUserSafetyReports(userId);

    return {
      'totalReports': reports.length,
      'pendingReports': reports.where((r) => r.isPending).length,
      'activeReports': reports.where((r) => r.isActive).length,
      'lastReport': reports.isNotEmpty ? reports.first.timestamp : null,
    };
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}
