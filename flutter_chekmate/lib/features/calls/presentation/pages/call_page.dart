import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/calls/domain/entities/call_entity.dart';
import 'package:flutter_chekmate/features/calls/presentation/providers/call_providers.dart';
import 'package:flutter_chekmate/features/calls/services/call_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Active call page - shown during an ongoing call
class CallPage extends ConsumerStatefulWidget {
  const CallPage({
    required this.call,
    super.key,
  });

  final CallEntity call;

  @override
  ConsumerState<CallPage> createState() => _CallPageState();
}

class _CallPageState extends ConsumerState<CallPage> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = false;
  bool _showControls = true;
  Duration _callDuration = Duration.zero;
  Timer? _durationTimer;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _startDurationTimer();
    _startHideControlsTimer();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && widget.call.isVideoCall) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    ref.read(callControllerProvider).toggleMute(_isMuted);
    HapticFeedback.lightImpact();
  }

  void _toggleVideo() {
    setState(() => _isVideoOff = !_isVideoOff);
    ref.read(callControllerProvider).toggleVideo(_isVideoOff);
    HapticFeedback.lightImpact();
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    ref.read(callControllerProvider).toggleSpeaker(_isSpeakerOn);
    HapticFeedback.lightImpact();
  }

  void _switchCamera() {
    ref.read(callControllerProvider).switchCamera();
    HapticFeedback.lightImpact();
  }

  Future<void> _endCall() async {
    await ref.read(callControllerProvider).endCall();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onTap() {
    if (widget.call.isVideoCall) {
      setState(() => _showControls = !_showControls);
      if (_showControls) {
        _startHideControlsTimer();
      }
    }
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
    final callService = ref.watch(callServiceProvider);
    final currentCall = ref.watch(currentCallProvider);

    // Check if call ended
    currentCall.whenData((call) {
      if (call == null || call.status == CallStatus.ended) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });

    return Scaffold(
      backgroundColor: widget.call.isVideoCall ? Colors.black : AppColors.navyBlue,
      body: GestureDetector(
        onTap: _onTap,
        child: Stack(
          children: [
            // Video views or avatar
            if (widget.call.isVideoCall)
              _buildVideoViews(callService)
            else
              _buildVoiceCallUI(),

            // Top bar
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(),
              ),

            // Bottom controls
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoViews(CallService callService) {
    return Stack(
      children: [
        // Remote video (full screen)
        Positioned.fill(
          child: callService.remoteRenderer != null
              ? RTCVideoView(
                  callService.remoteRenderer!,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: widget.call.receiverAvatarUrl.isNotEmpty
                              ? NetworkImage(widget.call.receiverAvatarUrl)
                              : null,
                          backgroundColor: AppColors.primary.withOpacity(0.3),
                          child: widget.call.receiverAvatarUrl.isEmpty
                              ? Text(
                                  widget.call.receiverName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Connecting...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // Local video (picture-in-picture)
        if (!_isVideoOff && callService.localRenderer != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 16,
            child: GestureDetector(
              onTap: _switchCamera,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                clipBehavior: Clip.hardEdge,
                child: RTCVideoView(
                  callService.localRenderer!,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: true,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVoiceCallUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundImage: widget.call.receiverAvatarUrl.isNotEmpty
                ? NetworkImage(widget.call.receiverAvatarUrl)
                : null,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: widget.call.receiverAvatarUrl.isEmpty
                ? Text(
                    widget.call.receiverName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Name
          Text(
            widget.call.receiverName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Duration
          Text(
            _formatDuration(_callDuration),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
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
          // Minimize button
          IconButton(
            onPressed: () {
              // TODO: Implement picture-in-picture
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          
          const Spacer(),
          
          // Call info
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.call.receiverName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDuration(_callDuration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Switch camera (video calls only)
          if (widget.call.isVideoCall)
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
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
          // Mute button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            isActive: !_isMuted,
            onTap: _toggleMute,
          ),

          // Video button (video calls only)
          if (widget.call.isVideoCall)
            _buildControlButton(
              icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
              label: _isVideoOff ? 'Video On' : 'Video Off',
              isActive: !_isVideoOff,
              onTap: _toggleVideo,
            ),

          // Speaker button
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
            isActive: _isSpeakerOn,
            onTap: _toggleSpeaker,
          ),

          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End',
            isEndCall: true,
            onTap: _endCall,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = true,
    bool isEndCall = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEndCall
                  ? Colors.red
                  : isActive
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isEndCall || isActive ? Colors.white : Colors.white54,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
