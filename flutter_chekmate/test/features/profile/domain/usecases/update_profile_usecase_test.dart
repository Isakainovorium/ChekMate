import 'package:flutter_chekmate/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_chekmate/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_profile_usecase_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  group('UpdateProfileUsecase', () {
    late UpdateProfileUsecase usecase;
    late MockProfileRepository mockRepository;
    late ProfileEntity testProfile;

    setUp(() {
      mockRepository = MockProfileRepository();
      usecase = UpdateProfileUsecase(mockRepository);
      testProfile = ProfileEntity(
        uid: 'user1',
        username: 'testuser',
        displayName: 'Test User',
        email: 'test@example.com',
        bio: 'Test bio',
        avatar: 'https://example.com/avatar.jpg',
        coverPhoto: 'https://example.com/cover.jpg',
        followers: 100,
        following: 50,
        posts: 25,
        isVerified: false,
        isPremium: false,
        age: 25,
        gender: 'male',
        location: 'San Francisco, CA',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    group('Validation', () {
      test('throws exception when username is empty', () async {
        final invalidProfile = testProfile.copyWith(username: '');
        expect(
          () => usecase(invalidProfile),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when displayName is empty', () async {
        final invalidProfile = testProfile.copyWith(displayName: '');
        expect(
          () => usecase(invalidProfile),
          throwsA(isA<Exception>()),
        );
      });

      test('calls repository when profile is valid', () async {
        when(mockRepository.updateProfile(any)).thenAnswer((_) async {});

        await usecase(testProfile);

        verify(mockRepository.updateProfile(testProfile)).called(1);
      });
    });
  });

  group('UpdateProfileFieldUsecase', () {
    late UpdateProfileFieldUsecase usecase;
    late MockProfileRepository mockRepository;

    setUp(() {
      mockRepository = MockProfileRepository();
      usecase = UpdateProfileFieldUsecase(mockRepository);
    });

    group('Validation', () {
      test('throws exception when username field is empty', () async {
        expect(
          () => usecase('user1', 'username', ''),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when displayName field is empty', () async {
        expect(
          () => usecase('user1', 'displayName', ''),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when age is less than 18', () async {
        expect(
          () => usecase('user1', 'age', 17),
          throwsA(isA<Exception>()),
        );
      });

      test('allows age of 18 or greater', () async {
        when(mockRepository.updateProfileField(any, any, any))
            .thenAnswer((_) async {});

        await usecase('user1', 'age', 18);

        verify(mockRepository.updateProfileField('user1', 'age', 18)).called(1);
      });

      test('calls repository when field update is valid', () async {
        when(mockRepository.updateProfileField(any, any, any))
            .thenAnswer((_) async {});

        await usecase('user1', 'bio', 'New bio');

        verify(mockRepository.updateProfileField('user1', 'bio', 'New bio'))
            .called(1);
      });
    });
  });
}
