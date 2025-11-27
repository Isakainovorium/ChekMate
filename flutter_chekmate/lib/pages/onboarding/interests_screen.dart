import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Interest Selection Screen - Step 2 of onboarding
/// User selects at least 3 interests from 25 categories
class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  // 25 interest categories with icons
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

  @override
  void initState() {
    super.initState();
    // Load existing selections from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingStateProvider);
      setState(() {
        _selectedInterests = Set.from(state.selectedInterests);
      });
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _handleContinue() async {
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
      // Save interests to provider
      await ref
          .read(onboardingStateProvider.notifier)
          .saveInterests(_selectedInterests.toList());

      if (mounted) {
        context.go('/onboarding/location');
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save interests: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleBack() {
    context.go('/onboarding/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selectedInterests.length >= 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _handleBack,
        ),
        title: const Text(
          'Step 2 of 5',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            const LinearProgressIndicator(
              value: 2 / 5,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    const Text(
                      'What experience topics interest you?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    AppSpacing.gapSM,

                    // Subtitle
                    Text(
                      'Choose topics to discover relevant experience stories (${_selectedInterests.length}/3 minimum)',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    AppSpacing.gapXL,

                    // Interest grid
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _categories.map((category) {
                        final isSelected =
                            _selectedInterests.contains(category.name);
                        return _buildInterestChip(
                          category: category,
                          isSelected: isSelected,
                          onTap: () => _toggleInterest(category.name),
                        );
                      }).toList(),
                    ),

                    AppSpacing.gapXL,
                  ],
                ),
              ),
            ),

            // Continue button (fixed at bottom)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isLoading || !canContinue ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.textDisabled,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textPrimary,
                            ),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip({
    required InterestCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceContainerHighest,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interest category model
class InterestCategory {
  const InterestCategory({
    required this.name,
    required this.icon,
  });
  final String name;
  final IconData icon;
}
