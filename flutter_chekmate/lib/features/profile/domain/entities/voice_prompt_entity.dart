import 'package:equatable/equatable.dart';

/// Voice Prompt Entity
/// Represents a voice prompt recording for user profile
class VoicePromptEntity extends Equatable {
  const VoicePromptEntity({
    required this.id,
    required this.userId,
    required this.question,
    required this.audioUrl,
    required this.duration,
    required this.createdAt,
    this.transcription,
    this.isPublic = true,
  });

  final String id;
  final String userId;
  final String question;
  final String audioUrl;
  final int duration; // Duration in seconds
  final DateTime createdAt;
  final String? transcription;
  final bool isPublic;

  /// Get formatted duration (e.g., "1:23", "0:45")
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if voice prompt is recent (less than 30 days old)
  bool get isRecent {
    final now = DateTime.now();
    final daysSinceCreation = now.difference(createdAt).inDays;
    return daysSinceCreation < 30;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        question,
        audioUrl,
        duration,
        createdAt,
        transcription,
        isPublic,
      ];

  VoicePromptEntity copyWith({
    String? id,
    String? userId,
    String? question,
    String? audioUrl,
    int? duration,
    DateTime? createdAt,
    String? transcription,
    bool? isPublic,
  }) {
    return VoicePromptEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      question: question ?? this.question,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      transcription: transcription ?? this.transcription,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

/// Voice Prompt Questions
/// Predefined questions for voice prompts
class VoicePromptQuestions {
  static const List<String> questions = [
    "What's your ideal first date?",
    "What makes you laugh the most?",
    "What's your favorite way to spend a weekend?",
    "What's something you're passionate about?",
    "What's your go-to karaoke song?",
    "What's the best advice you've ever received?",
    "What's your favorite travel destination?",
    "What's something you've always wanted to try?",
    "What's your favorite childhood memory?",
    "What's something that always makes you smile?",
  ];

  static String getRandomQuestion() {
    return questions[DateTime.now().millisecondsSinceEpoch % questions.length];
  }

  /// Get question by index
  static String getQuestion(int index) {
    if (index < 0 || index >= questions.length) {
      return questions[0];
    }
    return questions[index];
  }
}
