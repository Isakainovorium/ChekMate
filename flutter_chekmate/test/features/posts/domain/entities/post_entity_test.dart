import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostEntity', () {
    late PostEntity testPost;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 10, 17, 12);
      testPost = PostEntity(
        id: 'post1',
        userId: 'user1',
        username: 'Test User',
        userAvatar: 'https://example.com/avatar.jpg',
        content: 'Test post content',
        images: ['https://example.com/image1.jpg'],
        likes: 2,
        comments: 10,
        shares: 5,
        cheks: 3,
        likedBy: ['user2', 'user3'],
        bookmarkedBy: ['user2'],
        isVerified: false,
        tags: ['test', 'flutter'],
        location: 'San Francisco, CA',
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('Business Logic Methods', () {
      test('hasMedia returns true when post has images', () {
        expect(testPost.hasMedia, true);
      });

      test('hasMedia returns true when post has video', () {
        final videoPost = testPost.copyWith(
          images: <String>[],
          videoUrl: 'https://example.com/video.mp4',
        );
        expect(videoPost.hasMedia, true);
      });

      test('hasMedia returns false when post has no media', () {
        final textPost = testPost.copyWith(images: <String>[]);
        expect(textPost.hasMedia, false);
      });

      test('hasVideo returns true when post has video', () {
        final videoPost = testPost.copyWith(
          videoUrl: 'https://example.com/video.mp4',
        );
        expect(videoPost.hasVideo, true);
      });

      test('hasVideo returns false when post has no video', () {
        expect(testPost.hasVideo, false);
      });

      test('hasImages returns true when post has images', () {
        expect(testPost.hasImages, true);
      });

      test('hasImages returns false when post has no images', () {
        final textPost = testPost.copyWith(images: <String>[]);
        expect(textPost.hasImages, false);
      });

      test('hasMultipleImages returns true when post has multiple images', () {
        final multiImagePost = testPost.copyWith(
          images: <String>[
            'https://example.com/image1.jpg',
            'https://example.com/image2.jpg',
          ],
        );
        expect(multiImagePost.hasMultipleImages, true);
      });

      test('hasMultipleImages returns false when post has one image', () {
        expect(testPost.hasMultipleImages, false);
      });

      test('canEdit returns true when user is the author', () {
        expect(testPost.canEdit('user1'), true);
      });

      test('canEdit returns false when user is not the author', () {
        expect(testPost.canEdit('user2'), false);
      });

      test('canDelete returns true when user is the author', () {
        expect(testPost.canDelete('user1'), true);
      });

      test('canDelete returns false when user is not the author', () {
        expect(testPost.canDelete('user2'), false);
      });

      test('isLikedBy returns true when user has liked the post', () {
        expect(testPost.isLikedBy('user2'), true);
      });

      test('isLikedBy returns false when user has not liked the post', () {
        expect(testPost.isLikedBy('user1'), false);
      });

      test('isBookmarkedBy returns true when user has bookmarked the post', () {
        expect(testPost.isBookmarkedBy('user2'), true);
      });

      test('isBookmarkedBy returns false when user has not bookmarked the post',
          () {
        expect(testPost.isBookmarkedBy('user1'), false);
      });

      test('isRecent returns true for posts less than 24 hours old', () {
        final recentPost = testPost.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        );
        expect(recentPost.isRecent, true);
      });

      test('isRecent returns false for posts more than 24 hours old', () {
        final oldPost = testPost.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        );
        expect(oldPost.isRecent, false);
      });

      test('isEdited returns true when updatedAt is after createdAt', () {
        final editedPost = testPost.copyWith(
          updatedAt: testDate.add(const Duration(hours: 1)),
        );
        expect(editedPost.isEdited, true);
      });

      test('isEdited returns false when updatedAt equals createdAt', () {
        expect(testPost.isEdited, false);
      });

      test('timeAgo returns correct format for seconds', () {
        final recentPost = testPost.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        );
        expect(recentPost.timeAgo, 'Just now');
      });

      test('timeAgo returns correct format for minutes', () {
        final recentPost = testPost.copyWith(
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        expect(recentPost.timeAgo, '5m ago');
      });

      test('timeAgo returns correct format for hours', () {
        final recentPost = testPost.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        );
        expect(recentPost.timeAgo, '3h ago');
      });

      test('timeAgo returns correct format for days', () {
        final recentPost = testPost.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        expect(recentPost.timeAgo, '2d ago');
      });
    });

    group('Equality', () {
      test('two posts with same id are equal', () {
        final post1 = testPost;
        final post2 = testPost.copyWith(content: 'Different content');
        expect(post1, equals(post2));
      });

      test('two posts with different ids are not equal', () {
        final post1 = testPost;
        final post2 = testPost.copyWith(id: 'post2');
        expect(post1, isNot(equals(post2)));
      });

      test('hashCode is based on id', () {
        final post1 = testPost;
        final post2 = testPost.copyWith(content: 'Different content');
        expect(post1.hashCode, equals(post2.hashCode));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated fields', () {
        final updatedPost = testPost.copyWith(
          content: 'Updated content',
          likedBy: <String>['user1', 'user2', 'user3'],
        );

        expect(updatedPost.id, testPost.id);
        expect(updatedPost.content, 'Updated content');
        expect(updatedPost.likedBy, <String>['user1', 'user2', 'user3']);
        expect(updatedPost.username, testPost.username);
      });

      test('copyWith preserves original when no fields provided', () {
        final copiedPost = testPost.copyWith();

        expect(copiedPost.id, testPost.id);
        expect(copiedPost.content, testPost.content);
        expect(copiedPost.likes, testPost.likes);
      });
    });

    group('ToString', () {
      test('toString returns correct format', () {
        final string = testPost.toString();
        expect(string, contains('PostEntity'));
        expect(string, contains('post1'));
        expect(string, contains('user1'));
      });
    });
  });
}
