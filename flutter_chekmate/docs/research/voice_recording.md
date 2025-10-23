# Voice Recording Research - Phase 2

**Date:** October 17, 2025  
**Researcher:** AI Assistant  
**Duration:** 2 hours  
**Status:** ✅ Complete

---

## 📋 EXECUTIVE SUMMARY

Researched the `record` package (v5.x) for implementing voice message recording in ChekMate. The package provides a clean, cross-platform API for audio recording with support for iOS, Android, Web, Windows, macOS, and Linux.

**Recommendation:** ✅ Use `record` package (already in pubspec.yaml as `record: ^5.0.0`)

---

## 🔍 PACKAGE ANALYSIS

### **Package: record (v5.0.0)**

**Pub.dev:** https://pub.dev/packages/record  
**GitHub:** https://github.com/llfbandit/record  
**Context7 ID:** `/llfbandit/record`

**Key Features:**
- ✅ Cross-platform (iOS, Android, Web, Windows, macOS, Linux)
- ✅ No external dependencies (uses native APIs)
- ✅ Built-in permission handling
- ✅ Multiple audio formats (m4a, wav, pcm16bits, etc.)
- ✅ Stream or file-based recording
- ✅ Pause/resume support
- ✅ 22 code snippets in Context7

**Native APIs Used:**
- **iOS/macOS:** AVAudioRecorder
- **Android:** MediaRecorder
- **Web:** MediaRecorder API
- **Windows:** Windows Media Foundation
- **Linux:** GStreamer (via GTK)

---

## 🎯 CORE API

### **Basic Usage**

```dart
import 'package:record/record.dart';

final record = AudioRecorder();

// Check and request permission
if (await record.hasPermission()) {
  // Start recording to file
  await record.start(
    const RecordConfig(),
    path: 'aFullPath/myFile.m4a'
  );
  
  // ... or to stream
  final stream = await record.startStream(
    const RecordConfig(encoder: AudioEncoder.pcm16bits)
  );
}

// Stop recording
final path = await record.stop();

// Cancel recording (removes file)
await record.cancel();

// Always dispose
record.dispose();
```

---

## 🔐 PERMISSION HANDLING

### **iOS Configuration**

**File:** `ios/Runner/Info.plist`

```xml
<key>NSMicrophoneUsageDescription</key>
<string>ChekMate needs microphone access to record voice messages</string>
```

**macOS Additional:**

**File:** `macos/Runner/*.entitlements`

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

---

### **Android Configuration**

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Optional: For bluetooth headset support -->
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />

<!-- Optional: For saving to external storage (Android < 10) -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="28" />
```

---

### **Permission Request Flow**

```dart
// 1. Check if permission is granted
final hasPermission = await record.hasPermission();

if (!hasPermission) {
  // 2. Request permission (handled by package)
  // User will see system permission dialog
  // Returns true if granted, false if denied
  return;
}

// 3. Start recording
await record.start(config, path: filePath);
```

**Best Practices:**
- ✅ Always check permission before recording
- ✅ Handle permission denial gracefully
- ✅ Provide clear usage description in Info.plist
- ✅ Request permission at appropriate time (not on app launch)
- ✅ Show UI feedback when permission is denied

---

## 🎵 AUDIO FORMATS

### **Supported Encoders**

```dart
enum AudioEncoder {
  aacLc,      // AAC Low Complexity (default, best compatibility)
  aacEld,     // AAC Enhanced Low Delay
  aacHe,      // AAC High Efficiency
  amrNb,      // AMR Narrow Band
  amrWb,      // AMR Wide Band
  opus,       // Opus (high quality, low bitrate)
  flac,       // FLAC (lossless)
  wav,        // WAV (uncompressed)
  pcm16bits,  // PCM 16-bit (for streaming)
}
```

**Recommendation for ChekMate:**
- **File Recording:** `AudioEncoder.aacLc` (m4a format)
  - Best compatibility across iOS/Android
  - Good compression (small file size)
  - Good quality
- **Streaming:** `AudioEncoder.pcm16bits`
  - For real-time processing/waveform visualization

---

## ⚙️ RECORDING CONFIGURATION

### **RecordConfig Options**

```dart
const RecordConfig({
  AudioEncoder encoder = AudioEncoder.aacLc,
  int bitRate = 128000,           // 128 kbps (good quality)
  int sampleRate = 44100,          // 44.1 kHz (CD quality)
  int numChannels = 2,             // Stereo (1 = mono)
  bool autoGain = false,           // Auto gain control
  bool echoCancel = false,         // Echo cancellation
  bool noiseSuppress = false,      // Noise suppression
});
```

**Recommended Config for Voice Messages:**

```dart
const voiceMessageConfig = RecordConfig(
  encoder: AudioEncoder.aacLc,
  bitRate: 64000,        // 64 kbps (sufficient for voice)
  sampleRate: 22050,     // 22.05 kHz (half CD quality, good for voice)
  numChannels: 1,        // Mono (voice doesn't need stereo)
  autoGain: true,        // Normalize volume
  echoCancel: true,      // Remove echo
  noiseSuppress: true,   // Remove background noise
);
```

**File Size Estimation:**
- 64 kbps bitrate = 8 KB/second
- 60-second message = ~480 KB
- With AAC compression: ~300-400 KB actual size

---

## 📁 FILE STORAGE STRATEGY

### **File Naming Convention**

```dart
String generateVoiceMessageFileName() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final uuid = Uuid().v4();
  return 'voice_${timestamp}_$uuid.m4a';
}
```

**Example:** `voice_1697558400000_a1b2c3d4-e5f6-7890-abcd-ef1234567890.m4a`

---

### **File Path Strategy**

```dart
import 'package:path_provider/path_provider.dart';

Future<String> getVoiceMessagePath(String fileName) async {
  // Get app's temporary directory
  final tempDir = await getTemporaryDirectory();
  
  // Create voice_messages subdirectory
  final voiceDir = Directory('${tempDir.path}/voice_messages');
  if (!await voiceDir.exists()) {
    await voiceDir.create(recursive: true);
  }
  
  return '${voiceDir.path}/$fileName';
}
```

**Storage Flow:**
1. Record to temporary directory
2. Upload to Firebase Storage
3. Delete local file after successful upload
4. Download from Firebase when playing

---

## 🔄 RECORDING STATE MANAGEMENT

### **Recording States**

```dart
enum RecordingState {
  idle,           // Not recording
  recording,      // Currently recording
  paused,         // Recording paused
  stopped,        // Recording stopped (file available)
  error,          // Error occurred
}
```

### **State Transitions**

```
idle → recording → stopped → idle
       ↓           ↑
       paused ─────┘
```

---

## ⏱️ DURATION LIMIT (60 SECONDS)

### **Implementation Strategy**

```dart
class VoiceRecorder {
  Timer? _durationTimer;
  int _recordingDuration = 0;
  static const maxDuration = 60; // seconds
  
  Future<void> startRecording() async {
    await record.start(config, path: filePath);
    
    // Start duration timer
    _recordingDuration = 0;
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _recordingDuration++;
        
        // Auto-stop at 60 seconds
        if (_recordingDuration >= maxDuration) {
          stopRecording();
        }
        
        // Update UI
        notifyListeners();
      },
    );
  }
  
  Future<void> stopRecording() async {
    _durationTimer?.cancel();
    final path = await record.stop();
    // Handle recorded file
  }
}
```

---

## 🎨 UI/UX CONSIDERATIONS

### **Recording Indicator**

**Visual Feedback:**
- ✅ Pulsing red dot (recording active)
- ✅ Timer display (00:00 → 01:00)
- ✅ Waveform visualization (optional)
- ✅ Progress bar (0% → 100% at 60s)

**User Actions:**
- ✅ Hold to record (like WhatsApp)
- ✅ Slide to cancel
- ✅ Release to send
- ✅ Tap to lock recording (for longer messages)

---

### **Permission Denied Handling**

```dart
if (!await record.hasPermission()) {
  // Show dialog explaining why permission is needed
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Microphone Permission Required'),
      content: Text(
        'ChekMate needs microphone access to record voice messages. '
        'Please grant permission in Settings.'
      ),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

---

## 🚨 ERROR HANDLING

### **Common Errors**

1. **Permission Denied**
   - Show permission dialog
   - Guide user to settings

2. **Storage Full**
   - Check available space before recording
   - Show error message

3. **Recording Failed**
   - Retry mechanism
   - Fallback to text input

4. **File Not Found**
   - Handle missing file gracefully
   - Show error state

---

## 🧪 TESTING STRATEGY

### **Unit Tests**

```dart
test('should request permission before recording', () async {
  when(mockRecorder.hasPermission()).thenAnswer((_) async => true);
  
  await voiceRecordingService.startRecording();
  
  verify(mockRecorder.hasPermission()).called(1);
});

test('should stop recording at 60 seconds', () async {
  await voiceRecordingService.startRecording();
  
  // Fast-forward 60 seconds
  await Future.delayed(Duration(seconds: 60));
  
  expect(voiceRecordingService.state, RecordingState.stopped);
});
```

### **Widget Tests**

```dart
testWidgets('should show recording indicator when recording', (tester) async {
  await tester.pumpWidget(VoiceRecordingButton());
  
  await tester.tap(find.byType(VoiceRecordingButton));
  await tester.pump();
  
  expect(find.byType(RecordingIndicator), findsOneWidget);
});
```

### **Integration Tests**

```dart
testWidgets('full voice recording flow', (tester) async {
  // 1. Tap record button
  await tester.tap(find.byIcon(Icons.mic));
  await tester.pump();
  
  // 2. Wait 3 seconds
  await tester.pump(Duration(seconds: 3));
  
  // 3. Stop recording
  await tester.tap(find.byIcon(Icons.stop));
  await tester.pump();
  
  // 4. Verify file created
  expect(find.byType(VoiceMessageBubble), findsOneWidget);
});
```

---

## 📊 PERFORMANCE CONSIDERATIONS

### **Memory Usage**

- **File-based recording:** Low memory (writes directly to disk)
- **Stream-based recording:** Higher memory (buffers in RAM)
- **Recommendation:** Use file-based for voice messages

### **Battery Impact**

- **Microphone usage:** Moderate battery drain
- **Mitigation:** Auto-stop at 60 seconds
- **Background recording:** Not needed for ChekMate

### **File Size Optimization**

```dart
// Optimized config for small file size
const optimizedConfig = RecordConfig(
  encoder: AudioEncoder.aacLc,
  bitRate: 48000,        // 48 kbps (smaller files)
  sampleRate: 16000,     // 16 kHz (phone quality)
  numChannels: 1,        // Mono
);

// File size: ~360 KB for 60 seconds
```

---

## 🔗 INTEGRATION WITH FIREBASE STORAGE

### **Upload Strategy**

```dart
Future<String> uploadVoiceMessage(String localPath) async {
  final file = File(localPath);
  final fileName = path.basename(localPath);
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('voice_messages')
      .child(fileName);
  
  // Upload with metadata
  final uploadTask = storageRef.putFile(
    file,
    SettableMetadata(
      contentType: 'audio/m4a',
      customMetadata: {
        'duration': '60',
        'userId': currentUserId,
      },
    ),
  );
  
  // Get download URL
  final snapshot = await uploadTask;
  final downloadUrl = await snapshot.ref.getDownloadURL();
  
  // Delete local file
  await file.delete();
  
  return downloadUrl;
}
```

---

## ✅ RECOMMENDATIONS

### **For ChekMate Implementation**

1. **Use `record` package** (already in pubspec.yaml)
   - Mature, well-maintained
   - Cross-platform support
   - Clean API

2. **Audio Configuration:**
   - Encoder: AAC LC (m4a)
   - Bitrate: 64 kbps
   - Sample Rate: 22.05 kHz
   - Channels: Mono
   - Enable: Auto-gain, echo cancel, noise suppress

3. **File Storage:**
   - Record to temp directory
   - Upload to Firebase Storage
   - Delete local file after upload
   - Download on-demand for playback

4. **Duration Limit:**
   - 60 seconds maximum
   - Auto-stop with timer
   - Show progress indicator

5. **Permission Handling:**
   - Check before recording
   - Request at appropriate time
   - Handle denial gracefully
   - Guide to settings if needed

6. **UI/UX:**
   - Hold-to-record button
   - Slide-to-cancel gesture
   - Visual recording indicator
   - Timer display

---

## 🚀 NEXT STEPS

1. ✅ Create ADR-006 (Voice Recording Package Selection)
2. ⏳ Implement `PermissionService` with microphone permission
3. ⏳ Create voice recording domain layer
4. ⏳ Implement voice recording data layer
5. ⏳ Build voice recording UI components
6. ⏳ Integrate with Firebase Storage
7. ⏳ Write comprehensive tests

---

## 📚 REFERENCES

- **Package:** https://pub.dev/packages/record
- **GitHub:** https://github.com/llfbandit/record
- **Context7:** `/llfbandit/record`
- **Permission Handling:** https://www.freecodecamp.org/news/how-to-handle-permissions-in-flutter-for-beginners/
- **Best Practices:** https://atuoha.hashnode.dev/permission-handling-in-flutter

---

**Research Complete:** October 17, 2025  
**Next Task:** Task 1.2 - Research Firebase Storage Integration  
**Status:** ✅ Ready to proceed

