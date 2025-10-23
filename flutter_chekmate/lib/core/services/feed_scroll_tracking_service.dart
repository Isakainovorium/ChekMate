import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:flutter_chekmate/core/services/navigation_service.dart';

/// Feed Scroll Tracking Service
///
/// Tracks user scroll behavior in feeds and logs to analytics.
///
/// Features:
/// - Scroll depth tracking (percentage)
/// - Posts viewed count
/// - Automatic analytics logging
/// - Debounced logging (prevents spam)
///
/// Usage:
/// ```dart
/// // Attach to ScrollController
/// final scrollController = ScrollController();
/// FeedScrollTrackingService.instance.attachToScrollController(
///   scrollController: scrollController,
///   feedType: 'hybrid',
///   variant: 'control',
///   userId: currentUser.uid,
/// );
///
/// // Detach when done
/// FeedScrollTrackingService.instance.detach();
/// ```
///
/// Clean Architecture: Core Layer (Service)
class FeedScrollTrackingService {
  FeedScrollTrackingService._internal();

  static final FeedScrollTrackingService instance =
      FeedScrollTrackingService._internal();

  ScrollController? _scrollController;
  String? _feedType;
  String? _variant;
  String? _userId;
  int _postsViewed = 0;
  double _maxScrollDepth = 0.0;
  Timer? _debounceTimer;

  static const Duration _debounceDelay = Duration(seconds: 2);

  /// Attach to a scroll controller
  ///
  /// Parameters:
  /// - scrollController: ScrollController to track
  /// - feedType: Type of feed (hybrid, following, nearby, forYou)
  /// - variant: A/B test variant
  /// - userId: User's unique ID
  void attachToScrollController({
    required ScrollController scrollController,
    required String feedType,
    required String variant,
    required String userId,
  }) {
    // Detach from previous controller
    detach();

    _scrollController = scrollController;
    _feedType = feedType;
    _variant = variant;
    _userId = userId;
    _postsViewed = 0;
    _maxScrollDepth = 0.0;

    // Add scroll listener
    _scrollController!.addListener(_onScroll);

    developer.log(
      'Attached to scroll controller for $feedType feed (variant: $variant)',
      name: 'FeedScrollTrackingService',
    );
  }

  /// Detach from scroll controller
  void detach() {
    if (_scrollController != null) {
      _scrollController!.removeListener(_onScroll);
      _logScrollDepth(); // Log final scroll depth
    }

    _scrollController = null;
    _feedType = null;
    _variant = null;
    _userId = null;
    _postsViewed = 0;
    _maxScrollDepth = 0.0;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Increment posts viewed count
  ///
  /// Call this when a new post enters the viewport.
  void incrementPostsViewed() {
    _postsViewed++;
    developer.log(
      'Posts viewed: $_postsViewed',
      name: 'FeedScrollTrackingService',
    );
  }

  /// Handle scroll events
  void _onScroll() {
    if (_scrollController == null ||
        _feedType == null ||
        _variant == null ||
        _userId == null) {
      return;
    }

    // Calculate scroll depth percentage
    final scrollDepth = _calculateScrollDepth();

    // Update max scroll depth
    if (scrollDepth > _maxScrollDepth) {
      _maxScrollDepth = scrollDepth;

      // Debounce logging
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDelay, () {
        _logScrollDepth();
      });
    }
  }

  /// Calculate scroll depth percentage
  ///
  /// Returns a value between 0 and 100.
  double _calculateScrollDepth() {
    if (_scrollController == null || !_scrollController!.hasClients) {
      return 0.0;
    }

    final position = _scrollController!.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    if (maxScroll <= 0) {
      return 0.0;
    }

    final depth = (currentScroll / maxScroll) * 100;
    return depth.clamp(0.0, 100.0);
  }

  /// Log scroll depth to analytics
  void _logScrollDepth() {
    if (_feedType == null || _variant == null || _userId == null) {
      return;
    }

    final scrollDepth = _maxScrollDepth.round();

    AnalyticsService.instance.logFeedScrollDepth(
      feedType: _feedType!,
      variant: _variant!,
      userId: _userId!,
      scrollDepth: scrollDepth,
      postsViewed: _postsViewed,
    );

    developer.log(
      'Logged scroll depth: $scrollDepth% ($_postsViewed posts)',
      name: 'FeedScrollTrackingService',
    );
  }

  /// Get current scroll depth
  double get currentScrollDepth => _maxScrollDepth;

  /// Get posts viewed count
  int get postsViewed => _postsViewed;

  /// Check if tracking is active
  bool get isTracking => _scrollController != null;
}

