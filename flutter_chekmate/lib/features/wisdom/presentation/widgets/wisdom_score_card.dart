import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/wisdom/models/wisdom_score_model.dart';
import 'package:flutter_chekmate/features/wisdom/presentation/providers/wisdom_providers.dart';

/// Compact wisdom score dashboard for profile page integration.
class WisdomScoreCard extends ConsumerWidget {
  const WisdomScoreCard({
    super.key,
    required this.userId,
    this.isOwnProfile = false,
  });

  final String userId;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(userWisdomScoreProvider(userId));

    return scoreAsync.when(
      data: (score) => _WisdomScoreContent(
        score: score,
        isOwnProfile: isOwnProfile,
      ),
      loading: () => const _WisdomScoreSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _WisdomScoreContent extends StatelessWidget {
  const _WisdomScoreContent({
    required this.score,
    required this.isOwnProfile,
  });

  final WisdomScore score;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context) {
    final topCategories = (score.categoryScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surfaceVariant.withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.surfaceVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwnProfile ? 'Your Wisdom Score' : 'Wisdom Reputation',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isOwnProfile
                          ? 'Live insights from your community contributions'
                          : 'Insights from ${score.totalInteractions} interactions',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _InfoChip(
                          icon: Icons.emoji_events_outlined,
                          label: score.achievementLevel.displayName,
                        ),
                        _InfoChip(
                          icon: Icons.thumb_up_alt_outlined,
                          label:
                              '${score.getHelpfulPercentage().toStringAsFixed(0)}% helpful',
                        ),
                        _InfoChip(
                          icon: Icons.verified_outlined,
                          label: '${score.verifiedStories} verified stories',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _ScoreGauge(score: score.overallScore),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (topCategories.isNotEmpty) ...[
            const Text(
              'Top Categories',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...topCategories.map(
              (entry) => _CategoryProgressRow(
                label: _categoryDisplayName(entry.key),
                value: entry.value,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const Text(
            'Score Factors',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _FactorTile(
                label: 'Helpfulness',
                value: score.factors.helpfulnessRating,
              ),
              _FactorTile(
                label: 'Peer Validation',
                value: score.factors.peerValidation * 10,
              ),
              _FactorTile(
                label: 'Consistency',
                value: score.factors.consistencyScore * 10,
              ),
              _FactorTile(
                label: 'Engagement Boost',
                value: score.factors.engagementMultiplier * 5,
                suffix: 'x',
                max: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score),
      duration: const Duration(milliseconds: 600),
      builder: (context, animatedScore, _) {
        return SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: (animatedScore / 10).clamp(0, 1),
                strokeWidth: 8,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                backgroundColor:
                    AppColors.surfaceVariant.withOpacity(0.4),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animatedScore.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '/10',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (value / 10).clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactorTile extends StatelessWidget {
  const _FactorTile({
    required this.label,
    required this.value,
    this.max = 10,
    this.suffix = '',
  });

  final String label;
  final double value;
  final double max;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.clamp(0, max).toStringAsFixed(1)}$suffix',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (value / max).clamp(0, 1),
            minHeight: 6,
            backgroundColor: AppColors.surfaceVariant.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _WisdomScoreSkeleton extends StatelessWidget {
  const _WisdomScoreSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

String _categoryDisplayName(String key) {
  try {
    return WisdomCategory.values
        .firstWhere((category) => category.value == key)
        .displayName;
  } catch (_) {
    return key
        .split('_')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
