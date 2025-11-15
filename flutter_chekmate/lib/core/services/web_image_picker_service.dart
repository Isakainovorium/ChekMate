/// Web-compatible image picker service
/// 
/// This service provides a unified interface for picking images and videos
/// that works on both web and mobile platforms.
/// 
/// On mobile: Shows camera and gallery options
/// On web: Shows file picker (no camera access)
library;

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Result of picking an image or video
class PickedMediaFile {
  final XFile file;
  final Uint8List? bytes;
  final String path;
  final String name;
  final int? size;

  PickedMediaFile({
    required this.file,
    this.bytes,
    required this.path,
    required this.name,
    this.size,
  });

  /// Create from XFile
  static Future<PickedMediaFile> fromXFile(XFile file) async {
    Uint8List? bytes;
    if (kIsWeb) {
      bytes = await file.readAsBytes();
    }

    return PickedMediaFile(
      file: file,
      bytes: bytes,
      path: file.path,
      name: file.name,
      size: await file.length(),
    );
  }
}

/// Web-compatible image picker service
class WebImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from camera or gallery
  /// 
  /// On mobile: Shows dialog to choose camera or gallery
  /// On web: Opens file picker (no camera option)
  Future<PickedMediaFile?> pickImage(BuildContext context) async {
    if (kIsWeb) {
      // Web: Only file picker available
      return _pickImageFromFiles();
    } else {
      // Mobile: Show camera or gallery dialog
      return _showImageSourceDialog(context);
    }
  }

  /// Pick a video from camera or gallery
  /// 
  /// On mobile: Shows dialog to choose camera or gallery
  /// On web: Opens file picker (no camera option)
  Future<PickedMediaFile?> pickVideo(BuildContext context) async {
    if (kIsWeb) {
      // Web: Only file picker available
      return _pickVideoFromFiles();
    } else {
      // Mobile: Show camera or gallery dialog
      return _showVideoSourceDialog(context);
    }
  }

  /// Pick multiple images
  /// 
  /// On mobile: Opens gallery for multiple selection
  /// On web: Opens file picker for multiple selection
  Future<List<PickedMediaFile>> pickMultipleImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage();
      
      final List<PickedMediaFile> pickedFiles = [];
      for (final file in files) {
        pickedFiles.add(await PickedMediaFile.fromXFile(file));
      }
      
      return pickedFiles;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// Pick image from files (web and mobile)
  Future<PickedMediaFile?> _pickImageFromFiles() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file == null) return null;

      return await PickedMediaFile.fromXFile(file);
    } catch (e) {
      debugPrint('Error picking image from files: $e');
      return null;
    }
  }

  /// Pick video from files (web and mobile)
  Future<PickedMediaFile?> _pickVideoFromFiles() async {
    try {
      final XFile? file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (file == null) return null;

      return await PickedMediaFile.fromXFile(file);
    } catch (e) {
      debugPrint('Error picking video from files: $e');
      return null;
    }
  }

  /// Pick image from camera (mobile only)
  Future<PickedMediaFile?> _pickImageFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file == null) return null;

      return await PickedMediaFile.fromXFile(file);
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick video from camera (mobile only)
  Future<PickedMediaFile?> _pickVideoFromCamera() async {
    try {
      final XFile? file = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (file == null) return null;

      return await PickedMediaFile.fromXFile(file);
    } catch (e) {
      debugPrint('Error picking video from camera: $e');
      return null;
    }
  }

  /// Show dialog to choose image source (mobile only)
  Future<PickedMediaFile?> _showImageSourceDialog(BuildContext context) async {
    return showDialog<PickedMediaFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _pickImageFromCamera();
                if (context.mounted && file != null) {
                  Navigator.pop(context, file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _pickImageFromFiles();
                if (context.mounted && file != null) {
                  Navigator.pop(context, file);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to choose video source (mobile only)
  Future<PickedMediaFile?> _showVideoSourceDialog(BuildContext context) async {
    return showDialog<PickedMediaFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Video Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _pickVideoFromCamera();
                if (context.mounted && file != null) {
                  Navigator.pop(context, file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _pickVideoFromFiles();
                if (context.mounted && file != null) {
                  Navigator.pop(context, file);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

/// Widget for picking images with web compatibility
class WebImagePickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(PickedMediaFile) onImagePicked;
  final bool isVideo;

  const WebImagePickerButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onImagePicked,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    final service = WebImagePickerService();

    return ElevatedButton.icon(
      onPressed: () async {
        final file = isVideo
            ? await service.pickVideo(context)
            : await service.pickImage(context);

        if (file != null) {
          onImagePicked(file);
        }
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}

