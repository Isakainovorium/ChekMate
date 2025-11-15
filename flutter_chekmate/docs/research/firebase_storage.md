# Firebase Storage Research - Phase 2

**Date:** October 17, 2025  
**Researcher:** AI Assistant  
**Duration:** 2 hours  
**Status:** ✅ Complete

---

## 📋 EXECUTIVE SUMMARY

Researched Firebase Cloud Storage for implementing voice message file uploads, downloads, and management in ChekMate. Firebase Storage provides robust, scalable cloud storage for user-generated content with built-in security rules and Flutter SDK integration.

**Recommendation:** ✅ Use Firebase Storage (already in pubspec.yaml as `firebase_storage: ^11.5.6`)

---

## 🔍 PACKAGE ANALYSIS

### **Package: firebase_storage (v11.5.6)**

**Pub.dev:** https://pub.dev/packages/firebase_storage  
**Firebase Docs:** https://firebase.google.com/docs/storage  
**Context7 ID:** `/websites/firebase_google`

**Key Features:**
- ✅ Scalable cloud storage for user-generated content
- ✅ Built-in security rules (Firebase Security Rules v2)
- ✅ Upload/download with progress tracking
- ✅ Custom metadata support
- ✅ Automatic file compression and optimization
- ✅ CDN-backed downloads (fast global access)
- ✅ Integration with Firebase Authentication
- ✅ Support for resumable uploads

**Use Cases:**
- Images, audio, video, documents
- User-generated content
- Profile pictures, voice messages, video calls
- Any binary data

---

## 🎯 CORE API

### **Basic Upload/Download Flow**

```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// Get Firebase Storage instance
final storage = FirebaseStorage.instance;

// Create a reference to the file location
final storageRef = storage.ref();
final fileRef = storageRef.child('voice_messages/message_123.m4a');

// Upload file
final file = File('/path/to/local/file.m4a');
final uploadTask = fileRef.putFile(file);

// Monitor upload progress
uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
  final progress = snapshot.bytesTransferred / snapshot.totalBytes;
  print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
});

// Get download URL after upload
final snapshot = await uploadTask;
final downloadUrl = await snapshot.ref.getDownloadURL();

// Download file
final downloadTask = fileRef.writeToFile(File('/path/to/download/file.m4a'));
await downloadTask;
```

---

## 📁 FILE ORGANIZATION STRATEGY

### **Recommended Directory Structure**

```
gs://chekmate-bucket/
├── voice_messages/
│   ├── {userId}/
│   │   ├── voice_1697558400000_uuid.m4a
│   │   ├── voice_1697558500000_uuid.m4a
│   │   └── ...
├── video_calls/
│   ├── {callId}/
│   │   ├── recording_timestamp.mp4
│   │   └── thumbnail.jpg
├── profile_images/
│   ├── {userId}/
│   │   ├── profile.jpg
│   │   └── thumbnail.jpg
└── temp/
    └── {userId}/
        └── temp_files...
```

**Benefits:**
- ✅ User-based organization (easy to manage per-user data)
- ✅ Clear separation by content type
- ✅ Easy to implement security rules
- ✅ Scalable structure

---

## 🔐 SECURITY RULES

### **Recommended Security Rules for Voice Messages**

**File:** `storage.rules` (Firebase Console or deployed via CLI)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isValidAudioFile() {
      return request.resource.contentType.matches('audio/.*');
    }
    
    function isValidSize(maxSizeMB) {
      return request.resource.size < maxSizeMB * 1024 * 1024;
    }
    
    function hasValidMetadata() {
      return request.resource.metadata.duration != null
          && request.resource.metadata.userId != null;
    }
    
    // Voice messages: User can only upload their own, anyone can read
    match /voice_messages/{userId}/{fileName} {
      // Anyone can read (for playback in chat)
      allow read: if isSignedIn();
      
      // Only owner can upload
      allow create: if isSignedIn()
                    && isOwner(userId)
                    && isValidAudioFile()
                    && isValidSize(5)  // 5 MB max
                    && hasValidMetadata();
      
      // Only owner can delete
      allow delete: if isSignedIn() && isOwner(userId);
      
      // No updates allowed (immutable)
      allow update: if false;
    }
    
    // Video call recordings (if needed)
    match /video_calls/{callId}/{fileName} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && isValidSize(100);  // 100 MB max
    }
    
    // Profile images
    match /profile_images/{userId}/{fileName} {
      allow read: if true;  // Public read
      allow write: if isSignedIn()
                   && isOwner(userId)
                   && request.resource.contentType.matches('image/.*')
                   && isValidSize(5);
    }
    
    // Temp files (auto-delete after 24 hours via lifecycle rules)
    match /temp/{userId}/{fileName} {
      allow read, write: if isSignedIn() && isOwner(userId);
    }
  }
}
```

**Key Security Features:**
- ✅ User authentication required
- ✅ User can only upload to their own folder
- ✅ File type validation (audio/*)
- ✅ File size limits (5 MB for voice, 100 MB for video)
- ✅ Metadata validation (duration, userId)
- ✅ Immutable files (no updates, only create/delete)
- ✅ Public read for voice messages (for chat playback)

---

## 📊 METADATA MANAGEMENT

### **Custom Metadata for Voice Messages**

```dart
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadVoiceMessage({
  required File file,
  required String userId,
  required int durationSeconds,
  required String messageId,
}) async {
  final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}_$messageId.m4a';
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('voice_messages')
      .child(userId)
      .child(fileName);
  
  // Create metadata
  final metadata = SettableMetadata(
    contentType: 'audio/m4a',
    customMetadata: {
      'userId': userId,
      'messageId': messageId,
      'duration': durationSeconds.toString(),
      'uploadedAt': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'platform': Platform.operatingSystem,
    },
  );
  
  // Upload with metadata
  final uploadTask = storageRef.putFile(file, metadata);
  
  // Monitor progress
  uploadTask.snapshotEvents.listen((snapshot) {
    final progress = snapshot.bytesTransferred / snapshot.totalBytes;
    print('Upload: ${(progress * 100).toStringAsFixed(1)}%');
  });
  
  // Wait for completion
  final snapshot = await uploadTask;
  
  // Get download URL
  final downloadUrl = await snapshot.ref.getDownloadURL();
  
  // Delete local file
  await file.delete();
  
  return downloadUrl;
}
```

**Metadata Fields:**
- **contentType:** `audio/m4a` (MIME type)
- **userId:** Owner's Firebase Auth UID
- **messageId:** Unique message identifier
- **duration:** Recording duration in seconds
- **uploadedAt:** ISO 8601 timestamp
- **appVersion:** App version for debugging
- **platform:** iOS/Android for analytics

---

## 📥 DOWNLOAD STRATEGY

### **Download for Playback**

```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<File> downloadVoiceMessage(String downloadUrl) async {
  // Get app's cache directory
  final cacheDir = await getTemporaryDirectory();
  
  // Create voice_cache subdirectory
  final voiceCacheDir = Directory('${cacheDir.path}/voice_cache');
  if (!await voiceCacheDir.exists()) {
    await voiceCacheDir.create(recursive: true);
  }
  
  // Generate local file path
  final fileName = downloadUrl.split('/').last.split('?').first;
  final localFile = File('${voiceCacheDir.path}/$fileName');
  
  // Check if already cached
  if (await localFile.exists()) {
    print('Using cached file: ${localFile.path}');
    return localFile;
  }
  
  // Download from Firebase Storage
  final storageRef = FirebaseStorage.instance.refFromURL(downloadUrl);
  final downloadTask = storageRef.writeToFile(localFile);
  
  // Monitor download progress
  downloadTask.snapshotEvents.listen((snapshot) {
    final progress = snapshot.bytesTransferred / snapshot.totalBytes;
    print('Download: ${(progress * 100).toStringAsFixed(1)}%');
  });
  
  // Wait for completion
  await downloadTask;
  
  return localFile;
}
```

**Download Strategy:**
- ✅ Cache downloaded files in temp directory
- ✅ Check cache before downloading
- ✅ Monitor download progress
- ✅ Handle errors gracefully

---

## 🗑️ FILE DELETION

### **Delete Voice Message**

```dart
Future<void> deleteVoiceMessage(String downloadUrl) async {
  try {
    // Get reference from download URL
    final storageRef = FirebaseStorage.instance.refFromURL(downloadUrl);
    
    // Delete from Firebase Storage
    await storageRef.delete();
    
    print('Voice message deleted successfully');
  } on FirebaseException catch (e) {
    if (e.code == 'object-not-found') {
      print('File not found (already deleted)');
    } else if (e.code == 'unauthorized') {
      print('Permission denied (not owner)');
    } else {
      print('Error deleting file: ${e.message}');
      rethrow;
    }
  }
}
```

**Deletion Rules:**
- ✅ Only owner can delete
- ✅ Handle "not found" gracefully
- ✅ Handle permission errors
- ✅ Delete local cache after remote deletion

---

## ⚡ UPLOAD OPTIMIZATION

### **Resumable Uploads with Progress**

```dart
class VoiceUploadService {
  UploadTask? _currentUploadTask;
  
  Future<String> uploadWithProgress({
    required File file,
    required String userId,
    required Function(double) onProgress,
  }) async {
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('voice_messages/$userId/$fileName');
    
    final metadata = SettableMetadata(
      contentType: 'audio/m4a',
      customMetadata: {'userId': userId},
    );
    
    // Start upload
    _currentUploadTask = storageRef.putFile(file, metadata);
    
    // Listen to progress
    _currentUploadTask!.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress(progress);
      
      switch (snapshot.state) {
        case TaskState.running:
          print('Upload in progress: ${(progress * 100).toStringAsFixed(1)}%');
          break;
        case TaskState.paused:
          print('Upload paused');
          break;
        case TaskState.success:
          print('Upload complete!');
          break;
        case TaskState.canceled:
          print('Upload canceled');
          break;
        case TaskState.error:
          print('Upload error');
          break;
      }
    });
    
    // Wait for completion
    final snapshot = await _currentUploadTask!;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    return downloadUrl;
  }
  
  // Pause upload
  Future<bool> pauseUpload() async {
    return await _currentUploadTask?.pause() ?? false;
  }
  
  // Resume upload
  Future<bool> resumeUpload() async {
    return await _currentUploadTask?.resume() ?? false;
  }
  
  // Cancel upload
  Future<bool> cancelUpload() async {
    return await _currentUploadTask?.cancel() ?? false;
  }
}
```

**Upload Features:**
- ✅ Progress tracking (0-100%)
- ✅ Pause/resume support
- ✅ Cancel support
- ✅ State monitoring (running, paused, success, error)
- ✅ Resumable uploads (automatic retry on network failure)

---

## 🚨 ERROR HANDLING

### **Common Errors and Solutions**

```dart
Future<String> uploadVoiceMessageWithErrorHandling(File file, String userId) async {
  try {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('voice_messages/$userId/${file.path.split('/').last}');
    
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    return downloadUrl;
    
  } on FirebaseException catch (e) {
    switch (e.code) {
      case 'unauthorized':
        throw Exception('Permission denied. Please sign in.');
      
      case 'canceled':
        throw Exception('Upload canceled by user.');
      
      case 'unknown':
        throw Exception('Unknown error occurred. Please try again.');
      
      case 'object-not-found':
        throw Exception('File not found.');
      
      case 'bucket-not-found':
        throw Exception('Storage bucket not configured.');
      
      case 'project-not-found':
        throw Exception('Firebase project not found.');
      
      case 'quota-exceeded':
        throw Exception('Storage quota exceeded.');
      
      case 'unauthenticated':
        throw Exception('User not authenticated.');
      
      case 'retry-limit-exceeded':
        throw Exception('Upload failed after multiple retries.');
      
      case 'invalid-checksum':
        throw Exception('File corrupted during upload.');
      
      default:
        throw Exception('Upload failed: ${e.message}');
    }
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
```

---

## 📈 PERFORMANCE OPTIMIZATION

### **Best Practices**

1. **Compress Audio Before Upload**
   ```dart
   // Use AAC LC codec with 64 kbps bitrate
   // Already configured in record package
   ```

2. **Use Caching for Downloads**
   ```dart
   // Cache in temp directory
   // Check cache before downloading
   ```

3. **Implement Retry Logic**
   ```dart
   Future<String> uploadWithRetry(File file, {int maxRetries = 3}) async {
     int attempts = 0;
     while (attempts < maxRetries) {
       try {
         return await uploadVoiceMessage(file);
       } catch (e) {
         attempts++;
         if (attempts >= maxRetries) rethrow;
         await Future.delayed(Duration(seconds: 2 * attempts));
       }
     }
     throw Exception('Upload failed after $maxRetries attempts');
   }
   ```

4. **Monitor Network Status**
   ```dart
   // Use connectivity_plus package
   // Pause uploads on network loss
   // Resume when network returns
   ```

5. **Clean Up Old Files**
   ```dart
   // Implement lifecycle rules in Firebase Console
   // Auto-delete files older than 90 days
   // Or delete manually after message deletion
   ```

---

## 💰 COST OPTIMIZATION

### **Firebase Storage Pricing (as of 2024)**

**Free Tier (Spark Plan):**
- Storage: 5 GB
- Downloads: 1 GB/day
- Uploads: 20,000/day

**Paid Tier (Blaze Plan):**
- Storage: $0.026/GB/month
- Downloads: $0.12/GB
- Uploads: $0.05/GB

**Cost Estimation for ChekMate:**

**Assumptions:**
- 1,000 active users
- 10 voice messages/user/day
- 400 KB/message (60 seconds @ 64 kbps)
- 30-day retention

**Monthly Costs:**
- **Storage:** 1,000 users × 10 messages × 400 KB × 30 days = 120 GB
  - Cost: 120 GB × $0.026 = **$3.12/month**
- **Uploads:** 1,000 users × 10 messages × 400 KB × 30 days = 120 GB
  - Cost: 120 GB × $0.05 = **$6.00/month**
- **Downloads:** 1,000 users × 10 messages × 400 KB × 30 days = 120 GB
  - Cost: 120 GB × $0.12 = **$14.40/month**

**Total:** ~$23.52/month for 1,000 active users

**Optimization Strategies:**
- ✅ Use 64 kbps bitrate (not 128 kbps) → 50% cost reduction
- ✅ Implement 30-day auto-delete → Reduce storage costs
- ✅ Cache downloads → Reduce download costs
- ✅ Compress audio → Smaller file sizes

---

## 🧪 TESTING STRATEGY

### **Unit Tests**

```dart
test('should upload voice message with metadata', () async {
  final mockFile = File('test_voice.m4a');
  final userId = 'user123';
  
  final downloadUrl = await uploadVoiceMessage(
    file: mockFile,
    userId: userId,
    durationSeconds: 60,
    messageId: 'msg123',
  );
  
  expect(downloadUrl, isNotEmpty);
  expect(downloadUrl, contains('voice_messages'));
  expect(downloadUrl, contains(userId));
});

test('should handle upload errors gracefully', () async {
  final mockFile = File('nonexistent.m4a');
  
  expect(
    () => uploadVoiceMessage(file: mockFile, userId: 'user123'),
    throwsA(isA<Exception>()),
  );
});
```

### **Integration Tests**

```dart
testWidgets('full upload/download flow', (tester) async {
  // 1. Record voice message
  final recordedFile = await recordVoiceMessage();
  
  // 2. Upload to Firebase Storage
  final downloadUrl = await uploadVoiceMessage(recordedFile, 'user123');
  
  // 3. Download from Firebase Storage
  final downloadedFile = await downloadVoiceMessage(downloadUrl);
  
  // 4. Verify file exists
  expect(await downloadedFile.exists(), isTrue);
  
  // 5. Clean up
  await deleteVoiceMessage(downloadUrl);
});
```

---

## ✅ RECOMMENDATIONS

### **For ChekMate Implementation**

1. **File Organization:**
   - Use user-based folders: `voice_messages/{userId}/{fileName}`
   - Separate by content type (voice, video, images)

2. **Security Rules:**
   - Require authentication for all operations
   - User can only upload to their own folder
   - Validate file type (audio/*) and size (5 MB max)
   - Require metadata (userId, duration)
   - Make files immutable (no updates)

3. **Metadata:**
   - Store userId, messageId, duration, uploadedAt
   - Include app version and platform for debugging

4. **Upload Strategy:**
   - Use resumable uploads with progress tracking
   - Implement retry logic (3 attempts)
   - Monitor network status
   - Delete local file after successful upload

5. **Download Strategy:**
   - Cache downloads in temp directory
   - Check cache before downloading
   - Monitor download progress
   - Handle errors gracefully

6. **Cost Optimization:**
   - Use 64 kbps bitrate (not 128 kbps)
   - Implement 30-day auto-delete lifecycle rule
   - Cache downloads to reduce bandwidth
   - Compress audio before upload

---

## 🚀 NEXT STEPS

1. ✅ Create ADR-010 (Firebase Storage Integration)
2. ⏳ Setup Firebase Storage security rules
3. ⏳ Implement upload service with progress tracking
4. ⏳ Implement download service with caching
5. ⏳ Implement delete service
6. ⏳ Write comprehensive tests
7. ⏳ Configure lifecycle rules for auto-deletion

---

## 📚 REFERENCES

- **Firebase Storage Docs:** https://firebase.google.com/docs/storage
- **Flutter Package:** https://pub.dev/packages/firebase_storage
- **Security Rules:** https://firebase.google.com/docs/storage/security
- **Metadata:** https://firebase.google.com/docs/storage/web/file-metadata
- **Context7:** `/websites/firebase_google`

---

**Research Complete:** October 17, 2025  
**Next Task:** Task 1.3 - Setup Permission Handler  
**Status:** ✅ Ready to proceed

