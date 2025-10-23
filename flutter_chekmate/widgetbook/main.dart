import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_theme.dart';
import 'package:widgetbook/widgetbook.dart';

import 'showcases/animation_components.dart';
import 'showcases/data_display_components.dart';
import 'showcases/feedback_components.dart';
// Import all component showcases
import 'showcases/form_components.dart';
import 'showcases/layout_components.dart';
import 'showcases/loading_components.dart';

/// Widgetbook App - Component Showcase
///
/// This is the main entry point for the Widgetbook component showcase.
/// It provides an interactive catalog of all 56+ enterprise-grade UI components
/// in the ChekMate app.
///
/// Features:
/// - Live component preview with customizable props
/// - Light/Dark theme switching
/// - Device frame simulation
/// - Responsive design testing
/// - Accessibility testing
/// - Component documentation
///
/// Usage:
/// ```bash
/// flutter run -t widgetbook/main.dart
/// ```
///
/// Categories:
/// 1. Form Components (11 components)
/// 2. Layout Components (9 components)
/// 3. Feedback Components (8 components)
/// 4. Data Display Components (6 components)
/// 5. Loading Components (4 components)
/// 6. Animation Components (10+ components)
///
/// Total: 56+ components
void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // Catalog of all components
      directories: [
        // Form Components
        WidgetbookCategory(
          name: '📝 Form Components',
          children: FormComponentShowcases.showcases,
        ),

        // Layout Components
        WidgetbookCategory(
          name: '📐 Layout Components',
          children: LayoutComponentShowcases.showcases,
        ),

        // Feedback Components
        WidgetbookCategory(
          name: '💬 Feedback Components',
          children: FeedbackComponentShowcases.showcases,
        ),

        // Data Display Components
        WidgetbookCategory(
          name: '📊 Data Display Components',
          children: DataDisplayComponentShowcases.showcases,
        ),

        // Loading Components
        WidgetbookCategory(
          name: '⏳ Loading Components',
          children: LoadingComponentShowcases.showcases,
        ),

        // Animation Components
        WidgetbookCategory(
          name: '✨ Animation Components',
          children: AnimationComponentShowcases.showcases,
        ),
      ],

      // Addons for customization
      addons: [
        // Theme addon - Switch between light and dark themes
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: AppTheme.lightTheme,
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: AppTheme.darkTheme,
            ),
          ],
        ),

        // Text scale addon - Test accessibility
        TextScaleAddon(
          min: 0.8,
        ),

        // Locale addon - Test internationalization
        LocalizationAddon(
          locales: [
            const Locale('en', 'US'),
            const Locale('es', 'ES'),
            const Locale('fr', 'FR'),
            const Locale('de', 'DE'),
          ],
          localizationsDelegates: const [],
        ),

        // Alignment addon - Test component alignment
        AlignmentAddon(),

        // Builder addon - Custom wrapper for components
        BuilderAddon(
          name: 'SafeArea',
          builder: (context, child) => SafeArea(child: child),
        ),
      ],
    );
  }
}
