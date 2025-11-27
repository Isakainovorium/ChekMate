import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/features/stories/models/story_model.dart';

/// Full-screen Story Viewer with Instagram-style navigation
/// Features:
/// - Tap left/right to navigate
/// - Progress bar indicators
/// - Auto-advance timer
/// - Pause on hold
class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({
    required this.storyUser,
    super.key,
    this.onClose,
  });

  final StoryUser storyUser;
  final VoidCallback? onClose;

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentStoryIndex = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    
    // Set status bar style for dark background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });

    _startProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    // Reset status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  void _startProgress() {
    _progressController.forward(from: 0);
  }

  void _pauseProgress() {
    _progressController.stop();
    setState(() => _isPaused = true);
  }

  void _resumeProgress() {
    _progressController.forward();
    setState(() => _isPaused = false);
  }

  void _nextStory() {
    if (_currentStoryIndex < widget.storyUser.stories.length - 1) {
      setState(() => _currentStoryIndex++);
      _startProgress();
    } else {
      _closeViewer();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() => _currentStoryIndex--);
      _startProgress();
    } else {
      // Reset current story
      _startProgress();
    }
  }

  void _closeViewer() {
    widget.onClose?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final stories = widget.storyUser.stories;
    final currentStory = stories.isNotEmpty ? stories[_currentStoryIndex] : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _pauseProgress(),
        onTapUp: (details) {
          _resumeProgress();
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 3) {
            _previousStory();
          } else if (details.localPosition.dx > screenWidth * 2 / 3) {
            _nextStory();
          }
        },
        onLongPressStart: (_) => _pauseProgress(),
        onLongPressEnd: (_) => _resumeProgress(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story content
            if (currentStory != null)
              _buildStoryContent(currentStory)
            else
              _buildPlaceholderStory(),

            // Top gradient overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Progress indicators and header
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  // Progress bars
                  Row(
                    children: List.generate(stories.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              double progress;
                              if (index < _currentStoryIndex) {
                                progress = 1.0;
                              } else if (index == _currentStoryIndex) {
                                progress = _progressController.value;
                              } else {
                                progress = 0.0;
                              }
                              return LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  // User header
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: widget.storyUser.avatar != null
                              ? DecorationImage(
                                  image: NetworkImage(widget.storyUser.avatar!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: widget.storyUser.avatar == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),

                      const SizedBox(width: 12),

                      // Username and time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.storyUser.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (currentStory != null)
                              Text(
                                _formatTimestamp(currentStory.timestamp),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Close button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _closeViewer,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Paused indicator
            if (_isPaused)
              const Center(
                child: Icon(
                  Icons.pause_circle_outline,
                  color: Colors.white,
                  size: 80,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(StoryModel story) {
    // Display media based on type
    if (story.mediaType == 'image') {
      return Image.network(
        story.mediaUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderStory();
        },
      );
    }

    // Placeholder for video or other media types
    return _buildPlaceholderStory();
  }

  Widget _buildPlaceholderStory() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.storyGradient,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                image: widget.storyUser.avatar != null
                    ? DecorationImage(
                        image: NetworkImage(widget.storyUser.avatar!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.storyUser.avatar == null
                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              widget.storyUser.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Shared a moment',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
