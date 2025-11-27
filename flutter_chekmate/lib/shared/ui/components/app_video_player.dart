import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppVideoPlayer - Comprehensive video player with controls
class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({
    required this.videoUrl,
    super.key,
    this.thumbnailUrl,
    this.title,
    this.description,
    this.autoPlay = false,
    this.showControls = true,
    this.allowFullscreen = true,
    this.aspectRatio = 16 / 9,
    this.onPlay,
    this.onPause,
    this.onEnd,
    this.onError,
  });

  final String videoUrl;
  final String? thumbnailUrl;
  final String? title;
  final String? description;
  final bool autoPlay;
  final bool showControls;
  final bool allowFullscreen;
  final double aspectRatio;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onEnd;
  final ValueChanged<String>? onError;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController _controlsAnimationController;
  late AnimationController _playButtonAnimationController;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _isFullscreen = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _playButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    if (widget.autoPlay) {
      _play();
    }

    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    _playButtonAnimationController.dispose();
    super.dispose();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        _hideControls();
      }
    });
  }

  void _showControlsTemporarily() {
    _showControlsMethod();
    _hideControlsAfterDelay();
  }

  void _showControlsMethod() {
    setState(() {
      _showControls = true;
    });
    _controlsAnimationController.forward();
  }

  void _hideControls() {
    _controlsAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControls();
    } else {
      _showControlsTemporarily();
    }
  }

  void _play() {
    setState(() {
      _isPlaying = true;
      _isLoading = true;
    });
    _playButtonAnimationController.forward();

    // Simulate video loading and playback
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _duration = const Duration(minutes: 5, seconds: 30); // Mock duration
        });
        widget.onPlay?.call();
        _startPositionTimer();
      }
    });
  }

  void _pause() {
    setState(() {
      _isPlaying = false;
    });
    _playButtonAnimationController.reverse();
    widget.onPause?.call();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _startPositionTimer() {
    // Mock position updates
    if (_isPlaying && mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isPlaying) {
          setState(() {
            _position = Duration(seconds: _position.inSeconds + 1);
          });

          if (_position >= _duration) {
            _onVideoEnd();
          } else {
            _startPositionTimer();
          }
        }
      });
    }
  }

  void _onVideoEnd() {
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
    _playButtonAnimationController.reverse();
    widget.onEnd?.call();
  }

  void _seekTo(Duration position) {
    setState(() {
      _position = position;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _volume = 0.0;
      } else {
        _volume = 1.0;
      }
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              _FullscreenVideoPlayer(
            videoUrl: widget.videoUrl,
            title: widget.title,
            isPlaying: _isPlaying,
            position: _position,
            duration: _duration,
            volume: _volume,
            onClose: () {
              Navigator.of(context).pop();
              setState(() {
                _isFullscreen = false;
              });
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
              // Video content area
              Positioned.fill(
                child: _buildVideoContent(),
              ),

              // Overlay for tap detection
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.showControls ? _toggleControls : null,
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Loading indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),

              // Error state
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
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _errorMessage ?? 'Failed to load video',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                          });
                          _play();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              // Play button overlay (when paused)
              if (!_isPlaying && !_isLoading && !_hasError)
                Center(
                  child: GestureDetector(
                    onTap: _play,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
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

              // Controls
              if (widget.showControls)
                AnimatedBuilder(
                  animation: _controlsAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _showControls
                          ? _controlsAnimationController.value
                          : 0.0,
                      child: _buildControls(theme),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (!_isPlaying && widget.thumbnailUrl != null) {
      return Image.network(
        widget.thumbnailUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: Icon(
                Icons.video_library,
                color: Colors.white54,
                size: 48,
              ),
            ),
          );
        },
      );
    }

    // Mock video content (in real implementation, use video_player package)
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white54,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Top controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (widget.title != null)
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  if (widget.allowFullscreen)
                    IconButton(
                      onPressed: _toggleFullscreen,
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Progress bar
                  _VideoProgressBar(
                    position: _position,
                    duration: _duration,
                    onSeek: _seekTo,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Control buttons
                  Row(
                    children: [
                      IconButton(
                        onPressed: _togglePlayPause,
                        icon: AnimatedBuilder(
                          animation: _playButtonAnimationController,
                          builder: (context, child) {
                            return Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      // Time display
                      Text(
                        '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),

                      const Spacer(),

                      // Volume controls
                      IconButton(
                        onPressed: _toggleMute,
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

/// Video progress bar widget
class _VideoProgressBar extends StatefulWidget {
  const _VideoProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  State<_VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<_VideoProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final progress = widget.duration.inMilliseconds > 0
        ? widget.position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withOpacity(0.3),
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        trackHeight: 3,
      ),
      child: Slider(
        value: _isDragging ? _dragValue : progress.clamp(0.0, 1.0),
        onChanged: (value) {
          setState(() {
            _isDragging = true;
            _dragValue = value;
          });
        },
        onChangeEnd: (value) {
          final seekPosition = Duration(
            milliseconds: (value * widget.duration.inMilliseconds).round(),
          );
          widget.onSeek(seekPosition);
          setState(() {
            _isDragging = false;
          });
        },
      ),
    );
  }
}

/// Fullscreen video player
class _FullscreenVideoPlayer extends StatelessWidget {
  const _FullscreenVideoPlayer({
    required this.videoUrl,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.volume,
    required this.onClose,
    this.title,
  });

  final String videoUrl;
  final String? title;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Fullscreen video content
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white54,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            // Title
            if (title != null)
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                right: 60,
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// AppVideoThumbnail - Video thumbnail with play button
class AppVideoThumbnail extends StatelessWidget {
  const AppVideoThumbnail({
    required this.videoUrl,
    required this.thumbnailUrl,
    super.key,
    this.width = 200,
    this.height = 112,
    this.borderRadius = 8,
    this.duration,
    this.onTap,
    this.showPlayButton = true,
  });

  final String videoUrl;
  final String thumbnailUrl;
  final double width;
  final double height;
  final double borderRadius;
  final Duration? duration;
  final VoidCallback? onTap;
  final bool showPlayButton;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.grey[300],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Thumbnail image
              Image.network(
                thumbnailUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.video_library,
                        color: Colors.white54,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),

              // Play button overlay
              if (showPlayButton)
                Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

              // Duration badge
              if (duration != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(duration!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
