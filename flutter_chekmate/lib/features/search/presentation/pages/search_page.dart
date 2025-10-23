import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/search/presentation/providers/search_providers.dart';
import 'package:flutter_chekmate/features/search/presentation/widgets/recent_searches_widget.dart';
import 'package:flutter_chekmate/features/search/presentation/widgets/search_results_widget.dart';
import 'package:flutter_chekmate/features/search/presentation/widgets/trending_searches_widget.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SearchPage - Clean Architecture Implementation
///
/// Displays search interface with results, suggestions, and filters.
/// Uses Riverpod for state management and Clean Architecture pattern.
class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          _buildSearchBar(context, ref, searchState),
          if (searchState.isSearching)
            _buildFilterTabs(context, ref, searchState),
          Expanded(
            child: searchState.isSearching
                ? const SearchResultsWidget()
                : _buildEmptyState(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
    SearchState state,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: AppInput(
        hint: 'Search users, posts, hashtags...',
        prefixIcon: const Icon(Icons.search, size: 18),
        suffixIcon: state.query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  ref.read(searchStateProvider.notifier).clearSearch();
                },
              )
            : null,
        onChanged: (value) {
          ref.read(searchStateProvider.notifier).setQuery(value);
        },
        autofocus: true,
      ),
    );
  }

  Widget _buildFilterTabs(
    BuildContext context,
    WidgetRef ref,
    SearchState state,
  ) {
    final filters = [
      {'id': 'all', 'label': 'All'},
      {'id': 'users', 'label': 'Users'},
      {'id': 'posts', 'label': 'Posts'},
      {'id': 'hashtags', 'label': 'Hashtags'},
    ];

    final tabs = filters
        .map(
          (filter) => AppTab(
            label: filter['label'] as String,
          ),
        )
        .toList();

    final children = filters
        .map(
          (filter) => Center(
            child: Text('Content for ${filter['label']}'),
          ),
        )
        .toList();

    return AppTabs(
      tabs: tabs,
      children: children,
      onTap: (index) {
        ref.read(searchStateProvider.notifier).setActiveFilter(
              filters[index]['id'] as String,
            );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecentSearchesWidget(),
          SizedBox(height: AppSpacing.lg),
          TrendingSearchesWidget(),
        ],
      ),
    );
  }
}
