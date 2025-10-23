import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/search/presentation/providers/search_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// RecentSearchesWidget - Displays recent search history
class RecentSearchesWidget extends ConsumerWidget {
  const RecentSearchesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearchesAsync = ref.watch(recentSearchesProvider);

    return recentSearchesAsync.when(
      data: (searches) {
        if (searches.isEmpty) {
          return const SizedBox.shrink();
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(searchStateProvider.notifier).clearRecentSearches();
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),
              ...searches.map(
                (search) => ListTile(
                  leading: const Icon(Icons.history, size: 20),
                  title: Text(search.query),
                  subtitle: Text(search.timeAgo),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      ref.read(searchStateProvider.notifier).removeRecentSearch(search.query);
                    },
                  ),
                  onTap: () {
                    ref.read(searchStateProvider.notifier).setQuery(search.query);
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

