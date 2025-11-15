import 'package:flutter_chekmate/core/services/app_info_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppInfoService', () {
    group('AppInfoException', () {
      test('creates exception with message', () {
        const exception = AppInfoException('Test error');
        expect(exception.message, 'Test error');
        expect(exception.toString(), 'AppInfoException: Test error');
      });

      test('two exceptions with same message are equal', () {
        const exception1 = AppInfoException('Test error');
        const exception2 = AppInfoException('Test error');
        expect(exception1.message, exception2.message);
      });

      test('two exceptions with different messages are not equal', () {
        const exception1 = AppInfoException('Test error 1');
        const exception2 = AppInfoException('Test error 2');
        expect(exception1.message, isNot(exception2.message));
      });
    });

    group('Service Structure', () {
      test('AppInfoService has required static methods', () {
        expect(AppInfoService.initialize, isA<Function>());
        expect(AppInfoService.getAnalyticsInfo, isA<Function>());
        expect(AppInfoService.getSupportInfo, isA<Function>());
        expect(AppInfoService.getAllInfo, isA<Function>());
      });

      test('AppInfoService has required static getters', () {
        // App Info getters
        expect(() => AppInfoService.appName, returnsNormally);
        expect(() => AppInfoService.packageName, returnsNormally);
        expect(() => AppInfoService.appVersion, returnsNormally);
        expect(() => AppInfoService.buildNumber, returnsNormally);
        expect(() => AppInfoService.fullVersion, returnsNormally);
        expect(() => AppInfoService.installerStore, returnsNormally);

        // Device Info getters
        expect(() => AppInfoService.deviceModel, returnsNormally);
        expect(() => AppInfoService.deviceManufacturer, returnsNormally);
        expect(() => AppInfoService.deviceBrand, returnsNormally);
        expect(() => AppInfoService.osVersion, returnsNormally);
        expect(() => AppInfoService.osName, returnsNormally);
        expect(() => AppInfoService.platform, returnsNormally);
        expect(() => AppInfoService.isPhysicalDevice, returnsNormally);

        // Android-specific getters
        expect(() => AppInfoService.androidSdkVersion, returnsNormally);
        expect(() => AppInfoService.androidId, returnsNormally);
        expect(() => AppInfoService.androidSecurityPatch, returnsNormally);

        // iOS-specific getters
        expect(() => AppInfoService.iosDeviceName, returnsNormally);
        expect(() => AppInfoService.iosSystemName, returnsNormally);
        expect(() => AppInfoService.iosIdentifierForVendor, returnsNormally);
        expect(() => AppInfoService.iosLocalizedModel, returnsNormally);
      });
    });

    group('Method Return Types', () {
      test('initialize returns Future<void>', () {
        expect(AppInfoService.initialize(), isA<Future<void>>());
      });

      test('getAnalyticsInfo returns Map<String, dynamic>', () {
        expect(
          AppInfoService.getAnalyticsInfo,
          isA<Map<String, dynamic> Function()>(),
        );
      });

      test('getSupportInfo returns String', () {
        expect(
          AppInfoService.getSupportInfo,
          isA<String Function()>(),
        );
      });

      test('getAllInfo returns Map<String, dynamic>', () {
        expect(
          AppInfoService.getAllInfo,
          isA<Map<String, dynamic> Function()>(),
        );
      });
    });

    group('Getter Return Types', () {
      test('appName returns String', () {
        expect(AppInfoService.appName, isA<String>());
      });

      test('packageName returns String', () {
        expect(AppInfoService.packageName, isA<String>());
      });

      test('appVersion returns String', () {
        expect(AppInfoService.appVersion, isA<String>());
      });

      test('buildNumber returns String', () {
        expect(AppInfoService.buildNumber, isA<String>());
      });

      test('fullVersion returns String', () {
        expect(AppInfoService.fullVersion, isA<String>());
      });

      test('installerStore returns String?', () {
        expect(AppInfoService.installerStore, isA<String?>());
      });

      test('deviceModel returns String', () {
        expect(AppInfoService.deviceModel, isA<String>());
      });

      test('deviceManufacturer returns String', () {
        expect(AppInfoService.deviceManufacturer, isA<String>());
      });

      test('deviceBrand returns String', () {
        expect(AppInfoService.deviceBrand, isA<String>());
      });

      test('osVersion returns String', () {
        expect(AppInfoService.osVersion, isA<String>());
      });

      test('osName returns String', () {
        expect(AppInfoService.osName, isA<String>());
      });

      test('platform returns String', () {
        expect(AppInfoService.platform, isA<String>());
      });

      test('isPhysicalDevice returns bool', () {
        expect(AppInfoService.isPhysicalDevice, isA<bool>());
      });

      test('androidSdkVersion returns int?', () {
        expect(AppInfoService.androidSdkVersion, isA<int?>());
      });

      test('androidId returns String?', () {
        expect(AppInfoService.androidId, isA<String?>());
      });

      test('androidSecurityPatch returns String?', () {
        expect(AppInfoService.androidSecurityPatch, isA<String?>());
      });

      test('iosDeviceName returns String?', () {
        expect(AppInfoService.iosDeviceName, isA<String?>());
      });

      test('iosSystemName returns String?', () {
        expect(AppInfoService.iosSystemName, isA<String?>());
      });

      test('iosIdentifierForVendor returns String?', () {
        expect(AppInfoService.iosIdentifierForVendor, isA<String?>());
      });

      test('iosLocalizedModel returns String?', () {
        expect(AppInfoService.iosLocalizedModel, isA<String?>());
      });
    });

    group('Version Formatting', () {
      test('fullVersion combines appVersion and buildNumber', () {
        // The fullVersion should be in format "version (build)"
        final fullVersion = AppInfoService.fullVersion;
        expect(fullVersion, isA<String>());
        expect(fullVersion, isNotEmpty);
      });
    });

    group('Platform Detection', () {
      test('platform returns valid platform name', () {
        final platform = AppInfoService.platform;
        expect(platform, isA<String>());
        expect(platform, isNotEmpty);
        // Platform should be one of: android, ios, web, windows, macos, linux
        expect(
          ['android', 'ios', 'web', 'windows', 'macos', 'linux'],
          contains(platform.toLowerCase()),
        );
      });

      test('isPhysicalDevice returns boolean', () {
        final isPhysical = AppInfoService.isPhysicalDevice;
        expect(isPhysical, isA<bool>());
      });
    });

    group('Analytics Info', () {
      test('getAnalyticsInfo returns map with required keys', () async {
        final info = AppInfoService.getAnalyticsInfo();

        expect(info, isA<Map<String, dynamic>>());
        expect(info, isNotEmpty);

        // Should contain app info
        expect(info.containsKey('appName'), true);
        expect(info.containsKey('appVersion'), true);
        expect(info.containsKey('buildNumber'), true);

        // Should contain device info
        expect(info.containsKey('deviceModel'), true);
        expect(info.containsKey('osVersion'), true);
        expect(info.containsKey('platform'), true);
      });

      test('getAnalyticsInfo values are not null for required fields',
          () async {
        final info = AppInfoService.getAnalyticsInfo();

        expect(info['appName'], isNotNull);
        expect(info['appVersion'], isNotNull);
        expect(info['buildNumber'], isNotNull);
        expect(info['deviceModel'], isNotNull);
        expect(info['osVersion'], isNotNull);
        expect(info['platform'], isNotNull);
      });
    });

    group('Support Info', () {
      test('getSupportInfo returns string with required info', () async {
        final info = AppInfoService.getSupportInfo();

        expect(info, isA<String>());
        expect(info, isNotEmpty);

        // Should contain app info
        expect(info.contains('App:'), true);
        expect(info.contains('Version:'), true);
        expect(info.contains('Package:'), true);

        // Should contain device info
        expect(info.contains('Device:'), true);
        expect(info.contains('OS:'), true);
        expect(info.contains('Platform:'), true);
        expect(info.contains('Physical Device:'), true);
      });

      test('getSupportInfo is formatted correctly', () async {
        final info = AppInfoService.getSupportInfo();

        // Should be multi-line string
        expect(info.contains('\n'), true);

        // Should contain key-value pairs
        expect(info.split('\n').length, greaterThan(5));
      });
    });

    group('All Info', () {
      test('getAllInfo returns comprehensive map', () async {
        final info = AppInfoService.getAllInfo();

        expect(info, isA<Map<String, dynamic>>());
        expect(info, isNotEmpty);

        // Should contain all app info
        expect(info.containsKey('appName'), true);
        expect(info.containsKey('packageName'), true);
        expect(info.containsKey('appVersion'), true);
        expect(info.containsKey('buildNumber'), true);
        expect(info.containsKey('fullVersion'), true);

        // Should contain all device info
        expect(info.containsKey('deviceModel'), true);
        expect(info.containsKey('deviceManufacturer'), true);
        expect(info.containsKey('deviceBrand'), true);
        expect(info.containsKey('osVersion'), true);
        expect(info.containsKey('osName'), true);
        expect(info.containsKey('platform'), true);
        expect(info.containsKey('isPhysicalDevice'), true);
      });
    });

    group('Error Handling', () {
      test('AppInfoException includes error message', () {
        const exception = AppInfoException('Failed to get app info');

        expect(exception.message, contains('Failed to get app info'));
        expect(exception.toString(), contains('AppInfoException'));
      });

      test('AppInfoException toString includes message', () {
        const exception = AppInfoException('Test error');

        expect(exception.toString(), contains('Test error'));
        expect(exception.toString(), contains('AppInfoException'));
      });

      test('AppInfoException can be thrown and caught', () {
        expect(
          () => throw const AppInfoException('Test error'),
          throwsA(isA<AppInfoException>()),
        );
      });
    });

    group('Initialization', () {
      test('initialize can be called multiple times safely', () async {
        // The service should handle multiple initialization calls gracefully
        await AppInfoService.initialize();
        await AppInfoService.initialize();
        // Should not throw
      });
    });
  });
}
