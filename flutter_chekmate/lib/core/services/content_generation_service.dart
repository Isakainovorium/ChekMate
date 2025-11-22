import '../../features/templates/models/story_template_model.dart';
import 'template_engine_service.dart';

/// Service for converting template responses into post content
class ContentGenerationService {
  static final ContentGenerationService _instance =
      ContentGenerationService._internal();
  static ContentGenerationService get instance => _instance;

  ContentGenerationService._internal();

  /// Generate post content from template responses
  Future<String> generatePostContent({
    required StoryTemplate template,
    required List<TemplateResponse> responses,
    bool includeMetadata = true,
  }) async {
    final renderedStory = await TemplateEngineService.instance.renderStoryTemplate(
      template: template,
      responses: responses,
    );

    if (!includeMetadata) {
      return renderedStory;
    }

    // Add template metadata to the content
    final buffer = StringBuffer();
    buffer.writeln('**${template.title}**');
    buffer.writeln();
    buffer.writeln(renderedStory);
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('*Created using ChekMate Story Template*');

    return buffer.toString();
  }

  /// Generate a summary from template responses
  Future<String> generateSummary({
    required StoryTemplate template,
    required List<TemplateResponse> responses,
    int maxLength = 280, // Twitter-like length
  }) async {
    final responseMap = _createResponseMap(responses);
    final summaryParts = <String>[];

    // Extract key responses to create summary
    for (final section in template.sections) {
      final response = responseMap[section.id];
      if (response != null && response is String && response.isNotEmpty) {
        summaryParts.add(response);
        if (summaryParts.join(' ').length > maxLength) {
          break;
        }
      }
    }

    var summary = summaryParts.join(' ').trim();

    // Truncate if needed
    if (summary.length > maxLength) {
      summary = summary.substring(0, maxLength - 3) + '...';
    }

    return summary;
  }

  /// Generate tags from template responses
  Future<List<String>> generateTags({
    required StoryTemplate template,
    required List<TemplateResponse> responses,
  }) async {
    final tags = <String>{};

    // Add template category as tag
    tags.add(template.category.toARGB32());

    // Add template tags
    tags.addAll(template.tags);

    // Extract tags from text responses
    final responseMap = _createResponseMap(responses);
    for (final section in template.sections) {
      final response = responseMap[section.id];
      if (response is String) {
        final extractedTags = _extractHashtags(response);
        tags.addAll(extractedTags);
      }
    }

    return tags.toList();
  }

  /// Validate generated content
  Future<ContentValidationResult> validateGeneratedContent({
    required String content,
    required List<String> tags,
    int minContentLength = 50,
    int maxContentLength = 5000,
    int maxTags = 30,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    // Check content length
    if (content.isEmpty) {
      errors.add('Content cannot be empty');
    } else if (content.length < minContentLength) {
      warnings.add(
        'Content is quite short (${content.length} characters). Consider adding more details.',
      );
    } else if (content.length > maxContentLength) {
      errors.add(
        'Content exceeds maximum length ($maxContentLength characters). Please shorten it.',
      );
    }

    // Check tags
    if (tags.isEmpty) {
      warnings.add('No tags provided. Adding tags helps with discoverability.');
    } else if (tags.length > maxTags) {
      errors.add('Too many tags (${tags.length}). Maximum is $maxTags.');
    }

    // Check for spam patterns
    if (_containsSpamPatterns(content)) {
      errors.add('Content appears to contain spam or inappropriate patterns.');
    }

    // Check for excessive repetition
    if (_hasExcessiveRepetition(content)) {
      warnings.add('Content has excessive repetition. Consider varying your language.');
    }

    return ContentValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      contentLength: content.length,
      tagCount: tags.length,
    );
  }

  /// Format content for different platforms
  Future<Map<String, String>> formatContentForPlatforms({
    required String content,
    required List<String> tags,
  }) async {
    final formatted = <String, String>{};

    // Standard format
    formatted['standard'] = content;

    // Twitter format (280 chars max)
    final twitterContent = _truncateToLength(content, 280 - tags.length * 3);
    formatted['twitter'] = '$twitterContent ${tags.take(3).join(' ')}';

    // Instagram format (with line breaks)
    formatted['instagram'] = _formatForInstagram(content, tags);

    // LinkedIn format (professional)
    formatted['linkedin'] = _formatForLinkedIn(content, tags);

    return formatted;
  }

  /// Generate metadata for the post
  Future<Map<String, dynamic>> generatePostMetadata({
    required StoryTemplate template,
    required List<TemplateResponse> responses,
    required String userId,
  }) async {
    final wordCount = _calculateWordCount(
      await TemplateEngineService.instance.renderStoryTemplate(
        template: template,
        responses: responses,
      ),
    );

    return {
      'templateId': template.id,
      'templateTitle': template.title,
      'templateCategory': template.category.value,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
      'wordCount': wordCount,
      'estimatedReadTime': _calculateReadTime(wordCount),
      'difficulty': template.difficulty,
      'sections': template.sections.length,
      'completedSections': responses.length,
    };
  }

  // ===== PRIVATE HELPER METHODS =====

  Map<String, dynamic> _createResponseMap(List<TemplateResponse> responses) {
    final map = <String, dynamic>{};
    for (final response in responses) {
      map[response.sectionId] = response.response;
    }
    return map;
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#\w+');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(0)!.substring(1)).toList();
  }

  bool _containsSpamPatterns(String content) {
    // Check for common spam patterns
    final spamPatterns = [
      RegExp(r'(?:click|buy|order|now|limited|offer|deal|free|win|prize)',
          caseSensitive: false),
      RegExp(r'(?:http|https|www)\S+', caseSensitive: false),
      RegExp(r'(?:\$\d+|\d+\$)', caseSensitive: false),
    ];

    int spamScore = 0;
    for (final pattern in spamPatterns) {
      spamScore += pattern.allMatches(content).length;
    }

    // If more than 3 spam patterns found, consider it spam
    return spamScore > 3;
  }

  bool _hasExcessiveRepetition(String content) {
    final words = content.toLowerCase().split(RegExp(r'\s+'));
    final wordFrequency = <String, int>{};

    for (final word in words) {
      if (word.length > 3) {
        wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
      }
    }

    // Check if any word appears more than 20% of the time
    final totalWords = words.length;
    for (final count in wordFrequency.values) {
      if (count / totalWords > 0.2) {
        return true;
      }
    }

    return false;
  }

  String _truncateToLength(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 3) + '...';
  }

  String _formatForInstagram(String content, List<String> tags) {
    final lines = content.split('\n');
    final formatted = lines.join('\n\n');
    final tagString = tags.take(10).map((t) => '#$t').join(' ');
    return '$formatted\n\n$tagString';
  }

  String _formatForLinkedIn(String content, List<String> tags) {
    final buffer = StringBuffer();
    buffer.writeln('📝 Story');
    buffer.writeln();
    buffer.writeln(content);
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln(tags.take(5).map((t) => '#$t').join(' '));
    return buffer.toString();
  }

  int _calculateWordCount(String content) {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  String _calculateReadTime(int wordCount) {
    // Average reading speed is 200 words per minute
    final minutes = (wordCount / 200).ceil();
    if (minutes < 1) return 'Less than 1 min read';
    if (minutes == 1) return '1 min read';
    return '$minutes min read';
  }
}

/// Result of content validation
class ContentValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int contentLength;
  final int tagCount;

  const ContentValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.contentLength,
    required this.tagCount,
  });
}
