import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';

/// Voice Prompt Player Widget
/// Plays voice prompt audio
class VoicePromptPlayer extends StatefulWidget {
  const VoicePromptPlayer({
    super.key,
    required this.voicePrompt,
    this.onPlayPause,
    this.onSeek,
  });

  final VoicePromptEntity voicePrompt;
  final VoidCallback? onPlayPause;
  final ValueChanged<Duration>? onSeek;

  @override
  State<VoicePromptPlayer> createState() => _VoicePromptPlayerState();
}

class _VoicePromptPlayerState extends State<VoicePromptPlayer> {
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Question
          Text(
            widget.voicePrompt.question,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Progress bar
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          const SizedBox(height: 8),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Play/Pause button
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                  widget.onPlayPause?.call();
                },
              ),

              // Duration
              Text(
                widget.voicePrompt.formattedDuration,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          // Transcription (if available)
          if (widget.voicePrompt.transcription != null) ...[
            const SizedBox(height: 16),
            Text(
              'Transcription:',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              widget.voicePrompt.transcription!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

