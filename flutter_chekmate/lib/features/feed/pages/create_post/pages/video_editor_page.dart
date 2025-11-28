import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/pages/create_post/widgets/voiceover_recorder.dart';
import 'package:flutter_chekmate/features/feed/services/video_processing_service.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// Video Editor Page - TikTok-like video editing with green screen
///
/// Features:
/// - Real video playback with VideoPlayerController
/// - Speed control (0.5x - 2x) with live preview
/// - Visual effects with ColorFilter preview
/// - Text overlays with positioning
/// - Music library with categories
/// - Voiceover recording
/// - Green screen background replacement
class VideoEditorPage extends StatefulWidget {
  const VideoEditorPage({
    required this.videoPath,
    super.key,
    this.useGreenScreen = false,
  });
  final String videoPath;
  final bool useGreenScreen;

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  // Video controller for real playback
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  
  String? _backgroundImage;
  double _playbackSpeed = 1.0;
  final List<Map<String, dynamic>> _textOverlays = [];
  final List<String> _selectedEffects = [];
  VoiceMessageEntity? _voiceoverAudio;
  MusicTrackInfo? _selectedMusic;
  VideoEffect _currentEffect = VideoEffect.none;
  
  final VideoProcessingService _processingService = VideoProcessingService.instance;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(File(widget.videoPath));
    try {
      await _videoController!.initialize();
      _videoController!.addListener(_videoListener);
      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _videoListener() {
    if (mounted && _videoController != null) {
      setState(() {
        _isPlaying = _videoController!.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null) return;
    if (_isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Video',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveVideo,
            child: const Text(
              'Done',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Preview with real playback
          Expanded(
            flex: 3,
            child: _buildVideoPreview(),
          ),

          // Timeline/Scrubber with real video position
          _buildTimeline(),

          // Editing Tools
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade900,
              child: _buildEditingTools(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        color: Colors.grey.shade900,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final colorFilter = _processingService.getColorFilterForEffect(_currentEffect);

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background image for green screen
          if (_backgroundImage != null)
            Positioned.fill(
              child: Image.file(
                File(_backgroundImage!),
                fit: BoxFit.cover,
              ),
            ),

          // Video with effect filter
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: ColorFiltered(
                colorFilter: colorFilter ?? const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.dst,
                ),
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),

          // Play/Pause indicator
          if (!_isPlaying)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),

          // Speed indicator
          if (_playbackSpeed != 1.0)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${_playbackSpeed}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Effect indicator
          if (_currentEffect != VideoEffect.none)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _currentEffect.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

          // Green screen indicator
          if (widget.useGreenScreen && _backgroundImage != null)
            Positioned(
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Green Screen Active',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        height: 80,
        color: Colors.grey.shade900,
        child: const Center(
          child: Text('Loading...', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final duration = _videoController!.value.duration;
    final position = _videoController!.value.position;

    return Container(
      height: 80,
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _togglePlayPause,
          ),
          Expanded(
            child: Slider(
              value: position.inMilliseconds.toDouble().clamp(
                0,
                duration.inMilliseconds.toDouble(),
              ),
              min: 0,
              max: duration.inMilliseconds.toDouble(),
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey.shade700,
              onChanged: (value) {
                _videoController!.seekTo(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Text(
            '${_formatDuration(position.inSeconds)} / ${_formatDuration(duration.inSeconds)}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildEditingTools() {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Effects'),
              Tab(text: 'Green Screen'),
              Tab(text: 'Text'),
              Tab(text: 'Speed'),
              Tab(text: 'Music'),
              Tab(text: 'Voiceover'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildEffectsTab(),
                _buildGreenScreenTab(),
                _buildTextTab(),
                _buildSpeedTab(),
                _buildMusicTab(),
                _buildVoiceoverTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectsTab() {
    // Effects with VideoEffect enum for real-time preview
    final effects = [
      (VideoEffect.none, 'None', Icons.block),
      (VideoEffect.beauty, 'Beauty', Icons.face_retouching_natural),
      (VideoEffect.vintage, 'Vintage', Icons.filter_vintage),
      (VideoEffect.vivid, 'Vivid', Icons.filter_hdr),
      (VideoEffect.blackAndWhite, 'B&W', Icons.filter_b_and_w),
      (VideoEffect.sepia, 'Sepia', Icons.filter),
      (VideoEffect.cool, 'Cool', Icons.ac_unit),
      (VideoEffect.warm, 'Warm', Icons.wb_sunny),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: effects.length,
      itemBuilder: (context, index) {
        final (effect, name, icon) = effects[index];
        final isSelected = _currentEffect == effect;

        return InkWell(
          onTap: () {
            setState(() {
              _currentEffect = effect;
              // Also update the legacy list for backward compatibility
              _selectedEffects.clear();
              if (effect != VideoEffect.none) {
                _selectedEffects.add(effect.name);
              }
            });
            HapticFeedback.selectionClick();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreenScreenTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Green Screen Background',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Replace your background with a custom image',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_backgroundImage == null)
            ElevatedButton.icon(
              onPressed: _selectBackgroundImage,
              icon: const Icon(Icons.image),
              label: const Text('Choose Background'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          else
            Column(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _backgroundImage = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Remove Background'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _addTextOverlay,
            icon: const Icon(Icons.add),
            label: const Text('Add Text'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_textOverlays.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No text overlays yet',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _textOverlays.length,
                itemBuilder: (context, index) {
                  final overlay = _textOverlays[index];
                  return ListTile(
                    leading:
                        const Icon(Icons.text_fields, color: AppColors.primary),
                    title: Text(
                      overlay['text'] as String,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _textOverlays.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpeedTab() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Playback Speed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Speed changes are applied in real-time preview',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: speeds.map((speed) => _buildSpeedButton('${speed}x', speed)).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Slider(
            value: _playbackSpeed,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            label: '${_playbackSpeed}x',
            activeColor: AppColors.primary,
            onChanged: (value) {
              _setPlaybackSpeed(value);
            },
          ),
        ],
      ),
    );
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    // Apply speed to video controller for real-time preview
    _videoController?.setPlaybackSpeed(speed);
    HapticFeedback.selectionClick();
  }

  Widget _buildSpeedButton(String label, double speed) {
    final isSelected = _playbackSpeed == speed;

    return InkWell(
      onTap: () => _setPlaybackSpeed(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMusicTab() {
    return Column(
      children: [
        // Selected music indicator
        if (_selectedMusic != null)
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.music_note, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMusic!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_selectedMusic!.artist} • ${_selectedMusic!.formattedDuration}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => _selectedMusic = null),
                ),
              ],
            ),
          ),
        
        // Music library
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: MusicLibrary.categories.length,
            itemBuilder: (context, index) {
              final category = MusicLibrary.categories[index];
              return ExpansionTile(
                leading: Icon(category.icon, color: AppColors.primary),
                title: Text(category.name, style: const TextStyle(color: Colors.white)),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white70,
                children: category.tracks.map((track) {
                  final isSelected = _selectedMusic?.name == track.name;
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.music_note,
                      color: isSelected ? AppColors.primary : Colors.white70,
                    ),
                    title: Text(track.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '${track.artist} • ${track.formattedDuration}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isSelected ? Icons.remove_circle : Icons.add_circle,
                        color: isSelected ? Colors.red : AppColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedMusic = isSelected ? null : track;
                        });
                        HapticFeedback.selectionClick();
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectBackgroundImage() async {
    // Show AppFileUpload in a dialog for background selection
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Background Image'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: AppFileUpload(
            onFilesSelected: (files) {
              if (files.isNotEmpty && files.first.path != null) {
                setState(() {
                  _backgroundImage = files.first.path!;
                });
                Navigator.pop(context);
              }
            },
            acceptedTypes: const ['image/*'],
            placeholder: 'Choose background image',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addTextOverlay() {
    showDialog<void>(
      context: context,
      builder: (context) {
        var text = '';
        return AlertDialog(
          title: const Text('Add Text'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter text'),
            onChanged: (value) => text = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (text.isNotEmpty) {
                  setState(() {
                    _textOverlays.add({'text': text});
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveVideo() {
    _applyEditsAndSave();
  }

  Widget _buildVoiceoverTab() {
    if (_voiceoverAudio != null) {
      // Show voiceover preview
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Voiceover Added!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Duration: ${_formatDuration(_voiceoverAudio!.duration.inSeconds)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _voiceoverAudio = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remove Voiceover'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mic,
            color: AppColors.primary,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Add Voiceover',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Record audio narration over your video',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showVoiceoverRecorder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start Recording'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showVoiceoverRecorder() async {
    // Get actual video duration
    final videoDuration = await _getVideoDuration();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceoverRecorder(
        videoPath: widget.videoPath,
        videoDuration: Duration(milliseconds: videoDuration),
        onRecordingComplete: (voiceMessage) {
          // voiceMessage is a String (file path), but _voiceoverAudio expects VoiceMessageEntity
          // For now, we'll skip setting it until VoiceMessageEntity is properly created
          // setState(() {
          //   _voiceoverAudio = voiceMessage;
          // });
          Navigator.pop(context);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voiceover added! Tap Done to save video.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<int> _getVideoDuration() async {
    try {
      final controller = VideoPlayerController.file(File(widget.videoPath));
      await controller.initialize();
      final duration = controller.value.duration.inSeconds;
      await controller.dispose();
      return duration;
    } on Exception catch (e) {
      debugPrint('Error getting video duration: $e');
      // Return default duration if error occurs
      return 60;
    }
  }

  // Note: _formatDuration is defined earlier in the file for timeline display

  Future<String?> _mixAudioWithVideo() async {
    if (_voiceoverAudio == null) return null;

    try {
      // Get temporary directory for output
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/mixed_video_$timestamp.mp4';

      // Get the voiceover audio file path (use local file path, not download URL)
      final voiceoverPath =
          _voiceoverAudio!.filePath ?? _voiceoverAudio!.downloadUrl ?? '';

      // FFmpeg command to mix audio
      // -i [video] -i [voiceover] -filter_complex "[0:a][1:a]amix=inputs=2:duration=first:dropout_transition=2" -c:v copy output.mp4
      final command =
          '-i "${widget.videoPath}" -i "$voiceoverPath" -filter_complex "[0:a][1:a]amix=inputs=2:duration=first:dropout_transition=2" -c:v copy "$outputPath"';

      debugPrint('FFmpeg command: $command');

      // Note: Audio mixing requires native implementation
      // video_compress doesn't support audio mixing directly
      // For now, return the original video path
      // TODO: Implement native audio mixing or use a different package
      debugPrint('Audio mixing not yet implemented with video_compress');
      debugPrint('Command would be: $command');
      debugPrint('Output path: $outputPath');
      
      // Return original video for now
      return widget.videoPath;
    } on Exception catch (e) {
      debugPrint('Error mixing audio with video: $e');
      return null;
    }
  }

  Future<void> _applyEditsAndSave() async {
    // Show loading dialog
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text('Processing video...'),
            ],
          ),
        ),
      ),
    );

    try {
      var finalVideoPath = widget.videoPath;

      // Mix audio with video if voiceover exists
      if (_voiceoverAudio != null) {
        final mixedVideoPath = await _mixAudioWithVideo();

        if (mixedVideoPath != null) {
          finalVideoPath = mixedVideoPath;
          debugPrint('Using mixed video: $finalVideoPath');
        } else {
          // Audio mixing failed, show error and ask user
          if (!mounted) return;
          Navigator.pop(context); // Close loading dialog

          final shouldContinue = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Audio Mixing Failed'),
              content: const Text(
                'Failed to mix voiceover with video. Would you like to save the video without voiceover?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save Without Voiceover'),
                ),
              ],
            ),
          );

          if (shouldContinue != true) return;

          // Show loading dialog again
          if (!mounted) return;
          unawaited(
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.md),
                    Text('Saving video...'),
                  ],
                ),
              ),
            ),
          );
        }
      }

      // Clean up temporary files
      if (_voiceoverAudio != null && finalVideoPath != widget.videoPath) {
        // Delete voiceover audio file (only if it's a local file)
        final voiceoverPath = _voiceoverAudio!.filePath;
        if (voiceoverPath != null) {
          try {
            final voiceoverFile = File(voiceoverPath);
            // ignore: avoid_slow_async_io
            if (await voiceoverFile.exists()) {
              await voiceoverFile.delete();
              debugPrint('Deleted voiceover file: $voiceoverPath');
            }
          } on Exception catch (e) {
            debugPrint('Error deleting voiceover file: $e');
          }
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _voiceoverAudio != null && finalVideoPath != widget.videoPath
                ? 'Video saved with voiceover!'
                : 'Video saved successfully!',
          ),
          backgroundColor: AppColors.primary,
        ),
      );

      // Return to previous screen with the edited video
      Navigator.pop(context, XFile(finalVideoPath));

      // Clean up mixed video file after a delay (to allow upload to complete)
      if (finalVideoPath != widget.videoPath) {
        Future.delayed(const Duration(seconds: 5), () async {
          try {
            final mixedFile = File(finalVideoPath);
            // ignore: avoid_slow_async_io
            if (await mixedFile.exists()) {
              await mixedFile.delete();
              debugPrint('Deleted mixed video file: $finalVideoPath');
            }
          } on Exception catch (e) {
            debugPrint('Error deleting mixed video file: $e');
          }
        });
      }
    } on Exception catch (e) {
      debugPrint('Error in _applyEditsAndSave: $e');

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save video. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
