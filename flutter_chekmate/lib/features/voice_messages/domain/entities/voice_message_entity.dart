import 'package:equatable/equatable.dart';

/// Voice Message Entity - Domain Layer
///
/// Represents a voice message in the ChekMate application.
/// This is specific to the voice_messages feature for standalone voice messages.
///
class VoiceMessageEntity extends Equatable {
  const VoiceMessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.url,
    required this.duration,
    required this.createdAt,
    this.downloadUrl,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.waveform,
    this.transcription,
    this.isUploaded = false,
    this.uploadProgress = 0.0,
    this.isPlaying = false,
    this.playbackPosition = 0.0,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String url;
  final int duration; // Duration in seconds
  final DateTime createdAt;
  final String? downloadUrl;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final List<double>? waveform;
  final String? transcription;
  final bool isUploaded;
  final double uploadProgress;
  final bool isPlaying;
  final double playbackPosition;

  /// Get formatted duration (e.g., "0:45", "1:23")
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if voice message has waveform data
  bool get hasWaveform {
    return waveform != null && waveform!.isNotEmpty;
  }

  /// Check if voice message has transcription
  bool get hasTranscription {
    return transcription != null && transcription!.isNotEmpty;
  }

  /// Get human-readable time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if the voice message has been downloaded locally
  bool get isDownloaded => filePath != null;

  /// Check if the upload failed
  bool get uploadFailed => !isUploaded && uploadProgress == 0.0 && downloadUrl == null;

  /// Check if the voice message is currently uploading
  bool get isUploading => !isUploaded && uploadProgress > 0.0;

  /// Check if the voice message is ready to be played
  bool get isReadyToPlay => downloadUrl != null || filePath != null;

  /// Get formatted playback position in MM:SS format
  String get formattedPlaybackPosition {
    final minutes = (playbackPosition ~/ 60).toString().padLeft(2, '0');
    final seconds = (playbackPosition % 60).round().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Get formatted file size in human-readable format
  String get formattedFileSize {
    if (fileSize == null) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB'];
    var size = fileSize!.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) {
      return '${size.round()} ${units[unitIndex]}';
    } else {
      return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
    }
  }

  /// Get upload progress as percentage (0-100)
  int get uploadProgressPercentage {
    final percentage = uploadProgress * 100;
    return percentage.clamp(0, 100).round();
  }

  /// Get playback progress as percentage (0-100)
  int get playbackProgressPercentage {
    if (duration <= 0) return 0;
    final percentage = (playbackPosition / duration) * 100;
    return percentage.clamp(0, 100).round();
  }

  /// Validate the voice message entity
  bool validate() {
    // Check required fields are not empty
    if (id.isEmpty || senderId.isEmpty || receiverId.isEmpty) {
      return false;
    }

    // Check fileName is not empty
    if (fileName != null && fileName!.isEmpty) {
      return false;
    }

    // Check duration is valid (0 < duration <= 60 seconds)
    if (duration <= 0 || duration > 60) {
      return false;
    }

    // Check fileSize is valid (0 < fileSize <= 5 MB)
    if (fileSize != null && (fileSize! <= 0 || fileSize! > 5 * 1024 * 1024)) {
      return false;
    }

    return true;
  }

  /// Create a copy with updated fields
  VoiceMessageEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? url,
    int? duration,
    DateTime? createdAt,
    String? downloadUrl,
    String? filePath,
    String? fileName,
    int? fileSize,
    List<double>? waveform,
    String? transcription,
    bool? isUploaded,
    double? uploadProgress,
    bool? isPlaying,
    double? playbackPosition,
  }) {
    return VoiceMessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      waveform: waveform ?? this.waveform,
      transcription: transcription ?? this.transcription,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackPosition: playbackPosition ?? this.playbackPosition,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        url,
        duration,
        createdAt,
        downloadUrl,
        filePath,
        fileName,
        fileSize,
        waveform,
        transcription,
        isUploaded,
        uploadProgress,
        isPlaying,
        playbackPosition,
      ];

  @override
  bool get stringify => true;
}
