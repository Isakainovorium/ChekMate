import 'package:flutter_chekmate/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileEntity', () {
    late ProfileEntity testProfile;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 10, 17, 12);
      testProfile = ProfileEntity(
        uid: 'user1',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'Test bio',
        avatar: 'https://example.com/avatar.jpg',
        coverPhoto: 'https://example.com/cover.jpg',
        followers: 100,
        following: 50,
        posts: 10,
        isVerified: true,
        isPremium: false,
        createdAt: testDate,
        updatedAt: testDate,
        email: 'test@example.com',
        age: 25,
        gender: 'male',
        location: 'San Francisco, CA',
        interests: const ['coding', 'music'],
        voicePrompts: [
          VoicePromptEntity(
            id: 'vp1',
            question: 'What makes you happy?',
            audioUrl: 'https://example.com/vp1.mp3',
            duration: 30,
            createdAt: testDate,
          ),
        ],
        videoIntroUrl: 'https://example.com/intro.mp4',
        stats: const ProfileStats(
          totalPosts: 10,
          totalLikes: 50,
          totalComments: 20,
          totalShares: 5,
          totalViews: 100,
        ),
      );
    });

    group('Business Logic Methods', () {
      test('isComplete returns true when all required fields are filled', () {
        expect(testProfile.isComplete, true);
      });

      test('isComplete returns false when bio is missing', () {
        final incompleteProfile = testProfile.copyWith(bio: '');
        expect(incompleteProfile.isComplete, false);
      });

      test('isComplete returns false when avatar is missing', () {
        final incompleteProfile = testProfile.copyWith(avatar: '');
        expect(incompleteProfile.isComplete, false);
      });

      test('isComplete returns false when age is missing', () {
        final incompleteProfile = testProfile.copyWith();
        expect(incompleteProfile.isComplete, false);
      });

      test('isComplete returns false when gender is missing', () {
        final incompleteProfile = testProfile.copyWith(gender: '');
        expect(incompleteProfile.isComplete, false);
      });

      test('isComplete returns false when location is missing', () {
        final incompleteProfile = testProfile.copyWith(location: '');
        expect(incompleteProfile.isComplete, false);
      });

      test('hasVoicePrompts returns true when voice prompts exist', () {
        expect(testProfile.hasVoicePrompts, true);
      });

      test('hasVoicePrompts returns false when voice prompts are empty', () {
        final noVoiceProfile = testProfile.copyWith(voicePrompts: []);
        expect(noVoiceProfile.hasVoicePrompts, false);
      });

      test('hasVideoIntro returns true when video intro exists', () {
        expect(testProfile.hasVideoIntro, true);
      });

      test('hasVideoIntro returns false when video intro is null', () {
        final noVideoProfile = testProfile.copyWith();
        expect(noVideoProfile.hasVideoIntro, false);
      });

      test('hasVideoIntro returns false when video intro is empty', () {
        final noVideoProfile = testProfile.copyWith(videoIntroUrl: '');
        expect(noVideoProfile.hasVideoIntro, false);
      });

      test('completionPercentage returns 1.0 for complete profile', () {
        expect(testProfile.completionPercentage, 1.0);
      });

      test('completionPercentage returns 0.8 when one field is missing', () {
        final incompleteProfile = testProfile.copyWith(bio: '');
        expect(incompleteProfile.completionPercentage, 0.8);
      });

      test('completionPercentage returns 0.6 when two fields are missing', () {
        final incompleteProfile = testProfile.copyWith(bio: '', avatar: '');
        expect(incompleteProfile.completionPercentage, 0.6);
      });

      test('canBeMessaged returns true for complete profile', () {
        expect(testProfile.canBeMessaged, true);
      });

      test('canBeMessaged returns false for incomplete profile', () {
        final incompleteProfile = testProfile.copyWith(bio: '');
        expect(incompleteProfile.canBeMessaged, false);
      });
    });

    group('ProfileStats', () {
      test('has correct properties', () {
        const stats = ProfileStats(
          totalPosts: 10,
          totalLikes: 50,
          totalComments: 20,
          totalShares: 5,
          totalViews: 100,
        );
        expect(stats.totalPosts, 10);
        expect(stats.totalLikes, 50);
        expect(stats.totalComments, 20);
        expect(stats.totalShares, 5);
        expect(stats.totalViews, 100);
      });

      test('can be created with optional data lists', () {
        const stats = ProfileStats(
          totalPosts: 10,
          totalLikes: 50,
          totalComments: 20,
          totalShares: 10,
          totalViews: 100,
          postsData: [1, 2, 3],
          followersData: [10, 20, 30],
          likesData: [5, 10, 15],
        );
        expect(stats.postsData, [1, 2, 3]);
        expect(stats.followersData, [10, 20, 30]);
        expect(stats.likesData, [5, 10, 15]);
      });
    });

    group('VoicePromptEntity', () {
      test('has correct properties', () {
        final voicePrompt = VoicePromptEntity(
          id: 'vp1',
          question: 'Test question',
          audioUrl: 'https://example.com/audio.mp3',
          duration: 45,
          createdAt: testDate,
        );
        expect(voicePrompt.id, 'vp1');
        expect(voicePrompt.question, 'Test question');
        expect(voicePrompt.audioUrl, 'https://example.com/audio.mp3');
        expect(voicePrompt.duration, 45);
        expect(voicePrompt.createdAt, testDate);
      });

      test('can be created with different durations', () {
        final voicePrompt = VoicePromptEntity(
          id: 'vp1',
          question: 'Test question',
          audioUrl: 'https://example.com/audio.mp3',
          duration: 125,
          createdAt: testDate,
        );
        expect(voicePrompt.duration, 125);
      });
    });

    group('Equality', () {
      test('two profiles with same uid are equal', () {
        final profile1 = testProfile;
        final profile2 = testProfile.copyWith(bio: 'Different bio');
        expect(profile1, equals(profile2));
      });

      test('two profiles with different uids are not equal', () {
        final profile1 = testProfile;
        final profile2 = testProfile.copyWith(uid: 'user2');
        expect(profile1, isNot(equals(profile2)));
      });

      test('hashCode is based on uid', () {
        final profile1 = testProfile;
        final profile2 = testProfile.copyWith(bio: 'Different bio');
        expect(profile1.hashCode, equals(profile2.hashCode));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated fields', () {
        final updatedProfile = testProfile.copyWith(
          bio: 'Updated bio',
          age: 30,
        );

        expect(updatedProfile.uid, testProfile.uid);
        expect(updatedProfile.bio, 'Updated bio');
        expect(updatedProfile.age, 30);
        expect(updatedProfile.username, testProfile.username);
      });

      test('copyWith preserves original when no fields provided', () {
        final copiedProfile = testProfile.copyWith();

        expect(copiedProfile.uid, testProfile.uid);
        expect(copiedProfile.bio, testProfile.bio);
        expect(copiedProfile.age, testProfile.age);
      });
    });

    group('ToString', () {
      test('toString returns correct format', () {
        final string = testProfile.toString();
        expect(string, contains('ProfileEntity'));
        expect(string, contains('user1'));
        expect(string, contains('testuser'));
      });
    });
  });
}
