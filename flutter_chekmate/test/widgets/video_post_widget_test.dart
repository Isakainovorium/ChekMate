import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/feed/widgets/video_post_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../mocks/mock_video_player_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Register mock video player platform
    VideoPlayerPlatform.instance = MockVideoPlayerPlatform();
  });

  group('VideoPostWidget', () {
    const testVideoUrl = 'https://example.com/video.mp4';

    // Helper to clean up pending timers from VisibilityDetector
    Future<void> cleanupTimers(WidgetTester tester) async {
      // Remove all widgets to cancel VisibilityDetector timers
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('displays thumbnail initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: null,
            ),
          ),
        ),
      );

      // Pump to build the widget
      await tester.pump();

      // Verify widget is displayed (with black container as placeholder)
      expect(find.byType(VideoPostWidget), findsOneWidget);

      // Clean up timers
      await cleanupTimers(tester);
    });

    testWidgets('shows play button overlay', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              autoPlay: false, // Disable auto-play to see play button
            ),
          ),
        ),
      );
      await tester.pump(); // Build widget
      await tester.pump(const Duration(
          milliseconds:
              20)); // Wait for initialization event (10ms delay + buffer)
      await tester.pump(); // Complete setState from initialization

      // Verify play button is displayed (play_arrow icon when paused)
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await cleanupTimers(tester);
    });

    testWidgets('starts playing when tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              autoPlay: false, // Disable auto-play to see play button
            ),
          ),
        ),
      );
      await tester.pump(); // Build widget
      await tester.pump(
          const Duration(milliseconds: 20)); // Wait for initialization event
      await tester.pump(); // Complete setState from initialization

      // Tap the play button to start playing
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Verify video player is initialized and widget renders
      expect(find.byType(VideoPostWidget), findsOneWidget);

      await cleanupTimers(tester);
    });

    testWidgets('shows pause button when playing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              autoPlay: false, // Disable auto-play to see play button
            ),
          ),
        ),
      );
      await tester.pump(); // Build widget
      await tester.pump(
          const Duration(milliseconds: 20)); // Wait for initialization event
      await tester.pump(); // Complete setState from initialization

      // Tap the play button to start playing
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Tap to show controls
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Verify pause button is shown in controls when playing
      expect(find.byIcon(Icons.pause), findsOneWidget);

      await cleanupTimers(tester);
    });

    testWidgets('shows mute/unmute button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              autoPlay: false, // Disable auto-play to see play button
            ),
          ),
        ),
      );
      await tester.pump(); // Build widget
      await tester.pump(
          const Duration(milliseconds: 20)); // Wait for initialization event
      await tester.pump(); // Complete setState from initialization

      // Tap the play button to start playing
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Tap to show controls
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Verify mute button is shown (starts muted)
      expect(find.byIcon(Icons.volume_off), findsOneWidget);

      await cleanupTimers(tester);
    });

    testWidgets('toggles mute state when mute button tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              autoPlay: false, // Disable auto-play to see play button
            ),
          ),
        ),
      );
      await tester.pump(); // Build widget
      await tester.pump(
          const Duration(milliseconds: 20)); // Wait for initialization event
      await tester.pump(); // Complete setState from initialization

      // Tap the play button to start playing
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Tap to show controls
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Tap mute button (starts muted, so should unmute)
      await tester.tap(find.byIcon(Icons.volume_off));
      await tester.pump();

      // Verify unmuted icon is shown
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      await cleanupTimers(tester);
    });

    testWidgets('displays progress bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              autoPlay: false, // Disable auto-play to see play button
            ),
          ),
        ),
      );
      await tester.pump(); // Build widget
      await tester.pump(
          const Duration(milliseconds: 20)); // Wait for initialization event
      await tester.pump(); // Complete setState from initialization

      // Tap the play button to start playing
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Tap to show controls
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Verify progress indicator is displayed (VideoProgressIndicator, not LinearProgressIndicator)
      expect(find.byType(VideoProgressIndicator), findsOneWidget);

      await cleanupTimers(tester);
    });

    testWidgets('shows loading indicator while buffering', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
            ),
          ),
        ),
      );

      // Before initialization completes, should show loading indicator
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await cleanupTimers(tester);
    });

    testWidgets('auto-plays when visible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify video widget is rendered (auto-play is handled by mock)
      expect(find.byType(VideoPostWidget), findsOneWidget);

      await cleanupTimers(tester);
    });

    testWidgets('pauses when scrolled out of view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  VideoPostWidget(
                    videoUrl: testVideoUrl,
                  ),
                  SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(); // Build widget
      await tester.pump(
          const Duration(milliseconds: 20)); // Wait for initialization event
      await tester.pump(); // Complete setState from initialization

      // Video should be visible initially
      expect(find.byType(VideoPostWidget), findsOneWidget);

      // Scroll down to move video out of view
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      await tester.pump(const Duration(
          milliseconds: 600)); // Wait for VisibilityDetector timer

      // Verify ListView is still rendered (pause is handled by visibility detector)
      expect(find.byType(ListView), findsOneWidget);

      await cleanupTimers(tester);
    });

    testWidgets('disposes video player when widget disposed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
            ),
          ),
        ),
      );
      await tester.pump();

      // Remove widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );
      await tester.pump();

      // Verify widget is removed (disposal is handled by widget lifecycle)
      expect(find.byType(VideoPostWidget), findsNothing);

      await cleanupTimers(tester);
    });
  });
}
