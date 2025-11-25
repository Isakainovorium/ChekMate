import 'dart:async';

import '../../../../core/models/safety_report_model.dart';

/// Abstract repository for safety features
/// Focuses on pattern recognition and safety reporting
abstract class SafetyRepository {
  /// Safety Report Operations
  Future<void> createSafetyReport(SafetyReportModel report);
  Future<void> updateSafetyReport(String reportId, SafetyReportStatus newStatus,
      {String? reviewedBy, String? reviewNotes});
  Future<void> deleteSafetyReport(String reportId);

  /// Query Operations
  Future<List<SafetyReportModel>> getPendingSafetyReports({int limit = 100});
  Future<List<SafetyReportModel>> getActiveSafetyReports({
    DateTime? since,
    int? maxResults,
  });
  Future<List<SafetyReportModel>> getSafetyReportsForIndividual(
      String individualId);
  Future<List<SafetyReportModel>> getUserSafetyReports(String userId);
  Future<List<SafetyReportModel>> getSafetyReportsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  );

  /// Bulk Operations
  Future<void> batchUpdateSafetyReports({
    required List<String> reportIds,
    required SafetyReportStatus newStatus,
    String? reviewedBy,
    String? reviewNotes,
  });

  /// Analytics and Statistics
  Future<Map<String, dynamic>> getSafetyStatistics(String userId);
}
