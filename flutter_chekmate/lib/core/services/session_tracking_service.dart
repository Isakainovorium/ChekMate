import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_chekmate/core/services/navigation_service.dart';

/// Session Tracking Service
///
/// Tracks user session duration and automatically logs to analytics.
///
/// Features:
/// - Automatic session start/end tracking
/// - Session duration calculation
/// - Analytics integration
/// - App lifecycle awareness
///
/// Usage:
/// ```dart
/// // Start session
/// SessionTrackingService.instance.startSession(
///   userId: currentUser.uid,
///   variant: 'control',
/// );
///
/// // End session (automatic on app close)
/// SessionTrackingService.instance.endSession();
/// ```
///
/// Clean Architecture: Core Layer (Service)
class SessionTrackingService {
  SessionTrackingService._internal();

  static final SessionTrackingService instance = SessionTrackingService._internal();

  DateTime? _sessionStartTime;
  String? _userId;
  String? _variant;
  Timer? _periodicTimer;

  /// Start a new session
  ///
  /// Parameters:
  /// - userId: User's unique ID
  /// - variant: A/B test variant
  void startSession({
    required String userId,
    required String variant,
  }) {
    // End previous session if exists
    if (_sessionStartTime != null) {
      endSession();
    }

    _sessionStartTime = DateTime.now();
    _userId = userId;
    _variant = variant;

    developer.log(
      'Session started for user $userId (variant: $variant)',
      name: 'SessionTrackingService',
    );

    // Start periodic logging (every 5 minutes)
    _startPeriodicLogging();
  }

  /// End the current session
  ///
  /// Logs the session duration to analytics.
  void endSession() {
    if (_sessionStartTime == null || _userId == null || _variant == null) {
      return;
    }

    final duration = DateTime.now().difference(_sessionStartTime!);
    final durationSeconds = duration.inSeconds;

    // Log to analytics
    AnalyticsService.instance.logSessionDuration(
      variant: _variant!,
      userId: _userId!,
      durationSeconds: durationSeconds,
    );

    developer.log(
      'Session ended for user $_userId (duration: ${durationSeconds}s)',
      name: 'SessionTrackingService',
    );

    // Clean up
    _sessionStartTime = null;
    _userId = null;
    _variant = null;
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Get current session duration in seconds
  ///
  /// Returns null if no active session.
  int? getCurrentSessionDuration() {
    if (_sessionStartTime == null) {
      return null;
    }

    final duration = DateTime.now().difference(_sessionStartTime!);
    return duration.inSeconds;
  }

  /// Start periodic logging
  ///
  /// Logs session duration every 5 minutes to track long sessions.
  void _startPeriodicLogging() {
    _periodicTimer?.cancel();

    _periodicTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) {
        if (_sessionStartTime != null && _userId != null && _variant != null) {
          final duration = DateTime.now().difference(_sessionStartTime!);
          final durationSeconds = duration.inSeconds;

          developer.log(
            'Periodic session log: ${durationSeconds}s',
            name: 'SessionTrackingService',
          );

          // Log intermediate session duration
          AnalyticsService.instance.logSessionDuration(
            variant: _variant!,
            userId: _userId!,
            durationSeconds: durationSeconds,
          );
        }
      },
    );
  }

  /// Check if session is active
  bool get isSessionActive => _sessionStartTime != null;

  /// Get current user ID
  String? get currentUserId => _userId;

  /// Get current variant
  String? get currentVariant => _variant;
}

