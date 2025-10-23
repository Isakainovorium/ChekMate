import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Profile stats widget - converted from ProfileStats.tsx
/// Shows posts, followers, subscribers, likes counts with trend sparklines
class ProfileStatsWidget extends StatelessWidget {
  const ProfileStatsWidget({
    required this.posts,
    required this.followers,
    required this.subscribers,
    required this.likes,
    super.key,
    this.showTrends = true,
    this.postsData,
    this.followersData,
    this.subscribersData,
    this.likesData,
  });

  final int posts;
  final String followers;
  final String subscribers;
  final String likes;
  final bool showTrends;
  final List<double>? postsData;
  final List<double>? followersData;
  final List<double>? subscribersData;
  final List<double>? likesData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '$posts',
                'Posts',
                postsData ?? [10, 12, 8, 15, 18, 22, 25],
              ),
              _buildStatItem(
                followers,
                'Followers',
                followersData ?? [100, 120, 110, 140, 160, 180, 200],
              ),
              _buildStatItem(
                subscribers,
                'Subscribers',
                subscribersData ?? [50, 55, 48, 62, 70, 75, 80],
              ),
              _buildStatItem(
                likes,
                'Likes',
                likesData ?? [500, 520, 480, 580, 620, 650, 700],
              ),
            ],
          ),
        ),
        const AppSeparator(),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, List<double> trendData) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (showTrends) ...[
            const SizedBox(height: 8),
            AppSparkline(
              data: trendData,
              width: 60,
              height: 20,
              showFill: true,
              strokeWidth: 1.5,
            ),
          ],
        ],
      ),
    );
  }
}
