# ChekMate Implementation Best Practices Guide - Part 2

**Date:** October 16, 2025  
**Continuation of:** IMPLEMENTATION_BEST_PRACTICES.md  
**Sections:** Code Organization, Git Workflow, PR Review, Performance, Security

---

## 4. Code Organization Conventions

### File Naming
- **Dart files:** `snake_case.dart` (e.g., `voice_recorder_widget.dart`)
- **Classes:** `PascalCase` (e.g., `VoiceRecorderWidget`)
- **Variables/functions:** `camelCase` (e.g., `startRecording()`)
- **Constants:** `lowerCamelCase` (e.g., `maxRecordingDuration`)
- **Private members:** `_leadingUnderscore` (e.g., `_startTimer()`)

### Import Organization
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:io';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// 3. Package imports (alphabetical)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

// 4. Project imports (alphabetical)
import 'package:flutter_chekmate/core/constants/app_constants.dart';
import 'package:flutter_chekmate/features/messaging/domain/entities/voice_message.dart';
import 'package:flutter_chekmate/features/messaging/presentation/providers/voice_recorder_provider.dart';
```

### Folder Structure Rules
1. **One feature per folder** - `lib/features/{feature_name}/`
2. **Shared code in lib/shared/** - Reusable widgets, utilities
3. **Core infrastructure in lib/core/** - Config, constants, errors, theme
4. **Tests mirror source structure** - `test/features/{feature_name}/`
5. **Assets organized by type** - `assets/images/`, `assets/icons/`, `assets/lottie/`

### Best Practices
1. **Keep files under 300 lines** - Split into smaller files if needed
2. **One class per file** - Except for small helper classes
3. **Use const constructors** - For immutable widgets
4. **Extract complex widgets** - If build() > 100 lines, extract widgets
5. **Use meaningful names** - `sendVoiceMessage()` not `send()`
6. **Comment complex logic** - Why, not what
7. **Use TODO comments** - For future improvements

---

## 5. Git Workflow & Branching Strategy

### Branch Naming Convention
```
feature/{phase}-{package-name}-{description}
bugfix/{issue-number}-{description}
hotfix/{critical-issue}
release/{version}
```

**Examples:**
- `feature/phase2-record-voice-messages`
- `feature/phase3-carousel-multi-photo-posts`
- `bugfix/123-fix-video-playback-crash`
- `hotfix/firebase-auth-error`
- `release/1.0.0`

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Build process, dependencies

**Examples:**
```
feat(messaging): add voice message playback

- Implement VoiceMessagePlayer widget
- Add waveform visualization
- Add play/pause controls
- Handle audio playback errors

Closes #43
```

### Best Practices
1. **Commit often** - Small, focused commits
2. **Write clear commit messages** - Explain why, not what
3. **Reference issues** - Use "Closes #123" or "Fixes #456"
4. **Keep branches short-lived** - Merge within 1-2 days
5. **Never commit to main directly** - Always use PRs
6. **Delete merged branches** - Keep repository clean

---

## 6. PR Review Checklist

### Before Creating PR

- [ ] **Code compiles without errors**
- [ ] **All tests pass** (`flutter test`)
- [ ] **No linter warnings** (`flutter analyze`)
- [ ] **Code formatted** (`flutter format .`)
- [ ] **New tests added** (80%+ coverage for new code)
- [ ] **Documentation updated** (README, inline comments)
- [ ] **No debug code** (print statements, commented code)
- [ ] **No hardcoded values** (use constants)
- [ ] **Error handling implemented**
- [ ] **Loading states handled**
- [ ] **Empty states handled**

### Reviewer Checklist

**Code Quality:**
- [ ] Code is readable and maintainable
- [ ] Follows Clean Architecture patterns
- [ ] Proper error handling
- [ ] No code duplication
- [ ] Efficient algorithms

**Testing:**
- [ ] Adequate test coverage (80%+)
- [ ] Tests are meaningful
- [ ] Edge cases tested
- [ ] Integration tests for user flows

**Security:**
- [ ] No sensitive data exposed
- [ ] Input validation implemented
- [ ] Firebase security rules considered
- [ ] Permissions handled correctly

**Performance:**
- [ ] No memory leaks
- [ ] Efficient database queries
- [ ] Images/videos optimized
- [ ] Lazy loading implemented

**UI/UX:**
- [ ] Matches design specifications
- [ ] Responsive on different screen sizes
- [ ] Loading states implemented
- [ ] Error states implemented
- [ ] Accessibility considered

---

## 7. Performance Optimization Guidelines

### Image Optimization
```dart
// ✅ Good: Use cached_network_image
CachedNetworkImage(
  imageUrl: post.imageUrl,
  placeholder: (context, url) => ShimmerPlaceholder(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 800, // Resize for memory efficiency
  maxWidthDiskCache: 1920, // Limit disk cache size
)

// ❌ Bad: Direct Image.network
Image.network(post.imageUrl) // No caching, no optimization
```

### List Performance
```dart
// ✅ Good: Use ListView.builder for long lists
ListView.builder(
  itemCount: posts.length,
  itemBuilder: (context, index) {
    return PostWidget(post: posts[index]);
  },
)

// ❌ Bad: Use ListView with all items
ListView(
  children: posts.map((post) => PostWidget(post: post)).toList(),
) // Builds all items at once
```

### Video Performance
```dart
// ✅ Good: Dispose video controllers
@override
void dispose() {
  _videoController?.dispose();
  super.dispose();
}

// ✅ Good: Pause videos when not visible
if (!isVisible) {
  _videoController?.pause();
}

// ✅ Good: Limit concurrent video players
const maxConcurrentVideos = 3;
```

### Database Query Optimization
```dart
// ✅ Good: Use pagination
Query query = firestore
    .collection('posts')
    .orderBy('createdAt', descending: true)
    .limit(20); // Load 20 at a time

// ✅ Good: Use indexes for complex queries
// Create composite index in Firebase Console for:
// collection: posts, fields: userId (Ascending), createdAt (Descending)

// ❌ Bad: Load all data at once
Query query = firestore.collection('posts'); // Loads everything
```

### Best Practices
1. **Use const constructors** - Avoid unnecessary rebuilds
2. **Implement lazy loading** - Load data as needed
3. **Cache network requests** - Use cached_network_image, dio caching
4. **Optimize images** - Compress, resize, use appropriate formats
5. **Dispose resources** - Controllers, streams, timers
6. **Use keys wisely** - For list items, use ValueKey or ObjectKey
7. **Profile performance** - Use Flutter DevTools to identify bottlenecks
8. **Avoid expensive operations in build()** - Move to initState or providers

---

## 8. Security Best Practices for Firebase

### Firebase Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Posts are public read, but only owner can write
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Messages are private between sender and receiver
    match /messages/{messageId} {
      allow read: if request.auth.uid == resource.data.senderId 
                  || request.auth.uid == resource.data.receiverId;
      allow create: if request.auth.uid == request.resource.data.senderId;
      allow update, delete: if request.auth.uid == resource.data.senderId;
    }
    
    // Voice messages have size limit
    match /messages/{messageId} {
      allow create: if request.resource.data.type == 'voice' 
                    && request.resource.data.duration <= 60;
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile photos
    match /users/{userId}/profile/{fileName} {
      allow read: if true;
      allow write: if request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024 // 5MB limit
                   && request.resource.contentType.matches('image/.*');
    }
    
    // Voice messages
    match /audio/messages/{userId}/{messageId}.aac {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId
                   && request.resource.size < 2 * 1024 * 1024 // 2MB limit
                   && request.resource.contentType == 'audio/aac';
    }
    
    // Post images
    match /posts/{userId}/{postId}/{fileName} {
      allow read: if true;
      allow write: if request.auth.uid == userId
                   && request.resource.size < 10 * 1024 * 1024 // 10MB limit
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

### Input Validation
```dart
// ✅ Good: Validate user input
Future<void> sendVoiceMessage(String audioPath) async {
  // Validate file exists
  final file = File(audioPath);
  if (!await file.exists()) {
    throw Exception('Audio file not found');
  }
  
  // Validate file size (max 2MB)
  final fileSize = await file.length();
  if (fileSize > 2 * 1024 * 1024) {
    throw Exception('Audio file too large (max 2MB)');
  }
  
  // Validate file type
  if (!audioPath.endsWith('.aac')) {
    throw Exception('Invalid audio format (must be AAC)');
  }
  
  // Proceed with upload
  await _uploadAudio(file);
}
```

### Best Practices
1. **Never trust client input** - Validate everything
2. **Use Firebase Security Rules** - Server-side validation
3. **Implement rate limiting** - Prevent abuse
4. **Sanitize user content** - Prevent XSS attacks
5. **Use HTTPS only** - Encrypt data in transit
6. **Store secrets securely** - Use environment variables
7. **Implement proper authentication** - Check auth state
8. **Log security events** - Monitor suspicious activity
9. **Keep dependencies updated** - Patch security vulnerabilities
10. **Follow principle of least privilege** - Minimal permissions

---

## 📚 Additional Resources

- [Flutter Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

---

**Last Updated:** October 16, 2025  
**Version:** 1.0.0  
**Maintainer:** ChekMate Development Team

