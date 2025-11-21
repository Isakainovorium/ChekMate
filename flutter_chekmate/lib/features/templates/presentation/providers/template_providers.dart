import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/providers.dart';
import '../../../../core/services/template_engine_service.dart';
import '../../data/datasources/template_remote_data_source.dart';
import '../../data/repositories/template_repository_impl.dart';
import '../../domain/repositories/template_repository.dart';
import '../../models/story_template_model.dart';
import '../../data/premade_templates.dart';

// ===== REPOSITORY PROVIDERS =====

/// Provider for TemplateRemoteDataSource
final templateRemoteDataSourceProvider =
    Provider<TemplateRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return TemplateRemoteDataSource(firestore, const Uuid());
});

/// Provider for TemplateRepository
final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  final remoteDataSource = ref.watch(templateRemoteDataSourceProvider);
  return TemplateRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

// ===== TEMPLATE LISTING PROVIDERS =====

/// Get all available templates
final allTemplatesProvider = FutureProvider<List<StoryTemplate>>((ref) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getAllTemplates();
});

/// Get popular templates
final popularTemplatesProvider =
    FutureProvider<List<StoryTemplate>>((ref) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getPopularTemplates(limit: 20);
});

/// Get trending templates
final trendingTemplatesProvider =
    FutureProvider<List<StoryTemplate>>((ref) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getTrendingTemplates(limit: 10);
});

/// Get templates by category
final templatesByCategoryProvider =
    FutureProvider.family<List<StoryTemplate>, String>((ref, category) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getAllTemplates(category: category);
});

/// Get template by ID
final templateByIdProvider =
    FutureProvider.family<StoryTemplate, String>((ref, templateId) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getTemplateById(templateId: templateId);
});

/// Search templates
final searchTemplatesProvider =
    FutureProvider.family<List<StoryTemplate>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repository = ref.watch(templateRepositoryProvider);
  return repository.searchTemplates(query: query);
});

// ===== TEMPLATE SELECTION STATE =====

/// State notifier for selected template during post creation
class SelectedTemplateNotifier extends StateNotifier<StoryTemplate?> {
  SelectedTemplateNotifier() : super(null);

  void selectTemplate(StoryTemplate template) {
    state = template;
  }

  void clearSelection() {
    state = null;
  }
}

final selectedTemplateProvider =
    StateNotifierProvider<SelectedTemplateNotifier, StoryTemplate?>((ref) {
  return SelectedTemplateNotifier();
});

// ===== TEMPLATE RESPONSES STATE =====

/// State notifier for template responses during form filling
class TemplateResponsesNotifier extends StateNotifier<List<TemplateResponse>> {
  TemplateResponsesNotifier() : super([]);

  void addResponse(TemplateResponse response) {
    final existingIndex =
        state.indexWhere((r) => r.sectionId == response.sectionId);
    if (existingIndex >= 0) {
      // Update existing response
      final updatedList = [...state];
      updatedList[existingIndex] = response;
      state = updatedList;
    } else {
      // Add new response
      state = [...state, response];
    }
  }

  void removeResponse(String sectionId) {
    state = state.where((r) => r.sectionId != sectionId).toList();
  }

  void clearResponses() {
    state = [];
  }

  List<TemplateResponse> getResponses() => state;
}

final templateResponsesProvider =
    StateNotifierProvider<TemplateResponsesNotifier, List<TemplateResponse>>(
        (ref) {
  return TemplateResponsesNotifier();
});

// ===== TEMPLATE VALIDATION =====

/// Validate template responses
final validateTemplateResponsesProvider =
    Provider.family<ValidationResult, (StoryTemplate, List<TemplateResponse>)>(
        (ref, params) {
  final (template, responses) = params;
  return TemplateEngineService.instance.validateTemplateResponses(
    template: template,
    responses: responses,
  );
});

/// Calculate template completion percentage
final templateCompletionProvider =
    Provider.family<double, (StoryTemplate, List<TemplateResponse>)>(
        (ref, params) {
  final (template, responses) = params;
  return TemplateEngineService.instance.calculateCompletionPercentage(
    template: template,
    responses: responses,
  );
});

/// Get recommended sections to fill
final recommendedSectionsProvider =
    Provider.family<List<String>, (StoryTemplate, List<TemplateResponse>)>(
        (ref, params) {
  final (template, responses) = params;
  return TemplateEngineService.instance.getRecommendedSections(
    template: template,
    responses: responses,
  );
});

// ===== TEMPLATE RENDERING =====

/// Render story from template and responses
final renderStoryProvider =
    FutureProvider.family<String, (StoryTemplate, List<TemplateResponse>)>(
        (ref, params) async {
  final (template, responses) = params;
  return TemplateEngineService.instance.renderStoryTemplate(
    template: template,
    responses: responses,
  );
});

/// Generate story preview
final storyPreviewProvider =
    FutureProvider.family<String, (StoryTemplate, List<TemplateResponse>)>(
        (ref, params) async {
  final (template, responses) = params;
  return TemplateEngineService.instance.generateStoryPreview(
    template: template,
    responses: responses,
  );
});

// ===== USER SUBMISSIONS =====

/// Get user's template submissions
final userSubmissionsProvider =
    FutureProvider.family<List<UserStorySubmission>, String>(
        (ref, userId) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getUserSubmissions(userId: userId);
});

/// Get completed submissions only
final completedSubmissionsProvider =
    FutureProvider.family<List<UserStorySubmission>, String>(
        (ref, userId) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getUserSubmissions(userId: userId, completedOnly: true);
});

/// Get public submissions for a template
final publicSubmissionsProvider =
    FutureProvider.family<List<UserStorySubmission>, String>(
        (ref, templateId) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getPublicSubmissions(templateId: templateId);
});

/// Get featured submissions
final featuredSubmissionsProvider =
    FutureProvider<List<UserStorySubmission>>((ref) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getFeaturedSubmissions();
});

// ===== SUBMISSION STATE =====

/// State notifier for creating/editing a submission
class SubmissionNotifier extends StateNotifier<UserStorySubmission?> {
  final TemplateRepository _repository;

  SubmissionNotifier(this._repository) : super(null);

  Future<void> createSubmission({
    required String templateId,
    required String userId,
    required String title,
    required String summary,
    required List<TemplateResponse> responses,
    List<String> tags = const [],
    String privacy = 'friends',
  }) async {
    final submission = UserStorySubmission(
      id: const Uuid().v4(),
      templateId: templateId,
      userId: userId,
      responses: responses,
      title: title,
      summary: summary,
      tags: tags,
      privacy: privacy,
      isCompleted: true,
      createdAt: DateTime.now(),
    );

    final created = await _repository.submitUserStory(submission: submission);
    state = created;
  }

  Future<void> updateSubmission({
    required String submissionId,
    required UserStorySubmission submission,
  }) async {
    final updated = await _repository.updateSubmission(
      submissionId: submissionId,
      submission: submission,
    );
    state = updated;
  }

  void clearSubmission() {
    state = null;
  }
}

final submissionNotifierProvider =
    StateNotifierProvider<SubmissionNotifier, UserStorySubmission?>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return SubmissionNotifier(repository);
});

// ===== TEMPLATE STATISTICS =====

/// Get statistics for a template
final templateStatisticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, templateId) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getTemplateStatistics(templateId: templateId);
});

/// Get user's template statistics
final userTemplateStatisticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.getUserTemplateStatistics(userId: userId);
});

// ===== PREMADE TEMPLATES (LOCAL) =====

/// Get all premade templates (local, no Firebase needed)
final premadeTemplatesProvider = Provider<List<StoryTemplate>>((ref) {
  return PremadeTemplates.getAllTemplates();
});

/// Get premade template by ID
final premadeTemplateByIdProvider =
    Provider.family<StoryTemplate?, String>((ref, templateId) {
  try {
    return PremadeTemplates.getTemplateById(templateId);
  } catch (e) {
    return null;
  }
});

// ValidationResult class is defined in TemplateEngineService.dart
