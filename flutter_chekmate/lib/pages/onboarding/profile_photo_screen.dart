import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Profile Photo Screen - Step 4 of onboarding
/// User uploads profile photo from camera or gallery
class ProfilePhotoScreen extends ConsumerStatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  ConsumerState<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends ConsumerState<ProfilePhotoScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadedImageUrl;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromCamera() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Get current user ID
      final currentUser = ref.read(currentUserProvider);
      final userId = currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$userId.jpg');

      final uploadTask = storageRef.putFile(_selectedImage!);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadUrl;
      });

      // Mark profile photo as added in onboarding provider
      await ref
          .read(onboardingStateProvider.notifier)
          .setProfilePhotoAdded(true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _handleContinue() async {
    if (_selectedImage != null && _uploadedImageUrl == null) {
      // Upload image first
      await _uploadImage();
    }

    if (mounted) {
      context.go('/onboarding/completion');
    }
  }

  void _handleSkip() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Profile Photo?'),
        content: const Text(
          'You can add a profile photo later in your profile settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/onboarding/completion');
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
    context.go('/onboarding/location');
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
          'Step 4 of 5',
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
              value: 4 / 5,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Heading
                    const Text(
                      'Add Profile Photo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.gapSM,

                    // Subtitle
                    const Text(
                      'Show the world who you are',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.gapXL,

                    // Profile photo preview
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceVariant,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 80,
                                color: AppColors.textTertiary,
                              ),
                      ),
                    ),

                    AppSpacing.gapXL,

                    // Upload progress
                    if (_isUploading) ...[
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                      AppSpacing.gapSM,
                      Text(
                        'Uploading... ${(_uploadProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      AppSpacing.gapXL,
                    ],

                    // Camera button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickImageFromCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text(
                          'Take Photo',
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

                    AppSpacing.gapMD,

                    // Gallery button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isUploading ? null : _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text(
                          'Choose from Gallery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
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
                  onPressed: _isUploading ? null : _handleContinue,
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
                  child: _isUploading
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
}
