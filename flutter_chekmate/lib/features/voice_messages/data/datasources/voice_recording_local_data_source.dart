import 'dart:io';

import 'package:uuid/uuid.dart';

/// Exception thrown when recording operations fail
class RecordingException implements Exception {
  const RecordingException(this.message);

  final String message;

  @override
  String toString() => 'RecordingException: $message';
}

/// Mock interfaces for audio recording (to be replaced with actual record package)
abstract class AudioRecorder {
  Future<bool> isRecording();
  Future<bool> isPaused();
  Future<void> start(RecordConfig config, {required String path});
  Future<String?> stop();
  Future<void> pause();
  Future<void> resume();
}

class RecordConfig {
  const RecordConfig({
    required this.encoder,
    required this.bitRate,
    required this.sampleRate,
  });

  final AudioEncoder encoder;
  final int bitRate;
  final int sampleRate;
}

enum AudioEncoder {
  aacLc,
  wav,
}

/// Abstract interface for local voice recording data source
abstract class VoiceRecordingLocalDataSource {
  /// Start recording audio and return the file path
  Future<String> startRecording();

  /// Stop recording and return the final file path
  Future<String> stopRecording();

  /// Cancel recording and delete the temporary file
  Future<bool> cancelRecording();

  /// Pause the current recording
  Future<bool> pauseRecording();

  /// Resume a paused recording
  Future<bool> resumeRecording();

  /// Check if currently recording
  Future<bool> isRecording();

  /// Get the file size of a recorded file
  Future<int> getFileSize(String filePath);

  /// Delete a local file
  Future<bool> deleteLocalFile(String filePath);
}

/// Implementation of VoiceRecordingLocalDataSource
class VoiceRecordingLocalDataSourceImpl implements VoiceRecordingLocalDataSource {
  VoiceRecordingLocalDataSourceImpl({
    required AudioRecorder recorder,
    required Uuid uuid,
  })  : _recorder = recorder,
        _uuid = uuid;

  final AudioRecorder _recorder;
  final Uuid _uuid;


  @override
  Future<String> startRecording() async {
    try {
      // Check if already recording
      if (await _recorder.isRecording()) {
        throw const RecordingException('Already recording');
      }

      // Generate unique filename
      final fileName = 'voice_${_uuid.v4()}.m4a';

      // Use temporary directory for recording
      final tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/$fileName';

      // Configure recording settings
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      // Start recording
      await _recorder.start(config, path: filePath);

      return filePath;
    } catch (e) {
      throw RecordingException('Failed to start recording: $e');
    }
  }

  @override
  Future<String> stopRecording() async {
    try {
      // Check if recording
      if (!(await _recorder.isRecording())) {
        throw const RecordingException('Not currently recording');
      }

      // Stop recording
      final filePath = await _recorder.stop();

      if (filePath == null) {
        throw const RecordingException('Failed to get recording file path');
      }

      return filePath;
    } catch (e) {
      throw RecordingException('Failed to stop recording: $e');
    }
  }

  @override
  Future<bool> cancelRecording() async {
    try {
      // Stop recording if active
      if (await _recorder.isRecording()) {
        final filePath = await _recorder.stop();
        if (filePath != null) {
          // Delete the cancelled recording file
          await deleteLocalFile(filePath);
        }
      }

      return true;
    } catch (e) {
      // Even if cleanup fails, we consider cancellation successful
      return true;
    }
  }

  @override
  Future<bool> pauseRecording() async {
    try {
      // Check if recording
      if (!(await _recorder.isRecording())) {
        throw const RecordingException('Not currently recording');
      }

      await _recorder.pause();
      return true;
    } catch (e) {
      throw RecordingException('Failed to pause recording: $e');
    }
  }

  @override
  Future<bool> resumeRecording() async {
    try {
      // Check if paused
      if (!(await _recorder.isPaused())) {
        throw const RecordingException('Recording is not paused');
      }

      await _recorder.resume();
      return true;
    } catch (e) {
      throw RecordingException('Failed to resume recording: $e');
    }
  }

  @override
  Future<bool> isRecording() async {
    try {
      return await _recorder.isRecording();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<bool> deleteLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
