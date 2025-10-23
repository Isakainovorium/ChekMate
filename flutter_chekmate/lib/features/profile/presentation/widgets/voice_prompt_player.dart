import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/providers/voice_recording_providers.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_playback_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Voice Prompt Player Widget
///
/// Displays and plays voice prompts on user profiles (Bumble-style).
/// Features:
/// - Show question
/// - Play/pause button
/// - Waveform visualization
/// - Duration display
/// - Auto-play option
///
/// Usage:
/// ```dart
/// VoicePromptPlayer(
///   voicePrompt: voicePrompt,
///   autoPlay: false,
/// )
/// ```
class VoicePromptPlayer extends ConsumerStatefulWidget {
  const VoicePromptPlayer({
    required this.voicePrompt,
    super.key,
    this.autoPlay = false,
    this.showWaveform = true,
  });

  /// The voice prompt to display
  final VoicePromptEntity voicePrompt;

  /// Whether to auto-play when widget is built
  final bool autoPlay;

  /// Whether to show waveform visualization
  final bool showWaveform;

  @override
  ConsumerState<VoicePromptPlayer> createState() => _VoicePromptPlayerState();
}

class _VoicePromptPlayerState extends ConsumerState<VoicePromptPlayer> {
  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playPrompt();
      });
    }
  }

  void _playPrompt() {
    final playbackNotifier = ref.read(voicePlaybackNotifierProvider.notifier);
    final voiceMessage = VoiceMessageEntity(
      id: widget.voicePrompt.id,
      senderId: 'profile',
      receiverId: 'prompt',
      downloadUrl: widget.voicePrompt.audioUrl,
      duration: widget.voicePrompt.duration,
      fileName: 'prompt_${widget.voicePrompt.id}.m4a',
      fileSize: 0,
      createdAt: widget.voicePrompt.createdAt,
    );
    playbackNotifier.play(voiceMessage);
  }

  void _togglePlayback() {
    final playbackState = ref.read(voicePlaybackNotifierProvider);
    final playbackNotifier = ref.read(voicePlaybackNotifierProvider.notifier);

    if (playbackState.isPlaying) {
      playbackNotifier.pause();
    } else if (playbackState.status == VoicePlaybackStatus.paused) {
      playbackNotifier.resume();
    } else {
      _playPrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(voicePlaybackNotifierProvider);
    final isPlaying = playbackState.isPlaying &&
        playbackState.voiceMessage?.id == widget.voicePrompt.id;
    final isPaused = playbackState.status == VoicePlaybackStatus.paused &&
        playbackState.voiceMessage?.id == widget.voicePrompt.id;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VOICE PROMPT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Question
          Text(
            widget.voicePrompt.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Playback Controls
          Row(
            children: [
              // Play/Pause Button
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.pause
                        : isPaused
                            ? Icons.play_arrow
                            : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Waveform or Progress
              Expanded(
                child: widget.showWaveform
                    ? _buildWaveform(isPlaying, playbackState.progress)
                    : _buildProgressBar(isPlaying, playbackState.progress),
              ),

              const SizedBox(width: AppSpacing.md),

              // Duration
              Text(
                isPlaying || isPaused
                    ? '${playbackState.formattedPosition} / ${widget.voicePrompt.formatDuration()}'
                    : widget.voicePrompt.formatDuration(),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(bool isPlaying, double progress) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(30, (index) {
          final heights = [0.3, 0.5, 0.7, 0.9, 0.6, 0.4, 0.8, 0.5, 0.6, 0.7];
          final height = heights[index % heights.length];
          final isActive = (index / 30) <= progress;

          return Container(
            width: 2,
            height: 40 * height,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressBar(bool isPlaying, double progress) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
      ],
    );
  }
}

/// Compact Voice Prompt Player
///
/// Smaller version for profile cards
class CompactVoicePromptPlayer extends ConsumerWidget {
  const CompactVoicePromptPlayer({
    required this.voicePrompt,
    super.key,
  });

  final VoicePromptEntity voicePrompt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mic,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              voicePrompt.question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            voicePrompt.formatDuration(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

