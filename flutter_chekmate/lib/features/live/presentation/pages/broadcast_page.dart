import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/live/domain/entities/live_stream_entity.dart';
import 'package:flutter_chekmate/features/live/presentation/providers/live_providers.dart';
import 'package:flutter_chekmate/features/live/services/agora_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Broadcast page - Host view while streaming
class BroadcastPage extends ConsumerStatefulWidget {
  const BroadcastPage({required this.stream, super.key});

  final LiveStreamEntity stream;

  @override
  ConsumerState<BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends ConsumerState<BroadcastPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  bool _isCameraOn = true;
  bool _isMicOn = true;
  bool _showChat = true;
  Duration _streamDuration = Duration.zero;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    _startDurationTimer();
    
    // Listen for viewer count updates
    ref.read(liveStreamServiceProvider).viewerCount.listen((count) {
      if (mounted) setState(() {});
    });
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _streamDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  Future<void> _endStream() async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Stream?'),
        content: const Text('Are you sure you want to end your live stream?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('End Stream'),
          ),
        ],
      ),
    );

    if (shouldEnd == true && mounted) {
      await ref.read(liveStreamControllerProvider).endStream(widget.stream.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _toggleCamera() {
    setState(() => _isCameraOn = !_isCameraOn);
    ref.read(liveStreamControllerProvider).toggleCamera(_isCameraOn);
    HapticFeedback.lightImpact();
  }

  void _toggleMic() {
    setState(() => _isMicOn = !_isMicOn);
    ref.read(liveStreamControllerProvider).toggleMicrophone(_isMicOn);
    HapticFeedback.lightImpact();
  }

  void _switchCamera() {
    ref.read(liveStreamControllerProvider).switchCamera();
    HapticFeedback.lightImpact();
  }

  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    await ref.read(liveStreamControllerProvider).sendChatMessage(
      streamId: widget.stream.id,
      message: message,
    );

    _chatController.clear();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final streamService = ref.watch(liveStreamServiceProvider);
    final chatMessages = ref.watch(streamChatProvider(widget.stream.id));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video preview (full screen)
          Positioned.fill(
            child: _buildVideoPreview(streamService),
          ),

          // Top bar with stream info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // Chat overlay
          if (_showChat)
            Positioned(
              bottom: 100,
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
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(LiveStreamService streamService) {
    final renderer = streamService.localRenderer;
    
    if (renderer == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return RTCVideoView(
      renderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      mirror: true,
    );
  }

  Widget _buildTopBar() {
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
                  width: 8,
                  height: 8,
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppSpacing.sm),
          
          // Duration
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatDuration(_streamDuration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
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
                const Icon(Icons.visibility, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                StreamBuilder<int>(
                  stream: ref.read(liveStreamServiceProvider).viewerCount,
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // End stream button
          IconButton(
            onPressed: _endStream,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
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

  Widget _buildBottomControls() {
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
          
          // Toggle mic
          _buildControlButton(
            icon: _isMicOn ? Icons.mic : Icons.mic_off,
            label: 'Mic',
            isActive: _isMicOn,
            onTap: _toggleMic,
          ),
          
          // Toggle camera
          _buildControlButton(
            icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
            label: 'Camera',
            isActive: _isCameraOn,
            onTap: _toggleCamera,
          ),
          
          // Switch camera
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            label: 'Flip',
            onTap: _switchCamera,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = true,
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
              color: isActive
                  ? Colors.white.withOpacity(0.2)
                  : Colors.red.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.red,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
