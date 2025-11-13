import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/feed/widgets/video_post_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoPostWidget', () {
    const testVideoUrl = 'https://example.com/video.mp4';
    const testThumbnailUrl = 'https://example.com/thumbnail.jpg';

    testWidgets('displays thumbnail initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Verify thumbnail is displayed
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows play button overlay', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Verify play button is displayed
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('starts playing when tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Tap to play
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Verify video player is initialized
      // (This would require mocking the video player)
    });

    testWidgets('shows pause button when playing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Start playing
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Verify pause button is shown
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('shows mute/unmute button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Start playing
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Verify mute button is shown
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('toggles mute state when mute button tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Start playing
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Tap mute button
      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pump();

      // Verify muted icon is shown
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('displays progress bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Start playing
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Verify progress bar is displayed
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator while buffering', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Start playing
      await tester.tap(find.byType(VideoPostWidget));
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('auto-plays when visible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Wait for auto-play
      await tester.pump(const Duration(milliseconds: 500));

      // Verify video started playing
      // (This would require mocking the video player)
    });

    testWidgets('pauses when scrolled out of view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                SizedBox(height: 1000),
                VideoPostWidget(
                  videoUrl: testVideoUrl,
                  thumbnailUrl: testThumbnailUrl,
                ),
                SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );

      // Scroll to video
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pump();

      // Scroll away from video
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pump();

      // Verify video paused
      // (This would require mocking the video player)
    });

    testWidgets('disposes video player when widget disposed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPostWidget(
              videoUrl: testVideoUrl,
              thumbnailUrl: testThumbnailUrl,
            ),
          ),
        ),
      );

      // Remove widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Verify no memory leaks
      // (This would require checking video player disposal)
    });
  });
}

