/// Web-compatible Firebase Storage service
/// 
/// This service provides a unified interface for uploading files to Firebase Storage
/// that works on both web and mobile platforms.
/// 
/// On mobile: Uploads using file path
/// On web: Uploads using bytes
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'web_image_picker_service.dart';

/// Upload progress callback
typedef UploadProgressCallback = void Function(double progress);

/// Web-compatible Firebase Storage service
class WebStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload an image to Firebase Storage
  /// 
  /// Returns the download URL of the uploaded image
  Future<String> uploadImage({
    required PickedMediaFile file,
    required String path,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      UploadTask uploadTask;

      if (kIsWeb) {
        // Web: Upload using bytes
        if (file.bytes == null) {
          throw Exception('File bytes are null for web upload');
        }

        uploadTask = ref.putData(
          file.bytes!,
          SettableMetadata(
            contentType: _getContentType(file.name),
          ),
        );
      } else {
        // Mobile: Upload using file path
        uploadTask = ref.putFile(
          File(file.path),
          SettableMetadata(
            contentType: _getContentType(file.name),
          ),
        );
      }

      // Monitor upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload a video to Firebase Storage
  /// 
  /// Returns the download URL of the uploaded video
  Future<String> uploadVideo({
    required PickedMediaFile file,
    required String path,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      UploadTask uploadTask;

      if (kIsWeb) {
        // Web: Upload using bytes
        if (file.bytes == null) {
          throw Exception('File bytes are null for web upload');
        }

        uploadTask = ref.putData(
          file.bytes!,
          SettableMetadata(
            contentType: _getContentType(file.name),
          ),
        );
      } else {
        // Mobile: Upload using file path
        uploadTask = ref.putFile(
          File(file.path),
          SettableMetadata(
            contentType: _getContentType(file.name),
          ),
        );
      }

      // Monitor upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading video: $e');
      rethrow;
    }
  }

  /// Upload raw bytes to Firebase Storage
  /// 
  /// Useful for uploading data that's already in memory
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String path,
    String? contentType,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: contentType ?? 'application/octet-stream',
        ),
      );

      // Monitor upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading bytes: $e');
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  /// Delete a file by its download URL
  Future<void> deleteFileByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file by URL: $e');
      rethrow;
    }
  }

  /// Get the content type based on file extension
  String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      // Images
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';

      // Videos
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'webm':
        return 'video/webm';

      // Audio
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      case 'm4a':
        return 'audio/mp4';

      // Default
      default:
        return 'application/octet-stream';
    }
  }

  /// Generate a unique file path for uploads
  static String generateFilePath({
    required String userId,
    required String folder,
    required String fileName,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last;
    return '$folder/$userId/${timestamp}_${fileName.replaceAll(' ', '_')}';
  }

  /// Generate a unique file path for profile photos
  static String generateProfilePhotoPath(String userId, String fileName) {
    return generateFilePath(
      userId: userId,
      folder: 'profile_photos',
      fileName: fileName,
    );
  }

  /// Generate a unique file path for cover photos
  static String generateCoverPhotoPath(String userId, String fileName) {
    return generateFilePath(
      userId: userId,
      folder: 'cover_photos',
      fileName: fileName,
    );
  }

  /// Generate a unique file path for posts
  static String generatePostMediaPath(String userId, String fileName) {
    return generateFilePath(
      userId: userId,
      folder: 'posts',
      fileName: fileName,
    );
  }

  /// Generate a unique file path for stories
  static String generateStoryMediaPath(String userId, String fileName) {
    return generateFilePath(
      userId: userId,
      folder: 'stories',
      fileName: fileName,
    );
  }

  /// Generate a unique file path for messages
  static String generateMessageMediaPath(String userId, String fileName) {
    return generateFilePath(
      userId: userId,
      folder: 'messages',
      fileName: fileName,
    );
  }

  /// Generate a unique file path for voice prompts
  static String generateVoicePromptPath(String userId, String fileName) {
    return generateFilePath(
      userId: userId,
      folder: 'voice_prompts',
      fileName: fileName,
    );
  }

  /// Generate a unique file path for video intros
  static String generateVideoIntroPath(String userId, String fileName) {
    return generateFilePath(
      userId: userId,
      folder: 'video_intros',
      fileName: fileName,
    );
  }
}

/// Widget for showing upload progress
class UploadProgressIndicator extends StatefulWidget {
  final Future<String> Function(UploadProgressCallback) uploadFunction;
  final Function(String) onComplete;
  final Function(Object)? onError;

  const UploadProgressIndicator({
    super.key,
    required this.uploadFunction,
    required this.onComplete,
    this.onError,
  });

  @override
  State<UploadProgressIndicator> createState() => _UploadProgressIndicatorState();
}

class _UploadProgressIndicatorState extends State<UploadProgressIndicator> {
  double _progress = 0.0;
  bool _isUploading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startUpload();
  }

  Future<void> _startUpload() async {
    try {
      final url = await widget.uploadFunction((progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        widget.onComplete(url);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _error = e.toString();
        });
        widget.onError?.call(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Upload failed: $_error'),
        ],
      );
    }

    if (!_isUploading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 48),
          SizedBox(height: 16),
          Text('Upload complete!'),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(value: _progress),
        const SizedBox(height: 16),
        Text('Uploading... ${(_progress * 100).toStringAsFixed(0)}%'),
      ],
    );
  }
}

