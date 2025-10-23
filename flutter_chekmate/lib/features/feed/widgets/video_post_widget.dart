import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Video Post Widget - Video player for feed posts
///
/// Features:
/// - Real video_player integration
/// - Auto-play on scroll (visibility detection)
/// - Mute/unmute toggle
/// - Play/pause overlay
/// - Loading indicator
/// - Error handling
/// - Progress bar
/// - Duration display
///
/// Usage:
/// ```dart
/// VideoPostWidget(
///   videoUrl: 'https://example.com/video.mp4',
///   thumbnailUrl: 'https://example.com/thumbnail.jpg',
///   aspectRatio: 16 / 9,
///   autoPlay: true,
/// )
/// ```
class VideoPostWidget extends StatefulWidget {
  const VideoPostWidget({
    required this.videoUrl,
    super.key,
    this.thumbnailUrl,
    this.aspectRatio = 16 / 9,
    this.autoPlay = true,
    this.startMuted = true,
    this.onVideoEnd,
    this.onError,
  });

  final String videoUrl;
  final String? thumbnailUrl;
  final double aspectRatio;
  final bool autoPlay;
  final bool startMuted;
  final VoidCallback? onVideoEnd;
  final ValueChanged<String>? onError;

  @override
  State<VideoPostWidget> createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isMuted = true;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.startMuted;
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Allow background audio
        ),
      );

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Set initial mute state
        unawaited(_controller.setVolume(_isMuted ? 0.0 : 1.0));

        // Set looping
        unawaited(_controller.setLooping(true));

        // Add listener for video end
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            widget.onVideoEnd?.call();
          }
        });

        // Auto-play if enabled
        if (widget.autoPlay) {
          unawaited(_controller.play());
        }
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video';
        });
        widget.onError?.call(_errorMessage);
      }
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-${widget.videoUrl}'),
      onVisibilityChanged: (info) {
        if (!_isInitialized || _hasError) return;

        // Auto-play when 50%+ visible
        if (info.visibleFraction > 0.5) {
          if (!_controller.value.isPlaying) {
            _controller.play();
          }
        } else {
          // Auto-pause when scrolled out of view
          if (_controller.value.isPlaying) {
            _controller.pause();
          }
        }
      },
      child: GestureDetector(
        onTap: _toggleControls,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: Stack(
                children: [
                  // Video player or thumbnail
                  if (_isInitialized && !_hasError)
                    Positioned.fill(
                      child: VideoPlayer(_controller),
                    )
                  else if (widget.thumbnailUrl != null &&
                      widget.thumbnailUrl!.isNotEmpty)
                    Positioned.fill(
                      child: Image.network(
                        widget.thumbnailUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(color: Colors.black),

                  // Loading indicator
                  if (!_isInitialized && !_hasError)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),

                  // Error message
                  if (_hasError)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Play/Pause overlay (when paused)
                  if (_isInitialized &&
                      !_hasError &&
                      !_controller.value.isPlaying)
                    Center(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),

                  // Controls overlay
                  if (_isInitialized && !_hasError && _showControls)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress bar
                            VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: AppColors.primary,
                                bufferedColor: Colors.white30,
                                backgroundColor: Colors.white10,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            // Control buttons
                            Row(
                              children: [
                                // Play/Pause button
                                IconButton(
                                  onPressed: _togglePlayPause,
                                  icon: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                // Time display
                                ValueListenableBuilder(
                                  valueListenable: _controller,
                                  builder: (context, value, child) {
                                    return Text(
                                      '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                                const Spacer(),
                                // Mute/Unmute button
                                IconButton(
                                  onPressed: _toggleMute,
                                  icon: Icon(
                                    _isMuted
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
