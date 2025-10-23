import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/voice_messages/data/models/voice_message_model.dart';

/// Remote data source for voice message storage operations
///
/// Handles Firebase Storage operations for voice messages.
/// Implements the storage strategy from ADR-010.
abstract class VoiceStorageRemoteDataSource {
  /// Uploads a voice message file to Firebase Storage
  ///
  /// [model] - The voice message model containing file information
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  ///
  /// Returns the updated model with download URL
  /// Throws [StorageException] if upload fails
  Future<VoiceMessageModel> uploadVoiceMessage(
    VoiceMessageModel model, {
    void Function(double)? onProgress,
  });

  /// Downloads a voice message file from Firebase Storage
  ///
  /// [model] - The voice message model containing download URL
  /// [onProgress] - Optional callback for download progress (0.0 to 1.0)
  ///
  /// Returns the updated model with local file path
  /// Throws [StorageException] if download fails
  Future<VoiceMessageModel> downloadVoiceMessage(
    VoiceMessageModel model, {
    void Function(double)? onProgress,
  });

  /// Deletes a voice message file from Firebase Storage
  ///
  /// [downloadUrl] - The download URL of the file to delete
  ///
  /// Returns true if deletion was successful
  /// Throws [StorageException] if deletion fails
  Future<bool> deleteVoiceMessage(String downloadUrl);

  /// Gets the download URL for a voice message
  ///
  /// [userId] - The ID of the user who owns the file
  /// [fileName] - The name of the file
  ///
  /// Returns the download URL
  /// Throws [StorageException] if file not found
  Future<String> getDownloadUrl(String userId, String fileName);
}

/// Implementation of VoiceStorageRemoteDataSource
class VoiceStorageRemoteDataSourceImpl implements VoiceStorageRemoteDataSource {
  VoiceStorageRemoteDataSourceImpl({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;
  final FirebaseStorage _storage;

  /// File organization: voice_messages/{userId}/{fileName}
  /// From ADR-010
  String _getStoragePath(String userId, String fileName) {
    return 'voice_messages/$userId/$fileName';
  }

  @override
  Future<VoiceMessageModel> uploadVoiceMessage(
    VoiceMessageModel model, {
    void Function(double)? onProgress,
  }) async {
    try {
      // Validate file path exists
      if (model.filePath == null || model.filePath!.isEmpty) {
        throw StorageException('No local file path provided');
      }

      final file = File(model.filePath!);
      // ignore: avoid_slow_async_io
      if (!await file.exists()) {
        throw StorageException('Local file does not exist: ${model.filePath}');
      }

      // Create storage reference
      final storagePath = _getStoragePath(model.senderId, model.fileName);
      final ref = _storage.ref().child(storagePath);

      // Create metadata
      final metadata = SettableMetadata(
        contentType: 'audio/m4a',
        customMetadata: {
          'userId': model.senderId,
          'messageId': model.id,
          'duration': model.duration.toString(),
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload file
      final uploadTask = ref.putFile(file, metadata);

      // Listen to upload progress
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

      // Return updated model
      return model.copyWith(
        downloadUrl: downloadUrl,
        isUploaded: true,
        uploadProgress: 1.0,
      );
    } on FirebaseException catch (e) {
      throw StorageException('Firebase upload failed: ${e.message}');
    } catch (e) {
      throw StorageException('Upload failed: $e');
    }
  }

  @override
  Future<VoiceMessageModel> downloadVoiceMessage(
    VoiceMessageModel model, {
    void Function(double)? onProgress,
  }) async {
    try {
      // Validate download URL exists
      if (model.downloadUrl == null || model.downloadUrl!.isEmpty) {
        throw StorageException('No download URL provided');
      }

      // Create storage reference from URL
      final ref = _storage.refFromURL(model.downloadUrl!);

      // Create local file path
      final tempDir = Directory.systemTemp;
      final localPath = '${tempDir.path}/${model.fileName}';
      final file = File(localPath);

      // Download file
      final downloadTask = ref.writeToFile(file);

      // Listen to download progress
      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for download to complete
      await downloadTask;

      // Return updated model
      return model.copyWith(
        filePath: localPath,
      );
    } on FirebaseException catch (e) {
      throw StorageException('Firebase download failed: ${e.message}');
    } catch (e) {
      throw StorageException('Download failed: $e');
    }
  }

  @override
  Future<bool> deleteVoiceMessage(String downloadUrl) async {
    try {
      // Create storage reference from URL
      final ref = _storage.refFromURL(downloadUrl);

      // Delete file
      await ref.delete();

      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // File already deleted
        return true;
      }
      throw StorageException('Firebase delete failed: ${e.message}');
    } catch (e) {
      throw StorageException('Delete failed: $e');
    }
  }

  @override
  Future<String> getDownloadUrl(String userId, String fileName) async {
    try {
      final storagePath = _getStoragePath(userId, fileName);
      final ref = _storage.ref().child(storagePath);

      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        throw StorageException('File not found: $fileName');
      }
      throw StorageException('Failed to get download URL: ${e.message}');
    } catch (e) {
      throw StorageException('Failed to get download URL: $e');
    }
  }
}

/// Exception thrown when storage operations fail
class StorageException implements Exception {
  StorageException(this.message);
  final String message;

  @override
  String toString() => 'StorageException: $message';
}
