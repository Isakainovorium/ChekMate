import 'package:equatable/equatable.dart';

/// Safety report model for user-submitted safety concerns
class SafetyReportModel with EquatableMixin {
  final String id;
  final String reporterId;
  final String individualId; // Person being reported
  final DateTime timestamp;
  final SafetyReportLocation? location;
  final DateTime? incidentDate; // When the incident allegedly occurred
  final String incidentDescription;
  final List<String>
      incidentCategories; // "harassment", "threatening", "inappropriate", etc.
  final int severityScore; // 1-5 scale
  final String? additionalNotes;
  final bool isAnonymous;
  final SafetyReportStatus status;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNotes;
  final List<String> evidenceUrls; // Images/videos/witnesses
  final bool shareAnonymously; // For community pattern analysis

  const SafetyReportModel({
    required this.id,
    required this.reporterId,
    required this.individualId,
    required this.timestamp,
    this.location,
    this.incidentDate,
    required this.incidentDescription,
    required this.incidentCategories,
    required this.severityScore,
    this.additionalNotes,
    required this.isAnonymous,
    required this.status,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNotes,
    this.evidenceUrls = const [],
    this.shareAnonymously = true,
  });

  /// Factory constructor from JSON
  factory SafetyReportModel.fromJson(Map<String, dynamic> json) {
    return SafetyReportModel(
      id: json['id'] as String,
      reporterId: json['reporterId'] as String,
      individualId: json['individualId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] != null
          ? SafetyReportLocation.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
      incidentDate: json['incidentDate'] != null
          ? DateTime.parse(json['incidentDate'] as String)
          : null,
      incidentDescription: json['incidentDescription'] as String,
      incidentCategories: List<String>.from(json['incidentCategories'] as List),
      severityScore: json['severityScore'] as int,
      additionalNotes: json['additionalNotes'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      status: SafetyReportStatus.values[json['status'] as int],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewedBy: json['reviewedBy'] as String?,
      reviewNotes: json['reviewNotes'] as String?,
      evidenceUrls: List<String>.from(json['evidenceUrls'] as List? ?? []),
      shareAnonymously: json['shareAnonymously'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'individualId': individualId,
      'timestamp': timestamp.toIso8601String(),
      'location': location?.toJson(),
      'incidentDate': incidentDate?.toIso8601String(),
      'incidentDescription': incidentDescription,
      'incidentCategories': incidentCategories,
      'severityScore': severityScore,
      'additionalNotes': additionalNotes,
      'isAnonymous': isAnonymous,
      'status': status.index,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
      'evidenceUrls': evidenceUrls,
      'shareAnonymously': shareAnonymously,
    };
  }

  /// Create a copy with modified fields
  SafetyReportModel copyWith({
    String? id,
    String? reporterId,
    String? individualId,
    DateTime? timestamp,
    SafetyReportLocation? location,
    DateTime? incidentDate,
    String? incidentDescription,
    List<String>? incidentCategories,
    int? severityScore,
    String? additionalNotes,
    bool? isAnonymous,
    SafetyReportStatus? status,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNotes,
    List<String>? evidenceUrls,
    bool? shareAnonymously,
  }) {
    return SafetyReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      individualId: individualId ?? this.individualId,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      incidentDate: incidentDate ?? this.incidentDate,
      incidentDescription: incidentDescription ?? this.incidentDescription,
      incidentCategories: incidentCategories ?? this.incidentCategories,
      severityScore: severityScore ?? this.severityScore,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      shareAnonymously: shareAnonymously ?? this.shareAnonymously,
    );
  }

  /// Check if report is pending review
  bool get isPending => status == SafetyReportStatus.pending;

  /// Check if report is under review
  bool get isUnderReview => status == SafetyReportStatus.underReview;

  /// Check if report is active and visible
  bool get isActive => status == SafetyReportStatus.active;

  /// Get report age in days
  int get ageInDays => DateTime.now().difference(timestamp).inDays;

  /// Get severity level description
  String get severityDescription {
    switch (severityScore) {
      case 1:
        return 'Minor concern';
      case 2:
        return 'Mild inappropriate behavior';
      case 3:
        return 'Concerning behavior';
      case 4:
        return 'Serious violation';
      case 5:
        return 'Critical safety threat';
      default:
        return 'Unknown severity';
    }
  }

  /// Check if report should be shown anonymously
  bool get shouldShowAnonymously => isAnonymous;

  /// Get summary of incident for display
  String get summary {
    final categories = incidentCategories.take(2).join(', ');
    return '$categories • ${severityDescription.toLowerCase()}';
  }

  @override
  List<Object?> get props => [
        id,
        reporterId,
        individualId,
        timestamp,
        location,
        incidentDate,
        incidentDescription,
        incidentCategories,
        severityScore,
        additionalNotes,
        isAnonymous,
        status,
        reviewedAt,
        reviewedBy,
        reviewNotes,
        evidenceUrls,
        shareAnonymously,
      ];

  @override
  String toString() {
    return 'SafetyReportModel(id: $id, reporter: ${isAnonymous ? 'anonymous' : reporterId}, individual: $individualId, severity: $severityScore, status: $status)';
  }
}

/// Safety report status enum
enum SafetyReportStatus {
  pending, // Submitted but not reviewed
  underReview, // Being reviewed by moderators
  active, // Approved and visible for pattern analysis
  rejected, // Rejected after review
  archived, // Archived for compliance/legal reasons
}

extension SafetyReportStatusExtension on SafetyReportStatus {
  String get displayName {
    switch (this) {
      case SafetyReportStatus.pending:
        return 'Pending Review';
      case SafetyReportStatus.underReview:
        return 'Under Review';
      case SafetyReportStatus.active:
        return 'Active';
      case SafetyReportStatus.rejected:
        return 'Rejected';
      case SafetyReportStatus.archived:
        return 'Archived';
    }
  }

  String get description {
    switch (this) {
      case SafetyReportStatus.pending:
        return 'Report submitted and waiting for initial review';
      case SafetyReportStatus.underReview:
        return 'Report is being evaluated by safety team';
      case SafetyReportStatus.active:
        return 'Report is approved and contributes to safety analysis';
      case SafetyReportStatus.rejected:
        return 'Report was rejected after review';
      case SafetyReportStatus.archived:
        return 'Report has been archived for legal compliance';
    }
  }
}

/// Location data for safety reports
class SafetyReportLocation {
  final double latitude;
  final double longitude;
  final String? locationName; // "Starbucks on 5th Ave", etc.
  final String? city;
  final String? state;
  final String? country;

  const SafetyReportLocation({
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.city,
    this.state,
    this.country,
  });

  /// Factory constructor from JSON
  factory SafetyReportLocation.fromJson(Map<String, dynamic> json) {
    return SafetyReportLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      locationName: json['locationName'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'city': city,
      'state': state,
      'country': country,
    };
  }

  /// Get display-friendly location string
  String get displayString {
    final parts = [locationName, city].where((p) => p != null && p.isNotEmpty);
    return parts.isNotEmpty ? parts.join(', ') : '$latitude, $longitude';
  }

  @override
  String toString() {
    return 'SafetyReportLocation($displayString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SafetyReportLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Risk level enum for pattern analysis
enum RiskLevel {
  unknown,
  none,
  low,
  medium,
  high,
  critical,
}

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.unknown:
        return 'Unknown';
      case RiskLevel.none:
        return 'No Risk';
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical Risk';
    }
  }

  String get color {
    switch (this) {
      case RiskLevel.unknown:
        return '#6B7280'; // gray
      case RiskLevel.none:
        return '#10B981'; // green
      case RiskLevel.low:
        return '#84CC16'; // lime
      case RiskLevel.medium:
        return '#F59E0B'; // yellow/amber
      case RiskLevel.high:
        return '#F97316'; // orange
      case RiskLevel.critical:
        return '#EF4444'; // red
    }
  }
}

/// Pattern type enum for concerning behavior patterns
enum PatternType {
  multipleReporters,
  geographicClustering,
  temporalPatterns,
  escalationPattern,
}

extension PatternTypeExtension on PatternType {
  String get displayName {
    switch (this) {
      case PatternType.multipleReporters:
        return 'Multiple Reports';
      case PatternType.geographicClustering:
        return 'Location Clustering';
      case PatternType.temporalPatterns:
        return 'Time Patterns';
      case PatternType.escalationPattern:
        return 'Escalation';
    }
  }

  String get description {
    switch (this) {
      case PatternType.multipleReporters:
        return 'Multiple independent users have reported concerns';
      case PatternType.geographicClustering:
        return 'Reports cluster in specific geographic areas';
      case PatternType.temporalPatterns:
        return 'Reports show consistent timing patterns';
      case PatternType.escalationPattern:
        return 'Behavior shows escalating severity over time';
    }
  }
}

/// Concerning pattern model for safety analysis
class ConcerningPattern {
  final String patternId;
  final PatternType patternType;
  final String individualId;
  final double confidenceScore; // 0.0 to 1.0
  final RiskLevel severityLevel;
  final String description;
  final List<String> relatedReports; // Report IDs
  final DateTime detectedAt;

  ConcerningPattern({
    required this.patternId,
    required this.patternType,
    required this.individualId,
    required this.confidenceScore,
    required this.severityLevel,
    required this.description,
    required this.relatedReports,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'patternId': patternId,
      'patternType': patternType.index,
      'individualId': individualId,
      'confidenceScore': confidenceScore,
      'severityLevel': severityLevel.index,
      'description': description,
      'relatedReports': relatedReports,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  /// Factory constructor from JSON
  factory ConcerningPattern.fromJson(Map<String, dynamic> json) {
    return ConcerningPattern(
      patternId: json['patternId'] as String,
      patternType: PatternType.values[json['patternType'] as int],
      individualId: json['individualId'] as String,
      confidenceScore: json['confidenceScore'] as double,
      severityLevel: RiskLevel.values[json['severityLevel'] as int],
      description: json['description'] as String,
      relatedReports: List<String>.from(json['relatedReports'] as List),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ConcerningPattern(type: $patternType, confidence: ${(confidenceScore * 100).round()}%, severity: $severityLevel)';
  }
}
