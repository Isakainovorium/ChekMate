import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Location Settings Page
/// Allows users to manage location sharing and search radius preferences
class LocationSettingsPage extends ConsumerStatefulWidget {
  const LocationSettingsPage({super.key});

  @override
  ConsumerState<LocationSettingsPage> createState() =>
      _LocationSettingsPageState();
}

class _LocationSettingsPageState extends ConsumerState<LocationSettingsPage> {
  bool _isLoading = false;
  bool _isUpdatingLocation = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Location Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Please log in to access location settings'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Sharing Section
                _buildLocationSharingSection(user),
                const SizedBox(height: AppSpacing.lg),

                // Current Location Section
                if (user.locationEnabled) ...[
                  _buildCurrentLocationSection(user),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Search Radius Section
                if (user.locationEnabled) ...[
                  _buildSearchRadiusSection(user),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Info Section
                _buildInfoSection(),

                // Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: AppLoadingSpinner()),
        error: (error, stack) => Center(
          child: Text('Error loading user data: $error'),
        ),
      ),
    );
  }

  Widget _buildLocationSharingSection(dynamic user) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Sharing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Enable to discover local dating stories and experiences',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: user.locationEnabled as bool,
                onChanged: _isLoading
                    ? null
                    : (value) => _toggleLocationSharing(value),
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationSection(dynamic user) {
    final hasCoordinates = user.coordinates != null;
    final latitude = user.coordinates?.latitude;
    final longitude = user.coordinates?.longitude;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.my_location, size: 20, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasCoordinates) ...[
            _buildLocationInfo(
              'Latitude',
              (latitude as double).toStringAsFixed(6),
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildLocationInfo(
              'Longitude',
              (longitude as double).toStringAsFixed(6),
            ),
            const SizedBox(height: AppSpacing.md),
          ] else ...[
            const Text(
              'No location set',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppButton(
            onPressed: _isUpdatingLocation ? null : _updateCurrentLocation,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.sm,
            leadingIcon: _isUpdatingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 18),
            child:
                Text(_isUpdatingLocation ? 'Updating...' : 'Update Location'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRadiusSection(dynamic user) {
    final radiusKm = user.searchRadiusKm;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.radar, size: 20, color: AppColors.primary),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Search Radius',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${radiusKm.toInt()} km',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Maximum distance for discovering nearby posts',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Slider(
            value: radiusKm as double,
            min: 5,
            max: 100,
            divisions: 19,
            label: '${radiusKm.toInt()} km',
            activeColor: AppColors.primary,
            onChanged: (value) => _updateSearchRadius(value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 km',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '100 km',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'About Location Services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoItem(
            'Your location helps you discover dating stories from your area',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoItem(
            'Your exact location is never shared publicly',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoItem(
            'You can disable location sharing at any time',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleLocationSharing(bool enabled) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);

      if (enabled) {
        // Request location permission and get current location
        final position = await _requestLocationPermission();
        if (position != null) {
          await authController.updateLocationSettings(
            locationEnabled: true,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        } else {
          setState(() {
            _errorMessage = 'Location permission denied';
          });
        }
      } else {
        // Disable location sharing
        await authController.updateLocationSettings(
          locationEnabled: false,
        );
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Failed to update location settings: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCurrentLocation() async {
    setState(() {
      _isUpdatingLocation = true;
      _errorMessage = null;
    });

    try {
      final position = await _getCurrentLocation();
      if (position != null) {
        final authController = ref.read(authControllerProvider.notifier);
        await authController.updateLocationSettings(
          locationEnabled: true,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Failed to update location: $e';
      });
    } finally {
      setState(() {
        _isUpdatingLocation = false;
      });
    }
  }

  Future<void> _updateSearchRadius(double radiusKm) async {
    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.updateLocationSettings(
        searchRadiusKm: radiusKm,
      );
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Failed to update search radius: $e';
      });
    }
  }

  Future<Position?> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              'Location services are disabled. Please enable them in settings.';
        });
        return null;
      }

      // Check location permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
          });
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permission permanently denied. Please enable in settings.';
        });
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
      });
      return null;
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
      });
      return null;
    }
  }
}
