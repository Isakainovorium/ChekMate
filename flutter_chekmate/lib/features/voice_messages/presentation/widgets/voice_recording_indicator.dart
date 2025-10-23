import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/providers/voice_recording_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Animated voice recording indicator widget
///
/// This widget displays a pulsing animation when recording is active.
/// It provides visual feedback that recording is in progress.
///
/// Features:
/// - Pulsing red dot animation
/// - "Recording..." text
/// - Smooth fade in/out transitions
/// - Customizable colors and sizes
///
/// Usage:
/// ```dart
/// VoiceRecordingIndicator()
/// ```
class VoiceRecordingIndicator extends ConsumerStatefulWidget {

  const VoiceRecordingIndicator({
    super.key,
    this.dotSize = 12.0,
    this.text = 'Recording...',
    this.textStyle,
    this.dotColor,
    this.spacing = 8.0,
    this.animationDuration = const Duration(seconds: 1),
  });
  /// Size of the indicator dot (default: 12.0)
  final double dotSize;

  /// Text to display (default: "Recording...")
  final String text;

  /// Text style
  final TextStyle? textStyle;

  /// Color of the pulsing dot (default: Colors.red)
  final Color? dotColor;

  /// Spacing between dot and text (default: 8.0)
  final double spacing;

  /// Animation duration (default: 1 second)
  final Duration animationDuration;

  @override
  ConsumerState<VoiceRecordingIndicator> createState() =>
      _VoiceRecordingIndicatorState();
}

class _VoiceRecordingIndicatorState
    extends ConsumerState<VoiceRecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(isRecordingProvider);

    if (!isRecording) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final effectiveDotColor = widget.dotColor ?? Colors.red;
    final effectiveTextStyle = widget.textStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: effectiveDotColor,
          fontWeight: FontWeight.w500,
        );

    return AnimatedOpacity(
      opacity: isRecording ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: effectiveDotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(width: widget.spacing),

          // Recording text
          Text(
            widget.text,
            style: effectiveTextStyle,
          ),
        ],
      ),
    );
  }
}

/// Waveform-style recording indicator
///
/// This widget displays animated bars that simulate a waveform
/// during voice recording.
///
/// Usage:
/// ```dart
/// VoiceRecordingWaveform()
/// ```
class VoiceRecordingWaveform extends ConsumerStatefulWidget {

  const VoiceRecordingWaveform({
    super.key,
    this.barCount = 5,
    this.barWidth = 4.0,
    this.maxBarHeight = 24.0,
    this.minBarHeight = 4.0,
    this.barSpacing = 4.0,
    this.barColor,
    this.animationDuration = const Duration(milliseconds: 500),
  });
  /// Number of bars in the waveform (default: 5)
  final int barCount;

  /// Width of each bar (default: 4.0)
  final double barWidth;

  /// Maximum height of bars (default: 24.0)
  final double maxBarHeight;

  /// Minimum height of bars (default: 4.0)
  final double minBarHeight;

  /// Spacing between bars (default: 4.0)
  final double barSpacing;

  /// Color of the bars (default: Theme primary color)
  final Color? barColor;

  /// Animation duration (default: 500ms)
  final Duration animationDuration;

  @override
  ConsumerState<VoiceRecordingWaveform> createState() =>
      _VoiceRecordingWaveformState();
}

class _VoiceRecordingWaveformState
    extends ConsumerState<VoiceRecordingWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _barAnimations = List.generate(
      widget.barCount,
      (index) {
        final delay = index * 0.1;
        return Tween<double>(
          begin: widget.minBarHeight,
          end: widget.maxBarHeight,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay,
              1.0,
              curve: Curves.easeInOut,
            ),
          ),
        );
      },
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(isRecordingProvider);

    if (!isRecording) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final effectiveBarColor = widget.barColor ?? theme.colorScheme.primary;

    return AnimatedOpacity(
      opacity: isRecording ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.barCount,
          (index) => Padding(
            padding: EdgeInsets.only(
              right: index < widget.barCount - 1 ? widget.barSpacing : 0,
            ),
            child: AnimatedBuilder(
              animation: _barAnimations[index],
              builder: (context, child) {
                return Container(
                  width: widget.barWidth,
                  height: _barAnimations[index].value,
                  decoration: BoxDecoration(
                    color: effectiveBarColor,
                    borderRadius: BorderRadius.circular(widget.barWidth / 2),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

