import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// RateYourDateHeader - Header for rate your date page with progress and info
class RateYourDateHeaderWidget extends StatelessWidget {
  const RateYourDateHeaderWidget({
    required this.currentStep, required this.totalSteps, super.key,
    this.title,
    this.subtitle,
    this.onBack,
    this.onSkip,
    this.showProgress = true,
  });

  final int currentStep;
  final int totalSteps;
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = currentStep / totalSteps;
    
    return AppCard(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with back button and skip
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                )
              else
                const SizedBox(width: 48), // Maintain spacing
              
              Expanded(
                child: showProgress
                    ? Column(
                        children: [
                          Text(
                            'Step $currentStep of $totalSteps',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              
              if (onSkip != null)
                AppButton(
                  onPressed: onSkip,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.sm,
                  child: const Text('Skip'),
                )
              else
                const SizedBox(width: 48), // Maintain spacing
            ],
          ),
          
          if (title != null || subtitle != null) ...[
            const SizedBox(height: AppSpacing.lg),
            
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ],
      ),
    );
  }
}
