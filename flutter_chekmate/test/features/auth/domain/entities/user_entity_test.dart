import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserEntity', () {
    late UserEntity testUser;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025);
      testUser = UserEntity(
        uid: 'test-uid-123',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'Test bio',
        avatar: 'https://example.com/avatar.jpg',
       
        coverPhoto: 'https://example.com/cover.jpg',
        followers: 100,
        following: 50,
        posts: 25,
        isVerified: true,
        isPremium: false,
        createdAt: testDate,
        updatedAt: testDate,
        location: 'San Francisco, CA',
        age: 25,
        gender: 'male',
        interests: ['coding', 'music', 'travel'],
      );
    });

    test('should create UserEntity with all fields', () {
      expect(testUser.uid, 'test-uid-123');
      expect(testUser.email, 'test@example.com');
      expect(testUser.username, 'testuser');
      expect(testUser.displayName, 'Test User');
      expect(testUser.bio, 'Test bio');
      expect(testUser.avatar, 'https://example.com/avatar.jpg');
      expect(testUser.coverPhoto, 'https://example.com/cover.jpg');
      expect(testUser.followers, 100);
      expect(testUser.following, 50);
      expect(testUser.posts, 25);
      expect(testUser.isVerified, true);
      expect(testUser.isPremium, false);
      expect(testUser.createdAt, testDate);
      expect(testUser.updatedAt, testDate);
      expect(testUser.location, 'San Francisco, CA');
      expect(testUser.age, 25);
      expect(testUser.gender, 'male');
      expect(testUser.interests, ['coding', 'music', 'travel']);
    });

    group('hasCompleteProfile', () {
      test('should return true when profile is complete', () {
        expect(testUser.hasCompleteProfile, true);
      });

      test('should return false when displayName is empty', () {
        final incompleteUser = testUser.copyWith(displayName: '');
        expect(incompleteUser.hasCompleteProfile, false);
      });

      test('should return false when bio is empty', () {
        final incompleteUser = testUser.copyWith(bio: '');
        expect(incompleteUser.hasCompleteProfile, false);
      });

      test('should return false when avatar is empty', () {
        final incompleteUser = testUser.copyWith(avatar: '');
        expect(incompleteUser.hasCompleteProfile, false);
      });

      test('should return false when location is null', () {
        final incompleteUser = UserEntity(
          uid: testUser.uid,
          email: testUser.email,
          username: testUser.username,
          displayName: testUser.displayName,
          bio: testUser.bio,
          avatar: testUser.avatar,
          coverPhoto: testUser.coverPhoto,
          followers: testUser.followers,
          following: testUser.following,
          posts: testUser.posts,
          isVerified: testUser.isVerified,
          isPremium: testUser.isPremium,
          createdAt: testUser.createdAt,
          updatedAt: testUser.updatedAt,
          age: testUser.age,
          gender: testUser.gender,
          interests: testUser.interests,
        );
        expect(incompleteUser.hasCompleteProfile, false);
      });

      test('should return false when interests is null', () {
        final incompleteUser = UserEntity(
          uid: testUser.uid,
          email: testUser.email,
          username: testUser.username,
          displayName: testUser.displayName,
          bio: testUser.bio,
          avatar: testUser.avatar,
          coverPhoto: testUser.coverPhoto,
          followers: testUser.followers,
          following: testUser.following,
          posts: testUser.posts,
          isVerified: testUser.isVerified,
          isPremium: testUser.isPremium,
          createdAt: testUser.createdAt,
          updatedAt: testUser.updatedAt,
          location: testUser.location,
          age: testUser.age,
          gender: testUser.gender,
        );
        expect(incompleteUser.hasCompleteProfile, false);
      });

      test('should return false when interests is empty', () {
        final incompleteUser = testUser.copyWith(interests: []);
        expect(incompleteUser.hasCompleteProfile, false);
      });
    });

    group('canSendMessages', () {
      test('should return true when user is verified', () {
        final verifiedUser = testUser.copyWith(isVerified: true, isPremium: false);
        expect(verifiedUser.canSendMessages, true);
      });

      test('should return true when user is premium', () {
        final premiumUser = testUser.copyWith(isVerified: false, isPremium: true);
        expect(premiumUser.canSendMessages, true);
      });

      test('should return true when user is both verified and premium', () {
        final superUser = testUser.copyWith(isVerified: true, isPremium: true);
        expect(superUser.canSendMessages, true);
      });

      test('should return false when user is neither verified nor premium', () {
        final basicUser = testUser.copyWith(isVerified: false, isPremium: false);
        expect(basicUser.canSendMessages, false);
      });
    });

    group('canCreatePosts', () {
      test('should return true when profile is complete', () {
        expect(testUser.canCreatePosts, true);
      });

      test('should return false when profile is incomplete', () {
        final incompleteUser = testUser.copyWith(bio: '');
        expect(incompleteUser.canCreatePosts, false);
      });
    });

    group('displayNameOrUsername', () {
      test('should return displayName when it is not empty', () {
        expect(testUser.displayNameOrUsername, 'Test User');
      });

      test('should return username when displayName is empty', () {
        final userWithoutDisplayName = testUser.copyWith(displayName: '');
        expect(userWithoutDisplayName.displayNameOrUsername, 'testuser');
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final updatedUser = testUser.copyWith(
          displayName: 'Updated Name',
          followers: 200,
        );

        expect(updatedUser.displayName, 'Updated Name');
        expect(updatedUser.followers, 200);
        // Other fields should remain the same
        expect(updatedUser.uid, testUser.uid);
        expect(updatedUser.email, testUser.email);
        expect(updatedUser.username, testUser.username);
      });

      test('should keep original values when no parameters provided', () {
        final copiedUser = testUser.copyWith();

        expect(copiedUser.uid, testUser.uid);
        expect(copiedUser.email, testUser.email);
        expect(copiedUser.username, testUser.username);
        expect(copiedUser.displayName, testUser.displayName);
      });
    });

    group('equality', () {
      test('should be equal when uids are the same', () {
        final user1 = testUser;
        final user2 = testUser.copyWith(displayName: 'Different Name');

        expect(user1 == user2, true);
        expect(user1.hashCode, user2.hashCode);
      });

      test('should not be equal when uids are different', () {
        final user1 = testUser;
        final user2 = testUser.copyWith(uid: 'different-uid');

        expect(user1 == user2, false);
        expect(user1.hashCode == user2.hashCode, false);
      });
    });

    group('toString', () {
      test('should return string representation', () {
        final string = testUser.toString();

        expect(string, contains('UserEntity'));
        expect(string, contains('test-uid-123'));
        expect(string, contains('testuser'));
        expect(string, contains('test@example.com'));
      });
    });
  });
}

