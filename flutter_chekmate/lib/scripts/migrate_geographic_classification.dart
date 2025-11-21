import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_chekmate/core/services/cultural/location_context_service.dart';
import 'package:flutter_chekmate/core/services/cultural/cultural_vector_service.dart';
import 'package:flutter_chekmate/core/services/cultural/location_pattern_service.dart';

/// Migration script for geographic classification system
/// Migrates from static country mapping to ML-driven location patterns
class GeographicMigrationScript {
  final LocationContextService _locationService;
  final CulturalVectorService _vectorService;
  final LocationPatternService _patternService;
  final MigrationDatabase _database;

  // Migration configuration
  static const int _batchSize = 100;
  static const Duration _batchDelay = Duration(milliseconds: 500);

  GeographicMigrationScript({
    LocationContextService? locationService,
    CulturalVectorService? vectorService,
    LocationPatternService? patternService,
    required MigrationDatabase database,
  })  : _locationService = locationService ?? LocationContextService.instance,
        _vectorService = vectorService ?? CulturalVectorService(),
        _patternService = patternService ?? LocationPatternService.instance,
        _database = database;

  /// Main migration entry point
  Future<MigrationResult> migrateAllLocations({
    bool dryRun = false,
    Function(double)? onProgress,
  }) async {
    debugPrint('Starting geographic classification migration...');
    debugPrint('Mode: ${dryRun ? "DRY RUN" : "LIVE"}');

    final startTime = DateTime.now();
    int successCount = 0;
    int errorCount = 0;
    final errors = <String>[];

    try {
      // Step 1: Fetch all content with GPS coordinates
      final contentWithGPS = await _fetchContentWithCoordinates();
      debugPrint('Found ${contentWithGPS.length} content items with GPS data');

      if (contentWithGPS.isEmpty) {
        return MigrationResult(
          success: true,
          totalProcessed: 0,
          successCount: 0,
          errorCount: 0,
          duration: DateTime.now().difference(startTime),
          message: 'No content with GPS coordinates found',
        );
      }

      // Step 2: Process in batches
      for (int i = 0; i < contentWithGPS.length; i += _batchSize) {
        final batch = contentWithGPS.skip(i).take(_batchSize).toList();

        debugPrint('Processing batch ${i ~/ _batchSize + 1} '
            '(items ${i + 1}-${i + batch.length} of ${contentWithGPS.length})');

        // Process batch
        final batchResult = await _processBatch(
          batch,
          dryRun: dryRun,
        );

        successCount += batchResult.successCount;
        errorCount += batchResult.errorCount;
        errors.addAll(batchResult.errors);

        // Report progress
        if (onProgress != null) {
          final progress = (i + batch.length) / contentWithGPS.length;
          onProgress(progress.clamp(0.0, 1.0));
        }

        // Delay between batches to avoid overload
        if (i + _batchSize < contentWithGPS.length) {
          await Future.delayed(_batchDelay);
        }
      }

      // Step 3: Discover location patterns
      if (!dryRun && successCount > 0) {
        debugPrint('\nDiscovering location-based cultural patterns...');
        await _discoverLocationPatterns();
      }

      // Step 4: Generate migration report
      final duration = DateTime.now().difference(startTime);
      final report = _generateReport(
        totalProcessed: contentWithGPS.length,
        successCount: successCount,
        errorCount: errorCount,
        duration: duration,
        errors: errors,
      );

      debugPrint(report);

      return MigrationResult(
        success: errorCount == 0,
        totalProcessed: contentWithGPS.length,
        successCount: successCount,
        errorCount: errorCount,
        duration: duration,
        message: report,
        errors: errors,
      );
    } catch (e, stackTrace) {
      debugPrint('Migration failed with error: $e');
      debugPrint('Stack trace: $stackTrace');

      return MigrationResult(
        success: false,
        totalProcessed: successCount + errorCount,
        successCount: successCount,
        errorCount: errorCount + 1,
        duration: DateTime.now().difference(startTime),
        message: 'Migration failed: $e',
        errors: [...errors, e.toString()],
      );
    }
  }

  /// Process a batch of content items
  Future<BatchResult> _processBatch(List<ContentWithGPS> items,
      {required bool dryRun}) async {
    int successCount = 0;
    int errorCount = 0;
    final errors = <String>[];

    for (final item in items) {
      try {
        // Extract location context
        final locationContext = await _locationService.getCachedOrExtract(
          latitude: item.latitude,
          longitude: item.longitude,
        );

        // Generate cultural vector with location
        final culturalVector =
            await _vectorService.generateCulturalVectorWithLocation(
          heritageDescription: item.creatorHeritage,
          communityAffiliations: item.creatorCommunities ?? [],
          generationalIdentity: item.creatorGeneration,
          culturalPractices: item.creatorPractices ?? [],
          culturalInterests: item.creatorInterests ?? [],
          regionalInfluence: null,
          locationContext: locationContext,
        );

        if (!dryRun) {
          // Store location context and vector in database
          await _database.storeLocationContext(
            contentId: item.id,
            locationContext: locationContext,
            culturalVector: culturalVector,
          );
        }

        successCount++;
      } catch (e) {
        errorCount++;
        errors.add('Failed to process ${item.id}: $e');
        debugPrint('Error processing ${item.id}: $e');
      }
    }

    return BatchResult(
      successCount: successCount,
      errorCount: errorCount,
      errors: errors,
    );
  }

  /// Fetch all content with GPS coordinates
  Future<List<ContentWithGPS>> _fetchContentWithCoordinates() async {
    return await _database.fetchContentWithGPS();
  }

  /// Discover location patterns from migrated data
  Future<void> _discoverLocationPatterns() async {
    // Fetch all user profiles with location data
    final userProfiles = await _database.fetchUserLocationProfiles();

    if (userProfiles.isEmpty) {
      debugPrint('No user profiles with location data found');
      return;
    }

    // Discover patterns
    final patterns = await _patternService.discoverLocationPatterns(
      allUsers: userProfiles,
    );

    debugPrint('Discovered ${patterns.length} location-based cultural patterns:');
    for (final pattern in patterns.take(10)) {
      debugPrint('  - ${pattern.location}: ${pattern.userCount} users, '
          'confidence: ${(pattern.confidence * 100).toStringAsFixed(1)}%');
      if (pattern.commonThemes.isNotEmpty) {
        debugPrint('    Themes: ${pattern.commonThemes.take(5).join(', ')}');
      }
    }
  }

  /// Generate migration report
  String _generateReport({
    required int totalProcessed,
    required int successCount,
    required int errorCount,
    required Duration duration,
    required List<String> errors,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('\n' + '=' * 60);
    buffer.writeln('GEOGRAPHIC CLASSIFICATION MIGRATION REPORT');
    buffer.writeln('=' * 60);
    buffer.writeln('Total items processed: $totalProcessed');
    buffer.writeln('Successful migrations: $successCount');
    buffer.writeln('Failed migrations: $errorCount');
    buffer.writeln(
        'Success rate: ${(successCount / totalProcessed * 100).toStringAsFixed(1)}%');
    buffer.writeln(
        'Duration: ${duration.inMinutes}m ${duration.inSeconds % 60}s');

    if (errors.isNotEmpty) {
      buffer.writeln('\nErrors (first 10):');
      for (final error in errors.take(10)) {
        buffer.writeln('  - $error');
      }
    }

    buffer.writeln('=' * 60);

    return buffer.toString();
  }

  /// Validate migration results
  Future<ValidationResult> validateMigration() async {
    debugPrint('Validating geographic classification migration...');

    final issues = <String>[];

    // Check 1: Verify location contexts exist
    final contentCount = await _database.getContentCount();
    final locationContextCount = await _database.getLocationContextCount();

    if (locationContextCount < contentCount * 0.8) {
      issues.add(
          'Only ${(locationContextCount / contentCount * 100).toStringAsFixed(1)}% '
          'of content has location context (expected >80%)');
    }

    // Check 2: Verify cultural vectors were generated
    final vectorCount = await _database.getCulturalVectorCount();

    if (vectorCount < locationContextCount * 0.9) {
      issues.add(
          'Only ${(vectorCount / locationContextCount * 100).toStringAsFixed(1)}% '
          'of location contexts have vectors (expected >90%)');
    }

    // Check 3: Verify patterns were discovered
    final patternCount = await _database.getLocationPatternCount();

    if (patternCount == 0) {
      issues.add('No location patterns discovered');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      stats: {
        'content_count': contentCount,
        'location_context_count': locationContextCount,
        'vector_count': vectorCount,
        'pattern_count': patternCount,
      },
    );
  }

  /// Rollback migration
  Future<RollbackResult> rollbackMigration() async {
    debugPrint('Rolling back geographic classification migration...');

    try {
      // Clear location contexts
      await _database.clearLocationContexts();

      // Clear discovered patterns
      await _database.clearLocationPatterns();

      // Clear cultural vectors
      await _database.clearCulturalVectors();

      return RollbackResult(
        success: true,
        message: 'Migration rolled back successfully',
      );
    } catch (e) {
      return RollbackResult(
        success: false,
        message: 'Rollback failed: $e',
      );
    }
  }
}

/// Database interface for migration
abstract class MigrationDatabase {
  Future<List<ContentWithGPS>> fetchContentWithGPS();
  Future<void> storeLocationContext({
    required String contentId,
    required LocationContext locationContext,
    required List<double> culturalVector,
  });
  Future<List<UserLocationProfile>> fetchUserLocationProfiles();
  Future<int> getContentCount();
  Future<int> getLocationContextCount();
  Future<int> getCulturalVectorCount();
  Future<int> getLocationPatternCount();
  Future<void> clearLocationContexts();
  Future<void> clearLocationPatterns();
  Future<void> clearCulturalVectors();
}

/// Content item with GPS coordinates
class ContentWithGPS {
  final String id;
  final double latitude;
  final double longitude;
  final String? creatorHeritage;
  final List<String>? creatorCommunities;
  final String? creatorGeneration;
  final List<String>? creatorPractices;
  final List<String>? creatorInterests;

  ContentWithGPS({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.creatorHeritage,
    this.creatorCommunities,
    this.creatorGeneration,
    this.creatorPractices,
    this.creatorInterests,
  });
}

/// Migration result
class MigrationResult {
  final bool success;
  final int totalProcessed;
  final int successCount;
  final int errorCount;
  final Duration duration;
  final String message;
  final List<String> errors;

  MigrationResult({
    required this.success,
    required this.totalProcessed,
    required this.successCount,
    required this.errorCount,
    required this.duration,
    required this.message,
    this.errors = const [],
  });
}

/// Batch processing result
class BatchResult {
  final int successCount;
  final int errorCount;
  final List<String> errors;

  BatchResult({
    required this.successCount,
    required this.errorCount,
    required this.errors,
  });
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> issues;
  final Map<String, dynamic> stats;

  ValidationResult({
    required this.isValid,
    required this.issues,
    this.stats = const {},
  });
}

/// Rollback result
class RollbackResult {
  final bool success;
  final String message;

  RollbackResult({
    required this.success,
    required this.message,
  });
}
