import 'package:flutter_chekmate/core/services/app_info_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppInfoService', () {
    // Note: AppInfoService requires platform plugins which aren't available in unit tests.
    // Tests that require initialization are skipped in unit test environment.
    // Use integration tests to test actual functionality.

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
        // This test just verifies that the getters exist as part of the API
        // Actual functionality is tested in integration tests

        // Getters that work without initialization
        expect(AppInfoService.osName, isA<String>());
        expect(AppInfoService.platform, isA<String>());

        // Getters that require initialization throw AppInfoException
        expect(() => AppInfoService.appName, throwsA(isA<AppInfoException>()));
        expect(
            () => AppInfoService.packageName, throwsA(isA<AppInfoException>()));
        expect(
            () => AppInfoService.appVersion, throwsA(isA<AppInfoException>()));
        expect(
            () => AppInfoService.buildNumber, throwsA(isA<AppInfoException>()));
        expect(
            () => AppInfoService.fullVersion, throwsA(isA<AppInfoException>()));
        expect(() => AppInfoService.installerStore,
            throwsA(isA<AppInfoException>()));
        expect(
            () => AppInfoService.deviceModel, throwsA(isA<AppInfoException>()));
        expect(() => AppInfoService.deviceManufacturer,
            throwsA(isA<AppInfoException>()));
        expect(
            () => AppInfoService.deviceBrand, throwsA(isA<AppInfoException>()));
        expect(
            () => AppInfoService.osVersion, throwsA(isA<AppInfoException>()));
        expect(() => AppInfoService.isPhysicalDevice,
            throwsA(isA<AppInfoException>()));
        expect(() => AppInfoService.androidSdkVersion,
            throwsA(isA<AppInfoException>()));
        expect(
            () => AppInfoService.androidId, throwsA(isA<AppInfoException>()));
        expect(() => AppInfoService.androidSecurityPatch,
            throwsA(isA<AppInfoException>()));
        expect(() => AppInfoService.iosDeviceName,
            throwsA(isA<AppInfoException>()));
        expect(() => AppInfoService.iosSystemName,
            throwsA(isA<AppInfoException>()));
        expect(() => AppInfoService.iosIdentifierForVendor,
            throwsA(isA<AppInfoException>()));
        expect(() => AppInfoService.iosLocalizedModel,
            throwsA(isA<AppInfoException>()));
      });
    });

    group('Method Return Types', () {
      test(
          'initialize returns Future<void> that throws without platform plugins',
          () {
        // initialize() returns a Future, but it throws when platform plugins unavailable
        expect(
          AppInfoService.initialize(),
          throwsA(isA<AppInfoException>()),
        );
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
      // These tests require platform plugins and should be run as integration tests
      test('appName throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.appName,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('packageName throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.packageName,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('appVersion throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.appVersion,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('buildNumber throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.buildNumber,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('fullVersion throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.fullVersion,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('installerStore throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.installerStore,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('deviceModel throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.deviceModel,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('deviceManufacturer throws AppInfoException when not initialized',
          () {
        expect(
          () => AppInfoService.deviceManufacturer,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('deviceBrand throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.deviceBrand,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('osVersion throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.osVersion,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('osName returns String', () {
        expect(AppInfoService.osName, isA<String>());
      });

      test('platform returns String', () {
        expect(AppInfoService.platform, isA<String>());
      });

      test('isPhysicalDevice throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.isPhysicalDevice,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('androidSdkVersion throws AppInfoException when not initialized',
          () {
        expect(
          () => AppInfoService.androidSdkVersion,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('androidId throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.androidId,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('androidSecurityPatch throws AppInfoException when not initialized',
          () {
        expect(
          () => AppInfoService.androidSecurityPatch,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('iosDeviceName throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.iosDeviceName,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('iosSystemName throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.iosSystemName,
          throwsA(isA<AppInfoException>()),
        );
      });

      test(
          'iosIdentifierForVendor throws AppInfoException when not initialized',
          () {
        expect(
          () => AppInfoService.iosIdentifierForVendor,
          throwsA(isA<AppInfoException>()),
        );
      });

      test('iosLocalizedModel throws AppInfoException when not initialized',
          () {
        expect(
          () => AppInfoService.iosLocalizedModel,
          throwsA(isA<AppInfoException>()),
        );
      });
    });

    group('Version Formatting', () {
      test('fullVersion throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.fullVersion,
          throwsA(isA<AppInfoException>()),
        );
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

      test('isPhysicalDevice throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.isPhysicalDevice,
          throwsA(isA<AppInfoException>()),
        );
      });
    });

    group('Analytics Info', () {
      test('getAnalyticsInfo throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.getAnalyticsInfo(),
          throwsA(isA<AppInfoException>()),
        );
      });
    });

    group('Support Info', () {
      test('getSupportInfo throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.getSupportInfo(),
          throwsA(isA<AppInfoException>()),
        );
      });
    });

    group('All Info', () {
      test('getAllInfo throws AppInfoException when not initialized', () {
        expect(
          () => AppInfoService.getAllInfo(),
          throwsA(isA<AppInfoException>()),
        );
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
      test('initialize throws exception when platform plugins unavailable',
          () async {
        // In unit test environment, platform plugins are not available
        expect(
          AppInfoService.initialize(),
          throwsA(isA<AppInfoException>()),
        );
      });
    });
  });
}
