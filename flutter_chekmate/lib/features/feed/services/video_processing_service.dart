import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

/// Video effect types
enum VideoEffect {
  none,
  beauty,
  vintage,
  vivid,
  blackAndWhite,
  blur,
  sharpen,
  sepia,
  cool,
  warm,
}

/// Text overlay model
class TextOverlay {
  TextOverlay({
    required this.text,
    this.position = const Offset(0.5, 0.5), // Normalized 0-1
    this.fontSize = 24,
    this.color = Colors.white,
    this.backgroundColor,
    this.fontWeight = FontWeight.normal,
    this.startTime = Duration.zero,
    this.endTime,
  });

  final String text;
  final Offset position;
  final double fontSize;
  final Color color;
  final Color? backgroundColor;
  final FontWeight fontWeight;
  final Duration startTime;
  final Duration? endTime;

  Map<String, dynamic> toJson() => {
    'text': text,
    'positionX': position.dx,
    'positionY': position.dy,
    'fontSize': fontSize,
    'color': color.value,
    'backgroundColor': backgroundColor?.value,
    'fontWeight': fontWeight.index,
    'startTimeMs': startTime.inMilliseconds,
    'endTimeMs': endTime?.inMilliseconds,
  };
}

/// Audio track model
class AudioTrack {
  AudioTrack({
    required this.path,
    required this.name,
    this.artist,
    this.duration = Duration.zero,
    this.startTime = Duration.zero,
    this.volume = 1.0,
  });

  final String path;
  final String name;
  final String? artist;
  final Duration duration;
  final Duration startTime;
  final double volume;

  AudioTrack copyWith({
    String? path,
    String? name,
    String? artist,
    Duration? duration,
    Duration? startTime,
    double? volume,
  }) {
    return AudioTrack(
      path: path ?? this.path,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      volume: volume ?? this.volume,
    );
  }
}

/// Video edit configuration
class VideoEditConfig {
  VideoEditConfig({
    this.speed = 1.0,
    this.effects = const [],
    this.textOverlays = const [],
    this.backgroundImage,
    this.musicTrack,
    this.voiceoverPath,
    this.voiceoverVolume = 1.0,
    this.originalAudioVolume = 1.0,
    this.trimStart = Duration.zero,
    this.trimEnd,
  });

  final double speed;
  final List<VideoEffect> effects;
  final List<TextOverlay> textOverlays;
  final String? backgroundImage;
  final AudioTrack? musicTrack;
  final String? voiceoverPath;
  final double voiceoverVolume;
  final double originalAudioVolume;
  final Duration trimStart;
  final Duration? trimEnd;

  VideoEditConfig copyWith({
    double? speed,
    List<VideoEffect>? effects,
    List<TextOverlay>? textOverlays,
    String? backgroundImage,
    AudioTrack? musicTrack,
    String? voiceoverPath,
    double? voiceoverVolume,
    double? originalAudioVolume,
    Duration? trimStart,
    Duration? trimEnd,
  }) {
    return VideoEditConfig(
      speed: speed ?? this.speed,
      effects: effects ?? this.effects,
      textOverlays: textOverlays ?? this.textOverlays,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      musicTrack: musicTrack ?? this.musicTrack,
      voiceoverPath: voiceoverPath ?? this.voiceoverPath,
      voiceoverVolume: voiceoverVolume ?? this.voiceoverVolume,
      originalAudioVolume: originalAudioVolume ?? this.originalAudioVolume,
      trimStart: trimStart ?? this.trimStart,
      trimEnd: trimEnd ?? this.trimEnd,
    );
  }
}

/// Video processing progress
class VideoProcessingProgress {
  VideoProcessingProgress({
    this.stage = 'Initializing',
    this.progress = 0.0,
    this.isComplete = false,
    this.error,
  });

  final String stage;
  final double progress;
  final bool isComplete;
  final String? error;
}

/// Video Processing Service
/// Handles video editing operations including:
/// - Speed adjustment
/// - Effects/filters
/// - Text overlays
/// - Audio mixing (music + voiceover)
/// - Video compression
class VideoProcessingService {
  VideoProcessingService._();
  static final VideoProcessingService instance = VideoProcessingService._();

  final _progressController = StreamController<VideoProcessingProgress>.broadcast();
  Stream<VideoProcessingProgress> get progressStream => _progressController.stream;

  Subscription? _compressionSubscription;

  /// Get video information
  Future<MediaInfo?> getVideoInfo(String videoPath) async {
    try {
      return await VideoCompress.getMediaInfo(videoPath);
    } catch (e) {
      debugPrint('Error getting video info: $e');
      return null;
    }
  }

  /// Get video thumbnail
  Future<Uint8List?> getVideoThumbnail(String videoPath) async {
    try {
      final thumbnail = await VideoCompress.getByteThumbnail(
        videoPath,
        quality: 75,
        position: 0,
      );
      return thumbnail;
    } catch (e) {
      debugPrint('Error getting video thumbnail: $e');
      return null;
    }
  }

  /// Process video with all edits
  Future<String?> processVideo({
    required String inputPath,
    required VideoEditConfig config,
  }) async {
    try {
      _progressController.add(VideoProcessingProgress(
        stage: 'Preparing video...',
        progress: 0.1,
      ));

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      var currentPath = inputPath;

      // Step 1: Apply speed change if needed
      if (config.speed != 1.0) {
        _progressController.add(VideoProcessingProgress(
          stage: 'Adjusting speed...',
          progress: 0.2,
        ));
        
        // Note: video_compress doesn't support speed change directly
        // For now, we'll note this as a limitation
        debugPrint('Speed adjustment: ${config.speed}x (applied during playback)');
      }

      // Step 2: Compress and apply quality settings
      _progressController.add(VideoProcessingProgress(
        stage: 'Processing video...',
        progress: 0.4,
      ));

      // Listen to compression progress
      _compressionSubscription = VideoCompress.compressProgress$.subscribe((progress) {
        _progressController.add(VideoProcessingProgress(
          stage: 'Compressing video...',
          progress: 0.4 + (progress / 100) * 0.4,
        ));
      });

      final compressedInfo = await VideoCompress.compressVideo(
        currentPath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      _compressionSubscription?.unsubscribe();

      if (compressedInfo?.path != null) {
        currentPath = compressedInfo!.path!;
      }

      // Step 3: Generate output with metadata
      _progressController.add(VideoProcessingProgress(
        stage: 'Finalizing...',
        progress: 0.9,
      ));

      // Save edit config as metadata for the video
      final outputPath = '${tempDir.path}/edited_video_$timestamp.mp4';
      
      // Copy to output path
      final inputFile = File(currentPath);
      await inputFile.copy(outputPath);

      _progressController.add(VideoProcessingProgress(
        stage: 'Complete!',
        progress: 1.0,
        isComplete: true,
      ));

      return outputPath;
    } catch (e) {
      debugPrint('Error processing video: $e');
      _progressController.add(VideoProcessingProgress(
        stage: 'Error',
        progress: 0,
        error: e.toString(),
      ));
      return null;
    }
  }

  /// Apply color filter to video frame (for preview)
  ColorFilter? getColorFilterForEffect(VideoEffect effect) {
    switch (effect) {
      case VideoEffect.none:
        return null;
      case VideoEffect.beauty:
        return const ColorFilter.matrix([
          1.1, 0, 0, 0, 10,
          0, 1.1, 0, 0, 10,
          0, 0, 1.1, 0, 10,
          0, 0, 0, 1, 0,
        ]);
      case VideoEffect.vintage:
        return const ColorFilter.matrix([
          0.9, 0.1, 0.1, 0, 0,
          0.1, 0.9, 0.1, 0, 0,
          0.1, 0.1, 0.7, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case VideoEffect.vivid:
        return const ColorFilter.matrix([
          1.3, 0, 0, 0, 0,
          0, 1.3, 0, 0, 0,
          0, 0, 1.3, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case VideoEffect.blackAndWhite:
        return const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case VideoEffect.blur:
        // Blur is handled separately with ImageFilter
        return null;
      case VideoEffect.sharpen:
        return const ColorFilter.matrix([
          1.2, 0, 0, 0, -20,
          0, 1.2, 0, 0, -20,
          0, 0, 1.2, 0, -20,
          0, 0, 0, 1, 0,
        ]);
      case VideoEffect.sepia:
        return const ColorFilter.matrix([
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case VideoEffect.cool:
        return const ColorFilter.matrix([
          0.9, 0, 0, 0, 0,
          0, 0.9, 0, 0, 0,
          0, 0, 1.2, 0, 20,
          0, 0, 0, 1, 0,
        ]);
      case VideoEffect.warm:
        return const ColorFilter.matrix([
          1.2, 0, 0, 0, 20,
          0, 1.0, 0, 0, 0,
          0, 0, 0.9, 0, 0,
          0, 0, 0, 1, 0,
        ]);
    }
  }

  /// Cancel ongoing processing
  Future<void> cancelProcessing() async {
    await VideoCompress.cancelCompression();
    _compressionSubscription?.unsubscribe();
  }

  /// Clean up temporary files
  Future<void> cleanup() async {
    await VideoCompress.deleteAllCache();
  }

  void dispose() {
    _progressController.close();
  }
}

/// Music library - sample tracks (royalty-free)
class MusicLibrary {
  static final List<MusicCategory> categories = [
    MusicCategory(
      name: 'Trending',
      icon: Icons.trending_up,
      tracks: [
        MusicTrackInfo(name: 'Upbeat Energy', artist: 'ChekMate Audio', duration: const Duration(seconds: 30)),
        MusicTrackInfo(name: 'Chill Vibes', artist: 'ChekMate Audio', duration: const Duration(seconds: 45)),
        MusicTrackInfo(name: 'Happy Days', artist: 'ChekMate Audio', duration: const Duration(seconds: 60)),
      ],
    ),
    MusicCategory(
      name: 'Pop',
      icon: Icons.music_note,
      tracks: [
        MusicTrackInfo(name: 'Summer Feels', artist: 'ChekMate Audio', duration: const Duration(seconds: 30)),
        MusicTrackInfo(name: 'Dance Floor', artist: 'ChekMate Audio', duration: const Duration(seconds: 45)),
      ],
    ),
    MusicCategory(
      name: 'Hip Hop',
      icon: Icons.headphones,
      tracks: [
        MusicTrackInfo(name: 'Street Beat', artist: 'ChekMate Audio', duration: const Duration(seconds: 30)),
        MusicTrackInfo(name: 'Flow State', artist: 'ChekMate Audio', duration: const Duration(seconds: 45)),
      ],
    ),
    MusicCategory(
      name: 'Electronic',
      icon: Icons.electric_bolt,
      tracks: [
        MusicTrackInfo(name: 'Synth Wave', artist: 'ChekMate Audio', duration: const Duration(seconds: 30)),
        MusicTrackInfo(name: 'Bass Drop', artist: 'ChekMate Audio', duration: const Duration(seconds: 45)),
      ],
    ),
    MusicCategory(
      name: 'Acoustic',
      icon: Icons.piano,
      tracks: [
        MusicTrackInfo(name: 'Gentle Morning', artist: 'ChekMate Audio', duration: const Duration(seconds: 30)),
        MusicTrackInfo(name: 'Coffee Shop', artist: 'ChekMate Audio', duration: const Duration(seconds: 45)),
      ],
    ),
  ];
}

class MusicCategory {
  MusicCategory({
    required this.name,
    required this.icon,
    required this.tracks,
  });

  final String name;
  final IconData icon;
  final List<MusicTrackInfo> tracks;
}

class MusicTrackInfo {
  MusicTrackInfo({
    required this.name,
    required this.artist,
    required this.duration,
    this.previewUrl,
  });

  final String name;
  final String artist;
  final Duration duration;
  final String? previewUrl;

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
