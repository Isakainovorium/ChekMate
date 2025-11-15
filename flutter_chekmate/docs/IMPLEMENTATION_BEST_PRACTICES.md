# ChekMate Implementation Best Practices Guide

**Date:** October 16, 2025  
**Purpose:** Establish coding standards, patterns, and best practices for implementing all 70 packages  
**Audience:** Developers working on ChekMate Flutter app

---

## 📋 TABLE OF CONTENTS

1. [Flutter Clean Architecture Patterns](#flutter-clean-architecture-patterns)
2. [State Management with Riverpod](#state-management-with-riverpod)
3. [Testing Strategies](#testing-strategies)
4. [Code Organization Conventions](#code-organization-conventions)
5. [Git Workflow & Branching Strategy](#git-workflow--branching-strategy)
6. [PR Review Checklist](#pr-review-checklist)
7. [Performance Optimization Guidelines](#performance-optimization-guidelines)
8. [Security Best Practices for Firebase](#security-best-practices-for-firebase)

---

## 1. Flutter Clean Architecture Patterns

### Overview
ChekMate follows Clean Architecture with 3 layers: **Data**, **Domain**, and **Presentation**.

### Layer Structure

```
lib/features/{feature_name}/
├── data/
│   ├── models/           # Data models (JSON serialization)
│   ├── repositories/     # Repository implementations
│   └── datasources/      # Remote (Firebase) and local data sources
├── domain/
│   ├── entities/         # Business entities (pure Dart classes)
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic (one use case per file)
└── presentation/
    ├── pages/            # Full-screen pages
    ├── widgets/          # Reusable widgets
    └── providers/        # Riverpod providers (state management)
```

### Example: Voice Message Feature

```dart
// lib/features/messaging/domain/entities/voice_message.dart
class VoiceMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String audioUrl;
  final int duration;
  final bool listened;
  final DateTime createdAt;

  VoiceMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.audioUrl,
    required this.duration,
    required this.listened,
    required this.createdAt,
  });
}

// lib/features/messaging/domain/repositories/message_repository.dart
abstract class MessageRepository {
  Future<void> sendVoiceMessage(VoiceMessage message);
  Stream<List<VoiceMessage>> getVoiceMessages(String conversationId);
  Future<void> markAsListened(String messageId);
}

// lib/features/messaging/domain/usecases/send_voice_message.dart
class SendVoiceMessageUseCase {
  final MessageRepository repository;

  SendVoiceMessageUseCase(this.repository);

  Future<void> call(VoiceMessage message) async {
    // Business logic validation
    if (message.duration > 60) {
      throw Exception('Voice message too long (max 60 seconds)');
    }
    
    return await repository.sendVoiceMessage(message);
  }
}

// lib/features/messaging/data/models/voice_message_model.dart
class VoiceMessageModel extends VoiceMessage {
  VoiceMessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.audioUrl,
    required super.duration,
    required super.listened,
    required super.createdAt,
  });

  factory VoiceMessageModel.fromJson(Map<String, dynamic> json) {
    return VoiceMessageModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      audioUrl: json['audioUrl'],
      duration: json['duration'],
      listened: json['listened'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'audioUrl': audioUrl,
      'duration': duration,
      'listened': listened,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// lib/features/messaging/data/repositories/message_repository_impl.dart
class MessageRepositoryImpl implements MessageRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  MessageRepositoryImpl({required this.firestore, required this.storage});

  @override
  Future<void> sendVoiceMessage(VoiceMessage message) async {
    final model = VoiceMessageModel(
      id: message.id,
      senderId: message.senderId,
      receiverId: message.receiverId,
      audioUrl: message.audioUrl,
      duration: message.duration,
      listened: message.listened,
      createdAt: message.createdAt,
    );
    
    await firestore
        .collection('messages')
        .doc(message.id)
        .set(model.toJson());
  }

  @override
  Stream<List<VoiceMessage>> getVoiceMessages(String conversationId) {
    return firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .where('type', isEqualTo: 'voice')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VoiceMessageModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> markAsListened(String messageId) async {
    await firestore
        .collection('messages')
        .doc(messageId)
        .update({'listened': true});
  }
}
```

### Best Practices

1. **Entities are pure Dart** - No dependencies on Flutter or Firebase
2. **Use cases contain business logic** - One use case per action
3. **Repositories are interfaces** - Defined in domain, implemented in data
4. **Models handle serialization** - Extend entities, add fromJson/toJson
5. **Presentation depends on domain** - Never import from data layer

---

## 2. State Management with Riverpod

### Provider Types

```dart
// 1. Provider - For immutable values
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// 2. StateProvider - For simple state
final autoPlayVideosProvider = StateProvider<bool>((ref) => true);

// 3. FutureProvider - For async data
final userProfileProvider = FutureProvider.family<UserProfile, String>((ref, userId) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.getUserProfile(userId);
});

// 4. StreamProvider - For real-time data
final messagesProvider = StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repository = ref.read(messageRepositoryProvider);
  return repository.getMessages(conversationId);
});

// 5. StateNotifierProvider - For complex state
class VoiceRecorderNotifier extends StateNotifier<VoiceRecorderState> {
  final RecordingService recordingService;

  VoiceRecorderNotifier(this.recordingService) : super(VoiceRecorderState.initial());

  Future<void> startRecording() async {
    state = state.copyWith(isRecording: true, duration: 0);
    await recordingService.startRecording();
    _startTimer();
  }

  Future<void> stopRecording() async {
    state = state.copyWith(isRecording: false);
    final filePath = await recordingService.stopRecording();
    state = state.copyWith(audioFilePath: filePath);
  }

  void _startTimer() {
    // Timer logic
  }
}

final voiceRecorderProvider = StateNotifierProvider<VoiceRecorderNotifier, VoiceRecorderState>((ref) {
  final recordingService = ref.read(recordingServiceProvider);
  return VoiceRecorderNotifier(recordingService);
});
```

### Best Practices

1. **Use Provider for dependencies** - Services, repositories, Firebase instances
2. **Use StateProvider for simple toggles** - Settings, flags
3. **Use FutureProvider for one-time async data** - User profile, post details
4. **Use StreamProvider for real-time data** - Messages, feed updates
5. **Use StateNotifierProvider for complex state** - Recording state, form state
6. **Always dispose resources** - Cancel timers, close streams in dispose()
7. **Use .family for parameterized providers** - User-specific, post-specific data
8. **Use .autoDispose for temporary data** - Avoid memory leaks

---

## 3. Testing Strategies

### Test Coverage Goals
- **Unit Tests:** 80%+ coverage for business logic (use cases, services)
- **Widget Tests:** 70%+ coverage for UI components
- **Integration Tests:** Key user flows (login, create post, send message)
- **Golden Tests:** Critical UI components (post card, profile header)

### Unit Test Example

```dart
// test/features/messaging/domain/usecases/send_voice_message_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late SendVoiceMessageUseCase useCase;
  late MockMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockMessageRepository();
    useCase = SendVoiceMessageUseCase(mockRepository);
  });

  group('SendVoiceMessageUseCase', () {
    test('should send voice message when duration is valid', () async {
      // Arrange
      final message = VoiceMessage(
        id: '123',
        senderId: 'user1',
        receiverId: 'user2',
        audioUrl: 'https://example.com/audio.aac',
        duration: 30,
        listened: false,
        createdAt: DateTime.now(),
      );
      
      when(mockRepository.sendVoiceMessage(message))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase(message);

      // Assert
      verify(mockRepository.sendVoiceMessage(message)).called(1);
    });

    test('should throw exception when duration exceeds 60 seconds', () async {
      // Arrange
      final message = VoiceMessage(
        id: '123',
        senderId: 'user1',
        receiverId: 'user2',
        audioUrl: 'https://example.com/audio.aac',
        duration: 65, // Too long
        listened: false,
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(() => useCase(message), throwsException);
      verifyNever(mockRepository.sendVoiceMessage(any));
    });
  });
}
```

### Widget Test Example

```dart
// test/features/messaging/presentation/widgets/voice_recorder_widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('VoiceRecorderWidget shows record button when not recording', (tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: VoiceRecorderWidget(),
          ),
        ),
      ),
    );

    // Assert
    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.text('Hold to record'), findsOneWidget);
  });

  testWidgets('VoiceRecorderWidget shows timer when recording', (tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: VoiceRecorderWidget(),
          ),
        ),
      ),
    );

    // Act
    await tester.longPress(find.byIcon(Icons.mic));
    await tester.pump();

    // Assert
    expect(find.text('00:00'), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
  });
}
```

### Integration Test Example

```dart
// integration_test/send_voice_message_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can record and send voice message', (tester) async {
    // Launch app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Navigate to messages
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle();

    // Open conversation
    await tester.tap(find.text('John Doe'));
    await tester.pumpAndSettle();

    // Start recording
    await tester.longPress(find.byIcon(Icons.mic));
    await tester.pump(Duration(seconds: 2));

    // Stop recording
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pumpAndSettle();

    // Send message
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    // Verify message sent
    expect(find.byType(VoiceMessagePlayer), findsOneWidget);
  });
}
```

### Best Practices

1. **Test business logic thoroughly** - Use cases, services, utilities
2. **Mock external dependencies** - Firebase, APIs, file system
3. **Test edge cases** - Empty states, errors, loading states
4. **Use descriptive test names** - "should do X when Y"
5. **Arrange-Act-Assert pattern** - Clear test structure
6. **One assertion per test** - Focused, easy to debug
7. **Use setUp/tearDown** - Clean state between tests
8. **Test user flows, not implementation** - Integration tests

---


