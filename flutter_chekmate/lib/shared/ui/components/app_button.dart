import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppButton - shared button with variants and sizes
/// Variants: primary (Filled), secondary (Elevated), outline, text
/// Sizes: sm, md, lg
class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed, required this.child, super.key,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool fullWidth;

  double get _height => switch (size) {
        AppButtonSize.sm => 36,
        AppButtonSize.md => 44,
        AppButtonSize.lg => 52,
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        AppButtonSize.md => const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      };

  ButtonStyle _mergeStyle(BuildContext context, ButtonStyle base) {
    final radius = BorderRadius.circular(12);
    return base.copyWith(
      minimumSize: WidgetStatePropertyAll(Size(fullWidth ? double.infinity : 0, _height)),
      padding: WidgetStatePropertyAll(_padding),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: radius)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _ButtonContent(
      isLoading: isLoading,
      leading: leadingIcon,
      trailing: trailingIcon,
      child: child,
    );

    final disabled = onPressed == null || isLoading;

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: disabled ? null : onPressed,
          style: _mergeStyle(context, FilledButton.styleFrom()),
          child: content,
        ),
      AppButtonVariant.secondary => ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: _mergeStyle(context, ElevatedButton.styleFrom()),
          child: content,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: _mergeStyle(
            context,
            OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          child: content,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: disabled ? null : onPressed,
          style: _mergeStyle(context, TextButton.styleFrom()),
          child: content,
        ),
    };
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.isLoading,
    required this.child,
    this.leading,
    this.trailing,
  });

  final bool isLoading;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (isLoading) {
      children.add(const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),);
    } else if (leading != null) {
      children.add(leading!);
    }

    children.add(Flexible(child: Center(child: child)));

    if (trailing != null) {
      children.add(trailing!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          children[i],
        ],
      ],
    );
  }
}

enum AppButtonVariant { primary, secondary, outline, text }

enum AppButtonSize { sm, md, lg }
