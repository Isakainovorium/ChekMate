import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Post Options Panel - Location, privacy, and other settings
class PostOptionsPanel extends StatelessWidget {
  const PostOptionsPanel({
    required this.location,
    required this.privacy,
    required this.onLocationChanged,
    required this.onPrivacyChanged,
    super.key,
  });
  final String? location;
  final String privacy;
  final void Function(String?) onLocationChanged;
  final void Function(String) onPrivacyChanged;

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
          subtitle: 'Who are you with?',
          onTap: () => _showTagPeopleDialog(context),
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.my_location, color: AppColors.primary),
              title: const Text('Current Location'),
              onTap: () {
                onLocationChanged('Current Location');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: AppColors.primary),
              title: const Text('Search Location'),
              onTap: () {
                _showLocationSearch(context);
              },
            ),
            if (location != null)
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text('Remove Location'),
                onTap: () {
                  onLocationChanged(null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
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

  void _showTagPeopleDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tag People',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tag people feature coming soon',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationSearch(BuildContext context) {
    Navigator.pop(context); // Close the location picker first
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search for a location...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Placeholder for search functionality
              },
            ),
            const SizedBox(height: AppSpacing.md),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_searching,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Location search feature coming soon',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
