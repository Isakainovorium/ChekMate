import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';
import 'package:flutter_chekmate/core/services/location_service.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Location Permission Screen - Step 3 of onboarding
/// User enables location or enters manually
class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  bool _isLoading = false;
  LocationEntity? _currentLocation;
  final TextEditingController _manualLocationController =
      TextEditingController();

  @override
  void dispose() {
    _manualLocationController.dispose();
    super.dispose();
  }

  Future<void> _handleEnableLocation() async {
    setState(() => _isLoading = true);

    try {
      // Get current location using LocationService
      final location = await LocationService.getCurrentLocation();

      setState(() {
        _currentLocation = location;
      });

      // Save location to onboarding provider
      await ref
          .read(onboardingStateProvider.notifier)
          .enableLocation(location.displayName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location enabled: ${location.displayName}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on LocationServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                LocationService.openAppSettings();
              },
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
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

  Future<void> _handleManualLocation() async {
    final locationName = _manualLocationController.text.trim();

    if (locationName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save manual location to onboarding provider
      await ref
          .read(onboardingStateProvider.notifier)
          .enableLocation(locationName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location set: $locationName'),
            backgroundColor: AppColors.success,
          ),
        );

        setState(() {
          _currentLocation = LocationEntity(
            latitude: 0,
            longitude: 0,
            address: locationName,
          );
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save location: $e'),
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

  Future<void> _handleContinue() async {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable location or enter manually'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.go('/onboarding/profile-photo');
  }

  void _handleSkip() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Location?'),
        content: const Text(
          'Location helps you discover content near you. '
          'You can enable it later in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/onboarding/profile-photo');
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _handleBack() {
    context.go('/onboarding/interests');
  }

  @override
  Widget build(BuildContext context) {
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
          'Step 3 of 5',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _handleSkip,
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            const LinearProgressIndicator(
              value: 3 / 5,
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
                      'Enable Location',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    AppSpacing.gapSM,

                    // Subtitle
                    const Text(
                      'Discover content and people near you',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    AppSpacing.gapXL,

                    // Location icon
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    AppSpacing.gapXL,

                    // Current location display
                    if (_currentLocation != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Location Enabled',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentLocation!.displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.gapXL,
                    ],

                    // Enable Location Button
                    if (_currentLocation == null) ...[
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleEnableLocation,
                          icon: _isLoading
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
                              : const Icon(Icons.my_location),
                          label: const Text(
                            'Enable Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5A623),
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),

                      AppSpacing.gapLG,

                      // Divider with "OR"
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      AppSpacing.gapLG,

                      // Manual location entry
                      const Text(
                        'Enter Location Manually',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      AppSpacing.gapSM,

                      TextField(
                        controller: _manualLocationController,
                        decoration: InputDecoration(
                          hintText: 'e.g., San Francisco, CA',
                          filled: true,
                          fillColor: const Color(0xFFE8E8E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _handleManualLocation(),
                      ),

                      AppSpacing.gapMD,

                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _handleManualLocation,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Save Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  onPressed: _currentLocation == null ? null : _handleContinue,
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
                  child: const Text(
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
}
