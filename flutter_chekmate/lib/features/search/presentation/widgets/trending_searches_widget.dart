import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/search/presentation/providers/search_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TrendingSearchesWidget - Displays trending search terms
class TrendingSearchesWidget extends ConsumerWidget {
  const TrendingSearchesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingSearchesProvider);

    return trendingAsync.when(
      data: (trending) {
        if (trending.isEmpty) {
          return const SizedBox.shrink();
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 18, color: AppColors.primary),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Trending Searches',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              ...trending.asMap().entries.map(
                    (entry) => ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(entry.value),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ref
                            .read(searchStateProvider.notifier)
                            .setQuery(entry.value);
                      },
                    ),
                  ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
