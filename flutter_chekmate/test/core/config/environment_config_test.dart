import 'package:flutter_chekmate/core/config/environment_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Environment', () {
    test('should have correct values', () {
      expect(Environment.development.name, 'development');
      expect(Environment.staging.name, 'staging');
      expect(Environment.production.name, 'production');
    });
  });

  group('EnvironmentConfig', () {
    group('development', () {
      late EnvironmentConfig config;

      setUp(() {
        config = EnvironmentConfig.development;
      });

      test('should have correct environment', () {
        expect(config.environment, Environment.development);
      });

      test('should have development API URL', () {
        expect(config.apiBaseUrl, 'https://dev-api.chekmate.app');
      });

      test('should have debug logging enabled', () {
        expect(config.enableDebugLogging, true);
      });

      test('should have analytics disabled', () {
        expect(config.enableAnalytics, false);
      });

      test('should have crashlytics disabled', () {
        expect(config.enableCrashlytics, false);
      });

      test('should have correct timeout', () {
        expect(config.apiTimeout, 30000); // 30 seconds in milliseconds
      });
    });

    group('staging', () {
      late EnvironmentConfig config;

      setUp(() {
        config = EnvironmentConfig.staging;
      });

      test('should have correct environment', () {
        expect(config.environment, Environment.staging);
      });

      test('should have staging API URL', () {
        expect(config.apiBaseUrl, 'https://staging-api.chekmate.app');
      });

      test('should have debug logging enabled', () {
        expect(config.enableDebugLogging, true);
      });

      test('should have analytics enabled', () {
        expect(config.enableAnalytics, true);
      });

      test('should have crashlytics enabled', () {
        expect(config.enableCrashlytics, true);
      });

      test('should have correct timeout', () {
        expect(config.apiTimeout, 20000); // 20 seconds in milliseconds
      });
    });

    group('production', () {
      late EnvironmentConfig config;

      setUp(() {
        config = EnvironmentConfig.production;
      });

      test('should have correct environment', () {
        expect(config.environment, Environment.production);
      });

      test('should have production API URL', () {
        expect(config.apiBaseUrl, 'https://api.chekmate.app');
      });

      test('should have debug logging disabled', () {
        expect(config.enableDebugLogging, false);
      });

      test('should have analytics enabled', () {
        expect(config.enableAnalytics, true);
      });

      test('should have crashlytics enabled', () {
        expect(config.enableCrashlytics, true);
      });

      test('should have correct timeout', () {
        expect(config.apiTimeout, 15000); // 15 seconds in milliseconds
      });
    });

    group('isDevelopment', () {
      test('should return true for development environment', () {
        expect(EnvironmentConfig.development.isDevelopment, true);
      });

      test('should return false for non-development environments', () {
        expect(EnvironmentConfig.staging.isDevelopment, false);
        expect(EnvironmentConfig.production.isDevelopment, false);
      });
    });

    group('isProduction', () {
      test('should return true for production environment', () {
        expect(EnvironmentConfig.production.isProduction, true);
      });

      test('should return false for non-production environments', () {
        expect(EnvironmentConfig.development.isProduction, false);
        expect(EnvironmentConfig.staging.isProduction, false);
      });
    });
  });

  group('AppConfig', () {
    test('should have correct app name', () {
      expect(AppConfig.appName, 'ChekMate');
    });

    test('should have correct app version', () {
      expect(AppConfig.appVersion, '1.0.0');
    });

    test('should have correct build number', () {
      expect(AppConfig.appBuildNumber, 1);
    });

    test('should have correct max photo upload count', () {
      expect(AppConfig.maxPhotoUploadCount, 10);
    });

    test('should have correct max video length', () {
      expect(AppConfig.maxVideoLengthSeconds, 60);
    });

    test('should have correct max voice message duration', () {
      expect(AppConfig.maxVoiceMessageSeconds, 60);
    });

    test('should have correct max image size', () {
      expect(AppConfig.maxImageSizeMB, 10);
    });

    test('should have correct max video size', () {
      expect(AppConfig.maxVideoSizeMB, 100);
    });

    test('should have correct default page size', () {
      expect(AppConfig.defaultPageSize, 20);
    });

    test('should have correct max page size', () {
      expect(AppConfig.maxPageSize, 100);
    });

    test('should have feature flags enabled', () {
      expect(AppConfig.enableVoiceMessages, true);
      expect(AppConfig.enableVideoPlayback, true);
      expect(AppConfig.enableMultiPhotoUpload, true);
      expect(AppConfig.enableLocationServices, true);
      expect(AppConfig.enablePushNotifications, true);
    });
  });

  group('FirebaseConfig', () {
    test('should have correct users collection name', () {
      expect(FirebaseConfig.usersCollection, 'users');
    });

    test('should have correct posts collection name', () {
      expect(FirebaseConfig.postsCollection, 'posts');
    });

    test('should have correct messages collection name', () {
      expect(FirebaseConfig.messagesCollection, 'messages');
    });

    test('should have correct notifications collection name', () {
      expect(FirebaseConfig.notificationsCollection, 'notifications');
    });

    test('should have correct stories collection name', () {
      expect(FirebaseConfig.storiesCollection, 'stories');
    });

    test('should have correct comments collection name', () {
      expect(FirebaseConfig.commentsCollection, 'comments');
    });

    test('should have correct likes collection name', () {
      expect(FirebaseConfig.likesCollection, 'likes');
    });

    test('should have correct follows collection name', () {
      expect(FirebaseConfig.followsCollection, 'follows');
    });

    test('should have correct profile images storage path', () {
      expect(FirebaseConfig.profileImagesPath, 'profile_images');
    });

    test('should have correct post images storage path', () {
      expect(FirebaseConfig.postImagesPath, 'post_images');
    });

    test('should have correct post videos storage path', () {
      expect(FirebaseConfig.postVideosPath, 'post_videos');
    });

    test('should have correct voice messages storage path', () {
      expect(FirebaseConfig.voiceMessagesPath, 'voice_messages');
    });
  });

  group('ApiEndpoints', () {
    test('should have correct base URL from environment', () {
      expect(ApiEndpoints.baseUrl, contains('chekmate.app'));
    });

    test('should have correct auth endpoints', () {
      expect(ApiEndpoints.login, contains('/auth/login'));
      expect(ApiEndpoints.signup, contains('/auth/signup'));
      expect(ApiEndpoints.logout, contains('/auth/logout'));
      expect(ApiEndpoints.refreshToken, contains('/auth/refresh'));
    });

    test('should have correct user endpoints', () {
      expect(ApiEndpoints.users, contains('/users'));
      expect(ApiEndpoints.currentUser, contains('/users/me'));
    });

    test('should have correct posts endpoints', () {
      expect(ApiEndpoints.posts, contains('/posts'));
      expect(ApiEndpoints.feed, contains('/posts/feed'));
    });

    test('should have correct messages endpoints', () {
      expect(ApiEndpoints.messages, contains('/messages'));
    });

    test('should have correct stories endpoints', () {
      expect(ApiEndpoints.stories, contains('/stories'));
    });

    test('should have correct notifications endpoints', () {
      expect(ApiEndpoints.notifications, contains('/notifications'));
      expect(ApiEndpoints.notificationSettings,
          contains('/notifications/settings'),);
    });

    test('should have dynamic user endpoint', () {
      final userEndpoint = ApiEndpoints.userById('123');
      expect(userEndpoint, contains('/users/123'));
    });

    test('should have dynamic post endpoint', () {
      final postEndpoint = ApiEndpoints.postById('456');
      expect(postEndpoint, contains('/posts/456'));
    });

    test('should have dynamic message thread endpoint', () {
      final threadEndpoint = ApiEndpoints.messageThread('789');
      expect(threadEndpoint, contains('/messages/789'));
    });
  });
}
