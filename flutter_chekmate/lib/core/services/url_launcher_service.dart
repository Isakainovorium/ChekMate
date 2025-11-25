import 'package:url_launcher/url_launcher.dart';

/// URL Launcher Service Exception
class UrlLauncherException implements Exception {
  const UrlLauncherException(this.message);

  final String message;

  @override
  String toString() => 'UrlLauncherException: $message';
}

/// URL Launcher Service
/// Handles launching URLs, emails, phone calls, and social media apps
class UrlLauncherService {
  UrlLauncherService._();

  /// Open URL in default app/browser
  static Future<bool> openUrl(String url) async {
    if (!_isValidUrl(url)) {
      throw const UrlLauncherException('Invalid URL format');
    }

    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to open URL: $e');
    }
  }

  /// Open URL in external browser
  static Future<bool> openUrlInBrowser(String url) async {
    if (!_isValidUrl(url)) {
      throw const UrlLauncherException('Invalid URL format');
    }

    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw UrlLauncherException('Failed to open URL in browser: $e');
    }
  }

  /// Open URL in app (if supported) or external browser
  static Future<bool> openUrlInApp(String url) async {
    if (!_isValidUrl(url)) {
      throw const UrlLauncherException('Invalid URL format');
    }

    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } catch (e) {
      throw UrlLauncherException('Failed to open URL in app: $e');
    }
  }

  /// Open URL in web view
  static Future<bool> openUrlInWebView(String url) async {
    if (!_isValidUrl(url)) {
      throw const UrlLauncherException('Invalid URL format');
    }

    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } catch (e) {
      throw UrlLauncherException('Failed to open URL in web view: $e');
    }
  }

  /// Send email
  static Future<bool> sendEmail(String email, {
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    if (!_isValidEmail(email)) {
      throw const UrlLauncherException('Invalid email format');
    }

    try {
      final Uri uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
          if (cc != null && cc.isNotEmpty) 'cc': cc.join(','),
          if (bcc != null && bcc.isNotEmpty) 'bcc': bcc.join(','),
        },
      );

      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to send email: $e');
    }
  }

  /// Make phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    if (!_isValidPhoneNumber(phoneNumber)) {
      throw const UrlLauncherException('Invalid phone number format');
    }

    try {
      final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to make phone call: $e');
    }
  }

  /// Send SMS
  static Future<bool> sendSms(String phoneNumber, {String? message}) async {
    if (!_isValidPhoneNumber(phoneNumber)) {
      throw const UrlLauncherException('Invalid phone number format');
    }

    try {
      final Uri uri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: message != null ? {'body': message} : null,
      );
      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to send SMS: $e');
    }
  }

  /// Open maps with coordinates
  static Future<bool> openMaps(double latitude, double longitude, {String? label}) async {
    try {
      final Uri uri = Uri(
        scheme: 'geo',
        path: '$latitude,$longitude',
        queryParameters: label != null ? {'q': label} : null,
      );
      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to open maps: $e');
    }
  }

  /// Open maps with address
  static Future<bool> openMapsWithAddress(String address) async {
    if (address.trim().isEmpty) {
      throw const UrlLauncherException('Address cannot be empty');
    }

    try {
      final Uri uri = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': address},
      );
      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to open maps with address: $e');
    }
  }

  /// Open WhatsApp
  static Future<bool> openWhatsApp(String phoneNumber, {String? message}) async {
    if (!_isValidPhoneNumber(phoneNumber)) {
      throw const UrlLauncherException('Invalid phone number format');
    }

    try {
      final Uri uri = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: phoneNumber.replaceAll('+', ''),
        queryParameters: message != null ? {'text': message} : null,
      );
      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to open WhatsApp: $e');
    }
  }

  /// Open Instagram profile
  static Future<bool> openInstagram(String username) async {
    if (username.trim().isEmpty) {
      throw const UrlLauncherException('Instagram username cannot be empty');
    }

    try {
      final Uri uri = Uri(
        scheme: 'https',
        host: 'instagram.com',
        path: username.startsWith('@') ? username.substring(1) : username,
      );
      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to open Instagram: $e');
    }
  }

  /// Open Twitter profile
  static Future<bool> openTwitter(String username) async {
    if (username.trim().isEmpty) {
      throw const UrlLauncherException('Twitter username cannot be empty');
    }

    try {
      final Uri uri = Uri(
        scheme: 'https',
        host: 'twitter.com',
        path: username.startsWith('@') ? username.substring(1) : username,
      );
      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to open Twitter: $e');
    }
  }

  /// Open TikTok profile
  static Future<bool> openTikTok(String username) async {
    if (username.trim().isEmpty) {
      throw const UrlLauncherException('TikTok username cannot be empty');
    }

    try {
      final Uri uri = Uri(
        scheme: 'https',
        host: 'tiktok.com',
        path: '@${username.startsWith('@') ? username.substring(1) : username}',
      );
      return await launchUrl(uri);
    } catch (e) {
      throw UrlLauncherException('Failed to open TikTok: $e');
    }
  }

  /// Check if URL can be launched
  static Future<bool> canLaunch(String url) async {
    try {
      final uri = Uri.parse(url);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Validate URL format
  static bool _isValidUrl(String url) {
    if (url.trim().isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    if (email.trim().isEmpty) {
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number format (basic validation)
  static bool _isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.trim().isEmpty) {
      return false;
    }

    // Remove all non-digit characters except + and spaces
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+\s]'), '');
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');

    // Basic validation: should have at least 7 digits
    return digitsOnly.length >= 7;
  }
}
