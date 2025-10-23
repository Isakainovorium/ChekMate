import 'package:flutter_chekmate/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_chekmate/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_post_usecase_test.mocks.dart';

@GenerateMocks([PostsRepository])
void main() {
  group('DeletePostUseCase', () {
    late DeletePostUseCase useCase;
    late MockPostsRepository mockRepository;

    setUp(() {
      mockRepository = MockPostsRepository();
      useCase = DeletePostUseCase(mockRepository);
    });

    test('throws exception when postId is empty', () async {
      expect(
        () => useCase(postId: '', userId: 'user1'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws exception when userId is empty', () async {
      expect(
        () => useCase(postId: 'post1', userId: ''),
        throwsA(isA<Exception>()),
      );
    });

    test('calls repository with correct parameters', () async {
      when(mockRepository.deletePost(
        postId: anyNamed('postId'),
        userId: anyNamed('userId'),
      ),).thenAnswer((_) async => {});

      await useCase(postId: 'post1', userId: 'user1');

      verify(mockRepository.deletePost(
        postId: 'post1',
        userId: 'user1',
      ),).called(1);
    });

    test('propagates repository errors', () async {
      when(mockRepository.deletePost(
        postId: anyNamed('postId'),
        userId: anyNamed('userId'),
      ),).thenThrow(Exception('Failed to delete post'));

      expect(
        () => useCase(postId: 'post1', userId: 'user1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

