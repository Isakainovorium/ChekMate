import 'package:hive/hive.dart';

import '../../models/story_template_model.dart';

/// Abstract interface for local template data source
abstract class TemplateLocalDataSource {
  Future<List<StoryTemplate>> getCachedTemplates();
  Future<void> cacheTemplates(List<StoryTemplate> templates);
  Future<StoryTemplate?> getCachedTemplate(String templateId);
  Future<void> cacheTemplate(StoryTemplate template);
  Future<void> clearAllTemplates();
}

/// Local implementation using Hive for template caching
class TemplateLocalDataSourceImpl implements TemplateLocalDataSource {
  static const String _templatesBoxName = 'templates';
  static const String _templatesListKey = 'all_templates';

  late Box _templatesBox;

  Future<void> initialize() async {
    _templatesBox = await Hive.openBox(_templatesBoxName);
  }

  @override
  Future<List<StoryTemplate>> getCachedTemplates() async {
    final templatesJson = _templatesBox.get(_templatesListKey);
    if (templatesJson == null) return [];

    try {
      final templates = (templatesJson as List)
          .map((json) => StoryTemplate.fromJson(json))
          .toList();

      // Filter out expired/invalid templates (cache for 24 hours)
      final now = DateTime.now();
      final validTemplates = templates.where((template) {
        if (template.createdAt == null) return false;
        final cacheAge = now.difference(template.createdAt!);
        return cacheAge.inHours < 24;
      }).toList();

      return validTemplates;
    } catch (e) {
      // If deserialization fails, clear cache and return empty
      await clearAllTemplates();
      return [];
    }
  }

  @override
  Future<void> cacheTemplates(List<StoryTemplate> templates) async {
    final templatesJson = templates.map((t) => t.toJson()).toList();
    await _templatesBox.put(_templatesListKey, templatesJson);
  }

  @override
  Future<StoryTemplate?> getCachedTemplate(String templateId) async {
    final templateJson = _templatesBox.get(templateId);
    if (templateJson == null) return null;

    try {
      final template = StoryTemplate.fromJson(templateJson);

      // Check if template is still fresh (24 hours)
      if (template.createdAt == null) return null;

      final cacheAge = DateTime.now().difference(template.createdAt!);
      if (cacheAge.inHours >= 24) {
        // Remove expired cache entry
        await _templatesBox.delete(templateId);
        return null;
      }

      return template;
    } catch (e) {
      // Remove corrupted cache entry
      await _templatesBox.delete(templateId);
      return null;
    }
  }

  @override
  Future<void> cacheTemplate(StoryTemplate template) async {
    await _templatesBox.put(template.id, template.toJson());
  }

  @override
  Future<void> clearAllTemplates() async {
    await _templatesBox.clear();
  }
}
