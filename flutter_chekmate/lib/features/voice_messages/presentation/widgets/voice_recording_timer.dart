import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/providers/voice_recording_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Voice recording timer widget
///
/// This widget displays the current recording duration in MM:SS format.
/// It updates in real-time as the recording progresses.
///
/// Features:
/// - Real-time duration display
/// - Formatted time (MM:SS)
/// - Optional remaining time display
/// - Optional progress bar
/// - Customizable styling
///
/// Usage:
/// ```dart
/// VoiceRecordingTimer()
/// ```
class VoiceRecordingTimer extends ConsumerWidget {

  const VoiceRecordingTimer({
    super.key,
    this.textStyle,
    this.showRemainingTime = false,
    this.showProgressBar = false,
    this.progressBarHeight = 4.0,
    this.progressBarColor,
    this.progressBarBackgroundColor,
    this.prefix,
    this.suffix,
  });
  /// Text style for the timer
  final TextStyle? textStyle;

  /// Whether to show remaining time instead of elapsed time
  final bool showRemainingTime;

  /// Whether to show a progress bar
  final bool showProgressBar;

  /// Progress bar height (default: 4.0)
  final double progressBarHeight;

  /// Progress bar color (default: Theme primary color)
  final Color? progressBarColor;

  /// Background color for progress bar (default: Theme divider color)
  final Color? progressBarBackgroundColor;

  /// Prefix text (e.g., "Recording: ")
  final String? prefix;

  /// Suffix text (e.g., " / 01:00")
  final String? suffix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(voiceRecordingNotifierProvider);
    final isRecording = recordingState.isRecording || recordingState.isPaused;

    if (!isRecording) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final effectiveTextStyle = textStyle ??
        theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontFeatures: [const FontFeature.tabularFigures()],
        );

    final timeText = showRemainingTime
        ? recordingState.formattedRemainingTime
        : recordingState.formattedDuration;

    return AnimatedOpacity(
      opacity: isRecording ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer text
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefix != null)
                Text(
                  prefix!,
                  style: effectiveTextStyle?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              Text(
                timeText,
                style: effectiveTextStyle,
              ),
              if (suffix != null)
                Text(
                  suffix!,
                  style: effectiveTextStyle?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),

          // Progress bar
          if (showProgressBar) ...[
            const SizedBox(height: 8),
            _buildProgressBar(context, recordingState.progress),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final effectiveProgressBarColor =
        progressBarColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor =
        progressBarBackgroundColor ?? theme.dividerColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(progressBarHeight / 2),
      child: SizedBox(
        height: progressBarHeight,
        width: 200, // Fixed width for progress bar
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: effectiveBackgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressBarColor),
        ),
      ),
    );
  }
}

/// Circular voice recording timer widget
///
/// This widget displays the recording duration in a circular progress indicator.
///
/// Usage:
/// ```dart
/// CircularVoiceRecordingTimer()
/// ```
class CircularVoiceRecordingTimer extends ConsumerWidget {

  const CircularVoiceRecordingTimer({
    super.key,
    this.size = 80.0,
    this.strokeWidth = 6.0,
    this.textStyle,
    this.progressColor,
    this.backgroundColor,
  });
  /// Size of the circular timer (default: 80.0)
  final double size;

  /// Stroke width of the progress circle (default: 6.0)
  final double strokeWidth;

  /// Text style for the timer
  final TextStyle? textStyle;

  /// Progress color (default: Theme primary color)
  final Color? progressColor;

  /// Background color (default: Theme divider color)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(voiceRecordingNotifierProvider);
    final isRecording = recordingState.isRecording || recordingState.isPaused;

    if (!isRecording) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final effectiveProgressColor = progressColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? theme.dividerColor;
    final effectiveTextStyle = textStyle ??
        theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontFeatures: [const FontFeature.tabularFigures()],
        );

    return AnimatedOpacity(
      opacity: isRecording ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: strokeWidth,
                valueColor:
                    AlwaysStoppedAnimation<Color>(effectiveBackgroundColor),
              ),
            ),

            // Progress circle
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: recordingState.progress,
                strokeWidth: strokeWidth,
                valueColor:
                    AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              ),
            ),

            // Timer text
            Text(
              recordingState.formattedDuration,
              style: effectiveTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact voice recording timer widget
///
/// This widget displays a minimal timer with just the duration.
///
/// Usage:
/// ```dart
/// CompactVoiceRecordingTimer()
/// ```
class CompactVoiceRecordingTimer extends ConsumerWidget {

  const CompactVoiceRecordingTimer({
    super.key,
    this.textStyle,
    this.icon = Icons.fiber_manual_record,
    this.iconSize = 16.0,
    this.spacing = 4.0,
  });
  /// Text style for the timer
  final TextStyle? textStyle;

  /// Icon to show before the timer
  final IconData? icon;

  /// Icon size (default: 16.0)
  final double iconSize;

  /// Spacing between icon and text (default: 4.0)
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDuration = ref.watch(formattedDurationProvider);
    final isRecording = ref.watch(isRecordingProvider);

    if (!isRecording) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final effectiveTextStyle = textStyle ??
        theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          fontFeatures: [const FontFeature.tabularFigures()],
        );

    return AnimatedOpacity(
      opacity: isRecording ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: Colors.red,
            ),
            SizedBox(width: spacing),
          ],
          Text(
            formattedDuration,
            style: effectiveTextStyle,
          ),
        ],
      ),
    );
  }
}

