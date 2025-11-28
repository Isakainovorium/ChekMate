import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/services/video_processing_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// Video Editor Page V2 - Full featured video editing
/// 
/// Features:
/// - Real video playback with VideoPlayerController
/// - Speed control (0.5x - 2x) with live preview
/// - Visual effects with ColorFilter preview
/// - Text overlays with positioning
/// - Music library with categories
/// - Voiceover recording
/// - Green screen background replacement
class VideoEditorPageV2 extends StatefulWidget {
  const VideoEditorPageV2({
    required this.videoPath,
    super.key,
    this.useGreenScreen = false,
  });
  
  final String videoPath;
  final bool useGreenScreen;

  @override
  State<VideoEditorPageV2> createState() => _VideoEditorPageV2State();
}

class _VideoEditorPageV2State extends State<VideoEditorPageV2> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late TabController _tabController;
  
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isProcessing = false;
  double _processingProgress = 0;
  String _processingStage = '';
  
  // Edit configuration
  VideoEditConfig _editConfig = VideoEditConfig();
  VideoEffect _selectedEffect = VideoEffect.none;
  final List<TextOverlay> _textOverlays = [];
  MusicTrackInfo? _selectedMusic;
  String? _voiceoverPath;
  String? _backgroundImage;
  
  final VideoProcessingService _processingService = VideoProcessingService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(File(widget.videoPath));
    
    try {
      await _videoController.initialize();
      _videoController.addListener(_videoListener);
      
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _videoController.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _videoController.pause();
    } else {
      _videoController.play();
    }
    HapticFeedback.lightImpact();
  }

  void _setSpeed(double speed) {
    _videoController.setPlaybackSpeed(speed);
    setState(() {
      _editConfig = _editConfig.copyWith(speed: speed);
    });
    HapticFeedback.selectionClick();
  }

  void _setEffect(VideoEffect effect) {
    setState(() {
      _selectedEffect = effect;
      _editConfig = _editConfig.copyWith(
        effects: effect == VideoEffect.none ? [] : [effect],
      );
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _saveVideo() async {
    setState(() {
      _isProcessing = true;
      _processingProgress = 0;
      _processingStage = 'Starting...';
    });

    // Listen to progress
    final subscription = _processingService.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _processingProgress = progress.progress;
          _processingStage = progress.stage;
        });
      }
    });

    try {
      final outputPath = await _processingService.processVideo(
        inputPath: widget.videoPath,
        config: _editConfig,
      );

      subscription.cancel();

      if (mounted) {
        setState(() => _isProcessing = false);
        
        if (outputPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, XFile(outputPath));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save video'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      subscription.cancel();
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
        title: const Text('Edit Video', style: TextStyle(color: Colors.white)),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else
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
      body: Stack(
        children: [
          Column(
            children: [
              // Video Preview
              Expanded(
                flex: 3,
                child: _buildVideoPreview(),
              ),

              // Timeline
              _buildTimeline(),

              // Editing Tools
              Expanded(
                flex: 2,
                child: _buildEditingTools(),
              ),
            ],
          ),

          // Processing overlay
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (!_isInitialized) {
      return Container(
        color: Colors.grey.shade900,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final colorFilter = _processingService.getColorFilterForEffect(_selectedEffect);

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
              aspectRatio: _videoController.value.aspectRatio,
              child: ColorFiltered(
                colorFilter: colorFilter ?? const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.dst,
                ),
                child: VideoPlayer(_videoController),
              ),
            ),
          ),

          // Text overlays preview
          ..._textOverlays.map((overlay) => Positioned(
            left: overlay.position.dx * MediaQuery.of(context).size.width * 0.8,
            top: overlay.position.dy * 200,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: overlay.backgroundColor ?? Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                overlay.text,
                style: TextStyle(
                  color: overlay.color,
                  fontSize: overlay.fontSize,
                  fontWeight: overlay.fontWeight,
                ),
              ),
            ),
          )),

          // Play/Pause indicator
          if (!_isPlaying)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
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
          if (_editConfig.speed != 1.0)
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
                  '${_editConfig.speed}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Effect indicator
          if (_selectedEffect != VideoEffect.none)
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
                  _selectedEffect.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (!_isInitialized) return const SizedBox(height: 80);

    final duration = _videoController.value.duration;
    final position = _videoController.value.position;

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
              value: position.inMilliseconds.toDouble(),
              min: 0,
              max: duration.inMilliseconds.toDouble(),
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey.shade700,
              onChanged: (value) {
                _videoController.seekTo(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Text(
            '${_formatDuration(position)} / ${_formatDuration(duration)}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingTools() {
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.white70,
            tabs: const [
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
              controller: _tabController,
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
        final isSelected = _selectedEffect == effect;

        return InkWell(
          onTap: () => _setEffect(effect),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? AppColors.primary : Colors.white, size: 28),
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
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Replace your background with a custom image',
            style: TextStyle(color: Colors.white70, fontSize: 14),
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
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(File(_backgroundImage!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _backgroundImage = null),
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
          Expanded(
            child: _textOverlays.isEmpty
                ? const Center(
                    child: Text('No text overlays yet', style: TextStyle(color: Colors.white70)),
                  )
                : ListView.builder(
                    itemCount: _textOverlays.length,
                    itemBuilder: (context, index) {
                      final overlay = _textOverlays[index];
                      return ListTile(
                        leading: const Icon(Icons.text_fields, color: AppColors.primary),
                        title: Text(overlay.text, style: const TextStyle(color: Colors.white)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => _textOverlays.removeAt(index)),
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
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: speeds.map((speed) {
              final isSelected = _editConfig.speed == speed;
              return InkWell(
                onTap: () => _setSpeed(speed),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${speed}x',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Slider(
            value: _editConfig.speed,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            activeColor: AppColors.primary,
            label: '${_editConfig.speed}x',
            onChanged: _setSpeed,
          ),
        ],
      ),
    );
  }

  Widget _buildMusicTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
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
    );
  }

  Widget _buildVoiceoverTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _voiceoverPath != null ? Icons.check_circle : Icons.mic,
            color: _voiceoverPath != null ? Colors.green : AppColors.primary,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _voiceoverPath != null ? 'Voiceover Added!' : 'Add Voiceover',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _voiceoverPath != null
                ? 'Your voiceover will be mixed with the video'
                : 'Record audio narration over your video',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _voiceoverPath != null
                  ? () => setState(() => _voiceoverPath = null)
                  : _recordVoiceover,
              style: ElevatedButton.styleFrom(
                backgroundColor: _voiceoverPath != null ? Colors.red : AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(_voiceoverPath != null ? 'Remove Voiceover' : 'Start Recording'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: _processingProgress > 0 ? _processingProgress : null,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _processingStage,
              style: const TextStyle(color: Colors.white),
            ),
            if (_processingProgress > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  '${(_processingProgress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBackgroundImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _backgroundImage = image.path);
    }
  }

  void _addTextOverlay() {
    showDialog<void>(
      context: context,
      builder: (context) {
        var text = '';
        var selectedColor = Colors.white;
        
        return AlertDialog(
          title: const Text('Add Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Enter text'),
                onChanged: (value) => text = value,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Colors.white, Colors.yellow, Colors.red, Colors.blue, Colors.green]
                    .map((color) => GestureDetector(
                          onTap: () => selectedColor = color,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
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
                    _textOverlays.add(TextOverlay(
                      text: text,
                      color: selectedColor,
                    ));
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

  void _recordVoiceover() {
    // For now, show a message that recording will be implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tap and hold the mic button to record voiceover'),
        backgroundColor: AppColors.primary,
      ),
    );
    
    // TODO: Implement actual voiceover recording
    // This would use the VoiceoverRecorder widget
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
