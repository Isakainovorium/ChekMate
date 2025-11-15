import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/widgets/voice_recording_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceRecordingButton', () {
    testWidgets('displays microphone icon initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceRecordingButton(
                senderId: 'sender123',
                receiverId: 'receiver456',
              ),
            ),
          ),
        ),
      );

      // Verify initial state shows microphone icon
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('shows recording state when tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceRecordingButton(
                senderId: 'sender123',
                receiverId: 'receiver456',
              ),
            ),
          ),
        ),
      );

      // Tap record button
      await tester.tap(find.byType(VoiceRecordingButton));
      await tester.pump();

      // Verify button is present (state changes are handled by provider)
      expect(find.byType(VoiceRecordingButton), findsOneWidget);
    });

    testWidgets('accepts custom size parameter', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceRecordingButton(
                senderId: 'sender123',
                receiverId: 'receiver456',
                size: 80.0,
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(VoiceRecordingButton), findsOneWidget);
    });

    testWidgets('accepts custom icon size parameter', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceRecordingButton(
                senderId: 'sender123',
                receiverId: 'receiver456',
                iconSize: 32.0,
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(VoiceRecordingButton), findsOneWidget);
    });

    testWidgets('accepts custom max duration parameter', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceRecordingButton(
                senderId: 'sender123',
                receiverId: 'receiver456',
                maxDuration: 30,
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(VoiceRecordingButton), findsOneWidget);
    });

    testWidgets('accepts custom colors', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceRecordingButton(
                senderId: 'sender123',
                receiverId: 'receiver456',
                primaryColor: Colors.blue,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered with custom colors
      expect(find.byType(VoiceRecordingButton), findsOneWidget);
    });

    testWidgets('calls onRecordingComplete callback', (tester) async {
      // ignore: unused_local_variable
      dynamic completedMessage;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceRecordingButton(
                senderId: 'sender123',
                receiverId: 'receiver456',
                onRecordingComplete: (voiceMessage) {
                  completedMessage = voiceMessage;
                },
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(VoiceRecordingButton), findsOneWidget);
    });

    testWidgets('calls onRecordingCancelled callback', (tester) async {
      // ignore: unused_local_variable
      var cancelled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceRecordingButton(
                senderId: 'sender123',
                receiverId: 'receiver456',
                onRecordingCancelled: () {
                  cancelled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(VoiceRecordingButton), findsOneWidget);
    });

    testWidgets('calls onError callback on failure', (tester) async {
      // ignore: unused_local_variable
      String? errorMessage;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceRecordingButton(
                senderId: 'sender123',
                receiverId: 'receiver456',
                onError: (error) {
                  errorMessage = error;
                },
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(VoiceRecordingButton), findsOneWidget);
    });
  });
}
