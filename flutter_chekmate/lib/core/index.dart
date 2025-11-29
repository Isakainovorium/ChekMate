/// Core Module Barrel Export
/// 
/// Provides centralized access to all core functionality.
/// Import this file instead of individual core files for cleaner imports.
/// 
/// Usage:
/// ```dart
/// import 'package:flutter_chekmate/core/index.dart';
/// ```
library core;

// Configuration
export 'config/environment_config.dart';

// Constants
export 'constants/app_constants.dart';

// Domain Entities
export 'domain/entities/location_entity.dart';

// Models
export 'models/user_model.dart';
export 'models/safety_report_model.dart';

// Navigation
export 'navigation/main_navigation.dart';
export 'navigation/nav_state.dart';

// Router
export 'router/app_router.dart';
export 'router/route_constants.dart';

// Theme
export 'theme/app_colors.dart';
export 'theme/app_spacing.dart';
export 'theme/app_theme.dart';
export 'theme/app_animations.dart';
export 'theme/app_breakpoints.dart';
