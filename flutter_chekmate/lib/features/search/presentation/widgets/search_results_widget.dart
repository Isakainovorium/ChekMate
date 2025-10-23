import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/search/presentation/providers/search_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SearchResultsWidget - Displays search results based on active filter
class SearchResultsWidget extends ConsumerWidget {
  const SearchResultsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);
    final query = searchState.query;
    final filter = searchState.activeFilter;

    // Select provider based on active filter
    final resultsProvider = filter == 'users'
        ? searchUsersProvider(query)
        : filter == 'posts'
            ? searchPostsProvider(query)
            : filter == 'hashtags'
                ? searchHashtagsProvider(query)
                : searchAllProvider(query);

    final resultsAsync = ref.watch(resultsProvider);

    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return const AppEmptyState(
            icon: Icons.search_off,
            title: 'No results found',
            message: 'Try searching for something else',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: result.imageUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(result.imageUrl!),
                      )
                    : CircleAvatar(
                        child: Text(result.typeIcon),
                      ),
                title: Text(result.title),
                subtitle: Text(result.subtitle),
                trailing: result.isHighlyRelevant
                    ? const Icon(Icons.star, color: AppColors.primary, size: 16)
                    : null,
                onTap: () {
                  // Save to recent searches
                  ref.read(searchStateProvider.notifier).saveRecentSearch(query);
                  // Navigate to result detail
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Error loading results',
        message: error.toString(),
      ),
    );
  }
}

