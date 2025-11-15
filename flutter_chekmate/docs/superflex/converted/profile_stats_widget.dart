import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// ProfileStats - Displays user statistics (posts, followers, following)
class ProfileStatsWidget extends StatelessWidget {
  const ProfileStatsWidget({
    required this.stats, super.key,
    this.onPostsTap,
    this.onFollowersTap,
    this.onFollowingTap,
    this.isClickable = true,
  });

  final ProfileStats stats;
  final VoidCallback? onPostsTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final bool isClickable;

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          label: 'Posts',
          value: _formatCount(stats.postsCount),
          onTap: isClickable ? onPostsTap : null,
          theme: theme,
        ),
        _StatItem(
          label: 'Followers',
          value: _formatCount(stats.followersCount),
          onTap: isClickable ? onFollowersTap : null,
          theme: theme,
        ),
        _StatItem(
          label: 'Following',
          value: _formatCount(stats.followingCount),
          onTap: isClickable ? onFollowingTap : null,
          theme: theme,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.theme,
    this.onTap,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: child,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: child,
    );
  }
}

/// Data class for profile statistics
class ProfileStats {
  const ProfileStats({
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
  });

  final int postsCount;
  final int followersCount;
  final int followingCount;

  ProfileStats copyWith({
    int? postsCount,
    int? followersCount,
    int? followingCount,
  }) {
    return ProfileStats(
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}
