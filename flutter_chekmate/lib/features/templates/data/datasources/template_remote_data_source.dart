import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../models/story_template_model.dart';

/// Remote data source for story templates and user submissions
class TemplateRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  TemplateRemoteDataSource(this._firestore, this._uuid);

  // Collection references
  CollectionReference get _templates =>
      _firestore.collection('story_templates');
  CollectionReference get _submissions =>
      _firestore.collection('story_submissions');

  // ===== TEMPLATE OPERATIONS =====

  /// Get all available templates
  Future<List<StoryTemplate>> getAllTemplates({
    int limit = 50,
    int offset = 0,
    Map<String, dynamic>? filters,
  }) async {
    Query query = _templates
        .where('is_active', isEqualTo: true)
        .orderBy('usage_count', descending: true)
        .orderBy('created_at', descending: true);

    if (filters != null) {
      if (filters.containsKey('category')) {
        query = query.where('category', isEqualTo: filters['category']);
      }
      if (filters.containsKey('difficulty')) {
        query = query.where('difficulty', isEqualTo: filters['difficulty']);
      }
    }

    query = query.limit(limit);

    if (offset > 0) {
      // Note: Firestore doesn't support offset directly, this would need cursor-based pagination
      // For simplicity, using limit with startAfter if we had a document reference
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map(
            (doc) => StoryTemplate.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get popular templates
  Future<List<StoryTemplate>> getPopularTemplates({int limit = 20}) async {
    final snapshot = await _templates
        .where('is_active', isEqualTo: true)
        .orderBy('usage_count', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
            (doc) => StoryTemplate.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get trending templates (recent usage)
  Future<List<StoryTemplate>> getTrendingTemplates({int limit = 10}) async {
    // This would require additional tracking collection for analytics
    // For now, return recent templates
    final snapshot = await _templates
        .where('is_active', isEqualTo: true)
        .orderBy('updated_at', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
            (doc) => StoryTemplate.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get template by ID
  Future<StoryTemplate> getTemplateById(String templateId) async {
    final doc = await _templates.doc(templateId).get();
    if (!doc.exists) {
      throw Exception('Template not found');
    }
    return StoryTemplate.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Search templates
  Future<List<StoryTemplate>> searchTemplates({
    required String query,
    int limit = 20,
  }) async {
    // Note: Basic search - Firestore doesn't have full-text search
    // Would need to implement with Algolia or similar service for production
    final snapshot = await _templates
        .where('is_active', isEqualTo: true)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: '$query\uf8ff')
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
            (doc) => StoryTemplate.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Create new template
  Future<StoryTemplate> createTemplate(StoryTemplate template) async {
    final id = template.id.isEmpty ? _uuid.v4() : template.id;
    final now = DateTime.now();

    final templateData = StoryTemplate(
      id: id,
      title: template.title,
      description: template.description,
      category: template.category,
      icon: template.icon,
      color: template.color,
      difficulty: template.difficulty,
      estimatedMinutes: template.estimatedMinutes,
      sections: template.sections,
      version: template.version,
      isActive: template.isActive,
      coverImageUrl: template.coverImageUrl,
      tags: template.tags,
      usageCount: template.usageCount,
      averageRating: template.averageRating,
      createdBy: template.createdBy,
      createdAt: now,
      updatedAt: now,
      metadata: template.metadata,
    );

    await _templates.doc(templateData.id).set(templateData.toJson());
    return templateData;
  }

  /// Update template
  Future<StoryTemplate> updateTemplate(
      String templateId, StoryTemplate template) async {
    final updatedTemplate = StoryTemplate(
      id: templateId,
      title: template.title,
      description: template.description,
      category: template.category,
      icon: template.icon,
      color: template.color,
      difficulty: template.difficulty,
      estimatedMinutes: template.estimatedMinutes,
      sections: template.sections,
      version: template.version,
      isActive: template.isActive,
      coverImageUrl: template.coverImageUrl,
      tags: template.tags,
      usageCount: template.usageCount,
      averageRating: template.averageRating,
      createdBy: template.createdBy,
      createdAt: template.createdAt,
      updatedAt: DateTime.now(),
      metadata: template.metadata,
    );

    await _templates.doc(templateId).update(updatedTemplate.toJson());
    return updatedTemplate;
  }

  /// Update template usage count
  Future<void> incrementTemplateUsage(String templateId) async {
    await _templates.doc(templateId).update({
      'usage_count': FieldValue.increment(1),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ===== USER STORY SUBMISSIONS =====

  /// Submit user story
  Future<UserStorySubmission> submitUserStory(
      UserStorySubmission submission) async {
    final id = submission.id.isEmpty ? _uuid.v4() : submission.id;
    final now = DateTime.now();

    final submissionData = UserStorySubmission(
      id: id,
      templateId: submission.templateId,
      userId: submission.userId,
      responses: submission.responses,
      title: submission.title,
      summary: submission.summary,
      tags: submission.tags,
      privacy: submission.privacy,
      isCompleted: submission.isCompleted,
      createdAt: now,
      updatedAt: submission.updatedAt,
      completedAt: submission.completedAt,
      metadata: submission.metadata,
    );

    await _submissions.doc(submissionData.id).set(submissionData.toJson());

    // Increment template usage count
    await incrementTemplateUsage(submission.templateId);

    return submissionData;
  }

  /// Get user submissions
  Future<List<UserStorySubmission>> getUserSubmissions({
    required String userId,
    int limit = 20,
    int offset = 0,
    String? templateId,
    bool? completedOnly,
  }) async {
    Query query = _submissions
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true);

    if (templateId != null) {
      query = query.where('template_id', isEqualTo: templateId);
    }

    if (completedOnly == true) {
      query = query.where('is_completed', isEqualTo: true);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) =>
            UserStorySubmission.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get submission by ID
  Future<UserStorySubmission> getSubmissionById(String submissionId) async {
    final doc = await _submissions.doc(submissionId).get();
    if (!doc.exists) {
      throw Exception('Submission not found');
    }
    return UserStorySubmission.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Update submission
  Future<UserStorySubmission> updateSubmission(
    String submissionId,
    UserStorySubmission submission,
  ) async {
    await _submissions.doc(submissionId).update(submission.toJson());
    return submission;
  }

  /// Get public submissions for template
  Future<List<UserStorySubmission>> getPublicSubmissions({
    required String templateId,
    int limit = 10,
  }) async {
    final snapshot = await _submissions
        .where('template_id', isEqualTo: templateId)
        .where('privacy', isEqualTo: 'public')
        .where('is_completed', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) =>
            UserStorySubmission.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ===== ANALYTICS AND STATISTICS =====

  /// Get template statistics
  Future<Map<String, dynamic>> getTemplateStatistics(String templateId) async {
    final template = await getTemplateById(templateId);
    final submissions =
        await getPublicSubmissions(templateId: templateId, limit: 1000);

    return {
      'template': template.toJson(),
      'totalSubmissions': submissions.length,
      'completedStories': submissions.where((s) => s.isCompleted).length,
      'usageCount': template.usageCount,
      'lastUpdated': template.updatedAt?.toIso8601String(),
    };
  }

  /// Preload popular templates for offline use
  Future<List<StoryTemplate>> preloadPopularTemplates() async {
    return await getPopularTemplates(limit: 20);
  }
}
