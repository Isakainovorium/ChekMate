import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Profile Picture Changer - converted from ProfilePictureChanger.tsx
/// Modal for changing profile picture with rotation
class ProfilePictureChanger extends StatefulWidget {
  const ProfilePictureChanger({
    required this.currentAvatar,
    required this.onSave,
    super.key,
  });
  final String currentAvatar;
  final void Function(String) onSave;

  @override
  State<ProfilePictureChanger> createState() => _ProfilePictureChangerState();
}

class _ProfilePictureChangerState extends State<ProfilePictureChanger> {
  String? _selectedImage;
  double _rotation = 0;

  void _handleFileSelect() {
    // In a real app, this would open file picker
    // For now, we'll use a mock image
    setState(() {
      _selectedImage =
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a';
    });
  }

  void _handleSave() {
    if (_selectedImage != null) {
      widget.onSave(_selectedImage!);
    }
    Navigator.of(context).pop();
    setState(() {
      _selectedImage = null;
      _rotation = 0;
    });
  }

  void _handleCancel() {
    Navigator.of(context).pop();
    setState(() {
      _selectedImage = null;
      _rotation = 0;
    });
  }

  void _rotateImage() {
    setState(() {
      _rotation = (_rotation + 90) % 360;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 448),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildImagePreview(),
            const SizedBox(height: AppSpacing.lg),
            _buildActionButtons(),
            const SizedBox(height: AppSpacing.lg),
            _buildSaveButtons(),
            const SizedBox(height: AppSpacing.md),
            _buildTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Change Profile Picture',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        IconButton(
          onPressed: _handleCancel,
          icon: const Icon(Icons.close),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: _selectedImage != null
              ? Transform.rotate(
                  angle: _rotation * math.pi / 180,
                  child: Image.network(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                )
              : Image.network(
                  widget.currentAvatar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Upload New Photo
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleFileSelect,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Upload New Photo',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Take Photo
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleFileSelect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade50,
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        // Rotate Image (only show if image is selected)
        if (_selectedImage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _rotateImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.all(AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rotate_right, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Rotate Image',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _handleCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.all(AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ElevatedButton(
            onPressed: _selectedImage != null ? _handleSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedImage != null
                  ? AppColors.primary
                  : Colors.grey.shade200,
              foregroundColor:
                  _selectedImage != null ? Colors.white : Colors.grey.shade400,
              padding: const EdgeInsets.all(AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, size: 16),
                SizedBox(width: 4),
                Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '💡 For best results, use a high-quality square image',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
