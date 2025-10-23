import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:image_picker/image_picker.dart';

/// Camera Page - TikTok-like camera with filters and effects
///
/// Features:
/// - Photo/Video capture
/// - Real-time filters
/// - Beauty mode
/// - Flash control
/// - Camera flip
/// - Timer
class CameraPage extends StatefulWidget {
  const CameraPage({
    super.key,
    this.isVideo = false,
  });
  final bool isVideo;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isFlashOn = false;
  bool _isBeautyMode = false;
  int _selectedCameraIndex = 0;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        _showError('No cameras available');
        return;
      }

      _controller = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: widget.isVideo,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } on Exception catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          // Top Controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildTopControls(),
            ),
          ),

          // Side Controls (Filters, Beauty, etc.)
          Positioned(
            right: AppSpacing.md,
            top: MediaQuery.of(context).size.height * 0.3,
            child: _buildSideControls(),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildBottomControls(),
            ),
          ),

          // Recording Indicator
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.md,
              left: 0,
              right: 0,
              child: _buildRecordingIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),

          // Flash toggle
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideControls() {
    return Column(
      children: [
        // Flip camera
        _buildSideButton(
          icon: Icons.flip_camera_ios,
          label: 'Flip',
          onTap: _flipCamera,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Beauty mode
        _buildSideButton(
          icon: Icons.face_retouching_natural,
          label: 'Beauty',
          onTap: _toggleBeautyMode,
          isActive: _isBeautyMode,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Filters
        _buildSideButton(
          icon: Icons.auto_fix_high,
          label: 'Filters',
          onTap: _showFilterSelector,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Timer
        _buildSideButton(
          icon: Icons.timer,
          label: 'Timer',
          onTap: _showTimerSelector,
        ),
      ],
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.black45,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery
          GestureDetector(
            onTap: _openGallery,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Capture/Record button
          GestureDetector(
            onTap: widget.isVideo ? _toggleRecording : _takePicture,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: widget.isVideo && _isRecording
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.white,
                  borderRadius: widget.isVideo && _isRecording
                      ? BorderRadius.circular(8)
                      : null,
                ),
              ),
            ),
          ),

          // Placeholder for symmetry
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fiber_manual_record,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _formatDuration(_recordingSeconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } on Exception catch (e) {
      _showError('Failed to toggle flash: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    });

    await _controller?.dispose();
    await _initializeCamera();
  }

  void _toggleBeautyMode() {
    setState(() {
      _isBeautyMode = !_isBeautyMode;
    });
    _applyBeautyFilter();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.pop(context, image);
    } on Exception catch (e) {
      _showError('Failed to take picture: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      if (_isRecording) {
        final video = await _controller!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _recordingSeconds = 0;
        });
        if (!mounted) return;
        Navigator.pop(context, video);
      } else {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
        _startRecordingTimer();
      }
    } on Exception catch (e) {
      _showError('Failed to record video: $e');
    }
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingSeconds++;
        });
        _startRecordingTimer();
      }
    });
  }

  Future<void> _openGallery() async {
    final picker = ImagePicker();
    final XFile? media;

    if (widget.isVideo) {
      media = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      media = await picker.pickImage(source: ImageSource.gallery);
    }

    if (media != null) {
      if (!mounted) return;
      Navigator.pop(context, media);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showFilterSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Column(
          children: [
            Text(
              'Filters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Expanded(
              child: Center(
                child: Text(
                  'Filter selection coming soon',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Column(
          children: [
            Text(
              'Timer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Expanded(
              child: Center(
                child: Text(
                  'Timer selection coming soon',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyBeautyFilter() {
    // Beauty filter implementation would go here
    // This is a placeholder for the actual filter logic
    if (_isBeautyMode) {
      // Apply beauty filter settings to camera
      debugPrint('Beauty filter enabled');
    } else {
      // Remove beauty filter settings
      debugPrint('Beauty filter disabled');
    }
  }
}
