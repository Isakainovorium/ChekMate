import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/calls/domain/entities/call_entity.dart';
import 'package:flutter_chekmate/features/calls/presentation/pages/call_page.dart';
import 'package:flutter_chekmate/features/calls/presentation/providers/call_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incoming call page - shown when receiving a call
class IncomingCallPage extends ConsumerWidget {
  const IncomingCallPage({
    required this.call,
    super.key,
  });

  final CallEntity call;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // Caller info
            _buildCallerInfo(),
            
            const Spacer(),
            
            // Call type indicator
            _buildCallTypeIndicator(),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Action buttons
            _buildActionButtons(context, ref),
            
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildCallerInfo() {
    return Column(
      children: [
        // Animated ring around avatar
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 3,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: call.callerAvatarUrl.isNotEmpty
                  ? NetworkImage(call.callerAvatarUrl)
                  : null,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: call.callerAvatarUrl.isEmpty
                  ? Text(
                      call.callerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Caller name
        Text(
          call.callerName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Call type text
        Text(
          call.isVideoCall ? 'Incoming Video Call' : 'Incoming Voice Call',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCallTypeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            call.isVideoCall ? Icons.videocam : Icons.phone,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            call.isVideoCall ? 'Video Call' : 'Voice Call',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Decline button
        _buildActionButton(
          icon: Icons.call_end,
          label: 'Decline',
          color: Colors.red,
          onTap: () async {
            HapticFeedback.mediumImpact();
            await ref.read(callControllerProvider).declineCall(call.id);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        
        // Accept button
        _buildActionButton(
          icon: call.isVideoCall ? Icons.videocam : Icons.call,
          label: 'Accept',
          color: Colors.green,
          onTap: () async {
            HapticFeedback.mediumImpact();
            await ref.read(callControllerProvider).answerCall(call.id);
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => CallPage(call: call),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
