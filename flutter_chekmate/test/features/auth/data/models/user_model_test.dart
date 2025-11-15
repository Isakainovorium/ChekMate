import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/auth/data/models/user_model.dart';
import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    late UserModel testUserModel;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025);
      testUserModel = UserModel(
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

    group('fromEntity', () {
      test('should create UserModel from UserEntity', () {
        // Arrange
        final entity = UserEntity(
          uid: 'test-uid',
          email: 'test@example.com',
          username: 'testuser',
          displayName: 'Test User',
          bio: 'Bio',
          avatar: 'avatar.jpg',
          coverPhoto: 'cover.jpg',
          followers: 10,
          following: 5,
          posts: 3,
          isVerified: true,
          isPremium: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        // Act
        final model = UserModel.fromEntity(entity);

        // Assert
        expect(model.uid, entity.uid);
        expect(model.email, entity.email);
        expect(model.username, entity.username);
        expect(model.displayName, entity.displayName);
        expect(model.bio, entity.bio);
        expect(model.avatar, entity.avatar);
        expect(model.coverPhoto, entity.coverPhoto);
        expect(model.followers, entity.followers);
        expect(model.following, entity.following);
        expect(model.posts, entity.posts);
        expect(model.isVerified, entity.isVerified);
        expect(model.isPremium, entity.isPremium);
        expect(model.createdAt, entity.createdAt);
        expect(model.updatedAt, entity.updatedAt);
      });
    });

    group('toJson', () {
      test('should convert UserModel to JSON map', () {
        // Act
        final json = testUserModel.toJson();

        // Assert
        expect(json['uid'], 'test-uid-123');
        expect(json['email'], 'test@example.com');
        expect(json['username'], 'testuser');
        expect(json['displayName'], 'Test User');
        expect(json['bio'], 'Test bio');
        expect(json['avatar'], 'https://example.com/avatar.jpg');
        expect(json['coverPhoto'], 'https://example.com/cover.jpg');
        expect(json['followers'], 100);
        expect(json['following'], 50);
        expect(json['posts'], 25);
        expect(json['isVerified'], true);
        expect(json['isPremium'], false);
        expect(json['createdAt'], isA<Timestamp>());
        expect(json['updatedAt'], isA<Timestamp>());
        expect(json['location'], 'San Francisco, CA');
        expect(json['age'], 25);
        expect(json['gender'], 'male');
        expect(json['interests'], ['coding', 'music', 'travel']);
      });

      test('should exclude null optional fields from JSON', () {
        // Arrange
        final modelWithoutOptionals = UserModel(
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
          createdAt: testDate,
          updatedAt: testDate,
        );

        // Act
        final json = modelWithoutOptionals.toJson();

        // Assert
        expect(json.containsKey('location'), false);
        expect(json.containsKey('age'), false);
        expect(json.containsKey('gender'), false);
        expect(json.containsKey('interests'), false);
      });
    });

    group('fromJson', () {
      test('should create UserModel from JSON map with Timestamp', () {
        // Arrange
        final json = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'username': 'testuser',
          'displayName': 'Test User',
          'bio': 'Bio',
          'avatar': 'avatar.jpg',
          'coverPhoto': 'cover.jpg',
          'followers': 10,
          'following': 5,
          'posts': 3,
          'isVerified': true,
          'isPremium': false,
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
          'location': 'SF',
          'age': 25,
          'gender': 'male',
          'interests': ['coding', 'music'],
        };

        // Act
        final model = UserModel.fromJson(json);

        // Assert
        expect(model.uid, 'test-uid');
        expect(model.email, 'test@example.com');
        expect(model.username, 'testuser');
        expect(model.displayName, 'Test User');
        expect(model.location, 'SF');
        expect(model.age, 25);
        expect(model.gender, 'male');
        expect(model.interests, ['coding', 'music']);
      });

      test('should create UserModel from JSON map with DateTime string', () {
        // Arrange
        final json = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'username': 'testuser',
          'displayName': 'Test User',
          'bio': '',
          'avatar': '',
          'coverPhoto': '',
          'followers': 0,
          'following': 0,
          'posts': 0,
          'isVerified': false,
          'isPremium': false,
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
        };

        // Act
        final model = UserModel.fromJson(json);

        // Assert
        expect(model.uid, 'test-uid');
        expect(model.createdAt, testDate);
        expect(model.updatedAt, testDate);
      });

      test('should handle missing optional fields', () {
        // Arrange
        final json = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'username': 'testuser',
          'displayName': 'Test User',
          'bio': '',
          'avatar': '',
          'coverPhoto': '',
          'followers': 0,
          'following': 0,
          'posts': 0,
          'isVerified': false,
          'isPremium': false,
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
        };

        // Act
        final model = UserModel.fromJson(json);

        // Assert
        expect(model.location, null);
        expect(model.age, null);
        expect(model.gender, null);
        expect(model.interests, null);
      });
    });

    group('toEntity', () {
      test('should convert UserModel to UserEntity', () {
        // Act
        final entity = testUserModel.toEntity();

        // Assert
        expect(entity, isA<UserEntity>());
        expect(entity.uid, testUserModel.uid);
        expect(entity.email, testUserModel.email);
        expect(entity.username, testUserModel.username);
        expect(entity.displayName, testUserModel.displayName);
        expect(entity.bio, testUserModel.bio);
        expect(entity.avatar, testUserModel.avatar);
        expect(entity.coverPhoto, testUserModel.coverPhoto);
        expect(entity.followers, testUserModel.followers);
        expect(entity.following, testUserModel.following);
        expect(entity.posts, testUserModel.posts);
        expect(entity.isVerified, testUserModel.isVerified);
        expect(entity.isPremium, testUserModel.isPremium);
        expect(entity.createdAt, testUserModel.createdAt);
        expect(entity.updatedAt, testUserModel.updatedAt);
        expect(entity.location, testUserModel.location);
        expect(entity.age, testUserModel.age);
        expect(entity.gender, testUserModel.gender);
        expect(entity.interests, testUserModel.interests);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        // Act
        final updatedModel = testUserModel.copyWith(
          displayName: 'Updated Name',
          followers: 200,
        );

        // Assert
        expect(updatedModel.displayName, 'Updated Name');
        expect(updatedModel.followers, 200);
        // Other fields should remain the same
        expect(updatedModel.uid, testUserModel.uid);
        expect(updatedModel.email, testUserModel.email);
        expect(updatedModel.username, testUserModel.username);
      });

      test('should keep original values when no parameters provided', () {
        // Act
        final copiedModel = testUserModel.copyWith();

        // Assert
        expect(copiedModel.uid, testUserModel.uid);
        expect(copiedModel.email, testUserModel.email);
        expect(copiedModel.username, testUserModel.username);
        expect(copiedModel.displayName, testUserModel.displayName);
      });
    });

    group('inheritance', () {
      test('should extend UserEntity', () {
        expect(testUserModel, isA<UserEntity>());
      });

      test('should have all UserEntity business logic methods', () {
        expect(testUserModel.hasCompleteProfile, true);
        expect(testUserModel.canSendMessages, true);
        expect(testUserModel.canCreatePosts, true);
        expect(testUserModel.displayNameOrUsername, 'Test User');
      });
    });
  });
}

