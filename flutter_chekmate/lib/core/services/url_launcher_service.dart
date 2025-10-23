import 'package:url_launcher/url_launcher.dart';

/// UrlLauncherService - Core Service for Opening External Links
///
/// Handles opening URLs, emails, phone calls, SMS, and other external links.
/// Provides a clean API for launching different types of URLs.
///
/// Features:
/// - Open web URLs
/// - Send emails
/// - Make phone calls
/// - Send SMS
/// - Open maps
/// - Launch apps
///
/// Usage:
/// ```dart
/// await UrlLauncherService.openUrl('https://example.com');
/// await UrlLauncherService.sendEmail('test@example.com');
/// await UrlLauncherService.makePhoneCall('+1234567890');
/// ```
class UrlLauncherService {
  /// Open a web URL
  ///
  /// [url] - The URL to open (e.g., 'https://example.com')
  /// [mode] - Launch mode (external browser, in-app browser, etc.)
  static Future<bool> openUrl(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: mode);
      }
      throw UrlLauncherException('Cannot launch URL: $url');
    } catch (e) {
      throw UrlLauncherException('Failed to open URL: $e');
    }
  }

  /// Open URL in external browser
  static Future<bool> openUrlInBrowser(String url) async {
    return openUrl(url);
  }

  /// Open URL in in-app browser
  static Future<bool> openUrlInApp(String url) async {
    return openUrl(url, mode: LaunchMode.inAppBrowserView);
  }

  /// Open URL in in-app web view
  static Future<bool> openUrlInWebView(String url) async {
    return openUrl(url, mode: LaunchMode.inAppWebView);
  }

  /// Send an email
  ///
  /// [email] - Email address
  /// [subject] - Email subject (optional)
  /// [body] - Email body (optional)
  /// [cc] - CC recipients (optional)
  /// [bcc] - BCC recipients (optional)
  static Future<bool> sendEmail(
    String email, {
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        query: _encodeQueryParameters({
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
          if (cc != null && cc.isNotEmpty) 'cc': cc.join(','),
          if (bcc != null && bcc.isNotEmpty) 'bcc': bcc.join(','),
        }),
      );

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      throw UrlLauncherException('Cannot send email to: $email');
    } catch (e) {
      throw UrlLauncherException('Failed to send email: $e');
    }
  }

  /// Make a phone call
  ///
  /// [phoneNumber] - Phone number (e.g., '+1234567890')
  static Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      throw UrlLauncherException('Cannot make phone call to: $phoneNumber');
    } catch (e) {
      throw UrlLauncherException('Failed to make phone call: $e');
    }
  }

  /// Send an SMS
  ///
  /// [phoneNumber] - Phone number
  /// [message] - SMS message (optional)
  static Future<bool> sendSms(String phoneNumber, {String? message}) async {
    try {
      final uri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        query: message != null ? 'body=$message' : null,
      );

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      throw UrlLauncherException('Cannot send SMS to: $phoneNumber');
    } catch (e) {
      throw UrlLauncherException('Failed to send SMS: $e');
    }
  }

  /// Open maps with location
  ///
  /// [latitude] - Latitude
  /// [longitude] - Longitude
  /// [label] - Location label (optional)
  static Future<bool> openMaps(
    double latitude,
    double longitude, {
    String? label,
  }) async {
    try {
      final query = label != null
          ? '$latitude,$longitude($label)'
          : '$latitude,$longitude';
      final uri = Uri(
        scheme: 'geo',
        path: '0,0',
        query: 'q=$query',
      );

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }

      // Fallback to Google Maps web
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      return await openUrl(googleMapsUrl);
    } catch (e) {
      throw UrlLauncherException('Failed to open maps: $e');
    }
  }

  /// Open maps with address
  ///
  /// [address] - Address to search
  static Future<bool> openMapsWithAddress(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final uri = Uri(
        scheme: 'geo',
        path: '0,0',
        query: 'q=$encodedAddress',
      );

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }

      // Fallback to Google Maps web
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
      return await openUrl(googleMapsUrl);
    } catch (e) {
      throw UrlLauncherException('Failed to open maps: $e');
    }
  }

  /// Open WhatsApp chat
  ///
  /// [phoneNumber] - Phone number (with country code, e.g., '+1234567890')
  /// [message] - Pre-filled message (optional)
  static Future<bool> openWhatsApp(
    String phoneNumber, {
    String? message,
  }) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final encodedMessage =
          message != null ? Uri.encodeComponent(message) : '';
      final url =
          'https://wa.me/$cleanNumber${message != null ? '?text=$encodedMessage' : ''}';

      return await openUrl(url);
    } catch (e) {
      throw UrlLauncherException('Failed to open WhatsApp: $e');
    }
  }

  /// Open Instagram profile
  ///
  /// [username] - Instagram username
  static Future<bool> openInstagram(String username) async {
    try {
      final url = 'https://www.instagram.com/$username';
      return await openUrl(url);
    } catch (e) {
      throw UrlLauncherException('Failed to open Instagram: $e');
    }
  }

  /// Open Twitter profile
  ///
  /// [username] - Twitter username
  static Future<bool> openTwitter(String username) async {
    try {
      final url = 'https://twitter.com/$username';
      return await openUrl(url);
    } catch (e) {
      throw UrlLauncherException('Failed to open Twitter: $e');
    }
  }

  /// Open TikTok profile
  ///
  /// [username] - TikTok username
  static Future<bool> openTikTok(String username) async {
    try {
      final url = 'https://www.tiktok.com/@$username';
      return await openUrl(url);
    } catch (e) {
      throw UrlLauncherException('Failed to open TikTok: $e');
    }
  }

  /// Check if a URL can be launched
  static Future<bool> canLaunch(String url) async {
    try {
      final uri = Uri.parse(url);
      return await canLaunchUrl(uri);
    } on Exception {
      return false;
    }
  }

  /// Encode query parameters for URLs
  static String? _encodeQueryParameters(Map<String, String> params) {
    if (params.isEmpty) return null;
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}

/// UrlLauncherException - Custom exception for URL launcher errors
class UrlLauncherException implements Exception {
  const UrlLauncherException(this.message);
  final String message;

  @override
  String toString() => 'UrlLauncherException: $message';
}
