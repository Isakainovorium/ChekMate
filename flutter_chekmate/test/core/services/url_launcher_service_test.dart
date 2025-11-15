import 'package:flutter_chekmate/core/services/url_launcher_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UrlLauncherService', () {
    group('UrlLauncherException', () {
      test('creates exception with message', () {
        const exception = UrlLauncherException('Test error');
        expect(exception.message, 'Test error');
        expect(exception.toString(), 'UrlLauncherException: Test error');
      });

      test('two exceptions with same message are equal', () {
        const exception1 = UrlLauncherException('Test error');
        const exception2 = UrlLauncherException('Test error');
        expect(exception1, exception2);
      });

      test('two exceptions with different messages are not equal', () {
        const exception1 = UrlLauncherException('Test error 1');
        const exception2 = UrlLauncherException('Test error 2');
        expect(exception1, isNot(exception2));
      });
    });

    group('Service Structure', () {
      test('UrlLauncherService has required static methods', () {
        expect(UrlLauncherService.openUrl, isA<Function>());
        expect(UrlLauncherService.openUrlInBrowser, isA<Function>());
        expect(UrlLauncherService.openUrlInApp, isA<Function>());
        expect(UrlLauncherService.openUrlInWebView, isA<Function>());
        expect(UrlLauncherService.sendEmail, isA<Function>());
        expect(UrlLauncherService.makePhoneCall, isA<Function>());
        expect(UrlLauncherService.sendSms, isA<Function>());
        expect(UrlLauncherService.openMaps, isA<Function>());
        expect(UrlLauncherService.openMapsWithAddress, isA<Function>());
        expect(UrlLauncherService.openWhatsApp, isA<Function>());
        expect(UrlLauncherService.openInstagram, isA<Function>());
        expect(UrlLauncherService.openTwitter, isA<Function>());
        expect(UrlLauncherService.openTikTok, isA<Function>());
        expect(UrlLauncherService.canLaunch, isA<Function>());
      });
    });

    group('URL Validation', () {
      test('openUrl throws exception for empty URL', () async {
        expect(
          () => UrlLauncherService.openUrl(''),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('openUrl throws exception for whitespace-only URL', () async {
        expect(
          () => UrlLauncherService.openUrl('   '),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('openUrl throws exception for invalid URL format', () async {
        expect(
          () => UrlLauncherService.openUrl('not a url'),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('openUrl accepts valid HTTP URL', () {
        expect(
          () => UrlLauncherService.openUrl('http://example.com'),
          isA<Function>(),
        );
      });

      test('openUrl accepts valid HTTPS URL', () {
        expect(
          () => UrlLauncherService.openUrl('https://example.com'),
          isA<Function>(),
        );
      });
    });

    group('Email Validation', () {
      test('sendEmail throws exception for empty email', () async {
        expect(
          () => UrlLauncherService.sendEmail(''),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('sendEmail throws exception for invalid email format', () async {
        expect(
          () => UrlLauncherService.sendEmail('not-an-email'),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('sendEmail accepts valid email', () {
        expect(
          () => UrlLauncherService.sendEmail('test@example.com'),
          isA<Function>(),
        );
      });

      test('sendEmail accepts subject parameter', () {
        expect(
          () => UrlLauncherService.sendEmail(
            'test@example.com',
            subject: 'Test Subject',
          ),
          isA<Function>(),
        );
      });

      test('sendEmail accepts body parameter', () {
        expect(
          () => UrlLauncherService.sendEmail(
            'test@example.com',
            body: 'Test Body',
          ),
          isA<Function>(),
        );
      });

      test('sendEmail accepts cc parameter', () {
        expect(
          () => UrlLauncherService.sendEmail(
            'test@example.com',
            cc: ['cc@example.com'],
          ),
          isA<Function>(),
        );
      });

      test('sendEmail accepts bcc parameter', () {
        expect(
          () => UrlLauncherService.sendEmail(
            'test@example.com',
            bcc: ['bcc@example.com'],
          ),
          isA<Function>(),
        );
      });
    });

    group('Phone Number Validation', () {
      test('makePhoneCall throws exception for empty phone number', () async {
        expect(
          () => UrlLauncherService.makePhoneCall(''),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('makePhoneCall accepts valid phone number', () {
        expect(
          () => UrlLauncherService.makePhoneCall('+1234567890'),
          isA<Function>(),
        );
      });

      test('sendSms throws exception for empty phone number', () async {
        expect(
          () => UrlLauncherService.sendSms(''),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('sendSms accepts valid phone number', () {
        expect(
          () => UrlLauncherService.sendSms('+1234567890'),
          isA<Function>(),
        );
      });

      test('sendSms accepts message parameter', () {
        expect(
          () => UrlLauncherService.sendSms(
            '+1234567890',
            message: 'Test message',
          ),
          isA<Function>(),
        );
      });
    });

    group('Maps Validation', () {
      test('openMaps accepts valid coordinates', () {
        expect(
          () => UrlLauncherService.openMaps(37.7749, -122.4194),
          isA<Function>(),
        );
      });

      test('openMaps accepts label parameter', () {
        expect(
          () => UrlLauncherService.openMaps(
            37.7749,
            -122.4194,
            label: 'San Francisco',
          ),
          isA<Function>(),
        );
      });

      test('openMapsWithAddress throws exception for empty address', () async {
        expect(
          () => UrlLauncherService.openMapsWithAddress(''),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('openMapsWithAddress accepts valid address', () {
        expect(
          () => UrlLauncherService.openMapsWithAddress('San Francisco, CA'),
          isA<Function>(),
        );
      });
    });

    group('Social Media Validation', () {
      test('openWhatsApp throws exception for empty phone number', () async {
        expect(
          () => UrlLauncherService.openWhatsApp(''),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('openWhatsApp accepts valid phone number', () {
        expect(
          () => UrlLauncherService.openWhatsApp('+1234567890'),
          isA<Function>(),
        );
      });

      test('openWhatsApp accepts message parameter', () {
        expect(
          () => UrlLauncherService.openWhatsApp(
            '+1234567890',
            message: 'Hello',
          ),
          isA<Function>(),
        );
      });

      test('openInstagram throws exception for empty username', () async {
        expect(
          () => UrlLauncherService.openInstagram(''),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('openInstagram accepts valid username', () {
        expect(
          () => UrlLauncherService.openInstagram('testuser'),
          isA<Function>(),
        );
      });

      test('openTwitter throws exception for empty username', () async {
        expect(
          () => UrlLauncherService.openTwitter(''),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('openTwitter accepts valid username', () {
        expect(
          () => UrlLauncherService.openTwitter('testuser'),
          isA<Function>(),
        );
      });

      test('openTikTok throws exception for empty username', () async {
        expect(
          () => UrlLauncherService.openTikTok(''),
          throwsA(isA<UrlLauncherException>()),
        );
      });

      test('openTikTok accepts valid username', () {
        expect(
          () => UrlLauncherService.openTikTok('testuser'),
          isA<Function>(),
        );
      });
    });

    group('Method Return Types', () {
      test('openUrl returns Future<bool>', () {
        expect(
          UrlLauncherService.openUrl('https://example.com'),
          isA<Future<bool>>(),
        );
      });

      test('openUrlInBrowser returns Future<bool>', () {
        expect(
          UrlLauncherService.openUrlInBrowser('https://example.com'),
          isA<Future<bool>>(),
        );
      });

      test('openUrlInApp returns Future<bool>', () {
        expect(
          UrlLauncherService.openUrlInApp('https://example.com'),
          isA<Future<bool>>(),
        );
      });

      test('openUrlInWebView returns Future<bool>', () {
        expect(
          UrlLauncherService.openUrlInWebView('https://example.com'),
          isA<Future<bool>>(),
        );
      });

      test('sendEmail returns Future<bool>', () {
        expect(
          UrlLauncherService.sendEmail('test@example.com'),
          isA<Future<bool>>(),
        );
      });

      test('makePhoneCall returns Future<bool>', () {
        expect(
          UrlLauncherService.makePhoneCall('+1234567890'),
          isA<Future<bool>>(),
        );
      });

      test('sendSms returns Future<bool>', () {
        expect(
          UrlLauncherService.sendSms('+1234567890'),
          isA<Future<bool>>(),
        );
      });

      test('canLaunch returns Future<bool>', () {
        expect(
          UrlLauncherService.canLaunch('https://example.com'),
          isA<Future<bool>>(),
        );
      });
    });

    group('Error Handling', () {
      test('UrlLauncherException includes error message', () {
        const exception = UrlLauncherException('Cannot launch URL');

        expect(exception.message, contains('Cannot launch URL'));
      });

      test('UrlLauncherException toString includes message', () {
        const exception = UrlLauncherException('Test error');

        expect(exception.toString(), contains('Test error'));
        expect(exception.toString(), contains('UrlLauncherException'));
      });

      test('UrlLauncherException toString format is correct', () {
        const exception = UrlLauncherException('Test error');

        expect(exception.toString(), 'UrlLauncherException: Test error');
      });
    });
  });
}
