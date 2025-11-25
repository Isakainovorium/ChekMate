import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/ui/index.dart';
import '../../data/models/contextual_follow_suggestion_model.dart';
import '../providers/intelligence_providers.dart';

/// ContextualFollowSuggestionsWidget displays smart follow recommendations
class ContextualFollowSuggestionsWidget extends ConsumerWidget {
  const ContextualFollowSuggestionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(contextualFollowSuggestionsProvider);

    return suggestionsAsync.when(
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        // Group suggestions by match type
        final journeyMatches = suggestions
            .where((s) => s.matchType == MatchType.journeyMatch)
            .toList();
        final topicClusters = suggestions
            .where((s) => s.matchType == MatchType.topicCluster)
            .toList();
        final experienceMatches = suggestions
            .where((s) => s.matchType == MatchType.experienceCorrelation)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (journeyMatches.isNotEmpty)
              _buildSuggestionSection(
                context: context,
                ref: ref,
                title: 'Journey Matches',
                icon: Icons.route,
                suggestions: journeyMatches,
              ),
            if (topicClusters.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildSuggestionSection(
                context: context,
                ref: ref,
                title: 'Topic Specialists',
                icon: Icons.topic,
                suggestions: topicClusters,
              ),
            ],
            if (experienceMatches.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildSuggestionSection(
                context: context,
                ref: ref,
                title: 'Similar Experiences',
                icon: Icons.people_outline,
                suggestions: experienceMatches,
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildSuggestionSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required List<ContextualFollowSuggestionModel> suggestions,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...suggestions.take(3).map(
              (suggestion) => _buildSuggestionItem(context, ref, suggestion)),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    WidgetRef ref,
    ContextualFollowSuggestionModel suggestion,
  ) {
    return ListTile(
      leading: AppAvatar(
        imageUrl: '', // Would fetch from user data
        name: suggestion.suggestedUserId,
        size: AppAvatarSize.medium,
      ),
      title: Text(
        suggestion.suggestedUserId, // Would show username
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            suggestion.reason,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (suggestion.sharedAttributes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: suggestion.sharedAttributes
                  .take(3)
                  .map((attr) => AppBadge(
                        label: attr,
                        variant: AppBadgeVariant.secondary,
                        size: AppBadgeSize.small,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
      trailing: AppButton(
        onPressed: () async {
          final userController = ref.read(userControllerProvider);
          await userController.followUser(suggestion.suggestedUserId);
        },
        variant: AppButtonVariant.primary,
        size: AppButtonSize.sm,
        child: const Text('Follow'),
      ),
    );
  }
}
