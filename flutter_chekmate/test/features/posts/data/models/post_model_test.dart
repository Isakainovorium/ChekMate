import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/posts/data/models/post_model.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostModel', () {
    late PostModel testModel;
    late DateTime testDate;
    late Map<String, dynamic> testJson;

    setUp(() {
      testDate = DateTime(2025, 10, 17);
      testModel = PostModel(
        id: 'post1',
        userId: 'user1',
        username: 'Test User',
        userAvatar: 'https://example.com/avatar.jpg',
        content: 'Test post content',
        images: const ['https://example.com/image1.jpg'],
        likes: 2,
        comments: 10,
        shares: 5,
        cheks: 0,
        likedBy: const ['user2', 'user3'],
        bookmarkedBy: const ['user2'],
        tags: const ['test', 'flutter'],
        location: 'San Francisco, CA',
        createdAt: testDate,
        updatedAt: testDate,
        isVerified: false,
      );

      testJson = {
        'id': 'post1',
        'userId': 'user1',
        'username': 'Test User',
        'userAvatar': 'https://example.com/avatar.jpg',
        'content': 'Test post content',
        'images': ['https://example.com/image1.jpg'],
        'videoUrl': null,
        'thumbnailUrl': null,
        'likes': 2,
        'comments': 10,
        'shares': 5,
        'cheks': 0,
        'likedBy': ['user2', 'user3'],
        'bookmarkedBy': ['user2'],
        'tags': ['test', 'flutter'],
        'location': 'San Francisco, CA',
        'createdAt': Timestamp.fromDate(testDate),
        'updatedAt': Timestamp.fromDate(testDate),
        'isVerified': false,
      };
    });

    group('Serialization', () {
      test('fromJson creates correct model', () {
        final model = PostModel.fromJson(testJson);

        expect(model.id, 'post1');
        expect(model.userId, 'user1');
        expect(model.username, 'Test User');
        expect(model.userAvatar, 'https://example.com/avatar.jpg');
        expect(model.content, 'Test post content');
        expect(model.images, ['https://example.com/image1.jpg']);
        expect(model.videoUrl, null);
        expect(model.thumbnailUrl, null);
        expect(model.likes, 2);
        expect(model.likedBy, ['user2', 'user3']);
        expect(model.bookmarkedBy, ['user2']);
        expect(model.shares, 5);
        expect(model.comments, 10);
        expect(model.tags, ['test', 'flutter']);
        expect(model.location, 'San Francisco, CA');
        expect(model.createdAt, testDate);
        expect(model.updatedAt, testDate);
      });

      test('toJson creates correct map', () {
        final json = testModel.toJson();

        expect(json['id'], 'post1');
        expect(json['userId'], 'user1');
        expect(json['username'], 'Test User');
        expect(json['userAvatar'], 'https://example.com/avatar.jpg');
        expect(json['content'], 'Test post content');
        expect(json['images'], ['https://example.com/image1.jpg']);
        expect(json['videoUrl'], null);
        expect(json['thumbnailUrl'], null);
        expect(json['likes'], 2);
        expect(json['likedBy'], ['user2', 'user3']);
        expect(json['bookmarkedBy'], ['user2']);
        expect(json['shares'], 5);
        expect(json['comments'], 10);
        expect(json['cheks'], 0);
        expect(json['tags'], ['test', 'flutter']);
        expect(json['location'], 'San Francisco, CA');
        expect(json['createdAt'], isA<Timestamp>());
        expect(json['updatedAt'], isA<Timestamp>());
      });

      test('toFirestore excludes id field', () {
        final firestoreData = testModel.toFirestore();

        expect(firestoreData.containsKey('id'), false);
        expect(firestoreData['userId'], 'user1');
        expect(firestoreData['content'], 'Test post content');
      });

      test('fromJson handles missing optional fields', () {
        final minimalJson = {
          'id': 'post1',
          'userId': 'user1',
          'username': 'Test User',
          'userAvatar': 'https://example.com/avatar.jpg',
          'content': 'Test content',
          'images': <String>[],
          'likes': 0,
          'comments': 0,
          'shares': 0,
          'cheks': 0,
          'likedBy': <String>[],
          'bookmarkedBy': <String>[],
          'tags': <String>[],
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
          'isVerified': false,
        };

        final model = PostModel.fromJson(minimalJson);

        expect(model.id, 'post1');
        expect(model.videoUrl, null);
        expect(model.thumbnailUrl, null);
        expect(model.location, null);
        expect(model.images, isEmpty);
        expect(model.likes, 0);
        expect(model.likedBy, isEmpty);
        expect(model.bookmarkedBy, isEmpty);
        expect(model.tags, isEmpty);
      });
    });

    group('Entity Conversion', () {
      test('toEntity creates correct PostEntity', () {
        final entity = testModel.toEntity();

        expect(entity, isA<PostEntity>());
        expect(entity.id, testModel.id);
        expect(entity.userId, testModel.userId);
        expect(entity.username, testModel.username);
        expect(entity.content, testModel.content);
        expect(entity.images, testModel.images);
        expect(entity.likes, testModel.likes);
        expect(entity.likedBy, testModel.likedBy);
        expect(entity.bookmarkedBy, testModel.bookmarkedBy);
      });

      test('fromEntity creates correct PostModel', () {
        final entity = PostEntity(
          id: 'post1',
          userId: 'user1',
          username: 'Test User',
          userAvatar: 'https://example.com/avatar.jpg',
          content: 'Test content',
          images: const ['image1.jpg'],
          likes: 1,
          comments: 0,
          shares: 0,
          cheks: 0,
          likedBy: const ['user2'],
          bookmarkedBy: const <String>[],
          tags: const ['test'],
          createdAt: testDate,
          updatedAt: testDate,
          isVerified: false,
        );

        final model = PostModel.fromEntity(entity);

        expect(model, isA<PostModel>());
        expect(model.id, entity.id);
        expect(model.userId, entity.userId);
        expect(model.username, entity.username);
        expect(model.content, entity.content);
        expect(model.images, entity.images);
        expect(model.likes, entity.likes);
        expect(model.likedBy, entity.likedBy);
        expect(model.bookmarkedBy, entity.bookmarkedBy);
      });

      test('toEntity and fromEntity are inverse operations', () {
        final entity = testModel.toEntity();
        final model = PostModel.fromEntity(entity);

        expect(model.id, testModel.id);
        expect(model.userId, testModel.userId);
        expect(model.content, testModel.content);
        expect(model.images, testModel.images);
        expect(model.likes, testModel.likes);
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated fields', () {
        final updated = testModel.copyWith(
          content: 'Updated content',
          likedBy: const ['user1', 'user2', 'user3'],
        );

        expect(updated.id, testModel.id);
        expect(updated.content, 'Updated content');
        expect(updated.likedBy, ['user1', 'user2', 'user3']);
        expect(updated.username, testModel.username);
      });

      test('copyWith preserves original when no fields provided', () {
        final copied = testModel.copyWith();

        expect(copied.id, testModel.id);
        expect(copied.content, testModel.content);
        expect(copied.likes, testModel.likes);
      });
    });

    group('Inheritance', () {
      test('PostModel extends PostEntity', () {
        expect(testModel, isA<PostEntity>());
      });

      test('PostModel inherits business logic methods', () {
        expect(testModel.hasMedia, true);
        expect(testModel.hasImages, true);
        expect(testModel.canEdit('user1'), true);
        expect(testModel.canEdit('user2'), false);
      });
    });
  });
}
