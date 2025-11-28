import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/calls/domain/entities/call_entity.dart';
import 'package:flutter_chekmate/features/calls/presentation/pages/call_page.dart';
import 'package:flutter_chekmate/features/calls/presentation/providers/call_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Outgoing call page - shown when making a call (waiting for answer)
class OutgoingCallPage extends ConsumerStatefulWidget {
  const OutgoingCallPage({
    required this.call,
    super.key,
  });

  final CallEntity call;

  @override
  ConsumerState<OutgoingCallPage> createState() => _OutgoingCallPageState();
}

class _OutgoingCallPageState extends ConsumerState<OutgoingCallPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for call status changes
    final currentCall = ref.watch(currentCallProvider);

    currentCall.whenData((call) {
      if (call != null) {
        if (call.status == CallStatus.ongoing) {
          // Call was answered, navigate to call page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => CallPage(call: call),
                ),
              );
            }
          });
        } else if (call.status == CallStatus.declined ||
            call.status == CallStatus.ended ||
            call.status == CallStatus.missed) {
          // Call was declined/ended, go back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Receiver info with pulse animation
            _buildReceiverInfo(),

            const Spacer(),

            // Calling status
            _buildCallingStatus(),

            const SizedBox(height: AppSpacing.xxl),

            // Cancel button
            _buildCancelButton(context),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiverInfo() {
    return Column(
      children: [
        // Animated pulsing avatar
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
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
                ),
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // Receiver name
        Text(
          widget.call.receiverName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Call type text
        Text(
          widget.call.isVideoCall ? 'Video Call' : 'Voice Call',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCallingStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Calling...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await ref.read(callControllerProvider).endCall();
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
