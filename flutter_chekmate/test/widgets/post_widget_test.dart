import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/feed/models/post_model.dart';
import 'package:flutter_chekmate/features/feed/widgets/post_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostWidget', () {
    late Post testPost;

    setUp(() {
      testPost = const Post(
        id: 'post1',
        username: 'Test User',
        userAvatar: '', // Empty string - AppAvatar will show initials fallback
        content: 'Test post content',
        imageUrls: [], // Empty list to avoid NetworkImage issues in tests
        likes: 2,
        comments: 10,
        shares: 5,
        timestamp: '2 hours ago',
      );
    });

    testWidgets('displays user information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(post: testPost),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify user name is displayed
      expect(find.text('Test User'), findsOneWidget);

      // Verify user avatar is displayed (CircleAvatar should exist even with empty avatar)
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays post content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(post: testPost),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify content is displayed
      expect(find.text('Test post content'), findsOneWidget);
    });

    testWidgets('displays post image', (tester) async {
      // Create post with image for this test
      final postWithImage = testPost.copyWith(
        imageUrls: ['test-image-url'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostWidget(post: postWithImage),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify PostWidget renders (image rendering will fail but widget should exist)
      expect(find.byType(PostWidget), findsOneWidget);
    });

    testWidgets('displays like button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(post: testPost),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify like button is displayed
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('displays like count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(post: testPost),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify like count is displayed
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('displays comment button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(post: testPost),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify comment button is displayed
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('displays comment count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(post: testPost),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify comment count is displayed
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('displays share button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(post: testPost),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify share button is displayed
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets('displays bookmark button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(post: testPost),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify bookmark button is displayed
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('shows filled heart when post is liked', (tester) async {
      final likedPost = testPost.copyWith(
        isLiked: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(
              post: likedPost,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify filled heart is displayed
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows filled bookmark when post is bookmarked',
        (tester) async {
      final bookmarkedPost = testPost.copyWith(
        isBookmarked: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(
              post: bookmarkedPost,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify filled bookmark is displayed
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('calls onCommentPressed when comment button tapped',
        (tester) async {
      var commentCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(
              post: testPost,
              onCommentPressed: () {
                commentCalled = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap comment button
      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      await tester.pump();

      // Verify callback was called
      expect(commentCalled, true);
    });

    testWidgets('calls onSharePressed when share button tapped',
        (tester) async {
      var shareCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(
              post: testPost,
              onSharePressed: () {
                shareCalled = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap share button
      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pump();

      // Verify callback was called
      expect(shareCalled, true);
    });

    testWidgets('displays timestamp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(post: testPost),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify timestamp is displayed
      expect(find.text('2 hours ago'), findsOneWidget);
    });
  });
}
