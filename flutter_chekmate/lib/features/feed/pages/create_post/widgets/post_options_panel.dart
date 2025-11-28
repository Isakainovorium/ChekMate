import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/pages/create_post/widgets/location_search_sheet.dart';
import 'package:flutter_chekmate/features/feed/pages/create_post/widgets/tag_people_sheet.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Post Options Panel - Location, privacy, and other settings
class PostOptionsPanel extends StatelessWidget {
  const PostOptionsPanel({
    required this.location,
    required this.privacy,
    required this.onLocationChanged,
    required this.onPrivacyChanged,
    this.taggedUsers = const [],
    this.onTaggedUsersChanged,
    super.key,
  });
  final String? location;
  final String privacy;
  final void Function(String?) onLocationChanged;
  final void Function(String) onPrivacyChanged;
  final List<TaggedUser> taggedUsers;
  final void Function(List<TaggedUser>)? onTaggedUsersChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Post Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Location
        _buildOption(
          icon: Icons.location_on,
          title: 'Add Location',
          subtitle: location ?? 'Where are you?',
          onTap: () => _showLocationPicker(context),
        ),

        const SizedBox(height: AppSpacing.xs),

        // Privacy
        _buildOption(
          icon: Icons.lock,
          title: 'Privacy',
          subtitle: _getPrivacyLabel(privacy),
          onTap: () => _showPrivacyPicker(context),
        ),

        const SizedBox(height: AppSpacing.xs),

        // Tag People
        _buildOption(
          icon: Icons.person_add,
          title: 'Tag People',
          subtitle: taggedUsers.isEmpty 
              ? 'Who are you with?' 
              : '${taggedUsers.length} ${taggedUsers.length == 1 ? 'person' : 'people'} tagged',
          onTap: () => _showTagPeopleSheet(context),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getPrivacyLabel(String privacy) {
    switch (privacy) {
      case 'public':
        return 'Everyone can see';
      case 'friends':
        return 'Friends only';
      case 'private':
        return 'Only me';
      default:
        return 'Everyone can see';
    }
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => LocationSearchSheet(
        initialLocation: location,
        onLocationSelected: (result) {
          if (result != null) {
            onLocationChanged(result.displayName);
          } else {
            onLocationChanged(null);
          }
        },
      ),
    );
  }

  void _showPrivacyPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who can see this post?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Use AppRadioGroup for privacy selection
            AppRadioGroup<String>(
              value: privacy,
              items: const [
                AppRadioItem(
                  value: 'public',
                  label: 'Public',
                  subtitle: 'Everyone can see',
                ),
                AppRadioItem(
                  value: 'friends',
                  label: 'Friends',
                  subtitle: 'Friends only',
                ),
                AppRadioItem(
                  value: 'private',
                  label: 'Private',
                  subtitle: 'Only me',
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onPrivacyChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showTagPeopleSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TagPeopleSheet(
        initialTags: taggedUsers,
        onTagsChanged: (tags) {
          onTaggedUsersChanged?.call(tags);
        },
      ),
    );
  }
}
