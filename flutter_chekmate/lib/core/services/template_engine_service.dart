
import '../../features/templates/models/story_template_model.dart';

/// Service for dynamic template rendering and form processing
class TemplateEngineService {
  static final TemplateEngineService _instance =
      TemplateEngineService._internal();
  static TemplateEngineService get instance => _instance;

  TemplateEngineService._internal();

  /// Renders a template with user responses to create a story
  Future<String> renderStoryTemplate({
    required StoryTemplate template,
    required List<TemplateResponse> responses,
  }) async {
    final Map<String, dynamic> responseMap = _createResponseMap(responses);

    String renderedContent = '';
    int sectionIndex = 1;

    for (final section in template.sections) {
      final sectionContent = _renderSection(
        section,
        responseMap,
        sectionIndex++,
      );

      if (sectionContent.isNotEmpty) {
        renderedContent += '$sectionContent\n\n';
      }
    }

    return renderedContent.trim();
  }

  /// Validates template responses before submission
  ValidationResult validateTemplateResponses({
    required StoryTemplate template,
    required List<TemplateResponse> responses,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check required fields
    for (final section in template.sections) {
      if (section.required) {
        final response = responses.firstWhere(
          (r) => r.sectionId == section.id,
          orElse: () => TemplateResponse(
            sectionId: '',
            response: null,
            timestamp: DateTime.now(), // Fallback timestamp
          ),
        );

        if (response.response == null ||
            (response.response is String &&
                (response.response as String).isEmpty) ||
            (response.response is List &&
                (response.response as List).isEmpty)) {
          errors.add('${section.title} is required');
        }
      }
    }

    // Check conditional logic
    for (final section in template.sections) {
      if (section.conditionalDisplay != null) {
        final displayLogic = section.conditionalDisplay!;
        final dependsOnResponse = responses.firstWhere(
          (r) => r.sectionId == displayLogic.dependsOn,
          orElse: () => TemplateResponse(
            sectionId: '',
            response: null,
            timestamp: DateTime.now(), // Fallback timestamp
          ),
        );

        if (!_evaluateConditionalLogic(
            displayLogic, dependsOnResponse.response)) {
          // Section should be hidden, remove its response if present
          responses.removeWhere((r) => r.sectionId == section.id);
        }
      }
    }

    // Add validation warnings for specific section types
    for (final section in template.sections) {
      final response = responses.firstWhere(
        (r) => r.sectionId == section.id,
        orElse: () => TemplateResponse(
          sectionId: '',
          response: null,
          timestamp: DateTime.now(), // Fallback timestamp
        ),
      );

      if (response.response != null) {
        final warning = _validateSectionResponse(section, response.response);
        if (warning != null) {
          warnings.add(warning);
        }
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Generates a preview of how the story will look
  Future<String> generateStoryPreview({
    required StoryTemplate template,
    required List<TemplateResponse> responses,
  }) async {
    try {
      final renderedContent = await renderStoryTemplate(
        template: template,
        responses: responses,
      );

      return _formatStoryPreview(
        template: template,
        content: renderedContent,
      );
    } catch (e) {
      return 'Preview unavailable: ${e.toString()}';
    }
  }

  /// Exports story data in various formats
  Future<Map<String, dynamic>> exportStoryData({
    required StoryTemplate template,
    required UserStorySubmission submission,
  }) async {
    final Map<String, dynamic> exportData = {
      'template': template.toJson(),
      'submission': submission.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
      'formatVersion': '1.0',
    };

    // Generate formatted story content
    final renderedContent = await renderStoryTemplate(
      template: template,
      responses: submission.responses,
    );

    exportData['renderedContent'] = renderedContent;
    exportData['wordCount'] = _calculateWordCount(renderedContent);
    exportData['characterCount'] = renderedContent.length;

    return exportData;
  }

  /// Calculates template completion percentage
  double calculateCompletionPercentage({
    required StoryTemplate template,
    required List<TemplateResponse> responses,
  }) {
    if (template.sections.isEmpty) return 1.0;

    int totalRequiredSections = 0;
    int completedRequiredSections = 0;

    for (final section in template.sections) {
      if (section.required) {
        totalRequiredSections++;
        final hasResponse = responses.any((r) => r.sectionId == section.id);
        if (hasResponse) {
          completedRequiredSections++;
        }
      }
    }

    return totalRequiredSections == 0
        ? 1.0
        : completedRequiredSections / totalRequiredSections;
  }

  /// Generates recommendations for next sections to fill
  List<String> getRecommendedSections({
    required StoryTemplate template,
    required List<TemplateResponse> responses,
  }) {
    final recommendations = <String>[];

    for (final section in template.sections) {
      if (section.required) {
        final hasResponse = responses.any((r) => r.sectionId == section.id);
        if (!hasResponse) {
          recommendations.add(section.id);
        }
      }
    }

    return recommendations.take(3).toList(); // Return top 3 recommendations
  }

  // Private helper methods

  Map<String, dynamic> _createResponseMap(List<TemplateResponse> responses) {
    final map = <String, dynamic>{};
    for (final response in responses) {
      map[response.sectionId] = response.response;
    }
    return map;
  }

  String _renderSection(
    StoryTemplateSection section,
    Map<String, dynamic> responseMap,
    int sectionIndex,
  ) {
    final response = responseMap[section.id];

    // Skip section if conditional display is not met
    if (section.conditionalDisplay != null) {
      final displayLogic = section.conditionalDisplay!;
      final dependsOnResponse = responseMap[displayLogic.dependsOn];

      if (!_evaluateConditionalLogic(displayLogic, dependsOnResponse)) {
        return '';
      }
    }

    if (response == null) return '';

    return _formatSectionContent(section, response, sectionIndex);
  }

  bool _evaluateConditionalLogic(ConditionalDisplay logic, dynamic response) {
    switch (logic.condition) {
      case 'equals':
        return response == logic.value;
      case 'not_equals':
        return response != logic.value;
      case 'contains':
        if (response is String && logic.value is String) {
          return response.contains(logic.value);
        }
        return false;
      case 'greater_than':
        if (response is num && logic.value is num) {
          return response > logic.value;
        }
        return false;
      case 'less_than':
        if (response is num && logic.value is num) {
          return response < logic.value;
        }
        return false;
      default:
        return false;
    }
  }

  String _formatSectionContent(
    StoryTemplateSection section,
    dynamic response,
    int sectionIndex,
  ) {
    final buffer = StringBuffer();

    // Format based on section type
    switch (section.type) {
      case StoryTemplateSectionType.textInput:
        buffer.write('**${section.title}**\n');
        buffer.write(response.toString());
        break;

      case StoryTemplateSectionType.rating:
        buffer.write('**${section.title}**\n');
        final ratingValue = response as num?;
        if (ratingValue != null && section.ratingScale != null) {
          final scale = section.ratingScale!;
          buffer.write('$ratingValue/${scale.max}');
          // Add label if available
          if (scale.labels != null &&
              scale.labels!.containsKey(ratingValue.toString())) {
            buffer.write(' (${scale.labels![ratingValue.toString()]})');
          }
        }
        break;

      case StoryTemplateSectionType.multipleChoice:
        buffer.write('**${section.title}**\n');
        if (response is List) {
          buffer.write(response.join(', '));
        } else {
          buffer.write(response.toString());
        }
        break;

      case StoryTemplateSectionType.yesNo:
        buffer.write('**${section.title}**\n');
        buffer.write(response == true ? 'Yes' : 'No');
        break;

      case StoryTemplateSectionType.datePicker:
        buffer.write('**${section.title}**\n');
        if (response is DateTime) {
          buffer.write(_formatDate(response));
        } else {
          buffer.write(response.toString());
        }
        break;
    }

    return buffer.toString();
  }

  String _formatStoryPreview({
    required StoryTemplate template,
    required String content,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('# ${template.title}');
    buffer.writeln('\n*${template.description}*');
    buffer.writeln('\n---\n');
    buffer.writeln(content);
    buffer.writeln('\n---\n');
    buffer.writeln('*Generated on ${DateTime.now().toString()}*');

    return buffer.toString();
  }

  String? _validateSectionResponse(
      StoryTemplateSection section, dynamic response) {
    switch (section.type) {
      case StoryTemplateSectionType.rating:
        if (section.ratingScale != null) {
          final scale = section.ratingScale!;
          final rating = response as num?;
          if (rating != null && (rating < scale.min || rating > scale.max)) {
            return '${section.title} must be between ${scale.min} and ${scale.max}';
          }
        }
        break;

      case StoryTemplateSectionType.textInput:
        if (response is String) {
          if (section.placeholder?.contains('email') == true &&
              response.isNotEmpty) {
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
            if (!emailRegex.hasMatch(response)) {
              return '${section.title} must be a valid email address';
            }
          }
        }
        break;

      default:
        break;
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  int _calculateWordCount(String content) {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }
}

/// Validation result for template responses
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
}
