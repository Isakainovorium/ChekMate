import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/live/domain/entities/live_stream_entity.dart';
import 'package:flutter_chekmate/features/live/presentation/providers/live_providers.dart';
import 'package:flutter_chekmate/features/live/services/agora_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Watch Live page - Viewer experience
class WatchLivePage extends ConsumerStatefulWidget {
  const WatchLivePage({required this.streamId, super.key});

  final String streamId;

  @override
  ConsumerState<WatchLivePage> createState() => _WatchLivePageState();
}

class _WatchLivePageState extends ConsumerState<WatchLivePage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  bool _showChat = true;
  bool _isConnecting = true;
  bool _hasLiked = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _joinStream();
  }

  Future<void> _joinStream() async {
    try {
      await ref.read(liveStreamControllerProvider).joinStream(widget.streamId);
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _leaveStream();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  Future<void> _leaveStream() async {
    await ref.read(liveStreamControllerProvider).leaveStream(widget.streamId);
  }

  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    await ref.read(liveStreamControllerProvider).sendChatMessage(
      streamId: widget.streamId,
      message: message,
    );

    _chatController.clear();
  }

  void _likeStream() {
    if (_hasLiked) return;
    
    setState(() => _hasLiked = true);
    ref.read(liveStreamControllerProvider).likeStream(widget.streamId);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final streamAsync = ref.watch(streamProvider(widget.streamId));
    final streamService = ref.watch(liveStreamServiceProvider);
    final chatMessages = ref.watch(streamChatProvider(widget.streamId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: streamAsync.when(
        data: (stream) {
          if (stream == null) {
            return _buildError('Stream not found');
          }
          
          if (stream.status != LiveStreamStatus.live) {
            return _buildStreamEnded(stream);
          }

          return Stack(
            children: [
              // Video view (full screen)
              Positioned.fill(
                child: _buildVideoView(streamService),
              ),

              // Top bar with stream info
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(stream),
              ),

              // Chat overlay
              if (_showChat)
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  height: 250,
                  child: _buildChatOverlay(chatMessages),
                ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(stream),
              ),

              // Connecting overlay
              if (_isConnecting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Connecting to stream...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Error overlay
              if (_errorMessage != null)
                Positioned.fill(
                  child: _buildError(_errorMessage!),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _buildError(error.toString()),
      ),
    );
  }

  Widget _buildVideoView(LiveStreamService streamService) {
    final renderer = streamService.remoteRenderer;
    
    if (renderer == null || _isConnecting) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.videocam,
            color: Colors.white24,
            size: 80,
          ),
        ),
      );
    }

    return RTCVideoView(
      renderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    );
  }

  Widget _buildTopBar(LiveStreamEntity stream) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          
          // Host info
          CircleAvatar(
            radius: 18,
            backgroundImage: stream.hostAvatarUrl.isNotEmpty
                ? NetworkImage(stream.hostAvatarUrl)
                : null,
            backgroundColor: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        stream.hostName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (stream.isHostVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 14,
                        ),
                      ),
                  ],
                ),
                Text(
                  stream.title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppSpacing.sm),
          
          // Viewer count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  stream.formattedViewerCount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatOverlay(AsyncValue<List<LiveChatMessage>> chatMessages) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Chat messages
          Expanded(
            child: chatMessages.when(
              data: (messages) => ListView.builder(
                controller: _chatScrollController,
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return _buildChatMessage(message);
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          
          // Chat input
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Say something...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(LiveChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: message.userAvatarUrl.isNotEmpty
                ? NetworkImage(message.userAvatarUrl)
                : null,
            backgroundColor: AppColors.primary.withOpacity(0.3),
            child: message.userAvatarUrl.isEmpty
                ? Text(
                    message.userName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: message.isHost
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${message.userName} ',
                      style: TextStyle(
                        color: message.isHost ? AppColors.primary : Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (message.isHost)
                      const TextSpan(
                        text: '(Host) ',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                    TextSpan(
                      text: message.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(LiveStreamEntity stream) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Toggle chat
          _buildControlButton(
            icon: _showChat ? Icons.chat : Icons.chat_outlined,
            label: 'Chat',
            isActive: _showChat,
            onTap: () => setState(() => _showChat = !_showChat),
          ),
          
          // Like button
          _buildControlButton(
            icon: _hasLiked ? Icons.favorite : Icons.favorite_border,
            label: '${stream.likeCount + (_hasLiked ? 1 : 0)}',
            isActive: true,
            activeColor: _hasLiked ? Colors.red : null,
            onTap: _likeStream,
          ),
          
          // Share button
          _buildControlButton(
            icon: Icons.share,
            label: 'Share',
            onTap: () {
              // TODO: Implement share
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = true,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: activeColor ?? Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: activeColor ?? Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamEnded(LiveStreamEntity stream) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: stream.hostAvatarUrl.isNotEmpty
                    ? NetworkImage(stream.hostAvatarUrl)
                    : null,
                backgroundColor: AppColors.primary.withOpacity(0.3),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                stream.hostName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Stream has ended',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Duration: ${stream.formattedDuration}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              Text(
                'Peak viewers: ${stream.peakViewerCount}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
