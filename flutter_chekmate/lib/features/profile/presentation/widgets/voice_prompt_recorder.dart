import 'package:flutter/material.dart';

/// Voice Prompt Recorder Widget
/// Records voice prompt audio
class VoicePromptRecorder extends StatefulWidget {
  const VoicePromptRecorder({
    super.key,
    required this.question,
    this.onRecordingComplete,
    this.onCancel,
  });

  final String question;
  final ValueChanged<String>? onRecordingComplete;
  final VoidCallback? onCancel;

  @override
  State<VoicePromptRecorder> createState() => _VoicePromptRecorderState();
}

class _VoicePromptRecorderState extends State<VoicePromptRecorder> {
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Question
          Text(
            widget.question,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Recording indicator
          if (_isRecording)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.mic,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.mic_none,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Duration
          Text(
            _formatDuration(_recordingDuration),
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel button
              if (_isRecording)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isRecording = false;
                      _recordingDuration = Duration.zero;
                    });
                    widget.onCancel?.call();
                  },
                ),

              // Record/Stop button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isRecording = !_isRecording;
                    if (!_isRecording) {
                      // Recording complete
                      widget.onRecordingComplete?.call('audio_url');
                      _recordingDuration = Duration.zero;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(_isRecording ? 'Stop' : 'Record'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

