import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/voice_messages/data/models/voice_message_model.dart';

/// Exception thrown when storage operations fail
class StorageException implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  String toString() => 'StorageException: $message';
}

/// Abstract interface for remote voice storage data source
abstract class VoiceStorageRemoteDataSource {
  /// Upload voice message file to remote storage
  Future<VoiceMessageModel> uploadVoiceMessage(
    VoiceMessageModel model, {
    void Function(double progress)? onProgress,
  });

  /// Download voice message file from remote storage
  Future<VoiceMessageModel> downloadVoiceMessage(
    VoiceMessageModel model, {
    String? localPath,
    void Function(double progress)? onProgress,
  });

  /// Delete voice message file from remote storage
  Future<bool> deleteVoiceMessage(String downloadUrl);

  /// Get download URL for a voice message file
  Future<String> getDownloadUrl(String userId, String fileName);
}

/// Implementation of VoiceStorageRemoteDataSource using Firebase Storage
class VoiceStorageRemoteDataSourceImpl implements VoiceStorageRemoteDataSource {
  VoiceStorageRemoteDataSourceImpl({
    required FirebaseStorage storage,
  }) : _storage = storage;

  final FirebaseStorage _storage;

  @override
  Future<VoiceMessageModel> uploadVoiceMessage(
    VoiceMessageModel model, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Create storage reference
      final storageRef = _storage.ref();
      final fileRef = storageRef.child('voice_messages/${model.senderId}/${model.fileName}');

      // Upload file
      final uploadTask = fileRef.putFile(
        File(model.filePath!),
        SettableMetadata(
          contentType: 'audio/m4a',
          customMetadata: {
            'senderId': model.senderId,
            'receiverId': model.receiverId,
            'duration': model.duration.toString(),
            'fileSize': model.fileSize.toString(),
          },
        ),
      );

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for completion
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Return updated model
      return model.copyWith(
        downloadUrl: downloadUrl,
        isUploaded: true,
        uploadProgress: 1.0,
      );
    } catch (e) {
      throw StorageException('Failed to upload voice message: $e');
    }
  }

  @override
  Future<VoiceMessageModel> downloadVoiceMessage(
    VoiceMessageModel model, {
    String? localPath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      if (model.downloadUrl == null || model.downloadUrl!.isEmpty) {
        throw const StorageException('Download URL is required');
      }

      // Get storage reference from URL
      final ref = _storage.refFromURL(model.downloadUrl!);

      // Determine local path
      final downloadPath = localPath ?? '${Directory.systemTemp.path}/${model.fileName}';

      // Download file
      final downloadTask = ref.writeToFile(File(downloadPath));

      // Listen to progress
      downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for completion
      await downloadTask;

      // Return updated model with local path
      return model.copyWith(
        filePath: downloadPath,
      );
    } catch (e) {
      throw StorageException('Failed to download voice message: $e');
    }
  }

  @override
  Future<bool> deleteVoiceMessage(String downloadUrl) async {
    try {
      // Get storage reference from URL
      final ref = _storage.refFromURL(downloadUrl);

      // Delete file
      await ref.delete();

      return true;
    } on FirebaseException catch (e) {
      // If file doesn't exist, consider it successfully deleted
      if (e.code == 'object-not-found') {
        return true;
      }
      throw StorageException('Failed to delete voice message: ${e.message}');
    } catch (e) {
      throw StorageException('Failed to delete voice message: $e');
    }
  }

  @override
  Future<String> getDownloadUrl(String userId, String fileName) async {
    try {
      // Create storage reference
      final storageRef = _storage.ref();
      final fileRef = storageRef.child('voice_messages/$userId/$fileName');

      // Get download URL
      final downloadUrl = await fileRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw StorageException('Failed to get download URL: $e');
    }
  }
}
