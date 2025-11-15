import 'package:flutter/material.dart';

/// Video Post Widget
/// Displays a video post with controls
class VideoPostWidget extends StatefulWidget {
  const VideoPostWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.autoPlay = false,
    this.muted = false,
    this.onTap,
  });

  final String videoUrl;
  final String? thumbnailUrl;
  final bool autoPlay;
  final bool muted;
  final VoidCallback? onTap;

  @override
  State<VideoPostWidget> createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  bool _isPlaying = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.autoPlay;
    _isMuted = widget.muted;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPlaying = !_isPlaying;
        });
        widget.onTap?.call();
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail or video
              if (widget.thumbnailUrl != null && !_isPlaying)
                Image.network(
                  widget.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.video_library,
                        size: 64,
                        color: Colors.white54,
                      ),
                    );
                  },
                )
              else
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                ),

              // Play/Pause overlay
              if (!_isPlaying)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Mute button
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

