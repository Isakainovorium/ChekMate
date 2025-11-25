import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/premade_templates.dart';
import '../../models/story_template_model.dart';
import 'template_card.dart';

/// Bottom sheet for selecting story templates during post creation
class TemplateSelectorSheet extends ConsumerStatefulWidget {
  final Function(StoryTemplate)? onTemplateSelected;

  const TemplateSelectorSheet({
    super.key,
    this.onTemplateSelected,
  });

  @override
  ConsumerState<TemplateSelectorSheet> createState() =>
      _TemplateSelectorSheetState();
}

class _TemplateSelectorSheetState extends ConsumerState<TemplateSelectorSheet> {
  StoryTemplate? _selectedTemplate;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Safety',
    'Growth',
    'Success',
    'Relationships',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTemplates = _getFilteredTemplates();

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header with drag handle
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Choose a Story Template',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      'Templates guide your storytelling with structured prompts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Category filter chips
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: isSelected
                            ? const Color(0xFFF5A623).withValues(alpha: 0.1)
                            : Colors.grey[100],
                        selectedColor:
                            const Color(0xFFF5A623).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFFF5A623),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFFF5A623)
                              : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Templates grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = filteredTemplates[index];
                    final isSelected = _selectedTemplate?.id == template.id;

                    return TemplateCard(
                      template: template,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedTemplate = template;
                        });

                        // Auto-select after brief delay to show selection
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (!mounted) return;
                          if (widget.onTemplateSelected != null) {
                            widget.onTemplateSelected!(template);
                            Navigator.of(context).pop(template);
                          }
                        });
                      },
                    );
                  },
                ),
              ),

              // Bottom action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Skip template selection - return null
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Skip Template'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedTemplate != null
                            ? () {
                                if (widget.onTemplateSelected != null) {
                                  widget
                                      .onTemplateSelected!(_selectedTemplate!);
                                }
                                Navigator.of(context).pop(_selectedTemplate);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFF5A623), // Golden orange
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _selectedTemplate != null
                              ? 'Use Template'
                              : 'Select Template',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<StoryTemplate> _getFilteredTemplates() {
    final allTemplates = PremadeTemplates.getAllTemplates();

    if (_selectedCategory == 'All') {
      return allTemplates;
    }

    // Map category names to template categories
    final categoryMapping = {
      'Safety': [StoryTemplateCategory.firstDate],
      'Growth': [
        StoryTemplateCategory.patternRecognition,
        StoryTemplateCategory.breakupRecovery
      ],
      'Success': [StoryTemplateCategory.successStories],
      'Relationships': [
        StoryTemplateCategory.longDistance,
        StoryTemplateCategory.onlineDating,
        StoryTemplateCategory.ghostingRecovery,
      ],
    };

    final mappedCategories = categoryMapping[_selectedCategory] ?? [];
    return allTemplates
        .where((template) => mappedCategories.contains(template.category))
        .toList();
  }
}
