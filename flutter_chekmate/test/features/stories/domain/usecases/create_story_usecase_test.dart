import 'package:flutter_chekmate/features/stories/domain/entities/story_entity.dart';
import 'package:flutter_chekmate/features/stories/domain/repositories/story_repository.dart';
import 'package:flutter_chekmate/features/stories/domain/usecases/create_story_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStoryRepository extends Mock implements StoryRepository {}

void main() {
  group('CreateStoryUsecase', () {
    late CreateStoryUsecase usecase;
    late MockStoryRepository mockRepository;
    late StoryEntity testStory;

    setUp(() {
      mockRepository = MockStoryRepository();
      usecase = CreateStoryUsecase(mockRepository);
      testStory = StoryEntity(
        id: 'story1',
        userId: 'user1',
        username: 'testuser',
        userAvatar: 'https://example.com/avatar.jpg',
        type: StoryType.image,
        url: 'https://example.com/story.jpg',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        views: 10,
        likes: 5,
      );
    });

    group('Validation', () {
      test('throws exception when filePath is empty', () async {
        expect(
          () => usecase(
            type: StoryType.image,
            filePath: '',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when video duration is 0', () async {
        expect(
          () => usecase(
            type: StoryType.video,
            filePath: '/path/to/video.mp4',
            duration: 0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when video duration is negative', () async {
        expect(
          () => usecase(
            type: StoryType.video,
            filePath: '/path/to/video.mp4',
            duration: -1,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('uses default duration of 5 seconds for images', () async {
        when(() => mockRepository.createStory(
          type: any(named: 'type'),
          filePath: any(named: 'filePath'),
          duration: any(named: 'duration'),
        )).thenAnswer((_) async => testStory);

        await usecase(
          type: StoryType.image,
          filePath: '/path/to/image.jpg',
        );

        verify(() => mockRepository.createStory(
          type: StoryType.image,
          filePath: '/path/to/image.jpg',
          duration: 5,
        )).called(1);
      });

      test('uses default duration of 15 seconds for videos', () async {
        when(() => mockRepository.createStory(
          type: any(named: 'type'),
          filePath: any(named: 'filePath'),
          duration: any(named: 'duration'),
        )).thenAnswer((_) async => testStory);

        await usecase(
          type: StoryType.video,
          filePath: '/path/to/video.mp4',
        );

        verify(() => mockRepository.createStory(
          type: StoryType.video,
          filePath: '/path/to/video.mp4',
          duration: 15,
        )).called(1);
      });

      test('uses provided duration when specified', () async {
        when(() => mockRepository.createStory(
          type: any(named: 'type'),
          filePath: any(named: 'filePath'),
          duration: any(named: 'duration'),
          text: any(named: 'text'),
        )).thenAnswer((_) async => testStory);

        await usecase(
          type: StoryType.image,
          filePath: '/path/to/image.jpg',
          duration: 10,
          text: 'Hello!',
        );

        verify(() => mockRepository.createStory(
          type: StoryType.image,
          filePath: '/path/to/image.jpg',
          duration: 10,
          text: 'Hello!',
        )).called(1);
      });

      test('returns created story from repository', () async {
        when(() => mockRepository.createStory(
          type: any(named: 'type'),
          filePath: any(named: 'filePath'),
          duration: any(named: 'duration'),
        )).thenAnswer((_) async => testStory);

        final result = await usecase(
          type: StoryType.image,
          filePath: '/path/to/image.jpg',
        );

        expect(result, testStory);
      });
    });
  });

  group('DeleteStoryUsecase', () {
    late DeleteStoryUsecase usecase;
    late MockStoryRepository mockRepository;

    setUp(() {
      mockRepository = MockStoryRepository();
      usecase = DeleteStoryUsecase(mockRepository);
    });

    group('Validation', () {
      test('throws exception when storyId is empty', () async {
        expect(
          () => usecase(''),
          throwsA(isA<Exception>()),
        );
      });

      test('calls repository when storyId is valid', () async {
        when(() => mockRepository.deleteStory(any())).thenAnswer((_) async => {});

        await usecase('story1');

        verify(() => mockRepository.deleteStory('story1')).called(1);
      });
    });
  });
}

