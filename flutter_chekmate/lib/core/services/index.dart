/// Core Services Barrel Export
/// 
/// Provides centralized access to all core services.
/// 
/// Usage:
/// ```dart
/// import 'package:flutter_chekmate/core/services/index.dart';
/// ```
library core_services;

// App Services
export 'app_info_service.dart';
export 'auth_service.dart';
export 'content_generation_service.dart';
export 'fcm_service.dart';
export 'file_picker_service.dart';
export 'gamification_service.dart';
export 'http_client_service.dart';
export 'keyboard_shortcuts_service.dart';
export 'location_service.dart';
export 'pattern_recognition_service.dart';
export 'permission_service.dart';
export 'push_notification_service.dart';
export 'telemetry_service.dart';
export 'template_engine_service.dart';
export 'url_launcher_service.dart';
export 'web_image_picker_service.dart';
export 'web_storage_service.dart';

// Cultural Services (exported individually to avoid naming conflicts)
// Use: import 'package:flutter_chekmate/core/services/cultural/[service].dart';
// Available services:
// - cultural_context_service.dart
// - cultural_fingerprint_service.dart
// - cultural_intelligence_service.dart
// - cultural_matching_router.dart
// - cultural_migration_service.dart
// - cultural_pattern_discovery_service.dart
// - cultural_profile_adapter.dart
// - cultural_vector_service.dart
// - location_context_service.dart
// - location_pattern_service.dart
// - regional_analytics_service.dart
// - translation_service.dart
