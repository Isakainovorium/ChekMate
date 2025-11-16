import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';

/// Voice Message Model - Data Layer
///
/// Data transfer object for voice message data.
/// Converts between domain entities and Firestore documents.
///
class VoiceMessageModel extends Equatable {
  const VoiceMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.url,
    required this.duration,
    required this.createdAt,
    this.waveform,
    this.transcription,
    this.filePath,
    this.downloadUrl,
    required this.fileName,
    this.fileSize,
    this.isUploaded = false,
    this.uploadProgress = 0.0,
    this.isPlaying = false,
    this.playbackPosition = 0.0,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String url;
  final int duration;
  final DateTime createdAt;
  final List<double>? waveform;
  final String? transcription;
  final String? filePath;
  final String? downloadUrl;
  final String? fileName;
  final int? fileSize;
  final bool isUploaded;
  final double uploadProgress;
  final bool isPlaying;
  final double playbackPosition;

  /// Create VoiceMessageModel from VoiceMessageEntity
  factory VoiceMessageModel.fromEntity(VoiceMessageEntity entity) {
    return VoiceMessageModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      url: entity.url,
      duration: entity.duration,
      createdAt: entity.createdAt,
      waveform: entity.waveform,
      transcription: entity.transcription,
      filePath: entity.filePath,
      downloadUrl: entity.downloadUrl,
      fileName: entity.fileName,
      fileSize: entity.fileSize,
      isUploaded: entity.isUploaded,
      uploadProgress: entity.uploadProgress,
      isPlaying: entity.isPlaying,
      playbackPosition: entity.playbackPosition,
    );
  }

  /// Convert to VoiceMessageEntity
  VoiceMessageEntity toEntity() {
    return VoiceMessageEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      url: url,
      duration: duration,
      createdAt: createdAt,
      waveform: waveform,
      transcription: transcription,
      filePath: filePath,
      downloadUrl: downloadUrl,
      fileName: fileName,
      fileSize: fileSize,
      isUploaded: isUploaded,
      uploadProgress: uploadProgress,
      isPlaying: isPlaying,
      playbackPosition: playbackPosition,
    );
  }

  /// Create VoiceMessageModel from Firestore document
  factory VoiceMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoiceMessageModel.fromJson(data);
  }

  /// Convert to JSON for Firestore (with id for updates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      'waveform': waveform,
      'transcription': transcription,
      'filePath': filePath,
      'downloadUrl': downloadUrl,
      'senderId': senderId,
      'receiverId': receiverId,
      'fileName': fileName,
      'fileSize': fileSize,
      'isUploaded': isUploaded,
      'uploadProgress': uploadProgress,
      'isPlaying': isPlaying,
      'playbackPosition': playbackPosition,
    };
  }

  /// Create VoiceMessageModel from JSON
  factory VoiceMessageModel.fromJson(Map<String, dynamic> json) {
    final timestamp = json['createdAt'];
    DateTime createdAt;

    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else if (timestamp is String) {
      createdAt = DateTime.parse(timestamp);
    } else {
      createdAt = DateTime.now();
    }

    return VoiceMessageModel(
      id: json['id'] as String,
      url: json['url'] as String,
      duration: json['duration'] as int? ?? 0,
      createdAt: createdAt,
      waveform: (json['waveform'] as List<dynamic>?)?.cast<double>(),
      transcription: json['transcription'] as String?,
      filePath: json['filePath'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      isUploaded: json['isUploaded'] as bool? ?? false,
      uploadProgress: (json['uploadProgress'] as num?)?.toDouble() ?? 0.0,
      isPlaying: json['isPlaying'] as bool? ?? false,
      playbackPosition: (json['playbackPosition'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to Firestore data (excluding id for document creation)
  Map<String, dynamic> toFirestore() {
    return {
      'url': url,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      'waveform': waveform,
      'transcription': transcription,
      'filePath': filePath,
      'downloadUrl': downloadUrl,
      'senderId': senderId,
      'receiverId': receiverId,
      'fileName': fileName,
      'fileSize': fileSize,
      'isUploaded': isUploaded,
      'uploadProgress': uploadProgress,
      'isPlaying': isPlaying,
      'playbackPosition': playbackPosition,
    };
  }

  /// Create a copy with updated fields
  VoiceMessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? url,
    int? duration,
    DateTime? createdAt,
    List<double>? waveform,
    String? transcription,
    String? filePath,
    String? downloadUrl,
    String? fileName,
    int? fileSize,
    bool? isUploaded,
    double? uploadProgress,
    bool? isPlaying,
    double? playbackPosition,
  }) {
    return VoiceMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      waveform: waveform ?? this.waveform,
      transcription: transcription ?? this.transcription,
      filePath: filePath ?? this.filePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
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
        waveform,
        transcription,
        filePath,
        downloadUrl,
        fileName,
        fileSize,
        isUploaded,
        uploadProgress,
        isPlaying,
        playbackPosition,
      ];
}
