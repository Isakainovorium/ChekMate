import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppTextarea - Multi-line text input with consistent styling
class AppTextarea extends StatelessWidget {
  const AppTextarea({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.keyboardType = TextInputType.multiline,
    this.textInputAction = TextInputAction.newline,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.autofocus = false,
    this.expands = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final int minLines;
  final int? maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool expands;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: enabled 
                ? theme.colorScheme.onSurface 
                : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          enabled: enabled,
          readOnly: readOnly,
          minLines: expands ? null : minLines,
          maxLines: expands ? null : maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          autofocus: autofocus,
          expands: expands,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
