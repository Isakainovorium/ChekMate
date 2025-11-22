import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/story_template_model.dart';
import '../providers/template_providers.dart';

/// Full-screen guided form for filling out a story template
class TemplateGuidedForm extends ConsumerStatefulWidget {
  final StoryTemplate template;
  final Function(List<TemplateResponse>)? onComplete;
  final Function()? onCancel;

  const TemplateGuidedForm({
    super.key,
    required this.template,
    this.onComplete,
    this.onCancel,
  });

  @override
  ConsumerState<TemplateGuidedForm> createState() => _TemplateGuidedFormState();
}

class _TemplateGuidedFormState extends ConsumerState<TemplateGuidedForm> {
  late PageController _pageController;
  int _currentSectionIndex = 0;
  final Map<String, dynamic> _sectionResponses = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextSection() {
    if (_currentSectionIndex < widget.template.sections.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeForm();
    }
  }

  void _previousSection() {
    if (_currentSectionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeForm() {
    // Convert responses to TemplateResponse objects
    final responses = <TemplateResponse>[];
    _sectionResponses.forEach((sectionId, response) {
      responses.add(
        TemplateResponse(
          sectionId: sectionId,
          response: response,
          timestamp: DateTime.now(),
        ),
      );
    });

    // Update provider
    for (final response in responses) {
      ref.read(templateResponsesProvider.notifier).addResponse(response);
    }

    // Call callback
    if (widget.onComplete != null) {
      widget.onComplete!(responses);
    }

    // Navigate back
    Navigator.of(context).pop(responses);
  }

  void _updateResponse(String sectionId, dynamic value) {
    setState(() {
      _sectionResponses[sectionId] = value;
    });
  }

  double _getCompletionPercentage() {
    if (widget.template.sections.isEmpty) return 0;
    final requiredSections =
        widget.template.sections.where((s) => s.required).length;
    final completedRequired = _sectionResponses.entries.where((e) {
      final section = _findSectionById(e.key);
      return (section?.required ?? false) && e.value != null;
    }).length;
    return requiredSections > 0 ? completedRequired / requiredSections : 0;
  }

  @override
  Widget build(BuildContext context) {
    final completionPercentage = _getCompletionPercentage();
    final isLastSection =
        _currentSectionIndex == widget.template.sections.length - 1;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop) {
        widget.onCancel?.call();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel!();
              }
              Navigator.of(context).pop();
            },
          ),
          title: Text(widget.template.title),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '${_currentSectionIndex + 1}/${widget.template.sections.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value:
                  (_currentSectionIndex + 1) / widget.template.sections.length,
              minHeight: 4,
            ),

            // Completion percentage
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${(completionPercentage * 100).toStringAsFixed(0)}% Complete',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // Form sections
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentSectionIndex = index;
                  });
                },
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.template.sections.length,
                itemBuilder: (context, index) {
                  final section = widget.template.sections[index];
                  return _buildSectionWidget(section);
                },
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _currentSectionIndex > 0 ? _previousSection : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextSection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5A623),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isLastSection ? 'Complete' : 'Next',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWidget(StoryTemplateSection section) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            section.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),

          if (section.description != null) ...[
            const SizedBox(height: 8),
            Text(
              section.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],

          const SizedBox(height: 24),

          // Section input based on type
          _buildSectionInput(section),

          if (section.helpText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      section.helpText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[600],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Required indicator
          if (section.required)
            Text(
              '* Required field',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionInput(StoryTemplateSection section) {
    final currentValue = _sectionResponses[section.id];

    switch (section.type) {
      case StoryTemplateSectionType.textInput:
        return TextFormField(
          decoration: InputDecoration(
            hintText: section.placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 5,
          onChanged: (value) => _updateResponse(section.id, value),
          initialValue: currentValue as String? ?? '',
        );

      case StoryTemplateSectionType.rating:
        final scale = section.ratingScale ?? const RatingScale();
        return Column(
          children: [
            Slider(
              value: (currentValue as num?)?.toDouble() ?? scale.min.toDouble(),
              min: scale.min.toDouble(),
              max: scale.max.toDouble(),
              divisions: ((scale.max - scale.min) / scale.step).toInt(),
              label: currentValue?.toString() ?? scale.min.toString(),
              onChanged: (value) => _updateResponse(section.id, value.toInt()),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (scale.labels != null &&
                    scale.labels!.containsKey(scale.min.toString()))
                  Text(
                    scale.labels![scale.min.toString()]!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(
                  currentValue?.toString() ?? scale.min.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF5A623),
                      ),
                ),
                if (scale.labels != null &&
                    scale.labels!.containsKey(scale.max.toString()))
                  Text(
                    scale.labels![scale.max.toString()]!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        );

      case StoryTemplateSectionType.multipleChoice:
        final options = section.options ?? [];
        final selectedOptions = (currentValue as List<String>?) ?? [];

        return Column(
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  final newSelection = [...selectedOptions];
                  if (isSelected) {
                    newSelection.remove(option);
                  } else {
                    newSelection.add(option);
                  }
                  _updateResponse(section.id, newSelection);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF5A623)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? const Color(0xFFF5A623).withValues(alpha: 0.05)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFF5A623)
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: isSelected
                              ? const Color(0xFFF5A623)
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );

      case StoryTemplateSectionType.yesNo:
        final isYes = currentValue as bool?;
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _updateResponse(section.id, true),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isYes == true
                      ? const Color(0xFFF5A623).withValues(alpha: 0.1)
                      : Colors.transparent,
                  side: BorderSide(
                    color: isYes == true
                        ? const Color(0xFFF5A623)
                        : Colors.grey[300]!,
                    width: isYes == true ? 2 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: isYes == true
                        ? const Color(0xFFF5A623)
                        : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _updateResponse(section.id, false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isYes == false
                      ? const Color(0xFFF5A623).withValues(alpha: 0.1)
                      : Colors.transparent,
                  side: BorderSide(
                    color: isYes == false
                        ? const Color(0xFFF5A623)
                        : Colors.grey[300]!,
                    width: isYes == false ? 2 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'No',
                  style: TextStyle(
                    color: isYes == false
                        ? const Color(0xFFF5A623)
                        : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );

      case StoryTemplateSectionType.datePicker:
        final selectedDate = currentValue as DateTime?;
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              _updateResponse(section.id, picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(selectedDate)
                      : 'Select a date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selectedDate != null
                            ? Colors.black
                            : Colors.grey[500],
                      ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        );
    }
  }

  StoryTemplateSection? _findSectionById(String id) {
    for (final section in widget.template.sections) {
      if (section.id == id) {
        return section;
      }
    }
    return null;
  }
}
