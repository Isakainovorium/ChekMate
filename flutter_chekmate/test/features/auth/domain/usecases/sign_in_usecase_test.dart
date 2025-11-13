import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_chekmate/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  final testUser = UserEntity(
    uid: 'test-uid',
    email: 'test@example.com',
    username: 'testuser',
    displayName: 'Test User',
    bio: '',
    avatar: '',
    coverPhoto: '',
    followers: 0,
    following: 0,
    posts: 0,
    isVerified: false,
    isPremium: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('SignInUseCase', () {
    test('should sign in user with valid email and password', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenAnswer((_) async => testUser);

      // Act
      final result = await useCase(email: email, password: password);

      // Assert
      expect(result, testUser);
      verify(() => mockRepository.signInWithEmail(
            email: 'test@example.com', // Should be trimmed and lowercased
            password: password,
          ),).called(1);
    });

    test('should lowercase email before signing in', () async {
      // Arrange
      const email = 'TEST@EXAMPLE.COM';
      const password = 'password123';

      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenAnswer((_) async => testUser);

      // Act
      await useCase(email: email, password: password);

      // Assert
      verify(() => mockRepository.signInWithEmail(
            email: 'test@example.com',
            password: password,
          ),).called(1);
    });

    group('email validation', () {
      test('should throw exception for invalid email format', () async {
        // Arrange
        const invalidEmail = 'invalid-email';
        const password = 'password123';

        // Act & Assert
        expect(
          () => useCase(email: invalidEmail, password: password),
          throwsA(isA<Exception>()),
        );

        verifyNever(() => mockRepository.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),);
      });

      test('should throw exception for email without @', () async {
        // Arrange
        const invalidEmail = 'testexample.com';
        const password = 'password123';

        // Act & Assert
        expect(
          () => useCase(email: invalidEmail, password: password),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception for email without domain', () async {
        // Arrange
        const invalidEmail = 'test@';
        const password = 'password123';

        // Act & Assert
        expect(
          () => useCase(email: invalidEmail, password: password),
          throwsA(isA<Exception>()),
        );
      });

      test('should accept valid email formats', () async {
        // Arrange
        final validEmails = [
          'test@example.com',
          'user.name@example.com',
          'user+tag@example.co.uk',
          'test123@test-domain.com',
        ];
        const password = 'password123';

        when(() => mockRepository.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),).thenAnswer((_) async => testUser);

        // Act & Assert
        for (final email in validEmails) {
          await useCase(email: email, password: password);
        }

        verify(() => mockRepository.signInWithEmail(
              email: any(named: 'email'),
              password: password,
            ),).called(validEmails.length);
      });
    });

    group('password validation', () {
      test('should throw exception for password less than 6 characters',
          () async {
        // Arrange
        const email = 'test@example.com';
        const shortPassword = '12345';

        // Act & Assert
        expect(
          () => useCase(email: email, password: shortPassword),
          throwsA(isA<Exception>()),
        );

        verifyNever(() => mockRepository.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),);
      });

      test('should accept password with exactly 6 characters', () async {
        // Arrange
        const email = 'test@example.com';
        const password = '123456';

        when(() => mockRepository.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),).thenAnswer((_) async => testUser);

        // Act
        await useCase(email: email, password: password);

        // Assert
        verify(() => mockRepository.signInWithEmail(
              email: any(named: 'email'),
              password: password,
            ),).called(1);
      });

      test('should accept password with more than 6 characters', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'verylongpassword123';

        when(() => mockRepository.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),).thenAnswer((_) async => testUser);

        // Act
        await useCase(email: email, password: password);

        // Assert
        verify(() => mockRepository.signInWithEmail(
              email: any(named: 'email'),
              password: password,
            ),).called(1);
      });
    });

    test('should propagate repository exceptions', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final exception = Exception('Sign in failed');

      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(email: email, password: password),
        throwsA(exception),
      );
    });
  });
}
