/// A/B Test Variants
///
/// Defines all A/B test variants and their configurations for the ChekMate app.
///
/// Current Active Tests:
/// - Feed Algorithm Test: Chronological vs Hybrid Feed
///
/// Clean Architecture: Core Layer (Constants)
library;

/// A/B Test Names
///
/// Unique identifiers for each A/B test
class ABTestNames {
  ABTestNames._();

  /// Feed Algorithm Test
  /// Tests chronological feed (control) vs hybrid feed (variant)
  static const String feedAlgorithm = 'feed_algorithm_test';
}

/// Feed Algorithm Test Variants
///
/// Variants for the feed algorithm A/B test
enum FeedAlgorithmVariant {
  /// Control group: Chronological feed (Following feed)
  /// Shows posts in reverse chronological order from followed users
  control('control', 'Chronological Feed'),

  /// Variant group: Hybrid feed
  /// Shows posts combining location (60%) and interests (40%)
  variant('variant', 'Hybrid Feed');

  const FeedAlgorithmVariant(this.id, this.displayName);

  /// Variant ID for tracking and analytics
  final String id;

  /// Human-readable display name
  final String displayName;

  /// Convert from string ID to enum
  static FeedAlgorithmVariant fromId(String id) {
    return values.firstWhere(
      (variant) => variant.id == id,
      orElse: () => control, // Default to control if unknown
    );
  }
}

/// A/B Test Configuration
///
/// Configuration for A/B tests including rollout percentage and status
class ABTestConfig {
  const ABTestConfig({
    required this.testName,
    required this.isActive,
    required this.rolloutPercentage,
    required this.description,
  });

  /// Unique test name
  final String testName;

  /// Whether the test is currently active
  final bool isActive;

  /// Percentage of users to include in the test (0-100)
  /// Users not in the test will see the default experience
  final int rolloutPercentage;

  /// Test description for documentation
  final String description;
}

/// Active A/B Tests
///
/// Configuration for all active A/B tests
class ActiveABTests {
  ActiveABTests._();

  /// Feed Algorithm Test Configuration
  static const ABTestConfig feedAlgorithmTest = ABTestConfig(
    testName: ABTestNames.feedAlgorithm,
    isActive: true, // Set to false to disable the test
    rolloutPercentage:
        100, // 100% of users in the test (50/50 split between variants)
    description:
        'Tests chronological feed vs hybrid feed to measure engagement and retention',
  );

  /// Get all active tests
  static List<ABTestConfig> get allTests => [
        feedAlgorithmTest,
      ];

  /// Get active tests only
  static List<ABTestConfig> get activeTests =>
      allTests.where((test) => test.isActive).toList();
}

/// A/B Test Assignment
///
/// Represents a user's assignment to an A/B test variant
class ABTestAssignment {
  const ABTestAssignment({
    required this.testName,
    required this.variantId,
    required this.assignedAt,
  });

  /// Create from JSON
  factory ABTestAssignment.fromJson(Map<String, dynamic> json) {
    return ABTestAssignment(
      testName: json['testName'] as String,
      variantId: json['variantId'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );
  }

  /// Test name
  final String testName;

  /// Assigned variant ID
  final String variantId;

  /// When the assignment was made
  final DateTime assignedAt;

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'testName': testName,
      'variantId': variantId,
      'assignedAt': assignedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ABTestAssignment(testName: $testName, variantId: $variantId, assignedAt: $assignedAt)';
  }
}
