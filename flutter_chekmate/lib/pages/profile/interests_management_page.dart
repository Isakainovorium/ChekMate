import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interest Category Model
class InterestCategory {
  const InterestCategory({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}

/// Interests Management Page
/// Allows users to update their interests from profile settings
class InterestsManagementPage extends ConsumerStatefulWidget {
  const InterestsManagementPage({super.key});

  @override
  ConsumerState<InterestsManagementPage> createState() =>
      _InterestsManagementPageState();
}

class _InterestsManagementPageState
    extends ConsumerState<InterestsManagementPage> {
  // 25 interest categories with icons (same as onboarding)
  static const List<InterestCategory> _categories = [
    InterestCategory(name: 'Sports', icon: Icons.sports_soccer),
    InterestCategory(name: 'Music', icon: Icons.music_note),
    InterestCategory(name: 'Food', icon: Icons.restaurant),
    InterestCategory(name: 'Travel', icon: Icons.flight),
    InterestCategory(name: 'Fashion', icon: Icons.checkroom),
    InterestCategory(name: 'Fitness', icon: Icons.fitness_center),
    InterestCategory(name: 'Art', icon: Icons.palette),
    InterestCategory(name: 'Photography', icon: Icons.camera_alt),
    InterestCategory(name: 'Gaming', icon: Icons.sports_esports),
    InterestCategory(name: 'Technology', icon: Icons.computer),
    InterestCategory(name: 'Movies', icon: Icons.movie),
    InterestCategory(name: 'Books', icon: Icons.menu_book),
    InterestCategory(name: 'Pets', icon: Icons.pets),
    InterestCategory(name: 'Nature', icon: Icons.nature),
    InterestCategory(name: 'Cars', icon: Icons.directions_car),
    InterestCategory(name: 'Beauty', icon: Icons.face),
    InterestCategory(name: 'Dance', icon: Icons.music_video),
    InterestCategory(name: 'Comedy', icon: Icons.theater_comedy),
    InterestCategory(name: 'Business', icon: Icons.business_center),
    InterestCategory(name: 'Health', icon: Icons.favorite),
    InterestCategory(name: 'Parenting', icon: Icons.child_care),
    InterestCategory(name: 'DIY', icon: Icons.build),
    InterestCategory(name: 'Cooking', icon: Icons.soup_kitchen),
    InterestCategory(name: 'Nightlife', icon: Icons.nightlife),
    InterestCategory(name: 'Adventure', icon: Icons.explore),
  ];

  Set<String> _selectedInterests = {};
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Load existing interests from user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInterests();
    });
  }

  Future<void> _loadUserInterests() async {
    final authState = ref.read(authStateProvider);
    await authState.when(
      data: (user) async {
        if (user != null && user.interests != null) {
          setState(() {
            _selectedInterests = Set.from(user.interests!);
          });
        }
      },
      loading: () async {},
      error: (_, __) async {},
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
      _hasChanges = true;
    });
  }

  Future<void> _saveInterests() async {
    if (_selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 3 interests'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.updateInterests(_selectedInterests.toList());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interests updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _hasChanges = false;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update interests: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manage Interests'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveInterests,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Info Card
          AppCard(
            margin: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select your interests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Choose at least 3 interests to personalize your feed. Selected: ${_selectedInterests.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Interests Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedInterests.contains(category.name);

                return _InterestChip(
                  category: category,
                  isSelected: isSelected,
                  onTap: () => _toggleInterest(category.name),
                );
              },
            ),
          ),

          // Save Button (bottom)
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: AppButton(
                onPressed: _isLoading ? null : _saveInterests,
                isLoading: _isLoading,
                child: Text(
                  'Save Changes (${_selectedInterests.length} selected)',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Interest Chip Widget
class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final InterestCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 32,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

