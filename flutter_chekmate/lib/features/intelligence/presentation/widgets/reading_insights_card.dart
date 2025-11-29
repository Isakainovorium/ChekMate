import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/ui/index.dart';
import '../providers/intelligence_providers.dart';

/// ReadingInsightsCard displays personalized reading pattern insights
class ReadingInsightsCard extends ConsumerWidget {
  const ReadingInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userBehaviorProfileProvider);
    final controller = ref.read(readingInsightsControllerProvider);

    return profileAsync.when(
      data: (profile) {
        final insights = controller.getReadingInsightsSummary(profile);

        if (!(insights['hasData'] as bool)) {
          return AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.psychology_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Reading Insights',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    insights['message'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return AppCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Your Reading Insights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Main insight
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          insights['insight'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.category_outlined,
                        label: 'Top Category',
                        value: insights['topCategory'] as String,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.speed,
                        label: 'Learning Pace',
                        value: _formatPace(insights['learningPace'] as double),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Recommended tags
                if ((insights['recommendedTags'] as List<String>)
                    .isNotEmpty) ...[
                  Text(
                    'Recommended for you:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: (insights['recommendedTags'] as List<String>)
                        .take(5)
                        .map((tag) => AppBadge(
                              label: tag,
                              variant: AppBadgeVariant.secondary,
                              size: AppBadgeSize.small,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const AppCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Unable to load insights',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatPace(double pace) {
    if (pace < 0.3) return 'Slow';
    if (pace < 0.7) return 'Moderate';
    return 'Fast';
  }
}
