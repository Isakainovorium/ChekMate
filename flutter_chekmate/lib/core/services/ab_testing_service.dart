import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/constants/ab_test_variants.dart';

/// A/B Testing Service
///
/// Manages A/B test variant assignments for users.
///
/// Features:
/// - Deterministic assignment based on user ID hash (consistent across sessions)
/// - 50/50 split between control and variant groups
/// - Persistent storage in Firestore
/// - Rollout percentage control
/// - Multiple concurrent tests support
///
/// Algorithm:
/// 1. Check if test is active and user is in rollout percentage
/// 2. Hash user ID to get deterministic number (0-99)
/// 3. Assign to control (0-49) or variant (50-99)
/// 4. Persist assignment to Firestore
/// 5. Return same assignment on subsequent calls
///
/// Clean Architecture: Core Layer (Service)
class ABTestingService {
  ABTestingService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _abTestsField = 'abTests';

  /// Get user's variant for a specific test
  ///
  /// Returns the variant ID the user is assigned to.
  /// If user is not yet assigned, assigns them deterministically.
  ///
  /// Parameters:
  /// - userId: User's unique ID
  /// - testName: Name of the A/B test
  /// - config: Test configuration
  ///
  /// Returns:
  /// - Variant ID (e.g., 'control' or 'variant')
  ///
  /// Throws:
  /// - Exception if test is not active
  /// - Exception if Firestore operation fails
  Future<String> getUserVariant({
    required String userId,
    required String testName,
    required ABTestConfig config,
  }) async {
    try {
      developer.log(
        'Getting variant for user $userId in test $testName',
        name: 'ABTestingService',
      );

      // Check if test is active
      if (!config.isActive) {
        developer.log(
          'Test $testName is not active, returning control',
          name: 'ABTestingService',
        );
        return FeedAlgorithmVariant.control.id;
      }

      // Check if user is in rollout percentage
      if (!_isUserInRollout(userId, config.rolloutPercentage)) {
        developer.log(
          'User $userId not in rollout for test $testName, returning control',
          name: 'ABTestingService',
        );
        return FeedAlgorithmVariant.control.id;
      }

      // Check if user already has an assignment
      final existingAssignment = await _getExistingAssignment(
        userId: userId,
        testName: testName,
      );

      if (existingAssignment != null) {
        developer.log(
          'User $userId already assigned to ${existingAssignment.variantId} for test $testName',
          name: 'ABTestingService',
        );
        return existingAssignment.variantId;
      }

      // Assign user to variant deterministically
      final variantId = _assignVariant(userId);

      // Persist assignment to Firestore
      await _persistAssignment(
        userId: userId,
        assignment: ABTestAssignment(
          testName: testName,
          variantId: variantId,
          assignedAt: DateTime.now(),
        ),
      );

      developer.log(
        'Assigned user $userId to $variantId for test $testName',
        name: 'ABTestingService',
      );

      return variantId;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to get user variant for test $testName',
        name: 'ABTestingService',
        error: e,
        stackTrace: stackTrace,
      );
      // Return control variant on error (safe fallback)
      return FeedAlgorithmVariant.control.id;
    }
  }

  /// Get user's feed algorithm variant
  ///
  /// Convenience method for the feed algorithm test.
  ///
  /// Parameters:
  /// - userId: User's unique ID
  ///
  /// Returns:
  /// - FeedAlgorithmVariant enum value
  Future<FeedAlgorithmVariant> getFeedAlgorithmVariant({
    required String userId,
  }) async {
    final variantId = await getUserVariant(
      userId: userId,
      testName: ABTestNames.feedAlgorithm,
      config: ActiveABTests.feedAlgorithmTest,
    );

    return FeedAlgorithmVariant.fromId(variantId);
  }

  /// Check if user is in rollout percentage
  ///
  /// Uses user ID hash to deterministically assign users to rollout.
  ///
  /// Parameters:
  /// - userId: User's unique ID
  /// - rolloutPercentage: Percentage of users to include (0-100)
  ///
  /// Returns:
  /// - true if user is in rollout, false otherwise
  bool _isUserInRollout(String userId, int rolloutPercentage) {
    if (rolloutPercentage >= 100) return true;
    if (rolloutPercentage <= 0) return false;

    // Hash user ID to get number 0-99
    final hash = _hashUserId(userId);
    return hash < rolloutPercentage;
  }

  /// Assign user to variant deterministically
  ///
  /// Uses user ID hash to assign users to control or variant.
  /// 50/50 split: 0-49 = control, 50-99 = variant
  ///
  /// Parameters:
  /// - userId: User's unique ID
  ///
  /// Returns:
  /// - Variant ID ('control' or 'variant')
  String _assignVariant(String userId) {
    final hash = _hashUserId(userId);

    // 50/50 split
    if (hash < 50) {
      return FeedAlgorithmVariant.control.id;
    } else {
      return FeedAlgorithmVariant.variant.id;
    }
  }

  /// Hash user ID to get deterministic number 0-99
  ///
  /// Uses simple hash function for consistent assignment.
  ///
  /// Parameters:
  /// - userId: User's unique ID
  ///
  /// Returns:
  /// - Hash value 0-99
  int _hashUserId(String userId) {
    // Convert user ID to bytes and sum them
    final bytes = utf8.encode(userId);
    var sum = 0;
    for (final byte in bytes) {
      sum += byte;
    }

    // Return modulo 100 to get 0-99
    return sum % 100;
  }

  /// Get existing assignment from Firestore
  ///
  /// Parameters:
  /// - userId: User's unique ID
  /// - testName: Name of the A/B test
  ///
  /// Returns:
  /// - ABTestAssignment if exists, null otherwise
  Future<ABTestAssignment?> _getExistingAssignment({
    required String userId,
    required String testName,
  }) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(userId).get();

      if (!userDoc.exists) {
        return null;
      }

      final data = userDoc.data();
      if (data == null || !data.containsKey(_abTestsField)) {
        return null;
      }

      final abTests = data[_abTestsField] as Map<String, dynamic>?;
      if (abTests == null || !abTests.containsKey(testName)) {
        return null;
      }

      final assignmentData = abTests[testName] as Map<String, dynamic>;
      return ABTestAssignment.fromJson(assignmentData);
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to get existing assignment for test $testName',
        name: 'ABTestingService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Persist assignment to Firestore
  ///
  /// Stores the assignment in the user's document under the abTests field.
  ///
  /// Parameters:
  /// - userId: User's unique ID
  /// - assignment: Assignment to persist
  Future<void> _persistAssignment({
    required String userId,
    required ABTestAssignment assignment,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).set(
        {
          _abTestsField: {
            assignment.testName: assignment.toJson(),
          },
        },
        SetOptions(merge: true),
      );

      developer.log(
        'Persisted assignment for user $userId: ${assignment.testName} = ${assignment.variantId}',
        name: 'ABTestingService',
      );
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to persist assignment for test ${assignment.testName}',
        name: 'ABTestingService',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - assignment will be recalculated next time
    }
  }

  /// Get all assignments for a user
  ///
  /// Returns all A/B test assignments for a user.
  ///
  /// Parameters:
  /// - userId: User's unique ID
  ///
  /// Returns:
  /// - Map of test name to assignment
  Future<Map<String, ABTestAssignment>> getAllAssignments({
    required String userId,
  }) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(userId).get();

      if (!userDoc.exists) {
        return {};
      }

      final data = userDoc.data();
      if (data == null || !data.containsKey(_abTestsField)) {
        return {};
      }

      final abTests = data[_abTestsField] as Map<String, dynamic>?;
      if (abTests == null) {
        return {};
      }

      final assignments = <String, ABTestAssignment>{};
      for (final entry in abTests.entries) {
        try {
          assignments[entry.key] = ABTestAssignment.fromJson(
            entry.value as Map<String, dynamic>,
          );
        } on Exception catch (e) {
          developer.log(
            'Failed to parse assignment for test ${entry.key}',
            name: 'ABTestingService',
            error: e,
          );
        }
      }

      return assignments;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to get all assignments for user $userId',
        name: 'ABTestingService',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }
}

