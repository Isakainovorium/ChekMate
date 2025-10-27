import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/search/presentation/providers/search_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SearchResultsWidget - Displays search results based on active filter
class SearchResultsWidget extends ConsumerStatefulWidget {
  const SearchResultsWidget({super.key});

  @override
  ConsumerState<SearchResultsWidget> createState() =>
      _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends ConsumerState<SearchResultsWidget> {
  int _currentPage = 1;
  static const int _itemsPerPage = 20;

  @override
  Widget build(BuildContext context) {
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

        // Calculate pagination
        final totalPages = (results.length / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, results.length);
        final paginatedResults = results.sublist(startIndex, endIndex);

        return Column(
          children: [
            // Use AppVirtualizedList for better performance
            Expanded(
              child: AppVirtualizedList(
                items: paginatedResults,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemBuilder: (context, result, index) {
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      leading: result.imageUrl != null
                          ? AppAvatar(
                              imageUrl: result.imageUrl!,
                              name: result.title,
                              size: AppAvatarSize.medium,
                            )
                          : AppAvatar(
                              name: result.title,
                              size: AppAvatarSize.medium,
                            ),
                      title: Text(result.title),
                      subtitle: Text(result.subtitle),
                      trailing: result.isHighlyRelevant
                          ? const Icon(Icons.star,
                              color: AppColors.primary, size: 16)
                          : null,
                      onTap: () {
                        // Save to recent searches
                        ref
                            .read(searchStateProvider.notifier)
                            .saveRecentSearch(query);
                        // Navigate to result detail
                      },
                    ),
                  );
                },
              ),
            ),

            // Add AppPagination for navigation
            if (totalPages > 1) ...[
              const SizedBox(height: AppSpacing.md),
              AppPagination(
                currentPage: _currentPage,
                totalPages: totalPages,
                itemsPerPage: _itemsPerPage,
                totalItems: results.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
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
