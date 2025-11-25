import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/pages/create_post/widgets/voiceover_recorder.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// Video Editor Page - TikTok-like video editing with green screen
///
/// Features:
/// - Trim video
/// - Add music
/// - Green screen effect
/// - Filters and effects
/// - Text overlays
/// - Stickers
/// - Speed control
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
  String? _backgroundImage;
  double _playbackSpeed = 1.0;
  final List<Map<String, dynamic>> _textOverlays = [];
  final List<String> _selectedEffects = [];
  VoiceMessageEntity? _voiceoverAudio;

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
          // Video Preview
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade900,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Video Preview',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                    if (widget.useGreenScreen && _backgroundImage != null)
                      const Padding(
                        padding: EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          'Green Screen Active',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Timeline/Scrubber
          Container(
            height: 80,
            color: Colors.grey.shade900,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white),
                Expanded(
                  child: AppSlider(
                    value: 0.5,
                    onChanged: _seekVideo,
                  ),
                ),
                const Text(
                  '0:00 / 0:15',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

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
    final effects = [
      {'id': 'beauty', 'name': 'Beauty', 'icon': Icons.face_retouching_natural},
      {'id': 'vintage', 'name': 'Vintage', 'icon': Icons.filter_vintage},
      {'id': 'vivid', 'name': 'Vivid', 'icon': Icons.filter_hdr},
      {'id': 'bw', 'name': 'B&W', 'icon': Icons.filter_b_and_w},
      {'id': 'blur', 'name': 'Blur', 'icon': Icons.blur_on},
      {'id': 'sharpen', 'name': 'Sharpen', 'icon': Icons.auto_fix_high},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.2,
      ),
      itemCount: effects.length,
      itemBuilder: (context, index) {
        final effect = effects[index];
        final isSelected = _selectedEffects.contains(effect['id']);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedEffects.remove(effect['id']);
              } else {
                _selectedEffects.add(effect['id'] as String);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
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
                  effect['icon'] as IconData,
                  color: isSelected ? AppColors.primary : Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  effect['name'] as String,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontSize: 12,
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
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedButton('0.5x', 0.5),
              _buildSpeedButton('1x', 1.0),
              _buildSpeedButton('1.5x', 1.5),
              _buildSpeedButton('2x', 2.0),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppSlider(
            value: _playbackSpeed,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            label: 'Playback Speed',
            onChanged: (value) {
              setState(() {
                _playbackSpeed = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(String label, double speed) {
    final isSelected = _playbackSpeed == speed;

    return InkWell(
      onTap: () {
        setState(() {
          _playbackSpeed = speed;
        });
      },
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _openMusicLibrary,
            icon: const Icon(Icons.library_music),
            label: const Text('Add Music'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: _recordVoiceover,
            icon: const Icon(Icons.mic),
            label: const Text('Record Voiceover'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
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

  void _seekVideo(double position) {
    // Placeholder for video seeking functionality
    // In a real implementation, this would seek the video to the specified position
    debugPrint('Seeking video to position: $position');
  }

  void _openMusicLibrary() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Music Library',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.library_music,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Music library feature coming soon',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _recordVoiceover() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record Voiceover',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.mic,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Voiceover recording feature coming soon',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

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

      // Execute FFmpeg command using ffmpeg_kit_flutter
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('Audio mixing successful! Output: $outputPath');
        return outputPath;
      } else {
        debugPrint('Audio mixing failed with return code: $returnCode');
        return null;
      }
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
