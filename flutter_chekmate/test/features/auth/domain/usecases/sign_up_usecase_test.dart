import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_chekmate/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpUseCase(mockRepository);
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

  group('SignUpUseCase', () {
    test('should sign up user with valid credentials', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'Password123';
      const username = 'testuser';
      const displayName = 'Test User';

      when(() => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
          ),).thenAnswer((_) async => testUser);

      // Act
      final result = await useCase(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      // Assert
      expect(result, testUser);
      verify(() => mockRepository.signUpWithEmail(
            email: 'test@example.com',
            password: password,
            username: 'testuser',
            displayName: 'Test User',
          ),).called(1);
    });

    test('should lowercase email and username', () async {
      // Arrange
      const email = 'TEST@EXAMPLE.COM';
      const password = 'Password123';
      const username = 'TestUser';
      const displayName = 'Test User';

      when(() => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
          ),).thenAnswer((_) async => testUser);

      // Act
      await useCase(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      // Assert
      verify(() => mockRepository.signUpWithEmail(
            email: 'test@example.com',
            password: password,
            username: 'testuser',
            displayName: 'Test User',
          ),).called(1);
    });

    group('email validation', () {
      test('should throw exception for invalid email format', () async {
        // Arrange
        const invalidEmail = 'invalid-email';
        const password = 'Password123';
        const username = 'testuser';
        const displayName = 'Test User';

        // Act & Assert
        expect(
          () => useCase(
            email: invalidEmail,
            password: password,
            username: username,
            displayName: displayName,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('password validation', () {
      test('should throw exception for password less than 8 characters',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Pass12'; // Only 6 characters
        const username = 'testuser';
        const displayName = 'Test User';

        // Act & Assert
        expect(
          () => useCase(
            email: email,
            password: password,
            username: username,
            displayName: displayName,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception for password without uppercase letter',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123'; // No uppercase
        const username = 'testuser';
        const displayName = 'Test User';

        // Act & Assert
        expect(
          () => useCase(
            email: email,
            password: password,
            username: username,
            displayName: displayName,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception for password without lowercase letter',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'PASSWORD123'; // No lowercase
        const username = 'testuser';
        const displayName = 'Test User';

        // Act & Assert
        expect(
          () => useCase(
            email: email,
            password: password,
            username: username,
            displayName: displayName,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception for password without digit', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'PasswordABC'; // No digit
        const username = 'testuser';
        const displayName = 'Test User';

        // Act & Assert
        expect(
          () => useCase(
            email: email,
            password: password,
            username: username,
            displayName: displayName,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should accept password with all requirements', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Password123'; // 8+ chars, uppercase, lowercase, digit
        const username = 'testuser';
        const displayName = 'Test User';

        when(() => mockRepository.signUpWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
              displayName: any(named: 'displayName'),
            ),).thenAnswer((_) async => testUser);

        // Act
        await useCase(
          email: email,
          password: password,
          username: username,
          displayName: displayName,
        );

        // Assert
        verify(() => mockRepository.signUpWithEmail(
              email: any(named: 'email'),
              password: password,
              username: any(named: 'username'),
              displayName: any(named: 'displayName'),
            ),).called(1);
      });
    });

    group('username validation', () {
      test('should throw exception for username less than 3 characters',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Password123';
        const username = 'ab'; // Only 2 characters
        const displayName = 'Test User';

        // Act & Assert
        expect(
          () => useCase(
            email: email,
            password: password,
            username: username,
            displayName: displayName,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception for username with special characters',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Password123';
        const username = 'test@user'; // Contains @
        const displayName = 'Test User';

        // Act & Assert
        expect(
          () => useCase(
            email: email,
            password: password,
            username: username,
            displayName: displayName,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should accept username with underscores', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Password123';
        const username = 'test_user_123';
        const displayName = 'Test User';

        when(() => mockRepository.signUpWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
              displayName: any(named: 'displayName'),
            ),).thenAnswer((_) async => testUser);

        // Act
        await useCase(
          email: email,
          password: password,
          username: username,
          displayName: displayName,
        );

        // Assert
        verify(() => mockRepository.signUpWithEmail(
              email: any(named: 'email'),
              password: password,
              username: 'test_user_123',
              displayName: any(named: 'displayName'),
            ),).called(1);
      });

      test('should accept username with alphanumeric characters', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Password123';
        const username = 'testuser123';
        const displayName = 'Test User';

        when(() => mockRepository.signUpWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
              displayName: any(named: 'displayName'),
            ),).thenAnswer((_) async => testUser);

        // Act
        await useCase(
          email: email,
          password: password,
          username: username,
          displayName: displayName,
        );

        // Assert
        verify(() => mockRepository.signUpWithEmail(
              email: any(named: 'email'),
              password: password,
              username: 'testuser123',
              displayName: any(named: 'displayName'),
            ),).called(1);
      });
    });

    group('displayName validation', () {
      test('should throw exception for empty displayName', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Password123';
        const username = 'testuser';
        const displayName = '';

        // Act & Assert
        expect(
          () => useCase(
            email: email,
            password: password,
            username: username,
            displayName: displayName,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should accept non-empty displayName', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'Password123';
        const username = 'testuser';
        const displayName = 'Test User';

        when(() => mockRepository.signUpWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
              displayName: any(named: 'displayName'),
            ),).thenAnswer((_) async => testUser);

        // Act
        await useCase(
          email: email,
          password: password,
          username: username,
          displayName: displayName,
        );

        // Assert
        verify(() => mockRepository.signUpWithEmail(
              email: any(named: 'email'),
              password: password,
              username: any(named: 'username'),
              displayName: 'Test User',
            ),).called(1);
      });
    });

    test('should propagate repository exceptions', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'Password123';
      const username = 'testuser';
      const displayName = 'Test User';
      final exception = Exception('Sign up failed');

      when(() => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
          ),).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(
          email: email,
          password: password,
          username: username,
          displayName: displayName,
        ),
        throwsA(exception),
      );
    });
  });
}
