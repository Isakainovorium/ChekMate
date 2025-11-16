import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/explore/presentation/providers/explore_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SuggestedUsersWidget - Displays suggested users to follow
class SuggestedUsersWidget extends ConsumerWidget {
  const SuggestedUsersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(suggestedUsersProvider);
    final exploreState = ref.watch(exploreStateProvider);

    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const AppEmptyState(
            icon: Icons.people_outline,
            title: 'No suggested users',
            message: 'Check back later for user suggestions!',
          );
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Suggested Users',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              ...users.map(
                (user) => AppUserCard(
                  user: AppUserCardData(
                    name: user.name,
                    title: user.username,
                    bio: user.bio,
                    avatarUrl: user.avatar,
                    stats: AppUserStats(
                      followers: user.followers,
                      following: 0, // Not available in SuggestedUserEntity
                    ),
                  ),
                  child: ListTile(
                    leading: AppAvatar(
                      imageUrl: user.avatar,
                      name: user.name,
                      size: AppAvatarSize.medium,
                    ),
                    title: Row(
                      children: [
                        Text(user.name),
                        if (user.isVerified) ...[
                          const SizedBox(width: 4),
                          const AppBadge(
                            label: '',
                            variant: AppBadgeVariant.primary,
                            size: AppBadgeSize.small,
                            icon: Icons.verified,
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.username),
                        if (user.bio.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.bio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${user.formattedFollowers} followers',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    trailing: AppButton(
                      onPressed: () {
                        ref
                            .read(exploreStateProvider.notifier)
                            .toggleFollowUser(user.id);
                      },
                      variant: exploreState.followedUsers.contains(user.id)
                          ? AppButtonVariant.outline
                          : AppButtonVariant.primary,
                      size: AppButtonSize.sm,
                      child: Text(
                        exploreState.followedUsers.contains(user.id)
                            ? 'Following'
                            : 'Follow',
                      ),
                    ),
                    onTap: () {
                      // Navigate to user profile
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Error loading users',
        message: error.toString(),
      ),
    );
  }
}
