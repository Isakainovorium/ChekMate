import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Profile header widget - converted from ProfileHeader.tsx
/// Shows profile info with follow/message buttons
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    required this.name,
    required this.username,
    required this.bio,
    required this.avatar,
    super.key,
    this.isFollowing = false,
    this.onFollowClick,
    this.onMessageClick,
  });
  final String name;
  final String username;
  final String bio;
  final String avatar;
  final bool isFollowing;
  final VoidCallback? onFollowClick;
  final VoidCallback? onMessageClick;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          // Top icons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                onPressed: () {
                  if (kDebugMode) {
                    debugPrint('Notifications pressed');
                  }
                },
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                child: const Icon(Icons.notifications_outlined, size: 24),
              ),
              AppButton(
                onPressed: () {
                  if (kDebugMode) {
                    debugPrint('Share pressed');
                  }
                },
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                child: const Icon(Icons.share_outlined, size: 24),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Profile info and avatar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      bio,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Profile picture with gradient border
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFEBD59), Color(0xFFDF912F)],
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: AppAvatar(
                    imageUrl: avatar,
                    name: name,
                    size: AppAvatarSize.extraLarge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: onFollowClick,
                  variant: isFollowing
                      ? AppButtonVariant.secondary
                      : AppButtonVariant.primary,
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  onPressed: onMessageClick,
                  child: const Text('Message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
