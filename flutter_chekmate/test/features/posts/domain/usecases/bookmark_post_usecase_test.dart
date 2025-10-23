import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/bookmark_post_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_post_usecase_test.mocks.dart';

@GenerateMocks([PostsRepository])
void main() {
  group('BookmarkPostUseCase', () {
    late BookmarkPostUseCase bookmarkUseCase;
    late UnbookmarkPostUseCase unbookmarkUseCase;
    late MockPostsRepository mockRepository;

    setUp(() {
      mockRepository = MockPostsRepository();
      bookmarkUseCase = BookmarkPostUseCase(mockRepository);
      unbookmarkUseCase = UnbookmarkPostUseCase(mockRepository);
    });

    group('BookmarkPostUseCase', () {
      test('throws exception when postId is empty', () async {
        expect(
          () => bookmarkUseCase(postId: '', userId: 'user1'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when userId is empty', () async {
        expect(
          () => bookmarkUseCase(postId: 'post1', userId: ''),
          throwsA(isA<Exception>()),
        );
      });

      test('calls repository with correct parameters', () async {
        when(mockRepository.bookmarkPost(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        ),).thenAnswer((_) async => {});

        await bookmarkUseCase(postId: 'post1', userId: 'user1');

        verify(mockRepository.bookmarkPost(
          postId: 'post1',
          userId: 'user1',
        ),).called(1);
      });

      test('propagates repository errors', () async {
        when(mockRepository.bookmarkPost(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        ),).thenThrow(Exception('Failed to bookmark post'));

        expect(
          () => bookmarkUseCase(postId: 'post1', userId: 'user1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('UnbookmarkPostUseCase', () {
      test('throws exception when postId is empty', () async {
        expect(
          () => unbookmarkUseCase(postId: '', userId: 'user1'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when userId is empty', () async {
        expect(
          () => unbookmarkUseCase(postId: 'post1', userId: ''),
          throwsA(isA<Exception>()),
        );
      });

      test('calls repository with correct parameters', () async {
        when(mockRepository.unbookmarkPost(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        ),).thenAnswer((_) async => {});

        await unbookmarkUseCase(postId: 'post1', userId: 'user1');

        verify(mockRepository.unbookmarkPost(
          postId: 'post1',
          userId: 'user1',
        ),).called(1);
      });

      test('propagates repository errors', () async {
        when(mockRepository.unbookmarkPost(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        ),).thenThrow(Exception('Failed to unbookmark post'));

        expect(
          () => unbookmarkUseCase(postId: 'post1', userId: 'user1'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

