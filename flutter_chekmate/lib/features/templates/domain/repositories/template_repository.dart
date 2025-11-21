import 'package:dartz/dartz.dart';

import '../../models/story_template_model.dart';
import '../../models/guide_model.dart';

/// Repository for managing story templates and user submissions
abstract class TemplateRepository {
  // ===== TEMPLATE OPERATIONS =====

  /// Get all available templates
  Future<List<StoryTemplate>> getAllTemplates({
    int limit = 50,
    int offset = 0,
    String? category,
    String? difficulty,
    List<String>? tags,
  });

  /// Get popular templates by usage count
  Future<List<StoryTemplate>> getPopularTemplates({
    int limit = 20,
  });

  /// Get trending templates by recent usage
  Future<List<StoryTemplate>> getTrendingTemplates({
    int limit = 10,
    Duration? timeWindow,
  });

  /// Get templates by author/user
  Future<List<StoryTemplate>> getTemplatesByAuthor({
    required String authorId,
    int limit = 20,
    int offset = 0,
  });

  /// Get template by ID
  Future<StoryTemplate> getTemplateById({
    required String templateId,
  });

  /// Search templates by query
  Future<List<StoryTemplate>> searchTemplates({
    required String query,
    int limit = 20,
    int offset = 0,
    String? category,
    String? difficulty,
  });

  /// Create new template (community feature)
  Future<StoryTemplate> createTemplate({
    required StoryTemplate template,
  });

  /// Update template (only by author)
  Future<StoryTemplate> updateTemplate({
    required String templateId,
    required StoryTemplate template,
  });

  /// Delete template (only by author/admin)
  Future<void> deleteTemplate({
    required String templateId,
  });

  /// Get recommended templates for user
  Future<List<StoryTemplate>> getRecommendedTemplates({
    required String userId,
    int limit = 10,
  });

  /// Track template usage analytics
  Future<void> trackTemplateUsage({
    required String templateId,
    required String userId,
    String? action, // 'viewed', 'started', 'completed', 'shared'
  });

  // ===== USER STORY SUBMISSION OPERATIONS =====

  /// Submit user story (template completion)
  Future<UserStorySubmission> submitUserStory({
    required UserStorySubmission submission,
  });

  /// Get user submissions
  Future<List<UserStorySubmission>> getUserSubmissions({
    required String userId,
    int limit = 20,
    int offset = 0,
    String? templateId,
    bool? completedOnly,
  });

  /// Get submission by ID
  Future<UserStorySubmission> getSubmissionById({
    required String submissionId,
  });

  /// Update submission (partial updates, like completion)
  Future<UserStorySubmission> updateSubmission({
    required String submissionId,
    required UserStorySubmission submission,
  });

  /// Delete submission
  Future<void> deleteSubmission({
    required String submissionId,
  });

  /// Get public submissions for template (featured stories)
  Future<List<UserStorySubmission>> getPublicSubmissions({
    required String templateId,
    int limit = 10,
    int offset = 0,
  });

  /// Get featured/submission of the week
  Future<List<UserStorySubmission>> getFeaturedSubmissions({
    int limit = 5,
  });

  // ===== TEMPLATE STATISTICS =====

  /// Get template usage statistics
  Future<Map<String, dynamic>> getTemplateStatistics({
    required String templateId,
  });

  /// Get overall user statistics
  Future<Map<String, dynamic>> getUserTemplateStatistics({
    required String userId,
  });

  // ===== CACHING OPERATIONS =====

  /// Preload popular templates for offline use
  Future<void> preloadPopularTemplates();

  /// Sync offline submissions when online
  Future<List<String>> syncOfflineSubmissions();

  /// Clear template cache
  Future<Either<Exception, Unit>> clearTemplateCache();
}
