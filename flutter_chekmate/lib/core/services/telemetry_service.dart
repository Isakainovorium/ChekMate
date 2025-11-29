import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Telemetry Service
///
/// Centralized service for tracking app performance, user interactions,
/// and errors. Integrates with Firebase Analytics for production monitoring.
///
/// Usage:
/// ```dart
/// final telemetry = TelemetryService.instance;
/// telemetry.trackScreenView('HomePage');
/// telemetry.trackInteraction('like_post', {'post_id': '123'});
/// ```
///
/// Sprint 3 - Task 3.5.1
/// Date: November 28, 2025

class TelemetryService {
  TelemetryService._();

  static final TelemetryService instance = TelemetryService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Whether telemetry is enabled
  bool _isEnabled = true;

  /// Enable or disable telemetry
  set isEnabled(bool value) => _isEnabled = value;

  // ============================================================
  // SCREEN TRACKING
  // ============================================================

  /// Track screen view
  Future<void> trackScreenView(String screenName, {String? screenClass}) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      _debugLog('Screen view: $screenName');
    } catch (e) {
      _debugLog('Failed to track screen view: $e');
    }
  }

  /// Track screen render time
  Future<void> trackScreenRender(String screenName, Duration renderTime) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'screen_render',
        parameters: {
          'screen_name': screenName,
          'render_time_ms': renderTime.inMilliseconds,
          'is_slow': renderTime.inMilliseconds > 500,
        },
      );
      _debugLog('Screen render: $screenName (${renderTime.inMilliseconds}ms)');
    } catch (e) {
      _debugLog('Failed to track screen render: $e');
    }
  }

  // ============================================================
  // USER INTERACTION TRACKING
  // ============================================================

  /// Track user interaction
  Future<void> trackInteraction(
    String action, [
    Map<String, dynamic>? parameters,
  ]) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'user_interaction',
        parameters: {
          'action': action,
          ...?parameters,
        },
      );
      _debugLog('Interaction: $action');
    } catch (e) {
      _debugLog('Failed to track interaction: $e');
    }
  }

  /// Track interaction latency
  Future<void> trackInteractionLatency(
    String action,
    Duration latency,
  ) async {
    if (!_isEnabled) return;

    // Only log slow interactions (>100ms)
    if (latency.inMilliseconds < 100) return;

    try {
      await _analytics.logEvent(
        name: 'slow_interaction',
        parameters: {
          'action': action,
          'latency_ms': latency.inMilliseconds,
        },
      );
      _debugLog('Slow interaction: $action (${latency.inMilliseconds}ms)');
    } catch (e) {
      _debugLog('Failed to track interaction latency: $e');
    }
  }

  /// Track button tap
  Future<void> trackButtonTap(String buttonName, {String? screen}) async {
    await trackInteraction('button_tap', {
      'button_name': buttonName,
      if (screen != null) 'screen': screen,
    });
  }

  // ============================================================
  // FEATURE-SPECIFIC TRACKING
  // ============================================================

  /// Track post interaction (like, comment, share, chek, bookmark)
  Future<void> trackPostInteraction(
    String interactionType,
    String postId, {
    bool? isActive,
  }) async {
    await trackInteraction('post_$interactionType', {
      'post_id': postId,
      if (isActive != null) 'is_active': isActive,
    });
  }

  /// Track date rating (WOW, GTFOH, ChekMate)
  Future<void> trackDateRating(String ratingType, String dateId) async {
    try {
      await _analytics.logEvent(
        name: 'date_rated',
        parameters: {
          'rating_type': ratingType,
          'date_id': dateId,
        },
      );
      _debugLog('Date rated: $ratingType');
    } catch (e) {
      _debugLog('Failed to track date rating: $e');
    }
  }

  /// Track experience shared
  Future<void> trackExperienceShared({
    required bool hasMedia,
    required bool hasLocation,
    String? experienceType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'experience_shared',
        parameters: {
          'has_media': hasMedia,
          'has_location': hasLocation,
          if (experienceType != null) 'experience_type': experienceType,
        },
      );
      _debugLog('Experience shared');
    } catch (e) {
      _debugLog('Failed to track experience shared: $e');
    }
  }

  /// Track feed scroll depth
  Future<void> trackFeedScrollDepth(String feedType, int itemsViewed) async {
    // Only track at certain thresholds
    if (itemsViewed % 10 != 0) return;

    await trackInteraction('feed_scroll_depth', {
      'feed_type': feedType,
      'items_viewed': itemsViewed,
    });
  }

  // ============================================================
  // PERFORMANCE TRACKING
  // ============================================================

  /// Track frame drop
  Future<void> trackFrameDrop(int droppedFrames) async {
    if (!_isEnabled) return;

    // Only log significant frame drops
    if (droppedFrames < 3) return;

    try {
      await _analytics.logEvent(
        name: 'frame_drop',
        parameters: {
          'dropped_frames': droppedFrames,
          'severity': droppedFrames > 10 ? 'high' : 'medium',
        },
      );
      _debugLog('Frame drop: $droppedFrames frames');
    } catch (e) {
      _debugLog('Failed to track frame drop: $e');
    }
  }

  /// Track app startup time
  Future<void> trackAppStartup(Duration startupTime) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'app_startup',
        parameters: {
          'startup_time_ms': startupTime.inMilliseconds,
          'is_slow': startupTime.inMilliseconds > 3000,
        },
      );
      _debugLog('App startup: ${startupTime.inMilliseconds}ms');
    } catch (e) {
      _debugLog('Failed to track app startup: $e');
    }
  }

  /// Track network request
  Future<void> trackNetworkRequest(
    String endpoint,
    Duration duration, {
    bool success = true,
    int? statusCode,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'network_request',
        parameters: {
          'endpoint': endpoint,
          'duration_ms': duration.inMilliseconds,
          'success': success,
          if (statusCode != null) 'status_code': statusCode,
        },
      );
    } catch (e) {
      _debugLog('Failed to track network request: $e');
    }
  }

  // ============================================================
  // ERROR TRACKING
  // ============================================================

  /// Track error
  Future<void> trackError(
    String context,
    Object error, {
    StackTrace? stackTrace,
    bool fatal = false,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'context': context,
          'error_type': error.runtimeType.toString(),
          'error_message': error.toString().substring(
                0,
                error.toString().length.clamp(0, 100),
              ),
          'fatal': fatal,
        },
      );
      _debugLog('Error in $context: $error');
    } catch (e) {
      _debugLog('Failed to track error: $e');
    }
  }

  // ============================================================
  // USER PROPERTIES
  // ============================================================

  /// Set user property
  Future<void> setUserProperty(String name, String? value) async {
    if (!_isEnabled) return;

    try {
      await _analytics.setUserProperty(name: name, value: value);
      _debugLog('User property set: $name = $value');
    } catch (e) {
      _debugLog('Failed to set user property: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    if (!_isEnabled) return;

    try {
      await _analytics.setUserId(id: userId);
      _debugLog('User ID set: $userId');
    } catch (e) {
      _debugLog('Failed to set user ID: $e');
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[Telemetry] $message');
    }
  }
}

/// Mixin to add telemetry tracking to widgets
mixin TelemetryMixin {
  TelemetryService get telemetry => TelemetryService.instance;

  /// Track screen view on widget init
  void trackScreen(String screenName) {
    telemetry.trackScreenView(screenName);
  }

  /// Track button tap
  void trackTap(String buttonName, {String? screen}) {
    telemetry.trackButtonTap(buttonName, screen: screen);
  }
}

/// Helper to measure and track execution time
class TelemetryTimer {
  TelemetryTimer(this._name);

  final String _name;
  final Stopwatch _stopwatch = Stopwatch();

  void start() => _stopwatch.start();

  Future<void> stop() async {
    _stopwatch.stop();
    await TelemetryService.instance.trackInteractionLatency(
      _name,
      _stopwatch.elapsed,
    );
  }

  Duration get elapsed => _stopwatch.elapsed;
}
