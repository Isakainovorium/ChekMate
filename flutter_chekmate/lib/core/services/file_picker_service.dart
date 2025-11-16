import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// FilePickerService - File Selection Service
///
/// Image and video picking is implemented using image_picker package.
/// Document and generic file picking remain disabled due to package limitations.
///
/// Supported functionality:
/// - Image picking from gallery/camera
/// - Video picking from gallery/camera
///
/// Unsupported functionality (disabled):
/// - Document picking
/// - Audio picking
/// - Generic file picking
class FilePickerService {
  static Future<File?> pickImage({bool allowMultiple = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw FilePickerException('Failed to pick image: $e');
    }
  }

  static Future<List<File>> pickImages({int? maxFiles}) async {
    try {
      final file = await pickImage(allowMultiple: false);
      return file != null ? [file] : [];
    } catch (e) {
      throw FilePickerException('Failed to pick images: $e');
    }
  }

  static Future<File?> pickVideo({bool allowMultiple = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      return video != null ? File(video.path) : null;
    } catch (e) {
      throw FilePickerException('Failed to pick video: $e');
    }
  }

  static Future<List<File>> pickVideos({int? maxFiles}) async {
    try {
      final file = await pickVideo(allowMultiple: false);
      return file != null ? [file] : [];
    } catch (e) {
      throw FilePickerException('Failed to pick videos: $e');
    }
  }

  static Future<File?> pickAudio() async {
    throw UnimplementedError('FilePickerService disabled - file_picker package incompatibility');
  }

  static Future<File?> pickDocument() async {
    throw UnimplementedError('FilePickerService disabled - file_picker package incompatibility');
  }

  static Future<List<File>> pickDocuments({int? maxFiles}) async {
    throw UnimplementedError('FilePickerService disabled - file_picker package incompatibility');
  }

  static Future<File?> pickFile({List<String>? allowedExtensions}) async {
    throw UnimplementedError('FilePickerService disabled - file_picker package incompatibility');
  }

  static Future<List<File>> pickFiles({List<String>? allowedExtensions, int? maxFiles}) async {
    throw UnimplementedError('FilePickerService disabled - file_picker package incompatibility');
  }

  static String getFileExtension(File file) {
    final path = file.path;
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot + 1).toLowerCase();
  }

  static bool isImage(File file) {
    final ext = getFileExtension(file);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  static bool isVideo(File file) {
    final ext = getFileExtension(file);
    return ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'].contains(ext);
  }

  static bool isDocument(File file) {
    final ext = getFileExtension(file);
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(ext);
  }

  static bool isAudio(File file) {
    final ext = getFileExtension(file);
    return ['mp3', 'wav', 'aac', 'flac', 'm4a', 'ogg'].contains(ext);
  }

  static Future<bool> validateFileSize(File file, int maxSizeMB) async {
    final bytes = await file.length();
    final sizeMB = bytes / (1024 * 1024);
    return sizeMB <= maxSizeMB;
  }

  static Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }
}

/// Exception thrown by FilePickerService
class FilePickerException implements Exception {
  final String message;

  const FilePickerException(this.message);

  @override
  String toString() => 'FilePickerException: $message';
}

