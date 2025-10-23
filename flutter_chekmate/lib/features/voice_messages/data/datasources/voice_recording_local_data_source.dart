import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

/// Local data source for voice recording operations
///
/// Handles voice recording using the record package and local file management.
/// Implements the recording configuration from ADR-009.
abstract class VoiceRecordingLocalDataSource {
  /// Starts a new voice recording
  ///
  /// Returns the file path where the recording is being saved
  /// Throws [RecordingException] if recording fails to start
  Future<String> startRecording();

  /// Stops the current recording
  ///
  /// Returns the file path of the completed recording
  /// Throws [RecordingException] if no recording is in progress or stop fails
  Future<String> stopRecording();

  /// Cancels the current recording and deletes the file
  ///
  /// Returns true if cancellation was successful
  /// Throws [RecordingException] if cancellation fails
  Future<bool> cancelRecording();

  /// Pauses the current recording
  ///
  /// Returns true if pause was successful
  /// Throws [RecordingException] if pause fails
  Future<bool> pauseRecording();

  /// Resumes a paused recording
  ///
  /// Returns true if resume was successful
  /// Throws [RecordingException] if resume fails
  Future<bool> resumeRecording();

  /// Checks if a recording is currently in progress
  Future<bool> isRecording();

  /// Gets the current recording duration in seconds
  Future<int> getRecordingDuration();

  /// Deletes a voice message file from local storage
  ///
  /// Returns true if deletion was successful
  Future<bool> deleteLocalFile(String filePath);

  /// Gets the file size of a voice message
  Future<int> getFileSize(String filePath);
}

/// Implementation of VoiceRecordingLocalDataSource
class VoiceRecordingLocalDataSourceImpl
    implements VoiceRecordingLocalDataSource {
  VoiceRecordingLocalDataSourceImpl({
    AudioRecorder? recorder,
    Uuid? uuid,
  })  : _recorder = recorder ?? AudioRecorder(),
        _uuid = uuid ?? const Uuid();
  final AudioRecorder _recorder;
  final Uuid _uuid;

  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  /// Voice message recording configuration from ADR-009
  static const RecordConfig _recordConfig = RecordConfig(
    bitRate: 64000, // 64 kbps
    sampleRate: 22050, // 22.05 kHz
    numChannels: 1, // Mono
    autoGain: true,
    echoCancel: true,
    noiseSuppress: true,
  );

  @override
  Future<String> startRecording() async {
    try {
      // Check if already recording
      if (await _recorder.isRecording()) {
        throw RecordingException('Recording already in progress');
      }

      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueId = _uuid.v4();
      final fileName = 'voice_${timestamp}_$uniqueId.m4a';
      final filePath = '${tempDir.path}/$fileName';

      // Start recording
      await _recorder.start(_recordConfig, path: filePath);

      _currentRecordingPath = filePath;
      _recordingStartTime = DateTime.now();

      return filePath;
    } catch (e) {
      throw RecordingException('Failed to start recording: $e');
    }
  }

  @override
  Future<String> stopRecording() async {
    try {
      // Check if recording is in progress
      if (!await _recorder.isRecording()) {
        throw RecordingException('No recording in progress');
      }

      // Stop recording
      final path = await _recorder.stop();

      if (path == null) {
        throw RecordingException('Failed to stop recording: no path returned');
      }

      final recordingPath = _currentRecordingPath;
      _currentRecordingPath = null;
      _recordingStartTime = null;

      return recordingPath ?? path;
    } catch (e) {
      _currentRecordingPath = null;
      _recordingStartTime = null;
      throw RecordingException('Failed to stop recording: $e');
    }
  }

  @override
  Future<bool> cancelRecording() async {
    try {
      // Stop recording if in progress
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }

      // Delete the recording file if it exists
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        // ignore: avoid_slow_async_io
        if (await file.exists()) {
          await file.delete();
        }
      }

      _currentRecordingPath = null;
      _recordingStartTime = null;

      return true;
    } catch (e) {
      throw RecordingException('Failed to cancel recording: $e');
    }
  }

  @override
  Future<bool> pauseRecording() async {
    try {
      if (!await _recorder.isRecording()) {
        throw RecordingException('No recording in progress');
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
      if (!await _recorder.isPaused()) {
        throw RecordingException('Recording is not paused');
      }

      await _recorder.resume();
      return true;
    } catch (e) {
      throw RecordingException('Failed to resume recording: $e');
    }
  }

  @override
  Future<bool> isRecording() async {
    return _recorder.isRecording();
  }

  @override
  Future<int> getRecordingDuration() async {
    if (_recordingStartTime == null) {
      return 0;
    }

    final duration = DateTime.now().difference(_recordingStartTime!);
    return duration.inSeconds;
  }

  @override
  Future<bool> deleteLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw RecordingException('Failed to delete file: $e');
    }
  }

  @override
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      throw RecordingException('Failed to get file size: $e');
    }
  }
}

/// Exception thrown when recording operations fail
class RecordingException implements Exception {
  RecordingException(this.message);
  final String message;

  @override
  String toString() => 'RecordingException: $message';
}
