import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/safety_report_model.dart';

/// Pattern Recognition Service for Safety Features
/// Analyzes user reports and behavior patterns to identify safety risks
class PatternRecognitionService {
  static PatternRecognitionService? _instance;
  static PatternRecognitionService get instance =>
      _instance ??= PatternRecognitionService._();

  PatternRecognitionService._();

  // In-memory storage for pattern analysis (would be moved to database)
  final Map<String, List<SafetyReportModel>> _userReports = {};
  final Map<String, List<SafetyReportModel>> _individualReports = {};
  final _riskAssessmentController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Risk scoring thresholds
  static const double lowRiskThreshold = 2.0;
  static const double mediumRiskThreshold = 5.0;
  static const double highRiskThreshold = 8.0;

  // Pattern analysis settings
  static const int minReportsForPattern = 3;
  static const Duration patternAnalysisWindow = Duration(days: 90);

  Stream<Map<String, dynamic>> get riskAssessmentStream =>
      _riskAssessmentController.stream;

  /// Analyze patterns across all safety reports
  Future<void> analyzePatterns() async {
    debugPrint('Starting safety pattern analysis...');

    try {
      // Calculate risk scores for individuals
      final individualRiskScores = await _calculateIndividualRiskScores();

      // Identify concerning patterns
      final concerningPatterns = _identifyConcerningPatterns();

      // Update pattern indicators
      await _updatePatternIndicators(individualRiskScores, concerningPatterns);
      _emitRiskAssessmentSnapshot(
        riskScores: individualRiskScores,
        patterns: concerningPatterns,
      );

      debugPrint(
          'Pattern analysis completed. Found ${individualRiskScores.length} risk profiles.');
    } catch (e) {
      debugPrint('Error during pattern analysis: $e');
    }
  }

  /// Calculate risk scores for individuals based on reports
  Future<Map<String, double>> _calculateIndividualRiskScores() async {
    final riskScores = <String, double>{};

    for (final entry in _individualReports.entries) {
      final individualId = entry.key;
      final reports = entry.value;

      if (reports.length < minReportsForPattern) continue;

      // Filter reports within analysis window
      final recentReports = _filterRecentReports(reports);
      if (recentReports.isEmpty) continue;

      // Calculate risk score based on various factors
      double riskScore = 0.0;

      // 1. Report frequency (recency weighted)
      riskScore += _calculateFrequencyScore(recentReports);

      // 2. Report severity
      riskScore += _calculateSeverityScore(recentReports);

      // 3. Reporter consensus (multiple reporters saying similar things)
      riskScore += _calculateConsensusScore(recentReports);

      // 4. Geographic patterns (reports from same areas)
      riskScore += _calculateGeographicScore(recentReports);

      // 5. Time-based patterns (reports at similar times/dates)
      riskScore += _calculateTemporalScore(recentReports);

      riskScores[individualId] = riskScore.clamp(0.0, 10.0);
    }

    return riskScores;
  }

  /// Identify concerning behavior patterns
  List<ConcerningPattern> _identifyConcerningPatterns() {
    final patterns = <ConcerningPattern>[];

    // Pattern 1: Individuals reported by multiple different users
    patterns.addAll(_findMultipleReporterPatterns());

    // Pattern 2: Geographic clustering of reports
    patterns.addAll(_findGeographicClusteringPatterns());

    // Pattern 3: Temporal patterns (same times/dates)
    patterns.addAll(_findTemporalPatterns());

    // Pattern 4: Escalating behavior patterns
    patterns.addAll(_findEscalationPatterns());

    return patterns;
  }

  // ===== RISK SCORE CALCULATIONS =====

  /// Calculate risk score based on report frequency
  double _calculateFrequencyScore(List<SafetyReportModel> reports) {
    final now = DateTime.now();
    double score = 0.0;

    for (final report in reports) {
      final daysSinceReport = now.difference(report.timestamp).inDays;
      // More recent reports have higher weight (exponential decay)
      final weight = daysSinceReport <= 30
          ? 1.0 / (1 + daysSinceReport * 0.1)
          : daysSinceReport <= 90
              ? 0.5 / (1 + (daysSinceReport - 30) * 0.05)
              : 0.1;

      score += weight * report.severityScore;
    }

    // Scale to 0-3 range
    return (score / reports.length).clamp(0.0, 3.0);
  }

  /// Calculate risk score based on report severity
  double _calculateSeverityScore(List<SafetyReportModel> reports) {
    final averageSeverity =
        reports.map((r) => r.severityScore).reduce((a, b) => a + b) /
            reports.length;
    // Scale to 0-2 range
    return (averageSeverity / 5.0) * 2.0; // Assuming severity is 1-5 scale
  }

  /// Calculate consensus score (agreement between reporters)
  double _calculateConsensusScore(List<SafetyReportModel> reports) {
    final uniqueReporters = reports.map((r) => r.reporterId).toSet().length;
    final reporterConsensus =
        reports.length / uniqueReporters; // Reports per unique reporter

    // Higher consensus = more agreement between reporters
    return reporterConsensus > 1 ? 1.0 : (reporterConsensus - 1) * 0.5 + 1.0;
  }

  /// Calculate geographic clustering score
  double _calculateGeographicScore(List<SafetyReportModel> reports) {
    // Check if reports cluster in specific geographic areas
    final reportsWithLocation =
        reports.where((r) => r.location != null).toList();

    if (reportsWithLocation.length < 2) return 0.0;

    // Simple clustering: if reports are within 1km of each other
    const double clusteringThreshold = 1000; // meters

    int clusters = 0;
    final usedReports = <SafetyReportModel>[];

    for (final report in reportsWithLocation) {
      if (usedReports.contains(report)) continue;

      final cluster = _findReportsWithinDistance(
          report, reportsWithLocation, clusteringThreshold);
      if (cluster.length >= 2) {
        clusters++;
        usedReports.addAll(cluster);
      }
    }

    return clusters > 0 ? clusters.clamp(0.0, 2.0).toDouble() : 0.0;
  }

  /// Calculate temporal pattern score
  double _calculateTemporalScore(List<SafetyReportModel> reports) {
    // Check for patterns in reporting times/dates
    double score = 0.0;

    // Pattern 1: Reports at similar times of day
    score += _detectTimeOfDayPatterns(reports);

    // Pattern 2: Reports on similar days of week
    score += _detectDayOfWeekPatterns(reports);

    return score.clamp(0.0, 1.0);
  }

  // ===== PATTERN DETECTION =====

  /// Find individuals reported by multiple users
  List<ConcerningPattern> _findMultipleReporterPatterns() {
    final patterns = <ConcerningPattern>[];

    for (final entry in _individualReports.entries) {
      final individualId = entry.key;
      final reports = entry.value;

      final uniqueReporters = reports.map((r) => r.reporterId).toSet();
      if (uniqueReporters.length >= 2) {
        patterns.add(
          ConcerningPattern(
            patternId: 'multiple_reporters_$individualId',
            patternType: PatternType.multipleReporters,
            individualId: individualId,
            confidenceScore:
                (uniqueReporters.length / reports.length).clamp(0.0, 1.0),
            severityLevel:
                uniqueReporters.length >= 3 ? RiskLevel.high : RiskLevel.medium,
            description:
                '${uniqueReporters.length} different users have reported concerns about this individual',
            relatedReports: reports.map((r) => r.id).toList(),
          ),
        );
      }
    }

    return patterns;
  }

  /// Find geographic clustering of reports
  List<ConcerningPattern> _findGeographicClusteringPatterns() {
    final patterns = <ConcerningPattern>[];

    for (final entry in _individualReports.entries) {
      final individualId = entry.key;
      final reportsWithLocation =
          entry.value.where((r) => r.location != null).toList();

      if (reportsWithLocation.length < minReportsForPattern) continue;

      // Find clusters within 1km radius
      final clusters = _clusterGeographicReports(reportsWithLocation, 1000);

      for (final cluster in clusters) {
        if (cluster.length >= minReportsForPattern) {
          patterns.add(
            ConcerningPattern(
              patternId: 'geographic_cluster_${individualId}_${cluster.length}',
              patternType: PatternType.geographicClustering,
              individualId: individualId,
              confidenceScore: cluster.length / reportsWithLocation.length,
              severityLevel:
                  cluster.length >= 5 ? RiskLevel.high : RiskLevel.medium,
              description:
                  '${cluster.length} reports clustered within 1km area',
              relatedReports: cluster.map((r) => r.id).toList(),
            ),
          );
        }
      }
    }

    return patterns;
  }

  /// Find temporal patterns
  List<ConcerningPattern> _findTemporalPatterns() {
    final patterns = <ConcerningPattern>[];

    for (final entry in _individualReports.entries) {
      final individualId = entry.key;
      final reports = entry.value;

      // Check time-of-day patterns
      final timePattern = _detectTimeOfDayPatterns(reports);
      if (timePattern > 0.7) {
        // High confidence
        patterns.add(
          ConcerningPattern(
            patternId: 'temporal_pattern_$individualId',
            patternType: PatternType.temporalPatterns,
            individualId: individualId,
            confidenceScore: timePattern,
            severityLevel: RiskLevel.medium,
            description: 'Reports show consistent time-of-day patterns',
            relatedReports: reports.map((r) => r.id).toList(),
          ),
        );
      }
    }

    return patterns;
  }

  /// Find escalation patterns (increasing severity over time)
  List<ConcerningPattern> _findEscalationPatterns() {
    final patterns = <ConcerningPattern>[];

    for (final entry in _individualReports.entries) {
      final individualId = entry.key;
      final reports = entry.value.where((r) => r.incidentDate != null).toList();

      if (reports.length < minReportsForPattern) continue;

      // Sort by date and check for severity escalation
      reports.sort((a, b) => (a.incidentDate ?? a.timestamp)
          .compareTo(b.incidentDate ?? b.timestamp));

      final severityTrend = _calculateSeverityTrend(reports);

      if (severityTrend > 0.6) {
        // Escalating pattern
        patterns.add(
          ConcerningPattern(
            patternId: 'escalation_pattern_$individualId',
            patternType: PatternType.escalationPattern,
            individualId: individualId,
            confidenceScore: severityTrend,
            severityLevel: RiskLevel.high,
            description:
                'Reported behavior is escalating in severity over time',
            relatedReports: reports.map((r) => r.id).toList(),
          ),
        );
      }
    }

    return patterns;
  }

  // ===== HELPER METHODS =====

  /// Filter reports within recent time window
  List<SafetyReportModel> _filterRecentReports(
      List<SafetyReportModel> reports) {
    final cutoff = DateTime.now().subtract(patternAnalysisWindow);
    return reports.where((r) => r.timestamp.isAfter(cutoff)).toList();
  }

  /// Find reports within distance of a given report
  List<SafetyReportModel> _findReportsWithinDistance(
    SafetyReportModel center,
    List<SafetyReportModel> allReports,
    double distanceMeters,
  ) {
    if (center.location == null) return [];

    return allReports.where((report) {
      if (report.location == null) return false;

      final distance = _calculateDistance(
        center.location!.latitude,
        center.location!.longitude,
        report.location!.latitude,
        report.location!.longitude,
      );

      return distance <= distanceMeters;
    }).toList();
  }

  /// Calculate distance between two coordinates (simplified Haversine)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Cluster geographic reports
  List<List<SafetyReportModel>> _clusterGeographicReports(
    List<SafetyReportModel> reports,
    double maxDistance,
  ) {
    final clusters = <List<SafetyReportModel>>[];
    final used = <SafetyReportModel>{};

    for (final report in reports) {
      if (used.contains(report)) continue;

      final cluster = _findReportsWithinDistance(report, reports, maxDistance);
      if (cluster.isNotEmpty) {
        clusters.add(cluster);
        used.addAll(cluster);
      }
    }

    return clusters;
  }

  /// Detect time-of-day patterns
  double _detectTimeOfDayPatterns(List<SafetyReportModel> reports) {
    final times = reports.map((r) => r.timestamp.hour).toList();

    if (times.length < minReportsForPattern) return 0.0;

    // Check if most reports occur within 2-hour window
    final avgHour = times.reduce((a, b) => a + b) / times.length;

    int inRange = 0;
    const int range = 2; // 2-hour window

    for (final hour in times) {
      final normalizedHour = hour < avgHour - range ? hour + 24 : hour;
      if (normalizedHour >= avgHour - range &&
          normalizedHour <= avgHour + range) {
        inRange++;
      }
    }

    return inRange / times.length;
  }

  /// Detect day-of-week patterns
  double _detectDayOfWeekPatterns(List<SafetyReportModel> reports) {
    final days = reports.map((r) => r.timestamp.weekday).toList();

    if (days.length < minReportsForPattern) return 0.0;

    // Check concentration on specific days
    final dayCounts = <int, int>{};
    for (final day in days) {
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    final maxCount = dayCounts.values.reduce((a, b) => a > b ? a : b);
    return maxCount / days.length;
  }

  /// Calculate severity trend over time
  double _calculateSeverityTrend(List<SafetyReportModel> reports) {
    if (reports.length < minReportsForPattern) return 0.0;

    // Calculate slope of severity over time
    final severities = reports.map((r) => r.severityScore.toDouble()).toList();
    final times = List.generate(reports.length, (i) => i.toDouble());

    // Simple linear regression slope
    final n = reports.length;
    final sumX = times.reduce((a, b) => a + b);
    final sumY = severities.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => times[i] * severities[i])
        .reduce((a, b) => a + b);
    final sumXX = times.map((x) => x * x).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);

    // Positive slope = increasing severity, negative = decreasing
    return slope > 0 ? slope.clamp(0.0, 1.0) : 0.0;
  }

  /// Update pattern indicators in database
  Future<void> _updatePatternIndicators(
    Map<String, double> riskScores,
    List<ConcerningPattern> patterns,
  ) async {
    debugPrint('Updating pattern indicators...');

    // Implementation would save to database
    // For now, just log the results
    for (final entry in riskScores.entries) {
      final riskLevel = _getRiskLevel(entry.toARGB32());
      debugPrint(
          '${entry.key}: ${entry.value.toStringAsFixed(2)} (${riskLevel.name})');
    }

    for (final pattern in patterns) {
      debugPrint(
          'Pattern: ${pattern.patternType.name} - ${pattern.description}');
    }
  }

  // ===== PUBLIC API =====

  /// Add a safety report for analysis
  Future<void> addSafetyReport(SafetyReportModel report) async {
    _ingestReport(report);

    debugPrint(
        'Added safety report: ${report.id} for individual: ${report.individualId}');

    // Trigger analysis if enough reports accumulated
    if (_individualReports[report.individualId]?.length ==
        minReportsForPattern) {
      await analyzePatterns();
    }
  }

  /// Analyze patterns for a specific individual, ensuring cached reports exist
  Future<List<ConcerningPattern>> analyzeIndividualPatterns(
    String individualId,
    List<SafetyReportModel> reports,
  ) async {
    if (reports.isEmpty) return [];

    for (final report in reports) {
      _ingestReport(report);
    }

    return _identifyConcerningPatterns()
        .where((pattern) => pattern.individualId == individualId)
        .toList();
  }

  /// Run pattern analysis in the background with a batch of active reports
  Future<void> runBackgroundAnalysis(
      List<SafetyReportModel> activeReports) async {
    if (activeReports.isEmpty) return;

    for (final report in activeReports) {
      _ingestReport(report);
    }

    await analyzePatterns();
  }

  /// Calculate an aggregate community risk score (0-10)
  Future<double> calculateCommunityRiskScore() async {
    final riskScores = await _calculateIndividualRiskScores();
    if (riskScores.isEmpty) return 0.0;

    final average =
        riskScores.values.reduce((a, b) => a + b) / riskScores.length;
    return average.clamp(0.0, 10.0);
  }

  /// Validate a safety report before submission
  Future<SafetyValidationResult> validateSafetyReport(
      SafetyReportModel report) async {
    String? errorMessage;
    final warnings = <String>[];

    if (report.incidentCategories.isEmpty) {
      errorMessage = 'Select at least one incident category.';
    }

    if (report.severityScore < 1 || report.severityScore > 5) {
      errorMessage ??= 'Severity score must be between 1 and 5.';
    }

    if (report.incidentDescription.trim().length < 20) {
      warnings.add('Add more detail to help moderators verify the report.');
    }

    if (report.location == null) {
      warnings.add('Adding a location improves geographic pattern detection.');
    } else {
      final existingReports = _individualReports[report.individualId] ??
          const <SafetyReportModel>[];

      final nearbyReports = existingReports.where((existing) {
        if (existing.location == null) return false;
        final distance = _calculateDistance(
          report.location!.latitude,
          report.location!.longitude,
          existing.location!.latitude,
          existing.location!.longitude,
        );
        final hoursApart =
            (report.timestamp.difference(existing.timestamp).inHours).abs();
        return distance <= 100 && hoursApart <= 24;
      }).length;

      if (nearbyReports > 0) {
        warnings.add(
            '$nearbyReports similar report(s) already exist for this area in the last day.');
      }
    }

    final isValid = errorMessage == null;
    return SafetyValidationResult(
      isValid: isValid,
      errorMessage: errorMessage,
      warnings: warnings,
    );
  }

  /// Get risk score for individual
  Future<RiskLevel> getIndividualRiskLevel(String individualId) async {
    final reports = _individualReports[individualId];
    if (reports == null || reports.length < minReportsForPattern) {
      return RiskLevel.unknown;
    }

    final recentReports = _filterRecentReports(reports);
    if (recentReports.isEmpty) return RiskLevel.unknown;

    // Quick risk assessment
    final totalScore =
        recentReports.map((r) => r.severityScore).reduce((a, b) => a + b);
    final averageScore = totalScore / recentReports.length;

    return _getRiskLevel(averageScore);
  }

  /// Get concerning patterns for individual
  Future<List<ConcerningPattern>> getIndividualPatterns(
      String individualId) async {
    final allPatterns = _identifyConcerningPatterns();
    return allPatterns.where((p) => p.individualId == individualId).toList();
  }

  /// Get safety insights for user
  Future<Map<String, dynamic>> getSafetyInsights(String userId) async {
    final userReports = _userReports[userId] ?? [];
    final riskAssessments = <String, RiskLevel>{};
    final patternCounts = <PatternType, int>{};

    // Assess risks for all individuals user has reported
    for (final report in userReports) {
      riskAssessments[report.individualId] =
          await getIndividualRiskLevel(report.individualId);
    }

    // Count pattern types found
    final allPatterns = _identifyConcerningPatterns();
    for (final pattern in allPatterns) {
      if (userReports.any((r) => r.individualId == pattern.individualId)) {
        patternCounts[pattern.patternType] =
            (patternCounts[pattern.patternType] ?? 0) + 1;
      }
    }

    return {
      'totalReports': userReports.length,
      'recentReports': _filterRecentReports(userReports).length,
      'riskAssessments': riskAssessments,
      'patternCounts': patternCounts,
      'safetyScore': _calculateUserSafetyScore(userReports, riskAssessments),
    };
  }

  /// Calculate user's overall safety score
  double _calculateUserSafetyScore(
    List<SafetyReportModel> reports,
    Map<String, RiskLevel> riskAssessments,
  ) {
    if (riskAssessments.isEmpty) return 100.0; // Perfect score if no risks

    final highRiskCount =
        riskAssessments.values.where((r) => r == RiskLevel.high).length;
    final mediumRiskCount =
        riskAssessments.values.where((r) => r == RiskLevel.medium).length;
    final lowRiskCount =
        riskAssessments.values.where((r) => r == RiskLevel.low).length;

    // Scoring: Lower score = more safety concerns reported
    final penalties =
        (highRiskCount * 25) + (mediumRiskCount * 10) + (lowRiskCount * 5);

    return (100.0 - penalties).clamp(0.0, 100.0);
  }

  /// Get risk level from score
  RiskLevel _getRiskLevel(double score) {
    if (score >= highRiskThreshold) return RiskLevel.high;
    if (score >= mediumRiskThreshold) return RiskLevel.medium;
    if (score >= lowRiskThreshold) return RiskLevel.low;
    return RiskLevel.low;
  }

  /// Clear all analysis data (for testing)
  void clearAnalysisData() {
    _userReports.clear();
    _individualReports.clear();
    debugPrint('Analysis data cleared');
  }

  /// Dispose the risk assessment stream controller (mainly for tests)
  void dispose() {
    _riskAssessmentController.close();
  }

  void _ingestReport(SafetyReportModel report) {
    final reporterList = _userReports.putIfAbsent(report.reporterId, () => []);
    if (!reporterList.any((existing) => existing.id == report.id)) {
      reporterList.add(report);
    }

    final individualList =
        _individualReports.putIfAbsent(report.individualId, () => []);
    if (!individualList.any((existing) => existing.id == report.id)) {
      individualList.add(report);
    }
  }

  void _emitRiskAssessmentSnapshot({
    required Map<String, double> riskScores,
    required List<ConcerningPattern> patterns,
  }) {
    if (_riskAssessmentController.isClosed) return;

    final highRiskCount =
        riskScores.values.where((score) => score >= highRiskThreshold).length;
    final mediumRiskCount = riskScores.values
        .where((score) =>
            score >= mediumRiskThreshold && score < highRiskThreshold)
        .length;
    final lowRiskCount = riskScores.values
        .where(
            (score) => score >= lowRiskThreshold && score < mediumRiskThreshold)
        .length;

    final snapshot = {
      'timestamp': DateTime.now().toIso8601String(),
      'individualCount': riskScores.length,
      'highRiskCount': highRiskCount,
      'mediumRiskCount': mediumRiskCount,
      'lowRiskCount': lowRiskCount,
      'patternsDetected': patterns.length,
      'geographicClusters': patterns
          .where((pattern) =>
              pattern.patternType == PatternType.geographicClustering)
          .length,
    };

    _riskAssessmentController.add(snapshot);
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;
}

/// Validation response for safety report submissions
class SafetyValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> warnings;

  const SafetyValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warnings = const [],
  });
}
