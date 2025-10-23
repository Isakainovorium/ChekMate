import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/core/errors/app_exception.dart';
import 'package:flutter_chekmate/core/utils/logger.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload file to Firebase Storage
  Future<String> uploadFile({
    required File file,
    required String path,
    void Function(double)? onProgress,
  }) async {
    try {
      Logger.info('Uploading file to: $path');

      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      Logger.info('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      Logger.error('File upload failed', e);
      throw ServerException(
        message: 'Failed to upload file',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('Unexpected upload error', e);
      throw ServerException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  /// Upload image
  Future<String> uploadImage({
    required File image,
    required String userId,
    String folder = 'images',
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$folder/$userId/$timestamp.jpg';
    return uploadFile(file: image, path: path);
  }

  /// Upload image from path (for XFile compatibility)
  Future<String> uploadImageFromPath(
    String imagePath,
    String destination,
  ) async {
    final file = File(imagePath);
    return uploadFile(file: file, path: destination);
  }

  /// Upload video
  Future<String> uploadVideo({
    required File video,
    required String userId,
    String folder = 'videos',
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$folder/$userId/$timestamp.mp4';
    return uploadFile(file: video, path: path);
  }

  /// Upload video from path (for XFile compatibility)
  Future<String> uploadVideoFromPath(
    String videoPath,
    String destination,
  ) async {
    final file = File(videoPath);
    return uploadFile(file: file, path: destination);
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture({
    required File image,
    required String userId,
  }) async {
    final path = 'profiles/$userId/avatar.jpg';
    return uploadFile(file: image, path: path);
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String url) async {
    try {
      Logger.info('Deleting file: $url');
      final ref = _storage.refFromURL(url);
      await ref.delete();
      Logger.info('File deleted successfully');
    } on FirebaseException catch (e) {
      Logger.error('File deletion failed', e);
      throw ServerException(
        message: 'Failed to delete file',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('Unexpected deletion error', e);
      throw ServerException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String url) async {
    try {
      Logger.info('Getting file metadata: $url');
      final ref = _storage.refFromURL(url);
      return await ref.getMetadata();
    } on FirebaseException catch (e) {
      Logger.error('Failed to get metadata', e);
      throw ServerException(
        message: 'Failed to get file metadata',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.error('Unexpected metadata error', e);
      throw ServerException(
        message: 'An unexpected error occurred',
        originalError: e,
      );
    }
  }
}
