import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/components/app_alert.dart';
import '../../../shared/ui/components/app_breadcrumb.dart';
import '../../../shared/ui/components/app_button.dart';
import '../../../shared/ui/components/app_color_picker.dart';
import '../../../shared/ui/components/app_radio_group.dart';
import '../../../shared/ui/components/app_switch.dart';

/// Theme Settings Page
///
/// Allows users to customize app theme including:
/// - Theme presets (6 options)
/// - Custom color picker (primary + accent)
/// - Dark mode toggle
/// - Live theme preview
///
/// Date: 11/13/2025
class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Theme preset selection
  int _selectedPreset = 0;
  final List<ThemePreset> _presets = [
    const ThemePreset(
        name: 'Purple', primary: Colors.purple, accent: Colors.purpleAccent),
    const ThemePreset(
        name: 'Blue', primary: Colors.blue, accent: Colors.blueAccent),
    const ThemePreset(
        name: 'Green', primary: Colors.green, accent: Colors.greenAccent),
    const ThemePreset(
        name: 'Orange', primary: Colors.orange, accent: Colors.orangeAccent),
    const ThemePreset(
        name: 'Red', primary: Colors.red, accent: Colors.redAccent),
    const ThemePreset(
        name: 'Teal', primary: Colors.teal, accent: Colors.tealAccent),
  ];

  // Custom colors
  bool _useCustomColors = false;
  Color _customPrimary = Colors.purple;
  Color _customAccent = Colors.purpleAccent;

  // Dark mode
  bool _darkModeEnabled = false;

  bool _isSaving = false;
  String? _errorMessage;
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    final currentTheme = _buildCurrentTheme();

    return Theme(
      data: currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Theme Settings'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _handleCancel,
                child: const Text('Cancel'),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBreadcrumb(
                    items: [
                      AppBreadcrumbItem(label: 'Profile'),
                      AppBreadcrumbItem(label: 'Theme Settings'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    AppAlert(
                      message: _errorMessage!,
                      variant: AppAlertVariant.error,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Theme Presets',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  AppRadioGroup<int>(
                    value: _selectedPreset,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPreset = value;
                          _useCustomColors = false;
                          _hasChanges = true;
                        });
                      }
                    },
                    items: List.generate(_presets.length, (index) {
                      final preset = _presets[index];
                      return AppRadioItem<int>(
                        value: index,
                        label: preset.name,
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  AppSwitch(
                    value: _useCustomColors,
                    onChanged: (value) {
                      setState(() {
                        _useCustomColors = value;
                        if (value) {
                          final preset = _presets[_selectedPreset];
                          _customPrimary = preset.primary;
                          _customAccent = preset.accent;
                        }
                        _hasChanges = true;
                      });
                    },
                    label: 'Use Custom Colors',
                    subtitle: 'Override preset with custom colors',
                  ),
                  if (_useCustomColors) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Primary Color',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    AppColorPicker(
                      selectedColor: _customPrimary,
                      onColorChanged: (color) {
                        setState(() {
                          _customPrimary = color;
                          _hasChanges = true;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Accent Color',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    AppColorPicker(
                      selectedColor: _customAccent,
                      onColorChanged: (color) {
                        setState(() {
                          _customAccent = color;
                          _hasChanges = true;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 32),
                  AppSwitch(
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                        _hasChanges = true;
                      });
                    },
                    label: 'Dark Mode',
                    subtitle: 'Enable dark theme',
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Preview',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildThemePreview(currentTheme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    onPressed: _isSaving ? null : _handleSave,
                    isLoading: _isSaving,
                    fullWidth: true,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _buildCurrentTheme() {
    final primaryColor =
        _useCustomColors ? _customPrimary : _presets[_selectedPreset].primary;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: _darkModeEnabled ? Brightness.dark : Brightness.light,
      ),
    );
  }

  Widget _buildThemePreview(ThemeData theme) {
    return Theme(
      data: theme,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Primary Color',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Secondary Color',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Sample Button'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual save functionality with theme provider
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme settings saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save settings. Please try again.';
          _isSaving = false;
        });
      }
    }
  }

  void _handleCancel() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }
}

/// Theme preset data class
class ThemePreset {
  const ThemePreset({
    required this.name,
    required this.primary,
    required this.accent,
  });

  final String name;
  final Color primary;
  final Color accent;
}
