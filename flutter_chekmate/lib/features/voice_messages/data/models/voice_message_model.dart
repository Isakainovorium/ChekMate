import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';

/// Data model for VoiceMessage
///
/// This model extends VoiceMessageEntity and adds serialization/deserialization
/// capabilities for Firebase Firestore and local storage.
///
/// Follows Clean Architecture by separating data concerns from domain logic.
class VoiceMessageModel extends VoiceMessageEntity {
  const VoiceMessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.duration, required super.fileName, required super.fileSize, required super.createdAt, super.downloadUrl,
    super.filePath,
    super.isPlaying,
    super.playbackPosition,
    super.isUploaded,
    super.uploadProgress,
  });

  /// Creates a VoiceMessageModel from a VoiceMessageEntity
  factory VoiceMessageModel.fromEntity(VoiceMessageEntity entity) {
    return VoiceMessageModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      downloadUrl: entity.downloadUrl,
      duration: entity.duration,
      filePath: entity.filePath,
      fileName: entity.fileName,
      fileSize: entity.fileSize,
      createdAt: entity.createdAt,
      isPlaying: entity.isPlaying,
      playbackPosition: entity.playbackPosition,
      isUploaded: entity.isUploaded,
      uploadProgress: entity.uploadProgress,
    );
  }

  /// Creates a VoiceMessageModel from a Firestore document
  factory VoiceMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return VoiceMessageModel(
      id: doc.id,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      downloadUrl: data['downloadUrl'] as String?,
      duration: data['duration'] as int,
      fileName: data['fileName'] as String,
      fileSize: data['fileSize'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isUploaded: data['isUploaded'] as bool? ?? true,
      uploadProgress: 1.0, // If in Firestore, upload is complete
    );
  }

  /// Creates a VoiceMessageModel from a JSON map
  factory VoiceMessageModel.fromJson(Map<String, dynamic> json) {
    return VoiceMessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      downloadUrl: json['downloadUrl'] as String?,
      duration: json['duration'] as int,
      filePath: json['filePath'] as String?,
      fileName: json['fileName'] as String,
      fileSize: json['fileSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPlaying: json['isPlaying'] as bool? ?? false,
      playbackPosition: (json['playbackPosition'] as num?)?.toDouble() ?? 0.0,
      isUploaded: json['isUploaded'] as bool? ?? false,
      uploadProgress: (json['uploadProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts this model to a Firestore document map
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'downloadUrl': downloadUrl,
      'duration': duration,
      'fileName': fileName,
      'fileSize': fileSize,
      'createdAt': Timestamp.fromDate(createdAt),
      'isUploaded': isUploaded,
    };
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'downloadUrl': downloadUrl,
      'duration': duration,
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'isPlaying': isPlaying,
      'playbackPosition': playbackPosition,
      'isUploaded': isUploaded,
      'uploadProgress': uploadProgress,
    };
  }

  static const _undefined = Object();

  /// Creates a copy of this model with updated fields
  @override
  VoiceMessageModel copyWith({
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
    return VoiceMessageModel(
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
}
