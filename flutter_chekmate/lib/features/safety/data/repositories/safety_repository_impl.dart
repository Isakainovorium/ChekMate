import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/safety_repository.dart';
import '../../../../core/models/safety_report_model.dart';
import '../datasources/safety_remote_data_source.dart';

/// Repository implementation for safety features
/// Focuses on pattern recognition and safety reporting
class SafetyRepositoryImpl implements SafetyRepository {
  final SafetyRemoteDataSource _remoteDataSource;

  SafetyRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createSafetyReport(SafetyReportModel report) async {
    await _remoteDataSource.createSafetyReport(report);
    debugPrint('Safety report created: ${report.id}');
  }

  @override
  Future<void> updateSafetyReport(String reportId, SafetyReportStatus newStatus,
      {String? reviewedBy, String? reviewNotes}) async {
    await _remoteDataSource.updateSafetyReport(reportId, newStatus,
        reviewedBy: reviewedBy, reviewNotes: reviewNotes);
  }

  @override
  Future<void> deleteSafetyReport(String reportId) async {
    await _remoteDataSource.deleteSafetyReport(reportId);
  }

  @override
  Future<List<SafetyReportModel>> getPendingSafetyReports(
      {int limit = 100}) async {
    return await _remoteDataSource.getPendingSafetyReports(limit: limit);
  }

  @override
  Future<List<SafetyReportModel>> getActiveSafetyReports({
    DateTime? since,
    int? maxResults,
  }) async {
    return await _remoteDataSource.getActiveSafetyReports(
        since: since, maxResults: maxResults);
  }

  @override
  Future<List<SafetyReportModel>> getSafetyReportsForIndividual(
      String individualId) async {
    return await _remoteDataSource.getSafetyReportsForIndividual(individualId);
  }

  @override
  Future<List<SafetyReportModel>> getUserSafetyReports(String userId) async {
    return await _remoteDataSource.getUserSafetyReports(userId);
  }

  @override
  Future<List<SafetyReportModel>> getSafetyReportsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    return await _remoteDataSource.getSafetyReportsNearLocation(
        latitude, longitude, radiusKm);
  }

  @override
  Future<void> batchUpdateSafetyReports({
    required List<String> reportIds,
    required SafetyReportStatus newStatus,
    String? reviewedBy,
    String? reviewNotes,
  }) async {
    await _remoteDataSource.batchUpdateSafetyReports(
      reportIds: reportIds,
      newStatus: newStatus,
      reviewedBy: reviewedBy,
      reviewNotes: reviewNotes,
    );
  }

  @override
  Future<Map<String, dynamic>> getSafetyStatistics(String userId) async {
    return await _remoteDataSource.getSafetyStatistics(userId);
  }

  /// Run pattern recognition analysis
  Future<void> runPatternAnalysis() async {
    final activeReports = await getActiveSafetyReports(maxResults: 1000);
    // Pattern analysis is handled by the PatternRecognitionService
    // This method ensures we have the latest data for analysis
    debugPrint('Fetched ${activeReports.length} reports for pattern analysis');
  }
}
