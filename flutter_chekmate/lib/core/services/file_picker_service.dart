import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// FilePickerService - File Selection Service
///
/// Provides a clean API for selecting files from the device.
/// Supports images, videos, documents, audio, and custom file types.
///
/// Use Cases:
/// - Document uploads in messages
/// - Profile picture selection
/// - Media uploads (images, videos)
/// - File attachments
/// - Import/export functionality
///
/// Features:
/// - Single and multiple file selection
/// - File type filtering
/// - File size validation
/// - Cross-platform support (iOS, Android, Web)
/// - Custom file extensions
///
/// Usage:
/// ```dart
/// // Pick single image
/// final file = await FilePickerService.pickImage();
///
/// // Pick multiple documents
/// final files = await FilePickerService.pickDocuments(allowMultiple: true);
///
/// // Pick custom file types
/// final file = await FilePickerService.pickFile(
///   allowedExtensions: ['pdf', 'doc', 'docx'],
/// );
/// ```
class FilePickerService {
  /// Pick a single image
  ///
  /// Returns the selected image file or null if cancelled
  static Future<File?> pickImage({
    bool allowMultiple = false,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final path = result.files.first.path;
      if (path == null) {
        throw const FilePickerException('Failed to get file path');
      }

      return File(path);
    } catch (e) {
      throw FilePickerException('Failed to pick image: $e');
    }
  }

  /// Pick multiple images
  ///
  /// Returns a list of selected image files or empty list if cancelled
  static Future<List<File>> pickImages({
    int? maxFiles,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      var files = result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();

      // Limit number of files if specified
      if (maxFiles != null && files.length > maxFiles) {
        files = files.take(maxFiles).toList();
      }

      return files;
    } catch (e) {
      throw FilePickerException('Failed to pick images: $e');
    }
  }

  /// Pick a single video
  ///
  /// Returns the selected video file or null if cancelled
  static Future<File?> pickVideo({
    bool allowMultiple = false,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final path = result.files.first.path;
      if (path == null) {
        throw const FilePickerException('Failed to get file path');
      }

      return File(path);
    } catch (e) {
      throw FilePickerException('Failed to pick video: $e');
    }
  }

  /// Pick multiple videos
  ///
  /// Returns a list of selected video files or empty list if cancelled
  static Future<List<File>> pickVideos({
    int? maxFiles,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      var files = result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();

      // Limit number of files if specified
      if (maxFiles != null && files.length > maxFiles) {
        files = files.take(maxFiles).toList();
      }

      return files;
    } catch (e) {
      throw FilePickerException('Failed to pick videos: $e');
    }
  }

  /// Pick a single audio file
  ///
  /// Returns the selected audio file or null if cancelled
  static Future<File?> pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final path = result.files.first.path;
      if (path == null) {
        throw const FilePickerException('Failed to get file path');
      }

      return File(path);
    } catch (e) {
      throw FilePickerException('Failed to pick audio: $e');
    }
  }

  /// Pick a single document
  ///
  /// Supports PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, TXT
  static Future<File?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
        ],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final path = result.files.first.path;
      if (path == null) {
        throw const FilePickerException('Failed to get file path');
      }

      return File(path);
    } catch (e) {
      throw FilePickerException('Failed to pick document: $e');
    }
  }

  /// Pick multiple documents
  ///
  /// Returns a list of selected document files or empty list if cancelled
  static Future<List<File>> pickDocuments({
    int? maxFiles,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
        ],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      var files = result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();

      // Limit number of files if specified
      if (maxFiles != null && files.length > maxFiles) {
        files = files.take(maxFiles).toList();
      }

      return files;
    } catch (e) {
      throw FilePickerException('Failed to pick documents: $e');
    }
  }

  /// Pick any file type
  ///
  /// [allowedExtensions] - List of allowed file extensions (e.g., ['pdf', 'doc'])
  /// [allowMultiple] - Allow multiple file selection
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final path = result.files.first.path;
      if (path == null) {
        throw const FilePickerException('Failed to get file path');
      }

      return File(path);
    } catch (e) {
      throw FilePickerException('Failed to pick file: $e');
    }
  }

  /// Pick multiple files
  ///
  /// [allowedExtensions] - List of allowed file extensions (e.g., ['pdf', 'doc'])
  /// [maxFiles] - Maximum number of files to select
  static Future<List<File>> pickFiles({
    List<String>? allowedExtensions,
    int? maxFiles,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      var files = result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();

      // Limit number of files if specified
      if (maxFiles != null && files.length > maxFiles) {
        files = files.take(maxFiles).toList();
      }

      return files;
    } catch (e) {
      throw FilePickerException('Failed to pick files: $e');
    }
  }

  /// Get file info without picking
  ///
  /// Returns file metadata (name, size, extension, path)
  static Future<FilePickerResult?> getFileInfo({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      return await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );
    } catch (e) {
      throw FilePickerException('Failed to get file info: $e');
    }
  }

  /// Validate file size
  ///
  /// [file] - File to validate
  /// [maxSizeInMB] - Maximum file size in megabytes
  /// Returns true if file size is within limit
  static Future<bool> validateFileSize(File file, int maxSizeInMB) async {
    try {
      final bytes = await file.length();
      final mb = bytes / (1024 * 1024);
      return mb <= maxSizeInMB;
    } on Exception {
      return false;
    }
  }

  /// Get file size in MB
  ///
  /// [file] - File to get size for
  /// Returns file size in megabytes
  static Future<double> getFileSizeInMB(File file) async {
    try {
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } on Exception {
      return 0.0;
    }
  }

  /// Get file extension
  ///
  /// [file] - File to get extension for
  /// Returns file extension (e.g., 'pdf', 'jpg')
  static String getFileExtension(File file) {
    final path = file.path;
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot + 1).toLowerCase();
  }

  /// Check if file is an image
  static bool isImage(File file) {
    final ext = getFileExtension(file);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  /// Check if file is a video
  static bool isVideo(File file) {
    final ext = getFileExtension(file);
    return ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'].contains(ext);
  }

  /// Check if file is a document
  static bool isDocument(File file) {
    final ext = getFileExtension(file);
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']
        .contains(ext);
  }
}

/// File Picker Exception
class FilePickerException implements Exception {
  const FilePickerException(this.message);

  final String message;

  @override
  String toString() => 'FilePickerException: $message';
}
