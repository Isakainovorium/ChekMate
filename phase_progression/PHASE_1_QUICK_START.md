# Phase 1: Quick Start Guide for Developers

## 🚀 Getting Started with Templates

### How to Use Templates in Your Code

#### 1. Access Pre-made Templates
```dart
import 'package:flutter_chekmate/features/templates/data/premade_templates.dart';

// Get all templates
final templates = PremadeTemplates.getAllTemplates();

// Get specific template
final template = PremadeTemplates.getTemplateById('first_date_red_flags');
```

#### 2. Use Template Providers
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chekmate/features/templates/presentation/providers/template_providers.dart';

// In a ConsumerWidget
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Get all templates
  final templates = ref.watch(allTemplatesProvider);
  
  // Get popular templates
  final popular = ref.watch(popularTemplatesProvider);
  
  // Get template by ID
  final template = ref.watch(templateByIdProvider('first_date_red_flags'));
  
  return templates.when(
    data: (templates) => ListView(
      children: templates.map((t) => TemplateCard(template: t)).toList(),
    ),
    loading: () => CircularProgressIndicator(),
    error: (err, stack) => Text('Error: $err'),
  );
}
```

#### 3. Open Template Selector
```dart
import 'package:flutter_chekmate/features/templates/presentation/widgets/template_selector_sheet.dart';

// Show template selector
final selectedTemplate = await showModalBottomSheet<StoryTemplate>(
  context: context,
  isScrollControlled: true,
  builder: (context) => TemplateSelectorSheet(
    onTemplateSelected: (template) {
      print('Selected: ${template.title}');
    },
  ),
);
```

#### 4. Open Guided Form
```dart
import 'package:flutter_chekmate/features/templates/presentation/widgets/template_guided_form.dart';

// Show guided form
final responses = await Navigator.of(context).push<List<TemplateResponse>>(
  MaterialPageRoute(
    builder: (context) => TemplateGuidedForm(
      template: template,
      onComplete: (responses) {
        print('Completed with ${responses.length} responses');
      },
    ),
  ),
);
```

#### 5. Generate Content from Responses
```dart
import 'package:flutter_chekmate/core/services/content_generation_service.dart';

// Generate post content
final content = await ContentGenerationService.instance.generatePostContent(
  template: template,
  responses: responses,
  includeMetadata: true,
);

// Generate tags
final tags = await ContentGenerationService.instance.generateTags(
  template: template,
  responses: responses,
);

// Generate summary
final summary = await ContentGenerationService.instance.generateSummary(
  template: template,
  responses: responses,
  maxLength: 280,
);

// Validate content
final validation = await ContentGenerationService.instance.validateGeneratedContent(
  content: content,
  tags: tags,
);

if (validation.isValid) {
  print('Content is valid!');
} else {
  print('Errors: ${validation.errors}');
  print('Warnings: ${validation.warnings}');
}
```

#### 6. Render Template to Story
```dart
import 'package:flutter_chekmate/core/services/template_engine_service.dart';

// Render story from responses
final story = await TemplateEngineService.instance.renderStoryTemplate(
  template: template,
  responses: responses,
);

// Generate preview
final preview = await TemplateEngineService.instance.generateStoryPreview(
  template: template,
  responses: responses,
);

// Validate responses
final validation = TemplateEngineService.instance.validateTemplateResponses(
  template: template,
  responses: responses,
);

// Calculate completion
final completion = TemplateEngineService.instance.calculateCompletionPercentage(
  template: template,
  responses: responses,
);

print('Completion: ${(completion * 100).toStringAsFixed(0)}%');
```

---

## 📁 File Structure

```
lib/
├── features/templates/
│   ├── models/
│   │   ├── story_template_model.dart
│   │   └── guide_model.dart
│   ├── domain/repositories/
│   │   ├── template_repository.dart
│   │   └── guide_repository.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   └── template_remote_data_source.dart
│   │   ├── repositories/
│   │   │   └── template_repository_impl.dart
│   │   └── premade_templates.dart
│   └── presentation/
│       ├── providers/
│       │   └── template_providers.dart
│       └── widgets/
│           ├── template_card.dart
│           ├── template_selector_sheet.dart
│           └── template_guided_form.dart
├── core/services/
│   ├── template_engine_service.dart
│   └── content_generation_service.dart
└── pages/create_post/
    └── create_post_page.dart
```

---

## 🎯 Common Tasks

### Task 1: Display All Templates
```dart
final templates = ref.watch(allTemplatesProvider);

templates.when(
  data: (templates) => GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    itemCount: templates.length,
    itemBuilder: (context, index) => TemplateCard(
      template: templates[index],
      onTap: () => _selectTemplate(templates[index]),
    ),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

### Task 2: Create a Post from Template
```dart
// 1. Select template
final template = await _showTemplateSelector();

// 2. Fill form
final responses = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TemplateGuidedForm(template: template),
  ),
);

// 3. Generate content
final content = await ContentGenerationService.instance.generatePostContent(
  template: template,
  responses: responses,
);

// 4. Create post
await postsNotifier.createPost(
  content: content,
  tags: await ContentGenerationService.instance.generateTags(
    template: template,
    responses: responses,
  ),
);
```

### Task 3: Track Template Usage
```dart
// After user completes template
final repository = ref.read(templateRepositoryProvider);
await repository.trackTemplateUsage(
  templateId: template.id,
  userId: currentUser.uid,
  action: 'completed',
);
```

### Task 4: Get User's Submissions
```dart
final submissions = ref.watch(userSubmissionsProvider(userId));

submissions.when(
  data: (submissions) => ListView(
    children: submissions.map((s) => ListTile(
      title: Text(s.title),
      subtitle: Text(s.summary),
    )).toList(),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

---

## 🔍 Debugging Tips

### Check Template Structure
```dart
final template = PremadeTemplates.getTemplateById('first_date_red_flags');
print('Template: ${template.title}');
print('Sections: ${template.sections.length}');
for (final section in template.sections) {
  print('  - ${section.title} (${section.type.displayName})');
}
```

### Validate Responses
```dart
final validation = TemplateEngineService.instance.validateTemplateResponses(
  template: template,
  responses: responses,
);

if (!validation.isValid) {
  print('Errors:');
  for (final error in validation.errors) {
    print('  - $error');
  }
}

if (validation.warnings.isNotEmpty) {
  print('Warnings:');
  for (final warning in validation.warnings) {
    print('  - $warning');
  }
}
```

### Preview Generated Content
```dart
final preview = await TemplateEngineService.instance.generateStoryPreview(
  template: template,
  responses: responses,
);
print(preview);
```

---

## 🧪 Testing Examples

### Test Template Selection
```dart
testWidgets('User can select template', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap template button
  await tester.tap(find.byIcon(Icons.description));
  await tester.pumpAndSettle();
  
  // Verify sheet appears
  expect(find.byType(TemplateSelectorSheet), findsOneWidget);
  
  // Tap first template
  await tester.tap(find.byType(TemplateCard).first);
  await tester.pumpAndSettle();
  
  // Verify form appears
  expect(find.byType(TemplateGuidedForm), findsOneWidget);
});
```

### Test Content Generation
```dart
test('Content generation works correctly', () async {
  final template = PremadeTemplates.getTemplateById('first_date_red_flags');
  final responses = [
    TemplateResponse(
      sectionId: 'venue',
      response: ['Taken to sketchy area'],
      timestamp: DateTime.now(),
    ),
  ];
  
  final content = await ContentGenerationService.instance.generatePostContent(
    template: template,
    responses: responses,
  );
  
  expect(content, isNotEmpty);
  expect(content, contains('First Date Red Flags'));
});
```

---

## 🚨 Common Issues & Solutions

### Issue: Template not found
```dart
// ❌ Wrong
final template = PremadeTemplates.getTemplateById('invalid_id');

// ✅ Correct
try {
  final template = PremadeTemplates.getTemplateById('first_date_red_flags');
} catch (e) {
  print('Template not found: $e');
}
```

### Issue: Responses not saving
```dart
// ❌ Wrong - responses not added to provider
final responses = <TemplateResponse>[];

// ✅ Correct - add to provider
ref.read(templateResponsesProvider.notifier).addResponse(response);
```

### Issue: Content not generating
```dart
// ❌ Wrong - missing await
final content = ContentGenerationService.instance.generatePostContent(...);

// ✅ Correct - use await
final content = await ContentGenerationService.instance.generatePostContent(...);
```

---

## 📚 Resources

- **Models**: `lib/features/templates/models/story_template_model.dart`
- **Services**: `lib/core/services/template_engine_service.dart`
- **Providers**: `lib/features/templates/presentation/providers/template_providers.dart`
- **Widgets**: `lib/features/templates/presentation/widgets/`
- **Pre-made Templates**: `lib/features/templates/data/premade_templates.dart`

---

## 🔗 Related Documentation

- [Phase 1 Handoff](PHASE_1_TEMPLATES_GUIDES_HANDOFF.md)
- [Phase 1 Completion Summary](PHASE_1_COMPLETION_SUMMARY.md)
- [Gold Feature Expansion Plan](CHEKmate_GOLD_FEATURE_EXPANSION_PLAN.md)

---

## ✅ Checklist for Integration

- [ ] Import necessary packages
- [ ] Add template button to UI
- [ ] Implement template selector
- [ ] Implement guided form
- [ ] Implement content generation
- [ ] Test template selection flow
- [ ] Test content generation
- [ ] Test post creation with template
- [ ] Deploy Firebase collections
- [ ] Deploy security rules
- [ ] Monitor analytics

---

*Last Updated: November 20, 2025*
