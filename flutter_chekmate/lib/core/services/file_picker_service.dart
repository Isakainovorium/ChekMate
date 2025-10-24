import 'dart:io';

/// FilePickerService - File Selection Service
///
/// NOTE: This service is currently DISABLED due to file_picker package incompatibility with Flutter v2 embedding.
/// TODO: Re-enable when a compatible version is available or replace with image_picker for images.
///
/// All methods throw UnimplementedError until the package is re-enabled.
class FilePickerService {
  static Future<File?> pickImage({bool allowMultiple = false}) async {
    throw UnimplementedError('FilePickerService disabled - file_picker package incompatibility');
  }

  static Future<List<File>> pickImages({int? maxFiles}) async {
    throw UnimplementedError('FilePickerService disabled - file_picker package incompatibility');
  }

  static Future<File?> pickVideo({bool allowMultiple = false}) async {
    throw UnimplementedError('FilePickerService disabled - file_picker package incompatibility');
  }

  static Future<List<File>> pickVideos({int? maxFiles}) async {
    throw UnimplementedError('FilePickerService disabled - file_picker package incompatibility');
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

