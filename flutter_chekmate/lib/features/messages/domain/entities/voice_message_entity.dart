import 'package:equatable/equatable.dart';

/// Voice Message Entity - Domain Layer
///
/// Represents a voice message in the ChekMate application.
/// Used for voice messages in chat and voice-over audio in video posts.
///
/// Clean Architecture: Domain Layer
class VoiceMessageEntity extends Equatable {
  const VoiceMessageEntity({
    required this.id,
    required this.url,
    required this.duration,
    required this.createdAt,
    this.waveform,
    this.transcription,
    this.filePath,
    this.downloadUrl,
  });

  final String id;
  final String url;
  final Duration duration;
  final DateTime createdAt;
  final List<double>? waveform;
  final String? transcription;
  final String? filePath; // Local file path
  final String? downloadUrl; // Remote download URL

  /// Get formatted duration (e.g., "0:45", "1:23")
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
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

  /// Copy with method for creating modified copies
  VoiceMessageEntity copyWith({
    String? id,
    String? url,
    Duration? duration,
    DateTime? createdAt,
    List<double>? waveform,
    String? transcription,
    String? filePath,
    String? downloadUrl,
  }) {
    return VoiceMessageEntity(
      id: id ?? this.id,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      waveform: waveform ?? this.waveform,
      transcription: transcription ?? this.transcription,
      filePath: filePath ?? this.filePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        url,
        duration,
        createdAt,
        waveform,
        transcription,
        filePath,
        downloadUrl,
      ];
}
