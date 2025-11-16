import 'dart:typed_data';

import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  group('CreatePostUseCase', () {
    late CreatePostUseCase useCase;
    late MockPostsRepository mockRepository;

    setUp(() {
      mockRepository = MockPostsRepository();
      useCase = CreatePostUseCase(mockRepository);
    });

    group('Validation', () {
      test('throws exception when userId is empty', () async {
        expect(
          () => useCase(
            userId: '',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when username is empty', () async {
        expect(
          () => useCase(
            userId: 'user1',
            username: '',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when content is empty and no media', () async {
        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: '',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when content exceeds 5000 characters', () async {
        final longContent = 'a' * 5001;
        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: longContent,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when more than 10 images provided', () async {
        final images = List.generate(11, (_) => Uint8List.fromList([1, 2, 3]));
        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            images: images,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when more than 30 tags provided', () async {
        final tags = List.generate(31, (i) => 'tag$i');
        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            tags: tags,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when tag contains spaces', () async {
        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            tags: ['tag with spaces'],
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when location exceeds 200 characters', () async {
        final longLocation = 'a' * 201;
        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            location: longLocation,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when image exceeds 10MB', () async {
        // Create a large image (11MB)
        final largeImage = Uint8List(11 * 1024 * 1024);
        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            images: [largeImage],
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when video exceeds 100MB', () async {
        // Create a large video (101MB)
        final largeVideo = Uint8List(101 * 1024 * 1024);
        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            video: largeVideo,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when both images and video provided', () async {
        final image = Uint8List.fromList([1, 2, 3]);
        final video = Uint8List.fromList([4, 5, 6]);
        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            images: [image],
            video: video,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('accepts valid post with text only', () async {
        final mockPost = PostEntity(
          id: 'post1',
          userId: 'user1',
          username: 'Test User',
          userAvatar: 'https://example.com/avatar.jpg',
          content: 'Test content',
          images: const [],
          likes: 0,
          comments: 0,
          shares: 0,
          cheks: 0,
          likedBy: const [],
          bookmarkedBy: const [],
          chekedBy: const [],
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: false,
        );

        when(() => mockRepository.createPost(
            userId: any(named: 'userId'),
            username: any(named: 'username'),
            userAvatar: any(named: 'userAvatar'),
            content: any(named: 'content'),
            images: any(named: 'images'),
            video: any(named: 'video'),
            tags: any(named: 'tags'),
            location: any(named: 'location'),
        )).thenAnswer((_) async => mockPost);

        final result = await useCase(
          userId: 'user1',
          username: 'Test User',
          userAvatar: 'https://example.com/avatar.jpg',
          content: 'Test content',
        );

        expect(result, mockPost);
        verify(() => mockRepository.createPost(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
        )).called(1);
      });

      test('accepts valid post with images', () async {
        final images = [
          Uint8List.fromList([1, 2, 3]),
          Uint8List.fromList([4, 5, 6]),
        ];

        final mockPost = PostEntity(
          id: 'post1',
          userId: 'user1',
          username: 'Test User',
          userAvatar: 'https://example.com/avatar.jpg',
          content: 'Test content',
          images: const [
            'https://example.com/image1.jpg',
            'https://example.com/image2.jpg',
          ],
          likes: 0,
          comments: 0,
          shares: 0,
          cheks: 0,
          likedBy: const [],
          bookmarkedBy: const [],
          chekedBy: const [],
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: false,
        );

        when(() => mockRepository.createPost(
            userId: any(named: 'userId'),
            username: any(named: 'username'),
            userAvatar: any(named: 'userAvatar'),
            content: any(named: 'content'),
            images: any(named: 'images'),
            video: any(named: 'video'),
            tags: any(named: 'tags'),
            location: any(named: 'location'),
        )).thenAnswer((_) async => mockPost);

        final result = await useCase(
          userId: 'user1',
          username: 'Test User',
          userAvatar: 'https://example.com/avatar.jpg',
          content: 'Test content',
          images: images,
        );

        expect(result, mockPost);
        verify(() => mockRepository.createPost(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            images: images,
        )).called(1);
      });

      test('accepts valid post with video', () async {
        final video = Uint8List.fromList([1, 2, 3, 4, 5]);

        final mockPost = PostEntity(
          id: 'post1',
          userId: 'user1',
          username: 'Test User',
          userAvatar: 'https://example.com/avatar.jpg',
          content: 'Test content',
          images: const [],
          likes: 0,
          comments: 0,
          shares: 0,
          cheks: 0,
          likedBy: const [],
          bookmarkedBy: const [],
          chekedBy: const [],
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: false,
        );

        when(() => mockRepository.createPost(
            userId: any(named: 'userId'),
            username: any(named: 'username'),
            userAvatar: any(named: 'userAvatar'),
            content: any(named: 'content'),
            images: any(named: 'images'),
            video: any(named: 'video'),
            tags: any(named: 'tags'),
            location: any(named: 'location'),
        )).thenAnswer((_) async => mockPost);

        final result = await useCase(
          userId: 'user1',
          username: 'Test User',
          userAvatar: 'https://example.com/avatar.jpg',
          content: 'Test content',
          video: video,
        );

        expect(result, mockPost);
        verify(() => mockRepository.createPost(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            video: video,
        )).called(1);
      });

      test('accepts valid post with tags and location', () async {
        final mockPost = PostEntity(
          id: 'post1',
          userId: 'user1',
          username: 'Test User',
          userAvatar: 'https://example.com/avatar.jpg',
          content: 'Test content',
          images: const [],
          likes: 0,
          comments: 0,
          shares: 0,
          cheks: 0,
          likedBy: const [],
          bookmarkedBy: const [],
          chekedBy: const [],
          tags: const ['flutter', 'dart'],
          location: 'San Francisco, CA',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: false,
        );

        when(() => mockRepository.createPost(
            userId: any(named: 'userId'),
            username: any(named: 'username'),
            userAvatar: any(named: 'userAvatar'),
            content: any(named: 'content'),
            images: any(named: 'images'),
            video: any(named: 'video'),
            tags: any(named: 'tags'),
            location: any(named: 'location'),
        )).thenAnswer((_) async => mockPost);

        final result = await useCase(
          userId: 'user1',
          username: 'Test User',
          userAvatar: 'https://example.com/avatar.jpg',
          content: 'Test content',
          tags: ['flutter', 'dart'],
          location: 'San Francisco, CA',
        );

        expect(result, mockPost);
        verify(() => mockRepository.createPost(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
            tags: ['flutter', 'dart'],
            location: 'San Francisco, CA',
        )).called(1);
      });
    });

    group('Error Handling', () {
      test('propagates repository errors', () async {
        when(() => mockRepository.createPost(
            userId: any(named: 'userId'),
            username: any(named: 'username'),
            userAvatar: any(named: 'userAvatar'),
            content: any(named: 'content'),
            images: any(named: 'images'),
            video: any(named: 'video'),
            tags: any(named: 'tags'),
            location: any(named: 'location'),
          ),
        ).thenThrow(Exception('Failed to create post'));

        expect(
          () => useCase(
            userId: 'user1',
            username: 'Test User',
            userAvatar: 'https://example.com/avatar.jpg',
            content: 'Test content',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
