import 'package:equatable/equatable.dart';

/// Call type
enum CallType {
  voice,
  video,
}

/// Call status
enum CallStatus {
  ringing,
  ongoing,
  ended,
  missed,
  declined,
}

/// Call entity
class CallEntity extends Equatable {
  const CallEntity({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerAvatarUrl,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatarUrl,
    required this.type,
    required this.status,
    required this.channelId,
    required this.createdAt,
    this.answeredAt,
    this.endedAt,
    this.callerIsMuted = false,
    this.callerVideoOff = false,
    this.receiverIsMuted = false,
    this.receiverVideoOff = false,
  });

  final String id;
  final String callerId;
  final String callerName;
  final String callerAvatarUrl;
  final String receiverId;
  final String receiverName;
  final String receiverAvatarUrl;
  final CallType type;
  final CallStatus status;
  final String channelId;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final DateTime? endedAt;
  final bool callerIsMuted;
  final bool callerVideoOff;
  final bool receiverIsMuted;
  final bool receiverVideoOff;

  /// Duration of the call
  Duration get duration {
    if (answeredAt == null) return Duration.zero;
    final end = endedAt ?? DateTime.now();
    return end.difference(answeredAt!);
  }

  /// Formatted duration string
  String get formattedDuration {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}:${(d.inMinutes.remainder(60)).toString().padLeft(2, '0')}:${(d.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${(d.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
  }

  /// Check if call is active
  bool get isActive => status == CallStatus.ringing || status == CallStatus.ongoing;

  /// Check if this is a video call
  bool get isVideoCall => type == CallType.video;

  /// Copy with
  CallEntity copyWith({
    String? id,
    String? callerId,
    String? callerName,
    String? callerAvatarUrl,
    String? receiverId,
    String? receiverName,
    String? receiverAvatarUrl,
    CallType? type,
    CallStatus? status,
    String? channelId,
    DateTime? createdAt,
    DateTime? answeredAt,
    DateTime? endedAt,
    bool? callerIsMuted,
    bool? callerVideoOff,
    bool? receiverIsMuted,
    bool? receiverVideoOff,
  }) {
    return CallEntity(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerAvatarUrl: callerAvatarUrl ?? this.callerAvatarUrl,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverAvatarUrl: receiverAvatarUrl ?? this.receiverAvatarUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      channelId: channelId ?? this.channelId,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: answeredAt ?? this.answeredAt,
      endedAt: endedAt ?? this.endedAt,
      callerIsMuted: callerIsMuted ?? this.callerIsMuted,
      callerVideoOff: callerVideoOff ?? this.callerVideoOff,
      receiverIsMuted: receiverIsMuted ?? this.receiverIsMuted,
      receiverVideoOff: receiverVideoOff ?? this.receiverVideoOff,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatarUrl': callerAvatarUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatarUrl': receiverAvatarUrl,
      'type': type.name,
      'status': status.name,
      'channelId': channelId,
      'createdAt': createdAt.toIso8601String(),
      'answeredAt': answeredAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'callerIsMuted': callerIsMuted,
      'callerVideoOff': callerVideoOff,
      'receiverIsMuted': receiverIsMuted,
      'receiverVideoOff': receiverVideoOff,
    };
  }

  /// Create from JSON
  factory CallEntity.fromJson(Map<String, dynamic> json) {
    return CallEntity(
      id: json['id'] as String,
      callerId: json['callerId'] as String,
      callerName: json['callerName'] as String,
      callerAvatarUrl: json['callerAvatarUrl'] as String? ?? '',
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      receiverAvatarUrl: json['receiverAvatarUrl'] as String? ?? '',
      type: CallType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CallType.voice,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CallStatus.ended,
      ),
      channelId: json['channelId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'] as String)
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      callerIsMuted: json['callerIsMuted'] as bool? ?? false,
      callerVideoOff: json['callerVideoOff'] as bool? ?? false,
      receiverIsMuted: json['receiverIsMuted'] as bool? ?? false,
      receiverVideoOff: json['receiverVideoOff'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        callerId,
        callerName,
        callerAvatarUrl,
        receiverId,
        receiverName,
        receiverAvatarUrl,
        type,
        status,
        channelId,
        createdAt,
        answeredAt,
        endedAt,
        callerIsMuted,
        callerVideoOff,
        receiverIsMuted,
        receiverVideoOff,
      ];
}
