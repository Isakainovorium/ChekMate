import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppProgress - Progress indicator with consistent styling
class AppProgress extends StatelessWidget {
  const AppProgress({
    required this.value, super.key,
    this.label,
    this.showPercentage = false,
    this.height = 8,
    this.backgroundColor,
    this.valueColor,
    this.borderRadius = 4,
  });

  final double value; // 0.0 to 1.0
  final String? label;
  final bool showPercentage;
  final double height;
  final Color? backgroundColor;
  final Color? valueColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (value * 100).round();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: theme.textTheme.bodyMedium,
                ),
              if (showPercentage)
                Text(
                  '$percentage%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: LinearProgressIndicator(
            value: value,
            minHeight: height,
            backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              valueColor ?? theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// AppCircularProgress - Circular progress indicator
class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({
    super.key,
    this.value,
    this.size = 40,
    this.strokeWidth = 4,
    this.backgroundColor,
    this.valueColor,
    this.child,
  });

  final double? value; // null for indeterminate
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              valueColor ?? theme.colorScheme.primary,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// AppStepProgress - Step-based progress indicator
class AppStepProgress extends StatelessWidget {
  const AppStepProgress({
    required this.steps, required this.currentStep, super.key,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
  });

  final List<String> steps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCol = activeColor ?? theme.colorScheme.primary;
    final inactiveCol = inactiveColor ?? theme.colorScheme.surfaceContainerHighest;
    final completedCol = completedColor ?? theme.colorScheme.primary;
    
    return Column(
      children: [
        // Step indicators
        Row(
          children: List.generate(steps.length, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;
            final isInactive = index > currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  // Step circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted 
                          ? completedCol
                          : isActive 
                              ? activeCol
                              : inactiveCol,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: theme.colorScheme.onPrimary,
                              size: 16,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isInactive 
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  
                  // Connecting line
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < currentStep ? completedCol : inactiveCol,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Step labels
        Row(
          children: List.generate(steps.length, (index) {
            final isActive = index == currentStep;
            
            return Expanded(
              child: Text(
                steps[index],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive 
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    );
  }
}
