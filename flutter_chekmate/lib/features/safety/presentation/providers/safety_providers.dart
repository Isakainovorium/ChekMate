import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/pattern_recognition_service.dart';
import '../../../../core/models/safety_report_model.dart';
import '../../data/datasources/safety_remote_data_source.dart';
import '../../data/repositories/safety_repository_impl.dart';
import '../../domain/repositories/safety_repository.dart';

/// ===== DATA LAYER PROVIDERS =====

/// Firestore instance provider
final firestoreSafetyProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Safety remote data source provider
final safetyRemoteDataSourceProvider = Provider<SafetyRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreSafetyProvider);
  return SafetyRemoteDataSource(firestore);
});

/// Safety repository provider
final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  final dataSource = ref.watch(safetyRemoteDataSourceProvider);
  return SafetyRepositoryImpl(dataSource);
});

/// ===== SERVICE LAYER PROVIDERS =====

/// Pattern Recognition Service provider
final patternRecognitionServiceProvider =
    Provider<PatternRecognitionService>((ref) {
  return PatternRecognitionService.instance;
});

/// ===== BUSINESS LOGIC PROVIDERS =====

/// Safety reports for moderation (admin feature)
final pendingSafetyReportsProvider =
    FutureProvider<List<SafetyReportModel>>((ref) {
  final repository = ref.watch(safetyRepositoryProvider);
  return repository.getPendingSafetyReports();
});

/// Active safety reports for pattern recognition
final activeSafetyReportsProvider =
    FutureProvider<List<SafetyReportModel>>((ref) {
  final repository = ref.watch(safetyRepositoryProvider);
  return repository.getActiveSafetyReports(maxResults: 1000);
});

/// Risk assessment stream that continuously analyzes patterns
final riskAssessmentProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final patternService = ref.watch(patternRecognitionServiceProvider);
  return patternService.riskAssessmentStream;
});

/// Pattern analysis results for specific individuals
final patternAnalysisProvider =
    FutureProvider.family<List<PatternResult>, String>(
  (ref, individualId) async {
    final repository = ref.watch(safetyRepositoryProvider);
    final reports =
        await repository.getSafetyReportsForIndividual(individualId);

    if (reports.isEmpty) return [];

    final patternService = ref.watch(patternRecognitionServiceProvider);
    final concerningPatterns = await patternService.analyzeIndividualPatterns(
      individualId,
      reports,
    );

    // Convert ConcerningPattern to PatternResult for UI presentation
    return concerningPatterns
        .map((pattern) => PatternResult(
              patternType: convertPatternType(pattern.patternType),
              confidenceScore: pattern.confidenceScore,
              description: pattern.description,
              evidence: pattern.relatedReports,
            ))
        .toList();
  },
);

/// Safety statistics for community overview
final safetyStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(safetyRepositoryProvider);
  final patternService = ref.watch(patternRecognitionServiceProvider);

  final activeReports =
      await repository.getActiveSafetyReports(maxResults: 1000);
  final communityRiskScore = await patternService.calculateCommunityRiskScore();

  return {
    'totalActiveReports': activeReports.length,
    'communityRiskScore': communityRiskScore,
    'reportsLastWeek': activeReports
        .where((r) => r.timestamp
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .length,
    'highRiskIndividuals':
        activeReports.where((r) => r.severityScore >= 4).length,
  };
});

/// Safety report creation provider
final createSafetyReportProvider =
    FutureProvider.family<void, SafetyReportModel>(
  (ref, report) async {
    final repository = ref.watch(safetyRepositoryProvider);
    final patternService = ref.watch(patternRecognitionServiceProvider);

    await repository.createSafetyReport(report);
    await patternService.addSafetyReport(report);

    // Invalidate relevant providers to refresh data
    ref.invalidate(pendingSafetyReportsProvider);
    ref.invalidate(activeSafetyReportsProvider);
    ref.invalidate(safetyStatisticsProvider);
  },
);

/// Batch moderation provider for updating multiple reports
final batchUpdateSafetyReportsProvider =
    FutureProvider.family<void, BatchUpdateParams>(
  (ref, params) async {
    final repository = ref.watch(safetyRepositoryProvider);
    await repository.batchUpdateSafetyReports(
      reportIds: params.reportIds,
      newStatus: params.newStatus,
      reviewedBy: params.reviewerId,
      reviewNotes: params.reviewNotes,
    );

    // Refresh moderation queue
    ref.invalidate(pendingSafetyReportsProvider);
  },
);

/// Pattern analysis background processor
final patternBackgroundAnalysisProvider = StreamProvider<void>((ref) {
  final repository = ref.watch(safetyRepositoryProvider);
  final patternService = ref.watch(patternRecognitionServiceProvider);

  return Stream.periodic(const Duration(minutes: 30), (_) async {
    // Run background pattern analysis
    final activeReports = await repository.getActiveSafetyReports(
      since: DateTime.now().subtract(const Duration(days: 7)),
      maxResults: 500,
    );

    await patternService.runBackgroundAnalysis(activeReports);
  }).map((_) {});
});

/// Safety report validation before submission
final validateSafetyReportProvider =
    FutureProvider.family<SafetyValidationResult, SafetyReportModel>(
  (ref, report) async {
    final patternService = ref.watch(patternRecognitionServiceProvider);
    return await patternService.validateSafetyReport(report);
  },
);

/// ******* DATA CLASSES *******

class BatchUpdateParams {
  final List<String> reportIds;
  final SafetyReportStatus newStatus;
  final String? reviewerId;
  final String? reviewNotes;

  const BatchUpdateParams({
    required this.reportIds,
    required this.newStatus,
    this.reviewerId,
    this.reviewNotes,
  });
}

class PatternResult {
  final PatternType patternType;
  final double confidenceScore;
  final String description;
  final List<String> evidence;

  const PatternResult({
    required this.patternType,
    required this.confidenceScore,
    required this.description,
    required this.evidence,
  });
}

/// Pattern types for analysis results
enum PatternType {
  recurringReporter,
  geographicCluster,
  temporalPattern,
  escalatingSeverity,
  socialNetworkPattern,
}

/// Convert from core PatternType to presentation PatternType
PatternType convertPatternType(dynamic corePatternType) {
  // Map core pattern types to presentation pattern types
  if (corePatternType.toString() == 'PatternType.multipleReporters') {
    return PatternType.recurringReporter;
  } else if (corePatternType.toString() == 'PatternType.geographicClustering') {
    return PatternType.geographicCluster;
  } else if (corePatternType.toString() == 'PatternType.temporalPatterns') {
    return PatternType.temporalPattern;
  } else if (corePatternType.toString() == 'PatternType.escalationPattern') {
    return PatternType.escalatingSeverity;
  }

  return PatternType.recurringReporter; // Default fallback
}

/// Extensions for easy access to safety providers
extension SafetyProviderExtensions on WidgetRef {
  /// Quick access to safety repository
  SafetyRepository get safetyRepo => read(safetyRepositoryProvider);

  /// Quick access to pattern recognition service
  PatternRecognitionService get patternService =>
      read(patternRecognitionServiceProvider);
}
