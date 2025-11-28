/// Features Module Barrel Export
/// 
/// Provides centralized access to all feature modules.
/// Each feature follows Clean Architecture with data/domain/presentation layers.
/// 
/// Usage:
/// ```dart
/// import 'package:flutter_chekmate/features/index.dart';
/// ```
library features;

// Auth Feature
export 'auth/presentation/providers/auth_providers.dart';

// Feed Feature
export 'feed/models/post_model.dart';
export 'feed/widgets/post_widget.dart';

// Messages Feature
export 'messages/domain/entities/conversation_entity.dart';
export 'messages/domain/entities/message_entity.dart';
export 'messages/presentation/providers/messages_providers.dart';

// Notifications Feature
export 'notifications/domain/entities/notification_entity.dart';
export 'notifications/data/repositories/notifications_repository.dart';
export 'notifications/presentation/providers/notifications_providers.dart';

// Onboarding Feature
export 'onboarding/presentation/providers/onboarding_provider.dart';

// Posts Feature
export 'posts/domain/entities/post_entity.dart';

// Profile Feature
export 'profile/domain/entities/profile_entity.dart';

// Stories Feature
export 'stories/domain/entities/story_entity.dart';

// Search Feature
export 'search/domain/entities/search_result_entity.dart';
