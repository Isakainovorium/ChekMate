import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/providers/voice_recording_providers.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/widgets/voice_playback_controls.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/widgets/voice_waveform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Voice message player widget
///
/// This widget displays a voice message in a chat bubble with playback controls.
/// It integrates with the voice playback state to manage playback.
///
/// Features:
/// - Voice message bubble (similar to text message bubble)
/// - Waveform visualization
/// - Playback controls (play/pause, speed, duration)
/// - Sender avatar and timestamp
/// - Customizable styling
///
/// Usage:
/// ```dart
/// VoiceMessagePlayer(
///   voiceMessage: message,
///   isMe: false,
///   showAvatar: true,
///   avatar: 'https://...',
///   time: '2m ago',
/// )
/// ```
class VoiceMessagePlayer extends ConsumerWidget {
  const VoiceMessagePlayer({
    required this.voiceMessage,
    required this.isMe,
    required this.showAvatar,
    required this.time,
    super.key,
    this.avatar,
    this.onPlaybackStateChanged,
    this.backgroundColor,
    this.textColor,
  });

  /// The voice message to display
  final VoiceMessageEntity voiceMessage;

  /// Whether this message is from the current user
  final bool isMe;

  /// Whether to show the sender's avatar
  final bool showAvatar;

  /// Avatar URL (for other user's messages)
  final String? avatar;

  /// Formatted time string
  final String time;

  /// Callback when playback state changes
  final void Function(bool isPlaying)? onPlaybackStateChanged;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom text color
  final Color? textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch playback state for this voice message
    final playbackState = ref.watch(voicePlaybackNotifierProvider);
    final playbackNotifier = ref.read(voicePlaybackNotifierProvider.notifier);

    // Check if this message is currently playing
    final isThisMessagePlaying =
        playbackState.voiceMessage?.id == voiceMessage.id;
    final isPlaying = isThisMessagePlaying && playbackState.isPlaying;
    final isLoading = isThisMessagePlaying && playbackState.isLoading;
    final currentPosition = isThisMessagePlaying ? playbackState.position : 0;
    final progress = isThisMessagePlaying ? playbackState.progress : 0.0;

    return _buildMessageBubble(
      context,
      ref,
      playbackNotifier,
      isPlaying: isPlaying,
      isLoading: isLoading,
      currentPosition: currentPosition,
      progress: progress,
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    WidgetRef ref,
    dynamic playbackNotifier, {
    required bool isPlaying,
    required bool isLoading,
    required int currentPosition,
    required double progress,
  }) {
    final theme = Theme.of(context);

    // Format current time
    String formatTime(int seconds) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    final currentTime = formatTime(currentPosition);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar (for other user's messages)
          if (!isMe && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
              child: avatar == null ? const Icon(Icons.person, size: 16) : null,
            ),
            const SizedBox(width: AppSpacing.xs),
          ] else if (!isMe && !showAvatar)
            const SizedBox(width: 40), // Spacing for alignment

          // Message Bubble
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: backgroundColor ??
                    (isMe ? AppColors.primary : Colors.grey.shade200),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Waveform
                  CompactVoiceWaveform(
                    progress: progress,
                    playedColor:
                        textColor ?? (isMe ? Colors.white : AppColors.primary),
                    unplayedColor: (textColor ??
                            (isMe ? Colors.white : AppColors.textSecondary))
                        .withValues(alpha: 0.3),
                    onSeek: (seekProgress) {
                      // Seek to position based on progress (0.0 to 1.0)
                      final seekPosition =
                          (seekProgress * voiceMessage.duration).round();
                      playbackNotifier.seek(seekPosition);
                    },
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Playback Controls
                  CompactVoicePlaybackControls(
                    isPlaying: isPlaying,
                    isLoading: isLoading,
                    currentTime: currentTime,
                    totalTime: voiceMessage.formattedDuration,
                    primaryColor:
                        textColor ?? (isMe ? Colors.white : AppColors.primary),
                    onPlayPause: () {
                      if (isPlaying) {
                        playbackNotifier.pause();
                      } else {
                        playbackNotifier.play(voiceMessage);
                      }
                      onPlaybackStateChanged?.call(!isPlaying);
                    },
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Timestamp
                  Text(
                    time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (textColor ??
                              (isMe ? Colors.white : AppColors.textSecondary))
                          .withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full voice message player with all features
///
/// This version includes speed control and larger waveform
class FullVoiceMessagePlayer extends ConsumerWidget {
  const FullVoiceMessagePlayer({
    required this.voiceMessage,
    required this.isMe,
    required this.showAvatar,
    required this.time,
    super.key,
    this.avatar,
    this.onPlaybackStateChanged,
  });
  final VoiceMessageEntity voiceMessage;
  final bool isMe;
  final bool showAvatar;
  final String? avatar;
  final String time;
  final void Function(bool isPlaying)? onPlaybackStateChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch playback state for this voice message
    final playbackState = ref.watch(voicePlaybackNotifierProvider);
    final playbackNotifier = ref.read(voicePlaybackNotifierProvider.notifier);

    // Check if this message is currently playing
    final isThisMessagePlaying =
        playbackState.voiceMessage?.id == voiceMessage.id;
    final isPlaying = isThisMessagePlaying && playbackState.isPlaying;
    final isLoading = isThisMessagePlaying && playbackState.isLoading;
    final currentPosition = isThisMessagePlaying ? playbackState.position : 0;
    final progress = isThisMessagePlaying ? playbackState.progress : 0.0;
    final speed = isThisMessagePlaying ? playbackState.speed : 1.0;

    // Format current time
    String formatTime(int seconds) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    final currentTime = formatTime(currentPosition);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar
          if (!isMe && showAvatar) ...[
            CircleAvatar(
              radius: 20,
              backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
              child: avatar == null ? const Icon(Icons.person, size: 20) : null,
            ),
            const SizedBox(width: AppSpacing.sm),
          ] else if (!isMe && !showAvatar)
            const SizedBox(width: 48),

          // Message Bubble
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Waveform
                  VoiceWaveform(
                    progress: progress,
                    playedColor: isMe ? Colors.white : AppColors.primary,
                    unplayedColor:
                        (isMe ? Colors.white : AppColors.textSecondary)
                            .withValues(alpha: 0.3),
                    barCount: 50,
                    maxBarHeight: 50.0,
                    onSeek: (seekProgress) {
                      // Seek to position based on progress (0.0 to 1.0)
                      final seekPosition =
                          (seekProgress * voiceMessage.duration).round();
                      playbackNotifier.seek(seekPosition);
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Playback Controls
                  VoicePlaybackControls(
                    isPlaying: isPlaying,
                    isLoading: isLoading,
                    currentTime: currentTime,
                    totalTime: voiceMessage.formattedDuration,
                    speed: speed,
                    primaryColor: isMe ? Colors.white : AppColors.primary,
                    onPlayPause: () {
                      if (isPlaying) {
                        playbackNotifier.pause();
                      } else {
                        playbackNotifier.play(voiceMessage);
                      }
                      onPlaybackStateChanged?.call(!isPlaying);
                    },
                    onSpeedChange: () {
                      // Toggle between 1.0x -> 1.5x -> 2.0x -> 1.0x
                      playbackNotifier.toggleSpeed();
                    },
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Timestamp
                  Text(
                    time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (isMe ? Colors.white : AppColors.textSecondary)
                          .withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
