import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Profile Photo Screen - Onboarding step for profile photo
/// Features:
/// - Camera/gallery selection
/// - Photo preview
/// - Skip option
class ProfilePhotoScreen extends ConsumerStatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  ConsumerState<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends ConsumerState<ProfilePhotoScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isUploading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _animationController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Photo Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.secondary),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select an existing photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedImage == null) {
      // Allow skipping
      context.go('/onboarding/completion');
      return;
    }

    setState(() => _isUploading = true);

    try {
      // In production, upload to Firebase Storage here
      // final url = await uploadProfilePhoto(_selectedImage!);
      // await updateUserProfile(photoUrl: url);
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate upload
      
      if (mounted) {
        context.go('/onboarding/completion');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile Photo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isUploading ? null : () => context.go('/onboarding/completion'),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              
              // Title
              const Text(
                'Add a profile photo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              Text(
                'Help others recognize you with a great photo',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Photo preview/picker
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: ScaleTransition(
                    scale: _selectedImage != null 
                        ? _scaleAnimation 
                        : const AlwaysStoppedAnimation(1.0),
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
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              
              if (_selectedImage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                TextButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Change Photo'),
                ),
              ],
              
              const Spacer(),
              
              // Continue button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _selectedImage != null ? 'Continue' : 'Skip for Now',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Progress indicator
              const Text(
                'Step 4 of 5',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

