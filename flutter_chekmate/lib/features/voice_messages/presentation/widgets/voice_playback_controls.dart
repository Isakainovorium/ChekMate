import 'package:flutter/material.dart';

/// Voice playback controls widget
///
/// This widget displays playback controls for a voice message.
/// It includes play/pause button, speed control, and duration display.
///
/// Features:
/// - Play/pause button
/// - Speed control (1.0x, 1.5x, 2.0x)
/// - Duration display (current / total)
/// - Loading indicator
/// - Customizable styling
///
/// Usage:
/// ```dart
/// VoicePlaybackControls(
///   isPlaying: true,
///   isLoading: false,
///   currentTime: '00:15',
///   totalTime: '01:00',
///   speed: 1.0,
///   onPlayPause: () {},
///   onSpeedChange: () {},
/// )
/// ```
class VoicePlaybackControls extends StatelessWidget {

  const VoicePlaybackControls({
    required this.isPlaying, required this.isLoading, required this.currentTime, required this.totalTime, required this.speed, super.key,
    this.onPlayPause,
    this.onSpeedChange,
    this.buttonSize = 40.0,
    this.iconSize = 24.0,
    this.primaryColor,
    this.timeTextStyle,
    this.showSpeedControl = true,
  });
  /// Whether audio is currently playing
  final bool isPlaying;

  /// Whether audio is loading
  final bool isLoading;

  /// Current playback time (formatted)
  final String currentTime;

  /// Total duration (formatted)
  final String totalTime;

  /// Current playback speed
  final double speed;

  /// Callback when play/pause button is pressed
  final VoidCallback? onPlayPause;

  /// Callback when speed button is pressed
  final VoidCallback? onSpeedChange;

  /// Size of the play/pause button (default: 40.0)
  final double buttonSize;

  /// Icon size (default: 24.0)
  final double iconSize;

  /// Primary color (default: Theme primary color)
  final Color? primaryColor;

  /// Text style for time display
  final TextStyle? timeTextStyle;

  /// Whether to show speed control (default: true)
  final bool showSpeedControl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.colorScheme.primary;
    final effectiveTimeTextStyle = timeTextStyle ??
        theme.textTheme.bodySmall?.copyWith(
          fontFeatures: [const FontFeature.tabularFigures()],
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause Button
        _buildPlayPauseButton(effectivePrimaryColor),

        const SizedBox(width: 12),

        // Time Display
        Text(
          '$currentTime / $totalTime',
          style: effectiveTimeTextStyle,
        ),

        // Speed Control
        if (showSpeedControl) ...[
          const SizedBox(width: 12),
          _buildSpeedButton(theme),
        ],
      ],
    );
  }

  /// Build play/pause button
  Widget _buildPlayPauseButton(Color primaryColor) {
    if (isLoading) {
      return SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: Center(
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onPlayPause,
      borderRadius: BorderRadius.circular(buttonSize / 2),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build speed button
  Widget _buildSpeedButton(ThemeData theme) {
    return InkWell(
      onTap: onSpeedChange,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _getSpeedLabel(),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Get speed label
  String _getSpeedLabel() {
    if (speed == 1.0) return '1.0x';
    if (speed == 1.5) return '1.5x';
    if (speed == 2.0) return '2.0x';
    return '${speed.toStringAsFixed(1)}x';
  }
}

/// Compact playback controls (minimal version)
class CompactVoicePlaybackControls extends StatelessWidget {

  const CompactVoicePlaybackControls({
    required this.isPlaying, required this.isLoading, required this.currentTime, required this.totalTime, super.key,
    this.onPlayPause,
    this.primaryColor,
  });
  final bool isPlaying;
  final bool isLoading;
  final String currentTime;
  final String totalTime;
  final VoidCallback? onPlayPause;
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    return VoicePlaybackControls(
      isPlaying: isPlaying,
      isLoading: isLoading,
      currentTime: currentTime,
      totalTime: totalTime,
      speed: 1.0,
      onPlayPause: onPlayPause,
      buttonSize: 32.0,
      iconSize: 20.0,
      primaryColor: primaryColor,
      showSpeedControl: false,
    );
  }
}

/// Full playback controls with all features
class FullVoicePlaybackControls extends StatelessWidget {

  const FullVoicePlaybackControls({
    required this.isPlaying, required this.isLoading, required this.currentTime, required this.totalTime, required this.speed, super.key,
    this.onPlayPause,
    this.onSpeedChange,
    this.onRewind,
    this.onForward,
    this.primaryColor,
  });
  final bool isPlaying;
  final bool isLoading;
  final String currentTime;
  final String totalTime;
  final double speed;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSpeedChange;
  final VoidCallback? onRewind;
  final VoidCallback? onForward;
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rewind 10s
        if (onRewind != null)
          IconButton(
            onPressed: onRewind,
            icon: const Icon(Icons.replay_10),
            color: effectivePrimaryColor,
            iconSize: 24,
          ),

        const SizedBox(width: 8),

        // Play/Pause
        VoicePlaybackControls(
          isPlaying: isPlaying,
          isLoading: isLoading,
          currentTime: currentTime,
          totalTime: totalTime,
          speed: speed,
          onPlayPause: onPlayPause,
          onSpeedChange: onSpeedChange,
          primaryColor: primaryColor,
          buttonSize: 48.0,
          iconSize: 28.0,
        ),

        const SizedBox(width: 8),

        // Forward 10s
        if (onForward != null)
          IconButton(
            onPressed: onForward,
            icon: const Icon(Icons.forward_10),
            color: effectivePrimaryColor,
            iconSize: 24,
          ),
      ],
    );
  }
}

