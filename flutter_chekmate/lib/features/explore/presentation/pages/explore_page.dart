import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/explore/presentation/providers/explore_providers.dart';
import 'package:flutter_chekmate/features/explore/presentation/widgets/hashtags_widget.dart';
import 'package:flutter_chekmate/features/explore/presentation/widgets/suggested_users_widget.dart';
import 'package:flutter_chekmate/features/explore/presentation/widgets/trending_content_widget.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ExplorePage - Clean Architecture Implementation
///
/// Displays trending content, hashtags, and suggested users.
/// Uses Riverpod for state management and Clean Architecture pattern.
class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreState = ref.watch(exploreStateProvider);

    return Column(
      children: [
        _buildSearchBar(context, ref, exploreState),
        _buildCategoryTabs(context, ref, exploreState),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildContent(context, ref, exploreState),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
    ExploreState state,
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
        hint: 'Search trending topics, people, hashtags...',
        prefixIcon: const Icon(Icons.search, size: 18),
        onChanged: (value) {
          ref.read(exploreStateProvider.notifier).setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildCategoryTabs(
    BuildContext context,
    WidgetRef ref,
    ExploreState state,
  ) {
    final categories = [
      {'id': 'trending', 'label': 'Trending', 'icon': Icons.trending_up},
      {'id': 'popular', 'label': 'Popular', 'icon': Icons.favorite_border},
      {'id': 'hashtags', 'label': 'Hashtags', 'icon': Icons.tag},
      {'id': 'people', 'label': 'People', 'icon': Icons.people_outline},
    ];

    final tabs = categories
        .map(
          (category) => AppTab(
            label: category['label'] as String,
            icon: Icon(category['icon'] as IconData, size: 16),
          ),
        )
        .toList();

    final children = categories.map((category) {
      final categoryId = category['id'] as String;
      return _buildContent(
        context,
        ref,
        state.copyWith(activeCategory: categoryId),
      );
    }).toList();

    return AppTabs(
      tabs: tabs,
      children: children,
      onTap: (index) {
        ref.read(exploreStateProvider.notifier).setActiveCategory(
              categories[index]['id'] as String,
            );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ExploreState state,
  ) {
    switch (state.activeCategory) {
      case 'trending':
        return const TrendingContentWidget();
      case 'popular':
        return const TrendingContentWidget(isPopular: true);
      case 'hashtags':
        return const HashtagsWidget();
      case 'people':
        return const SuggestedUsersWidget();
      default:
        return const TrendingContentWidget();
    }
  }
}
