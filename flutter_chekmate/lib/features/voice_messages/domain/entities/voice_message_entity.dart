import 'package:equatable/equatable.dart';

/// Domain entity representing a voice message
///
/// This is a pure Dart class with no dependencies on external frameworks.
/// It represents the core business logic for voice messages in the app.
///
/// Properties:
/// - [id]: Unique identifier for the voice message
/// - [senderId]: ID of the user who sent the message
/// - [receiverId]: ID of the user who will receive the message
/// - [downloadUrl]: Firebase Storage download URL for the audio file
/// - [duration]: Duration of the voice message in seconds
/// - [filePath]: Local file path (if downloaded)
/// - [fileName]: Name of the audio file
/// - [fileSize]: Size of the audio file in bytes
/// - [createdAt]: Timestamp when the message was created
/// - [isPlaying]: Whether the message is currently playing
/// - [playbackPosition]: Current playback position in seconds
/// - [isUploaded]: Whether the message has been uploaded to Firebase Storage
/// - [uploadProgress]: Upload progress (0.0 to 1.0)
class VoiceMessageEntity extends Equatable { // 0.0 to 1.0

  const VoiceMessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.duration, required this.fileName, required this.fileSize, required this.createdAt, this.downloadUrl,
    this.filePath,
    this.isPlaying = false,
    this.playbackPosition = 0.0,
    this.isUploaded = false,
    this.uploadProgress = 0.0,
  });
  final String id;
  final String senderId;
  final String receiverId;
  final String? downloadUrl;
  final int duration; // in seconds
  final String? filePath; // local file path
  final String fileName;
  final int fileSize; // in bytes
  final DateTime createdAt;
  final bool isPlaying;
  final double playbackPosition; // in seconds
  final bool isUploaded;
  final double uploadProgress;

  /// Creates a copy of this entity with the given fields replaced
  ///
  /// To explicitly set a nullable field to null, use the corresponding parameter.
  /// For example: `copyWith(downloadUrl: null)` will set downloadUrl to null.
  VoiceMessageEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    Object? downloadUrl = _undefined,
    int? duration,
    Object? filePath = _undefined,
    String? fileName,
    int? fileSize,
    DateTime? createdAt,
    bool? isPlaying,
    double? playbackPosition,
    bool? isUploaded,
    double? uploadProgress,
  }) {
    return VoiceMessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      downloadUrl:
          downloadUrl == _undefined ? this.downloadUrl : downloadUrl as String?,
      duration: duration ?? this.duration,
      filePath: filePath == _undefined ? this.filePath : filePath as String?,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  static const _undefined = Object();

  /// Returns the duration formatted as MM:SS
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns the playback position formatted as MM:SS
  String get formattedPlaybackPosition {
    final position = playbackPosition.floor();
    final minutes = position ~/ 60;
    final seconds = position % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns the file size formatted as KB or MB
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      final kb = (fileSize / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else {
      final mb = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    }
  }

  /// Returns the upload progress as a percentage (0-100)
  int get uploadProgressPercentage {
    return (uploadProgress * 100).round();
  }

  /// Returns the playback progress as a percentage (0-100)
  int get playbackProgressPercentage {
    if (duration == 0) return 0;
    return ((playbackPosition / duration) * 100).round().clamp(0, 100);
  }

  /// Returns true if the voice message is ready to play
  bool get isReadyToPlay {
    final hasDownloadUrl = downloadUrl != null && downloadUrl!.isNotEmpty;
    final hasFilePath = filePath != null && filePath!.isNotEmpty;
    return hasDownloadUrl || hasFilePath;
  }

  /// Returns true if the voice message is currently uploading
  bool get isUploading {
    return !isUploaded && uploadProgress > 0.0 && uploadProgress < 1.0;
  }

  /// Returns true if the voice message upload failed
  bool get uploadFailed {
    final hasNoDownloadUrl = downloadUrl == null || downloadUrl!.isEmpty;
    return !isUploaded && uploadProgress == 0.0 && hasNoDownloadUrl;
  }

  /// Returns true if the voice message is downloaded locally
  bool get isDownloaded {
    return filePath != null && filePath!.isNotEmpty;
  }

  /// Validates the voice message entity
  ///
  /// Returns true if all required fields are valid
  bool validate() {
    return id.isNotEmpty &&
        senderId.isNotEmpty &&
        receiverId.isNotEmpty &&
        fileName.isNotEmpty &&
        duration > 0 &&
        duration <= 60 && // Max 60 seconds
        fileSize > 0 &&
        fileSize <= 5 * 1024 * 1024; // Max 5 MB
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        downloadUrl,
        duration,
        filePath,
        fileName,
        fileSize,
        createdAt,
        isPlaying,
        playbackPosition,
        isUploaded,
        uploadProgress,
      ];

  @override
  String toString() {
    return 'VoiceMessageEntity('
        'id: $id, '
        'senderId: $senderId, '
        'receiverId: $receiverId, '
        'downloadUrl: $downloadUrl, '
        'duration: $duration, '
        'filePath: $filePath, '
        'fileName: $fileName, '
        'fileSize: $fileSize, '
        'createdAt: $createdAt, '
        'isPlaying: $isPlaying, '
        'playbackPosition: $playbackPosition, '
        'isUploaded: $isUploaded, '
        'uploadProgress: $uploadProgress'
        ')';
  }
}
