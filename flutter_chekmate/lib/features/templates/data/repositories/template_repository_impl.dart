import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/template_repository.dart';
import '../../models/story_template_model.dart';
import '../datasources/template_remote_data_source.dart';

/// Implementation of TemplateRepository
class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateRemoteDataSource _remoteDataSource;

  TemplateRepositoryImpl({
    required TemplateRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<StoryTemplate>> getAllTemplates({
    int limit = 50,
    int offset = 0,
    String? category,
    String? difficulty,
    List<String>? tags,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (category != null) filters['category'] = category;
      if (difficulty != null) filters['difficulty'] = difficulty;

      final templates = await _remoteDataSource.getAllTemplates(
        limit: limit,
        filters: filters,
      );

      // Sort by usage count and creation date
      templates.sort((a, b) {
        final usageCompare = b.usageCount.compareTo(a.usageCount);
        if (usageCompare != 0) return usageCompare;
        return b.createdAt.compareTo(a.createdAt);
      });

      return templates;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  @override
  Future<List<StoryTemplate>> getPopularTemplates({int limit = 20}) async {
    try {
      return await _remoteDataSource.getPopularTemplates(limit: limit);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<StoryTemplate>> getTrendingTemplates({
    int limit = 10,
    Duration? timeWindow,
  }) async {
    try {
      return await _remoteDataSource.getTrendingTemplates(limit: limit);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<StoryTemplate>> getTemplatesByAuthor({
    required String authorId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final allTemplates = await _remoteDataSource.getAllTemplates(limit: 1000);
      final authorTemplates = allTemplates
          .where((template) => template.createdBy == authorId)
          .take(limit)
          .toList();
      return authorTemplates;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<StoryTemplate> getTemplateById({required String templateId}) async {
    return await _remoteDataSource.getTemplateById(templateId);
  }

  @override
  Future<List<StoryTemplate>> searchTemplates({
    required String query,
    int limit = 20,
    int offset = 0,
    String? category,
    String? difficulty,
  }) async {
    try {
      return await _remoteDataSource.searchTemplates(
        query: query,
        limit: limit,
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<StoryTemplate> createTemplate({
    required StoryTemplate template,
  }) async {
    return await _remoteDataSource.createTemplate(template);
  }

  @override
  Future<StoryTemplate> updateTemplate({
    required String templateId,
    required StoryTemplate template,
  }) async {
    return await _remoteDataSource.updateTemplate(
      templateId,
      template,
    );
  }

  @override
  Future<void> deleteTemplate({required String templateId}) async {
    // Note: Remote data source doesn't have delete yet
    // return await _remoteDataSource.deleteTemplate(templateId);
  }

  @override
  Future<List<StoryTemplate>> getRecommendedTemplates({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // For now, return popular templates
      // Future implementation could use user behavior analytics
      return await getPopularTemplates(limit: limit);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> trackTemplateUsage({
    required String templateId,
    required String userId,
    String? action,
  }) async {
    try {
      await _remoteDataSource.incrementTemplateUsage(templateId);
    } catch (e) {
      // Fail silently for tracking
    }
  }

  @override
  Future<UserStorySubmission> submitUserStory({
    required UserStorySubmission submission,
  }) async {
    return await _remoteDataSource.submitUserStory(submission);
  }

  @override
  Future<List<UserStorySubmission>> getUserSubmissions({
    required String userId,
    int limit = 20,
    int offset = 0,
    String? templateId,
    bool? completedOnly,
  }) async {
    return await _remoteDataSource.getUserSubmissions(
      userId: userId,
      limit: limit,
      templateId: templateId,
      completedOnly: completedOnly,
    );
  }

  @override
  Future<UserStorySubmission> getSubmissionById({
    required String submissionId,
  }) async {
    return await _remoteDataSource.getSubmissionById(submissionId);
  }

  @override
  Future<UserStorySubmission> updateSubmission({
    required String submissionId,
    required UserStorySubmission submission,
  }) async {
    return await _remoteDataSource.updateSubmission(
      submissionId,
      submission,
    );
  }

  @override
  Future<void> deleteSubmission({required String submissionId}) async {
    // Note: Remote data source doesn't have delete yet
    // return await _remoteDataSource.deleteSubmission(submissionId);
  }

  @override
  Future<List<UserStorySubmission>> getPublicSubmissions({
    required String templateId,
    int limit = 10,
    int offset = 0,
  }) async {
    return await _remoteDataSource.getPublicSubmissions(
      templateId: templateId,
      limit: limit,
    );
  }

  @override
  Future<List<UserStorySubmission>> getFeaturedSubmissions({
    int limit = 5,
  }) async {
    try {
      // Get featured stories from all templates
      // For now, get recent public submissions
      const tempOne = 'first_date_red_flags';
      const tempTwo = 'ghosting_recovery';
      const tempThree = 'success_stories';

      final submissions = <UserStorySubmission>[];

      // Get submissions from each template
      final submissions1 = await getPublicSubmissions(
        templateId: tempOne,
        limit: (limit / 3).ceil(),
      );
      final submissions2 = await getPublicSubmissions(
        templateId: tempTwo,
        limit: (limit / 3).ceil(),
      );
      final submissions3 = await getPublicSubmissions(
        templateId: tempThree,
        limit: (limit / 3).ceil(),
      );

      submissions.addAll(submissions1);
      submissions.addAll(submissions2);
      submissions.addAll(submissions3);

      // Sort by creation date and take limit
      submissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return submissions.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getTemplateStatistics({
    required String templateId,
  }) async {
    return await _remoteDataSource.getTemplateStatistics(templateId);
  }

  @override
  Future<Map<String, dynamic>> getUserTemplateStatistics({
    required String userId,
  }) async {
    try {
      final submissions = await getUserSubmissions(userId: userId);
      final completedCount = submissions.where((s) => s.isCompleted).length;

      return {
        'totalStoriesCreated': submissions.length,
        'completedStories': completedCount,
        'completionRate': submissions.isNotEmpty
            ? (completedCount / submissions.length) * 100
            : 0.0,
        'favoriteCategories': _getFavoriteCategories(submissions),
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> preloadPopularTemplates() async {
    try {
      await _remoteDataSource.preloadPopularTemplates();
    } catch (e) {
      // Fail silently
    }
  }

  @override
  Future<List<String>> syncOfflineSubmissions() async {
    // Not implemented yet
    return [];
  }

  @override
  Future<Either<Exception, Unit>> clearTemplateCache() async {
    try {
      // TODO: implement local cache clear via remote/local datastore
      return const Right(unit);
    } catch (e) {
      return Left(e is Exception ? e : Exception(e.toString()));
    }
  }

  List<String> _getFavoriteCategories(List<UserStorySubmission> submissions) {
    final categoryCount = <String, int>{};

    for (final submission in submissions) {
      // We would need to get template details to know the category
      // For now, return empty or placeholder
      final templateId = submission.templateId;
      categoryCount.update(templateId, (value) => value + 1, ifAbsent: () => 1);
    }

    if (categoryCount.isEmpty) {
      return [];
    }

    final sortedEntries = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(3).map((e) => e.key).toList();
  }
}

/// Provider for TemplateRepository
final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final uuid = ref.watch(uuidProvider);

  return TemplateRepositoryImpl(
    remoteDataSource: TemplateRemoteDataSource(
      firestore,
      uuid,
    ),
  );
});

/// Note: These providers are imported/injected as dependencies
final firestoreProvider = Provider((ref) => throw UnimplementedError());
final uuidProvider = Provider((ref) => throw UnimplementedError());
