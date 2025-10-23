import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Voice waveform widget
///
/// This widget displays a visual representation of an audio waveform.
/// It shows static bars representing the audio amplitude and a progress
/// overlay showing the current playback position.
///
/// Features:
/// - Static waveform visualization
/// - Progress overlay
/// - Tap to seek functionality
/// - Customizable colors and sizes
///
/// Usage:
/// ```dart
/// VoiceWaveform(
///   progress: 0.5, // 50% played
///   onSeek: (progress) {
///     // Seek to position
///   },
/// )
/// ```
class VoiceWaveform extends StatelessWidget {
  const VoiceWaveform({
    super.key,
    this.progress = 0.0,
    this.onSeek,
    this.barCount = 40,
    this.barWidth = 3.0,
    this.maxBarHeight = 40.0,
    this.minBarHeight = 4.0,
    this.barSpacing = 2.0,
    this.playedColor,
    this.unplayedColor,
    this.barBorderRadius = 2.0,
    this.waveformData,
  });

  /// Playback progress (0.0 to 1.0)
  final double progress;

  /// Callback when user taps to seek
  final void Function(double progress)? onSeek;

  /// Number of bars in the waveform (default: 40)
  final int barCount;

  /// Width of each bar (default: 3.0)
  final double barWidth;

  /// Maximum height of bars (default: 40.0)
  final double maxBarHeight;

  /// Minimum height of bars (default: 4.0)
  final double minBarHeight;

  /// Spacing between bars (default: 2.0)
  final double barSpacing;

  /// Color of played bars (default: Theme primary color)
  final Color? playedColor;

  /// Color of unplayed bars (default: Theme divider color)
  final Color? unplayedColor;

  /// Border radius of bars (default: 2.0)
  final double barBorderRadius;

  /// Waveform data (optional, if null, generates random waveform)
  /// Values should be between 0.0 and 1.0
  final List<double>? waveformData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePlayedColor = playedColor ?? theme.colorScheme.primary;
    final effectiveUnplayedColor =
        unplayedColor ?? theme.dividerColor.withValues(alpha: 0.5);

    // Generate or use provided waveform data
    final data = waveformData ?? _generateWaveformData();

    return GestureDetector(
      onTapDown: (details) => _handleTap(details, context),
      child: CustomPaint(
        size: Size(
          (barWidth + barSpacing) * barCount - barSpacing,
          maxBarHeight,
        ),
        painter: _WaveformPainter(
          data: data,
          progress: progress,
          barWidth: barWidth,
          barSpacing: barSpacing,
          maxBarHeight: maxBarHeight,
          minBarHeight: minBarHeight,
          playedColor: effectivePlayedColor,
          unplayedColor: effectiveUnplayedColor,
          barBorderRadius: barBorderRadius,
        ),
      ),
    );
  }

  /// Generate random waveform data
  List<double> _generateWaveformData() {
    final random = math.Random(42); // Fixed seed for consistent waveform
    return List.generate(
      barCount,
      (index) {
        // Create a wave-like pattern
        final wave = math.sin(index * 0.3) * 0.5 + 0.5;
        final randomness = random.nextDouble() * 0.3;
        return (wave + randomness).clamp(0.2, 1.0);
      },
    );
  }

  /// Handle tap to seek
  void _handleTap(TapDownDetails details, BuildContext context) {
    if (onSeek == null) return;

    final box = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;
    final width = box.size.width;
    final progress = (localPosition.dx / width).clamp(0.0, 1.0);

    onSeek!(progress);
  }
}

/// Waveform painter
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.data,
    required this.progress,
    required this.barWidth,
    required this.barSpacing,
    required this.maxBarHeight,
    required this.minBarHeight,
    required this.playedColor,
    required this.unplayedColor,
    required this.barBorderRadius,
  });
  final List<double> data;
  final double progress;
  final double barWidth;
  final double barSpacing;
  final double maxBarHeight;
  final double minBarHeight;
  final Color playedColor;
  final Color unplayedColor;
  final double barBorderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final playedPaint = Paint()
      ..color = playedColor
      ..style = PaintingStyle.fill;

    final unplayedPaint = Paint()
      ..color = unplayedColor
      ..style = PaintingStyle.fill;

    final progressX = size.width * progress;

    for (var i = 0; i < data.length; i++) {
      final x = i * (barWidth + barSpacing);
      final barHeight = minBarHeight + (maxBarHeight - minBarHeight) * data[i];
      final y = (maxBarHeight - barHeight) / 2;

      // Determine if this bar is played or unplayed
      final paint = x < progressX ? playedPaint : unplayedPaint;

      // Draw rounded rectangle
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(barBorderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.data != data ||
        oldDelegate.playedColor != playedColor ||
        oldDelegate.unplayedColor != unplayedColor;
  }
}

/// Compact waveform widget (smaller version)
class CompactVoiceWaveform extends StatelessWidget {
  const CompactVoiceWaveform({
    super.key,
    this.progress = 0.0,
    this.onSeek,
    this.playedColor,
    this.unplayedColor,
  });
  final double progress;
  final void Function(double progress)? onSeek;
  final Color? playedColor;
  final Color? unplayedColor;

  @override
  Widget build(BuildContext context) {
    return VoiceWaveform(
      progress: progress,
      onSeek: onSeek,
      barCount: 30,
      barWidth: 2.0,
      maxBarHeight: 24.0,
      minBarHeight: 3.0,
      barSpacing: 1.5,
      playedColor: playedColor,
      unplayedColor: unplayedColor,
      barBorderRadius: 1.5,
    );
  }
}

/// Large waveform widget (bigger version for detail view)
class LargeVoiceWaveform extends StatelessWidget {
  const LargeVoiceWaveform({
    super.key,
    this.progress = 0.0,
    this.onSeek,
    this.playedColor,
    this.unplayedColor,
    this.waveformData,
  });
  final double progress;
  final void Function(double progress)? onSeek;
  final Color? playedColor;
  final Color? unplayedColor;
  final List<double>? waveformData;

  @override
  Widget build(BuildContext context) {
    return VoiceWaveform(
      progress: progress,
      onSeek: onSeek,
      barCount: 60,
      barWidth: 4.0,
      maxBarHeight: 60.0,
      minBarHeight: 6.0,
      barSpacing: 3.0,
      playedColor: playedColor,
      unplayedColor: unplayedColor,
      barBorderRadius: 2.5,
      waveformData: waveformData,
    );
  }
}
