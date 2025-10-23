import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Media Type Selector - Choose between text, image, or video post
class MediaTypeSelector extends StatelessWidget {
  const MediaTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
    super.key,
  });
  final String selectedType;
  final void Function(String) onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: AppToggleGroup<String>(
        selectedValues: {selectedType},
        onSelectionChanged: (values) => onTypeSelected(values.first),
        options: const [
          AppToggleOption(
            value: 'text',
            icon: Icons.text_fields,
            label: 'Text',
          ),
          AppToggleOption(
            value: 'image',
            icon: Icons.image,
            label: 'Image',
          ),
          AppToggleOption(
            value: 'video',
            icon: Icons.videocam,
            label: 'Video',
          ),
        ],
      ),
    );
  }
}
