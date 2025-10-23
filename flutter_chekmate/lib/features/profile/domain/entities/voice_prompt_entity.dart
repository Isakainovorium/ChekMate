import 'package:equatable/equatable.dart';

/// Voice Prompt Entity - Domain Layer
///
/// Represents a voice answer to a profile prompt (Bumble-style).
/// Pure Dart class with no framework dependencies.
///
/// Business Rules:
/// - Max 30 seconds per prompt
/// - Up to 3 voice prompts per profile
/// - Must have a question and audio URL
///
/// Clean Architecture: Domain Layer
class VoicePromptEntity extends Equatable {
  /// Create VoicePromptEntity from JSON
  factory VoicePromptEntity.fromJson(Map<String, dynamic> json) {
    return VoicePromptEntity(
      id: json['id'] as String,
      question: json['question'] as String,
      audioUrl: json['audioUrl'] as String,
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPlaying: json['isPlaying'] as bool? ?? false,
      playbackPosition: (json['playbackPosition'] as num?)?.toDouble() ?? 0.0,
    );
  }
  const VoicePromptEntity({
    required this.id,
    required this.question,
    required this.audioUrl,
    required this.duration,
    required this.createdAt,
    this.isPlaying = false,
    this.playbackPosition = 0.0,
  });

  /// Unique identifier
  final String id;

  /// The prompt question (e.g., "What's your ideal date?")
  final String question;

  /// Firebase Storage URL for the audio file
  final String audioUrl;

  /// Duration in seconds
  final int duration;

  /// When the prompt was created
  final DateTime createdAt;

  /// Whether the prompt is currently playing
  final bool isPlaying;

  /// Current playback position (0.0 to 1.0)
  final double playbackPosition;

  @override
  List<Object?> get props => [
        id,
        question,
        audioUrl,
        duration,
        createdAt,
        isPlaying,
        playbackPosition,
      ];

  /// Business logic: Check if the prompt is valid
  bool isValid() {
    return id.isNotEmpty &&
        question.isNotEmpty &&
        audioUrl.isNotEmpty &&
        duration > 0 &&
        duration <= 30; // Max 30 seconds
  }

  /// Business logic: Check if the prompt can be played
  bool canPlay() {
    return audioUrl.isNotEmpty && duration > 0;
  }

  /// Business logic: Format duration as MM:SS
  String formatDuration() {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'audioUrl': audioUrl,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'isPlaying': isPlaying,
      'playbackPosition': playbackPosition,
    };
  }

  /// Business logic: Get playback position in seconds
  int get playbackPositionSeconds => (playbackPosition * duration).round();

  /// Business logic: Format playback position as MM:SS
  String formatPlaybackPosition() {
    final positionSeconds = playbackPositionSeconds;
    final minutes = positionSeconds ~/ 60;
    final seconds = positionSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Creates a copy of this entity with the given fields replaced
  VoicePromptEntity copyWith({
    String? id,
    String? question,
    String? audioUrl,
    int? duration,
    DateTime? createdAt,
    bool? isPlaying,
    double? playbackPosition,
  }) {
    return VoicePromptEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackPosition: playbackPosition ?? this.playbackPosition,
    );
  }
}

/// Predefined voice prompt questions (Bumble/Hinge-style)
class VoicePromptQuestions {
  static const List<String> questions = [
    "What's your ideal date?",
    'What makes you laugh?',
    'What are you passionate about?',
    'Describe your perfect weekend',
    "What's your hidden talent?",
    "What's your favorite way to spend a Sunday?",
    "What's something you're really good at?",
    "What's your go-to karaoke song?",
    "What's the best trip you've ever taken?",
    "What's your favorite childhood memory?",
    "What's something you've always wanted to learn?",
    "What's your biggest pet peeve?",
    "What's your favorite thing about yourself?",
    "What's the most spontaneous thing you've ever done?",
    "What's your dream job?",
  ];

  /// Get a random question
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
