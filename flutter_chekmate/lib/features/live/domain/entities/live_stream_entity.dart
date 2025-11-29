import 'package:equatable/equatable.dart';

/// Live stream status
enum LiveStreamStatus {
  scheduled,
  live,
  ended,
}

/// Live stream category
enum LiveStreamCategory {
  experiences('Experience Sharing'),
  advice('Community Q&A'),
  stories('Live Stories'),
  all('All Live');

  const LiveStreamCategory(this.label);
  final String label;
}

/// Live stream entity
class LiveStreamEntity extends Equatable {
  const LiveStreamEntity({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.hostUsername,
    required this.hostAvatarUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.channelName,
    required this.createdAt,
    this.thumbnailUrl,
    this.viewerCount = 0,
    this.likeCount = 0,
    this.peakViewerCount = 0,
    this.startedAt,
    this.endedAt,
    this.tags = const [],
    this.isHostVerified = false,
  });

  final String id;
  final String hostId;
  final String hostName;
  final String hostUsername;
  final String hostAvatarUrl;
  final String title;
  final String description;
  final LiveStreamCategory category;
  final LiveStreamStatus status;
  final String channelName;
  final String? thumbnailUrl;
  final int viewerCount;
  final int likeCount;
  final int peakViewerCount;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final List<String> tags;
  final bool isHostVerified;

  /// Duration of the stream
  Duration get duration {
    if (startedAt == null) return Duration.zero;
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt!);
  }

  /// Formatted duration string
  String get formattedDuration {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  /// Formatted viewer count
  String get formattedViewerCount {
    if (viewerCount >= 1000000) {
      return '${(viewerCount / 1000000).toStringAsFixed(1)}M';
    }
    if (viewerCount >= 1000) {
      return '${(viewerCount / 1000).toStringAsFixed(1)}K';
    }
    return viewerCount.toString();
  }

  /// Check if stream is currently live
  bool get isLive => status == LiveStreamStatus.live;

  /// Copy with
  LiveStreamEntity copyWith({
    String? id,
    String? hostId,
    String? hostName,
    String? hostUsername,
    String? hostAvatarUrl,
    String? title,
    String? description,
    LiveStreamCategory? category,
    LiveStreamStatus? status,
    String? channelName,
    String? thumbnailUrl,
    int? viewerCount,
    int? likeCount,
    int? peakViewerCount,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    List<String>? tags,
    bool? isHostVerified,
  }) {
    return LiveStreamEntity(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostUsername: hostUsername ?? this.hostUsername,
      hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      channelName: channelName ?? this.channelName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      viewerCount: viewerCount ?? this.viewerCount,
      likeCount: likeCount ?? this.likeCount,
      peakViewerCount: peakViewerCount ?? this.peakViewerCount,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      tags: tags ?? this.tags,
      isHostVerified: isHostVerified ?? this.isHostVerified,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostId': hostId,
      'hostName': hostName,
      'hostUsername': hostUsername,
      'hostAvatarUrl': hostAvatarUrl,
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'channelName': channelName,
      'thumbnailUrl': thumbnailUrl,
      'viewerCount': viewerCount,
      'likeCount': likeCount,
      'peakViewerCount': peakViewerCount,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'tags': tags,
      'isHostVerified': isHostVerified,
    };
  }

  /// Create from JSON
  factory LiveStreamEntity.fromJson(Map<String, dynamic> json) {
    return LiveStreamEntity(
      id: json['id'] as String,
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      hostUsername: json['hostUsername'] as String,
      hostAvatarUrl: json['hostAvatarUrl'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: LiveStreamCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => LiveStreamCategory.all,
      ),
      status: LiveStreamStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LiveStreamStatus.ended,
      ),
      channelName: json['channelName'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      viewerCount: json['viewerCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      peakViewerCount: json['peakViewerCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      isHostVerified: json['isHostVerified'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hostId,
        hostName,
        hostUsername,
        hostAvatarUrl,
        title,
        description,
        category,
        status,
        channelName,
        thumbnailUrl,
        viewerCount,
        likeCount,
        peakViewerCount,
        createdAt,
        startedAt,
        endedAt,
        tags,
        isHostVerified,
      ];
}

/// Live stream chat message
class LiveChatMessage extends Equatable {
  const LiveChatMessage({
    required this.id,
    required this.streamId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.message,
    required this.createdAt,
    this.isHost = false,
    this.isVerified = false,
    this.isPinned = false,
  });

  final String id;
  final String streamId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String message;
  final DateTime createdAt;
  final bool isHost;
  final bool isVerified;
  final bool isPinned;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streamId': streamId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isHost': isHost,
      'isVerified': isVerified,
      'isPinned': isPinned,
    };
  }

  factory LiveChatMessage.fromJson(Map<String, dynamic> json) {
    return LiveChatMessage(
      id: json['id'] as String,
      streamId: json['streamId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String? ?? '',
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isHost: json['isHost'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        streamId,
        userId,
        userName,
        userAvatarUrl,
        message,
        createdAt,
        isHost,
        isVerified,
        isPinned,
      ];
}
