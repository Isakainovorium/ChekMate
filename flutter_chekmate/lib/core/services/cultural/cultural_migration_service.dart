import 'dart:async';
import 'package:flutter_chekmate/features/cultural/models/cultural_identity_model.dart';
import 'package:flutter_chekmate/features/cultural/models/cultural_identity_evolved.dart';
import 'package:flutter_chekmate/core/services/cultural/cultural_profile_adapter.dart';
import 'package:flutter_chekmate/core/services/cultural/cultural_vector_service.dart';

/// Service for managing the migration from enum-based to ML-driven cultural system
class CulturalMigrationService {
  final CulturalVectorService _vectorService;
  final CulturalProfileAdapter _profileAdapter;
  final MigrationRepository _repository;

  // Migration configuration
  static const int _batchSize = 100;
  static const Duration _migrationDelay = Duration(milliseconds: 100);

  CulturalMigrationService({
    required CulturalVectorService vectorService,
    required CulturalProfileAdapter profileAdapter,
    required MigrationRepository repository,
  })  : _vectorService = vectorService,
        _profileAdapter = profileAdapter,
        _repository = repository;

  /// Migrate a single user profile from enum to ML system
  Future<MigrationResult> migrateUserProfile({
    required String userId,
    required CulturalIdentity legacyProfile,
    bool generateVector = true,
  }) async {
    try {
      // Step 1: Create evolved profile from legacy
      final evolvedProfile = CulturalIdentityEvolved.fromLegacy(legacyProfile);

      // Step 2: Convert enum data to free-form text
      final freeFormData = _profileAdapter.convertToFreeForm(legacyProfile);

      // Step 3: Generate vector embedding if requested
      List<double>? culturalVector;
      if (generateVector) {
        culturalVector =
            await _profileAdapter.generateVectorFromEnum(legacyProfile);
      }

      // Step 4: Calculate profile richness
      final profileRichness =
          CulturalProfileAdapter.calculateProfileRichness(freeFormData);

      // Step 5: Create updated profile with all data
      final migratedProfile = evolvedProfile.copyWith(
        heritageDescription: freeFormData['heritage_description'] as String?,
        communityAffiliations:
            freeFormData['community_affiliations'] as List<String>? ?? [],
        generationalIdentity: freeFormData['generational_identity'] as String?,
        culturalPractices:
            freeFormData['cultural_practices'] as List<String>? ?? [],
        culturalInterestsText:
            freeFormData['cultural_interests_text'] as List<String>? ?? [],
        culturalVector: culturalVector,
        profileRichness: profileRichness,
        migrationStatus: culturalVector != null
            ? MigrationStatus.parallel
            : MigrationStatus.enumOnly,
        vectorGeneratedAt: culturalVector != null ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      // Step 6: Save migration status
      await _repository.saveMigrationStatus(
        userId: userId,
        status: MigrationStatus.parallel,
        enumBackup: legacyProfile.toJson(),
        freeFormData: freeFormData,
        vectorData: culturalVector != null
            ? {'vector': culturalVector, 'dimension': culturalVector.length}
            : null,
      );

      // Step 7: Save migrated profile
      await _repository.saveEvolvedProfile(migratedProfile);

      return MigrationResult(
        success: true,
        userId: userId,
        migratedProfile: migratedProfile,
        migrationStatus: MigrationStatus.parallel,
        message: 'Profile successfully migrated to parallel system',
      );
    } catch (e) {
      print('Migration failed for user $userId: $e');

      // Log failure
      await _repository.logMigrationError(
        userId: userId,
        error: e.toString(),
      );

      return MigrationResult(
        success: false,
        userId: userId,
        migrationStatus: MigrationStatus.enumOnly,
        message: 'Migration failed: $e',
        error: e.toString(),
      );
    }
  }

  /// Batch migrate multiple user profiles
  Future<BatchMigrationResult> batchMigrateProfiles({
    required List<CulturalIdentity> legacyProfiles,
    bool generateVectors = true,
    Function(double)? onProgress,
  }) async {
    final results = <MigrationResult>[];
    int successCount = 0;
    int failureCount = 0;

    // Process in batches to avoid overwhelming the system
    for (int i = 0; i < legacyProfiles.length; i += _batchSize) {
      final batch = legacyProfiles.skip(i).take(_batchSize).toList();

      // Process batch in parallel
      final batchResults = await Future.wait(
        batch.map((profile) => migrateUserProfile(
              userId: profile.id,
              legacyProfile: profile,
              generateVector: generateVectors,
            )),
      );

      results.addAll(batchResults);

      // Count successes and failures
      for (final result in batchResults) {
        if (result.success) {
          successCount++;
        } else {
          failureCount++;
        }
      }

      // Report progress
      if (onProgress != null) {
        final progress = (i + batch.length) / legacyProfiles.length;
        onProgress(progress.clamp(0.0, 1.0));
      }

      // Add delay between batches to prevent overload
      if (i + _batchSize < legacyProfiles.length) {
        await Future.delayed(_migrationDelay);
      }
    }

    return BatchMigrationResult(
      totalProfiles: legacyProfiles.length,
      successCount: successCount,
      failureCount: failureCount,
      results: results,
      completedAt: DateTime.now(),
    );
  }

  /// Validate migration for a user
  Future<ValidationResult> validateMigration(String userId) async {
    try {
      // Get migrated profile
      final evolvedProfile = await _repository.getEvolvedProfile(userId);
      if (evolvedProfile == null) {
        return ValidationResult(
          isValid: false,
          userId: userId,
          issues: ['Profile not found'],
        );
      }

      // Get migration status
      final migrationStatus = await _repository.getMigrationStatus(userId);
      if (migrationStatus == null) {
        return ValidationResult(
          isValid: false,
          userId: userId,
          issues: ['Migration status not found'],
        );
      }

      final issues = <String>[];

      // Validate enum data preservation
      if (evolvedProfile.hasEnumData) {
        final enumBackup =
            migrationStatus['enum_data_backup'] as Map<String, dynamic>?;
        if (enumBackup == null) {
          issues.add('Enum backup data missing');
        }
      }

      // Validate free-form data generation
      if (!evolvedProfile.hasFreeFormData && evolvedProfile.hasEnumData) {
        issues.add('Free-form data not generated from enum data');
      }

      // Validate vector generation if applicable
      if (evolvedProfile.migrationStatus == MigrationStatus.parallel ||
          evolvedProfile.migrationStatus == MigrationStatus.mlReady) {
        if (!evolvedProfile.hasVectorData) {
          issues.add('Vector data missing for parallel/ML-ready profile');
        }
      }

      // Validate profile richness calculation
      if (evolvedProfile.profileRichness == 0 &&
          evolvedProfile.hasFreeFormData) {
        issues.add('Profile richness not calculated');
      }

      return ValidationResult(
        isValid: issues.isEmpty,
        userId: userId,
        issues: issues,
        profile: evolvedProfile,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        userId: userId,
        issues: ['Validation error: $e'],
      );
    }
  }

  /// Rollback migration for a user
  Future<RollbackResult> rollbackMigration(String userId) async {
    try {
      // Get migration status with enum backup
      final migrationStatus = await _repository.getMigrationStatus(userId);
      if (migrationStatus == null) {
        return RollbackResult(
          success: false,
          userId: userId,
          message: 'No migration status found',
        );
      }

      final enumBackup =
          migrationStatus['enum_data_backup'] as Map<String, dynamic>?;
      if (enumBackup == null) {
        return RollbackResult(
          success: false,
          userId: userId,
          message: 'No enum backup data available',
        );
      }

      // Restore enum-only profile
      final restoredProfile = CulturalIdentity.fromJson(enumBackup);
      final evolvedProfile =
          CulturalIdentityEvolved.fromLegacy(restoredProfile);

      // Update profile to enum-only status
      final rolledBackProfile = evolvedProfile.copyWith(
        migrationStatus: MigrationStatus.enumOnly,
        heritageDescription: null,
        communityAffiliations: [],
        generationalIdentity: null,
        culturalPractices: [],
        culturalInterestsText: [],
        culturalVector: null,
        profileRichness: 0.0,
        vectorGeneratedAt: null,
        updatedAt: DateTime.now(),
      );

      // Save rolled back profile
      await _repository.saveEvolvedProfile(rolledBackProfile);

      // Update migration status
      await _repository.updateMigrationStatus(
        userId: userId,
        status: MigrationStatus.enumOnly,
        rollbackAt: DateTime.now(),
      );

      return RollbackResult(
        success: true,
        userId: userId,
        restoredProfile: rolledBackProfile,
        message: 'Successfully rolled back to enum-only profile',
      );
    } catch (e) {
      return RollbackResult(
        success: false,
        userId: userId,
        message: 'Rollback failed: $e',
        error: e.toString(),
      );
    }
  }

  /// Get migration statistics
  Future<MigrationStatistics> getMigrationStatistics() async {
    final stats = await _repository.getMigrationStatistics();

    return MigrationStatistics(
      totalUsers: stats['total_users'] ?? 0,
      enumOnlyUsers: stats['enum_only_users'] ?? 0,
      parallelUsers: stats['parallel_users'] ?? 0,
      mlReadyUsers: stats['ml_ready_users'] ?? 0,
      completedUsers: stats['completed_users'] ?? 0,
      averageProfileRichness: stats['avg_profile_richness'] ?? 0.0,
      usersWithVectors: stats['users_with_vectors'] ?? 0,
      uniquePatternsDiscovered: stats['unique_patterns_discovered'] ?? 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Monitor migration health
  Future<MigrationHealth> checkMigrationHealth() async {
    final stats = await getMigrationStatistics();
    final recentErrors = await _repository.getRecentMigrationErrors(hours: 24);

    final issues = <String>[];
    HealthStatus status = HealthStatus.healthy;

    // Check error rate
    final errorRate =
        recentErrors.length / (stats.totalUsers > 0 ? stats.totalUsers : 1);
    if (errorRate > 0.1) {
      issues.add('High error rate: ${(errorRate * 100).toStringAsFixed(1)}%');
      status = HealthStatus.degraded;
    }
    if (errorRate > 0.25) {
      status = HealthStatus.critical;
    }

    // Check vector generation rate
    final vectorRate = stats.usersWithVectors /
        (stats.parallelUsers > 0 ? stats.parallelUsers : 1);
    if (vectorRate < 0.8) {
      issues.add(
          'Low vector generation rate: ${(vectorRate * 100).toStringAsFixed(1)}%');
      if (status == HealthStatus.healthy) {
        status = HealthStatus.warning;
      }
    }

    // Check profile richness
    if (stats.averageProfileRichness < 0.3) {
      issues.add(
          'Low average profile richness: ${stats.averageProfileRichness.toStringAsFixed(2)}');
      if (status == HealthStatus.healthy) {
        status = HealthStatus.warning;
      }
    }

    return MigrationHealth(
      status: status,
      statistics: stats,
      recentErrorCount: recentErrors.length,
      issues: issues,
      checkedAt: DateTime.now(),
    );
  }
}

/// Repository interface for migration data persistence
abstract class MigrationRepository {
  Future<void> saveMigrationStatus({
    required String userId,
    required MigrationStatus status,
    Map<String, dynamic>? enumBackup,
    Map<String, dynamic>? freeFormData,
    Map<String, dynamic>? vectorData,
  });

  Future<Map<String, dynamic>?> getMigrationStatus(String userId);

  Future<void> updateMigrationStatus({
    required String userId,
    required MigrationStatus status,
    DateTime? rollbackAt,
  });

  Future<void> saveEvolvedProfile(CulturalIdentityEvolved profile);

  Future<CulturalIdentityEvolved?> getEvolvedProfile(String userId);

  Future<void> logMigrationError({
    required String userId,
    required String error,
  });

  Future<List<Map<String, dynamic>>> getRecentMigrationErrors({
    required int hours,
  });

  Future<Map<String, dynamic>> getMigrationStatistics();
}

/// Result of a single profile migration
class MigrationResult {
  final bool success;
  final String userId;
  final CulturalIdentityEvolved? migratedProfile;
  final MigrationStatus migrationStatus;
  final String message;
  final String? error;

  MigrationResult({
    required this.success,
    required this.userId,
    this.migratedProfile,
    required this.migrationStatus,
    required this.message,
    this.error,
  });
}

/// Result of batch migration
class BatchMigrationResult {
  final int totalProfiles;
  final int successCount;
  final int failureCount;
  final List<MigrationResult> results;
  final DateTime completedAt;

  BatchMigrationResult({
    required this.totalProfiles,
    required this.successCount,
    required this.failureCount,
    required this.results,
    required this.completedAt,
  });

  double get successRate =>
      totalProfiles > 0 ? successCount / totalProfiles : 0.0;
}

/// Result of migration validation
class ValidationResult {
  final bool isValid;
  final String userId;
  final List<String> issues;
  final CulturalIdentityEvolved? profile;

  ValidationResult({
    required this.isValid,
    required this.userId,
    required this.issues,
    this.profile,
  });
}

/// Result of migration rollback
class RollbackResult {
  final bool success;
  final String userId;
  final CulturalIdentityEvolved? restoredProfile;
  final String message;
  final String? error;

  RollbackResult({
    required this.success,
    required this.userId,
    this.restoredProfile,
    required this.message,
    this.error,
  });
}

/// Migration statistics
class MigrationStatistics {
  final int totalUsers;
  final int enumOnlyUsers;
  final int parallelUsers;
  final int mlReadyUsers;
  final int completedUsers;
  final double averageProfileRichness;
  final int usersWithVectors;
  final int uniquePatternsDiscovered;
  final DateTime lastUpdated;

  MigrationStatistics({
    required this.totalUsers,
    required this.enumOnlyUsers,
    required this.parallelUsers,
    required this.mlReadyUsers,
    required this.completedUsers,
    required this.averageProfileRichness,
    required this.usersWithVectors,
    required this.uniquePatternsDiscovered,
    required this.lastUpdated,
  });

  double get migrationProgress {
    if (totalUsers == 0) return 0.0;
    return (parallelUsers + mlReadyUsers + completedUsers) / totalUsers;
  }
}

/// Migration health status
enum HealthStatus {
  healthy,
  warning,
  degraded,
  critical,
}

/// Migration health check result
class MigrationHealth {
  final HealthStatus status;
  final MigrationStatistics statistics;
  final int recentErrorCount;
  final List<String> issues;
  final DateTime checkedAt;

  MigrationHealth({
    required this.status,
    required this.statistics,
    required this.recentErrorCount,
    required this.issues,
    required this.checkedAt,
  });
}
