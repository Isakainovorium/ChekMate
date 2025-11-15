import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/like_post_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_post_usecase_test.mocks.dart';

@GenerateMocks([PostsRepository])
void main() {
  group('LikePostUseCase', () {
    late LikePostUseCase likeUseCase;
    late UnlikePostUseCase unlikeUseCase;
    late MockPostsRepository mockRepository;

    setUp(() {
      mockRepository = MockPostsRepository();
      likeUseCase = LikePostUseCase(mockRepository);
      unlikeUseCase = UnlikePostUseCase(mockRepository);
    });

    group('LikePostUseCase', () {
      test('throws exception when postId is empty', () async {
        expect(
          () => likeUseCase(postId: '', userId: 'user1'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when userId is empty', () async {
        expect(
          () => likeUseCase(postId: 'post1', userId: ''),
          throwsA(isA<Exception>()),
        );
      });

      test('calls repository with correct parameters', () async {
        when(mockRepository.likePost(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        ),).thenAnswer((_) async => {});

        await likeUseCase(postId: 'post1', userId: 'user1');

        verify(mockRepository.likePost(
          postId: 'post1',
          userId: 'user1',
        ),).called(1);
      });

      test('propagates repository errors', () async {
        when(mockRepository.likePost(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        ),).thenThrow(Exception('Failed to like post'));

        expect(
          () => likeUseCase(postId: 'post1', userId: 'user1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('UnlikePostUseCase', () {
      test('throws exception when postId is empty', () async {
        expect(
          () => unlikeUseCase(postId: '', userId: 'user1'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when userId is empty', () async {
        expect(
          () => unlikeUseCase(postId: 'post1', userId: ''),
          throwsA(isA<Exception>()),
        );
      });

      test('calls repository with correct parameters', () async {
        when(mockRepository.unlikePost(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        ),).thenAnswer((_) async => {});

        await unlikeUseCase(postId: 'post1', userId: 'user1');

        verify(mockRepository.unlikePost(
          postId: 'post1',
          userId: 'user1',
        ),).called(1);
      });

      test('propagates repository errors', () async {
        when(mockRepository.unlikePost(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        ),).thenThrow(Exception('Failed to unlike post'));

        expect(
          () => unlikeUseCase(postId: 'post1', userId: 'user1'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

