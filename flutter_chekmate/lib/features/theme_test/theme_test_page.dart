import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Theme Test Page
/// Displays all theme elements for visual verification against Figma design
class ThemeTestPage extends StatelessWidget {
  const ThemeTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Test'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
            Text(
              'ChekMate Design System',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            AppSpacing.gapMD,

            Text(
              'Visual verification of all theme elements',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            AppSpacing.gapXL,

            // Section: Colors
            _buildSectionTitle(context, 'Colors'),
            AppSpacing.gapMD,
            _buildColorSwatches(),
            AppSpacing.gapXL,

            // Section: Typography
            _buildSectionTitle(context, 'Typography'),
            AppSpacing.gapMD,
            _buildTypographySamples(context),
            AppSpacing.gapXL,

            // Section: Spacing
            _buildSectionTitle(context, 'Spacing'),
            AppSpacing.gapMD,
            _buildSpacingExamples(),
            AppSpacing.gapXL,

            // Section: Components
            _buildSectionTitle(context, 'Components'),
            AppSpacing.gapMD,
            _buildComponentExamples(context),
            AppSpacing.gapXL,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  Widget _buildColorSwatches() {
    return const Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _ColorSwatch(name: 'Primary Gold', color: AppColors.primary),
        _ColorSwatch(name: 'Navy Blue', color: AppColors.navyBlue),
        _ColorSwatch(name: 'Secondary', color: AppColors.secondary),
        _ColorSwatch(name: 'Surface', color: AppColors.surface),
        _ColorSwatch(name: 'Background', color: AppColors.background),
        _ColorSwatch(name: 'Text Primary', color: AppColors.textPrimary),
        _ColorSwatch(name: 'Text Secondary', color: AppColors.textSecondary),
        _ColorSwatch(name: 'Border', color: AppColors.border),
        _ColorSwatch(name: 'Error', color: AppColors.error),
        _ColorSwatch(name: 'Success', color: AppColors.success),
        _ColorSwatch(name: 'Warning', color: AppColors.warning),
        _ColorSwatch(name: 'Info', color: AppColors.info),
      ],
    );
  }

  Widget _buildTypographySamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypographySample(
          label: 'Display Large (H1)',
          style: Theme.of(context).textTheme.displayLarge!,
          text: 'The quick brown fox',
        ),
        AppSpacing.gapSM,
        _TypographySample(
          label: 'Display Small (H2)',
          style: Theme.of(context).textTheme.displaySmall!,
          text: 'The quick brown fox',
        ),
        AppSpacing.gapSM,
        _TypographySample(
          label: 'Headline Medium (H3)',
          style: Theme.of(context).textTheme.headlineMedium!,
          text: 'The quick brown fox',
        ),
        AppSpacing.gapSM,
        _TypographySample(
          label: 'Body Medium',
          style: Theme.of(context).textTheme.bodyMedium!,
          text: 'The quick brown fox jumps over the lazy dog',
        ),
        AppSpacing.gapSM,
        _TypographySample(
          label: 'Body Small',
          style: Theme.of(context).textTheme.bodySmall!,
          text: 'The quick brown fox jumps over the lazy dog',
        ),
        AppSpacing.gapSM,
        _TypographySample(
          label: 'Label Large (Button)',
          style: Theme.of(context).textTheme.labelLarge!,
          text: 'Button Text',
        ),
      ],
    );
  }

  Widget _buildSpacingExamples() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SpacingBox(size: AppSpacing.xs, label: 'XS (4px)'),
            AppSpacing.gapSM,
            _SpacingBox(size: AppSpacing.sm, label: 'SM (8px)'),
            AppSpacing.gapSM,
            _SpacingBox(size: AppSpacing.md, label: 'MD (16px)'),
            AppSpacing.gapSM,
            _SpacingBox(size: AppSpacing.lg, label: 'LG (24px)'),
          ],
        ),
        AppSpacing.gapMD,
        Row(
          children: [
            _SpacingBox(size: AppSpacing.xl, label: 'XL (32px)'),
            AppSpacing.gapSM,
            _SpacingBox(size: AppSpacing.xxl, label: 'XXL (48px)'),
          ],
        ),
      ],
    );
  }

  Widget _buildComponentExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buttons
        Text('Buttons', style: Theme.of(context).textTheme.titleMedium),
        AppSpacing.gapSM,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
          ],
        ),
        AppSpacing.gapLG,

        // Text Fields
        Text('Text Fields', style: Theme.of(context).textTheme.titleMedium),
        AppSpacing.gapSM,
        const TextField(
          decoration: InputDecoration(
            labelText: 'Label',
            hintText: 'Hint text',
          ),
        ),
        AppSpacing.gapLG,

        // Cards
        Text('Cards', style: Theme.of(context).textTheme.titleMedium),
        AppSpacing.gapSM,
        Card(
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Title',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppSpacing.gapSM,
                Text(
                  'This is a card with the default theme applied. It uses the spacing and border radius from the design system.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Helper Widgets

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.name,
    required this.color,
  });
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppSpacing.radiusMD,
            border: Border.all(color: AppColors.border),
          ),
        ),
        AppSpacing.gapXS,
        SizedBox(
          width: 80,
          child: Text(
            name,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TypographySample extends StatelessWidget {
  const _TypographySample({
    required this.label,
    required this.style,
    required this.text,
  });
  final String label;
  final TextStyle style;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(text, style: style),
      ],
    );
  }
}

class _SpacingBox extends StatelessWidget {
  const _SpacingBox({
    required this.size,
    required this.label,
  });
  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
            border: Border.all(color: AppColors.primary),
          ),
        ),
        AppSpacing.gapXS,
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
