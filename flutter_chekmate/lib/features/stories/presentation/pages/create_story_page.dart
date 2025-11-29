import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// Create Story Page
/// Allows users to capture or select media and create a story
class CreateStoryPage extends StatefulWidget {
  const CreateStoryPage({
    required this.onStoryCreated,
    super.key,
  });

  final void Function(String filePath, StoryType type, String? text) onStoryCreated;

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  
  XFile? _selectedFile;
  StoryType? _storyType;
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  bool _showTextInput = false;

  @override
  void dispose() {
    _textController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        _setSelectedFile(image, StoryType.image);
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _captureVideo() async {
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
      if (video != null) {
        _setSelectedFile(video, StoryType.video);
      }
    } catch (e) {
      _showError('Failed to capture video: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      // Show bottom sheet to choose image or video
      final result = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: AppColors.primary),
                title: const Text('Photo'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: AppColors.primary),
                title: const Text('Video'),
                onTap: () => Navigator.pop(context, 'video'),
              ),
            ],
          ),
        ),
      );

      if (result == 'image') {
        final image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1080,
          maxHeight: 1920,
          imageQuality: 85,
        );
        if (image != null) {
          _setSelectedFile(image, StoryType.image);
        }
      } else if (result == 'video') {
        final video = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 30),
        );
        if (video != null) {
          _setSelectedFile(video, StoryType.video);
        }
      }
    } catch (e) {
      _showError('Failed to pick from gallery: $e');
    }
  }

  void _setSelectedFile(XFile file, StoryType type) async {
    setState(() {
      _selectedFile = file;
      _storyType = type;
    });

    if (type == StoryType.video) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(file.path));
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.play();
      setState(() {});
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
      _storyType = null;
      _showTextInput = false;
      _textController.clear();
    });
    _videoController?.dispose();
    _videoController = null;
  }

  void _toggleTextInput() {
    setState(() => _showTextInput = !_showTextInput);
    HapticFeedback.lightImpact();
  }

  Future<void> _createStory() async {
    if (_selectedFile == null || _storyType == null) return;

    setState(() => _isLoading = true);

    try {
      widget.onStoryCreated(
        _selectedFile!.path,
        _storyType!,
        _textController.text.isNotEmpty ? _textController.text : null,
      );
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to create story: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _selectedFile == null
            ? _buildCaptureView()
            : _buildPreviewView(),
      ),
    );
  }

  Widget _buildCaptureView() {
    return Stack(
      children: [
        // Camera preview placeholder
        Container(
          color: Colors.grey.shade900,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Colors.white54,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Create Your Story',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Share moments that disappear in 24 hours',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Close button
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ),

        // Capture buttons
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                _buildCaptureButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: _pickFromGallery,
                ),

                // Photo button
                _buildCaptureButton(
                  icon: Icons.camera_alt,
                  label: 'Photo',
                  onTap: _captureImage,
                  isPrimary: true,
                ),

                // Video button
                _buildCaptureButton(
                  icon: Icons.videocam,
                  label: 'Video',
                  onTap: _captureVideo,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isPrimary ? 20 : 16),
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.primary : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: isPrimary
                  ? null
                  : Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? 32 : 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    return Stack(
      children: [
        // Media preview
        Positioned.fill(
          child: _storyType == StoryType.video && _videoController != null
              ? _videoController!.value.isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator())
              : Image.file(
                  File(_selectedFile!.path),
                  fit: BoxFit.cover,
                ),
        ),

        // Text overlay
        if (_textController.text.isNotEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _textController.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Text input overlay
        if (_showTextInput)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _textController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Add text...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => setState(() => _showTextInput = false),
                  ),
                ),
              ),
            ),
          ),

        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _clearSelection,
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleTextInput,
                      icon: Icon(
                        Icons.text_fields,
                        color: _showTextInput ? AppColors.primary : Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Bottom bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Your Story',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: _isLoading ? null : _createStory,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
