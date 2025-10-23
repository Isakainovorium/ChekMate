import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/data/services/storage_service.dart';
import 'package:flutter_chekmate/core/services/ab_testing_service.dart';
import 'package:flutter_chekmate/core/services/auth_service.dart';
import 'package:flutter_chekmate/core/services/feed_scroll_tracking_service.dart';
import 'package:flutter_chekmate/core/services/navigation_service.dart';
import 'package:flutter_chekmate/core/services/session_tracking_service.dart';
import 'package:flutter_chekmate/core/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service Providers
/// Singleton providers for Firebase services

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// User Service Provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// A/B Testing Service Provider
final abTestingServiceProvider = Provider<ABTestingService>((ref) {
  return ABTestingService(
    firestore: FirebaseFirestore.instance,
  );
});

/// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService.instance;
});

/// Session Tracking Service Provider
final sessionTrackingServiceProvider = Provider<SessionTrackingService>((ref) {
  return SessionTrackingService.instance;
});

/// Feed Scroll Tracking Service Provider
final feedScrollTrackingServiceProvider =
    Provider<FeedScrollTrackingService>((ref) {
  return FeedScrollTrackingService.instance;
});
