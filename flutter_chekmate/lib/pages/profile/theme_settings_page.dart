import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:go_router/go_router.dart';

/// Theme customization settings page
class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  Color _primaryColor = AppColors.primary;
  Color _accentColor = AppColors.navyBlue;
  bool _darkModeEnabled = false;
  String _themePreset = 'default';
  bool _hasChanges = false;

  final List<Map<String, dynamic>> _themePresets = [
    {
      'id': 'default',
      'name': 'ChekMate Orange',
      'primary': AppColors.primary,
      'accent': AppColors.navyBlue,
    },
    {
      'id': 'sunset',
      'name': 'Sunset Romance',
      'primary': const Color(0xFFFF6B6B),
      'accent': const Color(0xFFFFE66D),
    },
    {
      'id': 'ocean',
      'name': 'Ocean Blue',
      'primary': const Color(0xFF4A90E2),
      'accent': const Color(0xFF50E3C2),
    },
    {
      'id': 'forest',
      'name': 'Forest Green',
      'primary': const Color(0xFF27AE60),
      'accent': const Color(0xFF2ECC71),
    },
    {
      'id': 'lavender',
      'name': 'Lavender Dreams',
      'primary': const Color(0xFF9B59B6),
      'accent': const Color(0xFFE91E63),
    },
    {
      'id': 'custom',
      'name': 'Custom',
      'primary': AppColors.primary,
      'accent': AppColors.navyBlue,
    },
  ];

  void _applyPreset(String presetId) {
    final preset = _themePresets.firstWhere((p) => p['id'] == presetId);
    setState(() {
      _themePreset = presetId;
      if (presetId != 'custom') {
        _primaryColor = preset['primary'] as Color;
        _accentColor = preset['accent'] as Color;
      }
      _hasChanges = true;
    });
  }

  void _saveSettings() {
    // TODO: Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theme settings saved!'),
        backgroundColor: AppColors.primary,
      ),
    );
    setState(() {
      _hasChanges = false;
    });
  }

  void _resetToDefault() {
    setState(() {
      _themePreset = 'default';
      _primaryColor = AppColors.primary;
      _accentColor = AppColors.navyBlue;
      _darkModeEnabled = false;
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navyBlue),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Theme Settings',
          style: TextStyle(
            color: AppColors.navyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Breadcrumb
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: const AppBreadcrumb(
                items: [
                  AppBreadcrumbItem(label: 'Profile'),
                  AppBreadcrumbItem(label: 'Settings'),
                  AppBreadcrumbItem(label: 'Theme'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Theme Preview
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primaryColor),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Theme Preview',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text('Primary'),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _accentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text('Accent'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Theme Presets
                    Text(
                      'Theme Presets',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppRadioGroup<String>(
                      value: _themePreset,
                      items: _themePresets
                          .map(
                            (preset) => AppRadioItem(
                              value: preset['id'] as String,
                              label: preset['name'] as String,
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _applyPreset(value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Custom Colors (only show if custom preset selected)
                    if (_themePreset == 'custom') ...[
                      Text(
                        'Custom Colors',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppColorPicker(
                        selectedColor: _primaryColor,
                        onColorChanged: (color) {
                          setState(() {
                            _primaryColor = color;
                            _hasChanges = true;
                          });
                        },
                        showHexInput: true,
                        showSwatches: true,
                        label: 'Primary Color',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppColorPicker(
                        selectedColor: _accentColor,
                        onColorChanged: (color) {
                          setState(() {
                            _accentColor = color;
                            _hasChanges = true;
                          });
                        },
                        showHexInput: true,
                        showSwatches: true,
                        label: 'Accent Color',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // Dark Mode Toggle
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.dark_mode,
                                color: AppColors.navyBlue,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'Dark Mode',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          AppSwitch(
                            value: _darkModeEnabled,
                            onChanged: (value) {
                              setState(() {
                                _darkModeEnabled = value;
                                _hasChanges = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Reset button
                    AppButton(
                      onPressed: _resetToDefault,
                      variant: AppButtonVariant.outline,
                      child: const Text('Reset to Default'),
                    ),
                  ],
                ),
              ),
            ),

            // Save button
            if (_hasChanges)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: AppButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Changes'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

