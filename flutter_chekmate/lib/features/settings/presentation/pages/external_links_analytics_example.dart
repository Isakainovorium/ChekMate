import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/services/app_info_service.dart';
import 'package:flutter_chekmate/core/services/url_launcher_service.dart';

/// ExternalLinksAnalyticsExample - Example Page
///
/// Demonstrates how to use UrlLauncherService and AppInfoService.
/// Shows URL launching, email, phone, SMS, maps, social media, and app info.
///
/// Features:
/// - Open web URLs
/// - Send emails
/// - Make phone calls
/// - Send SMS
/// - Open maps
/// - Open social media
/// - Display app info
/// - Display device info
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => ExternalLinksAnalyticsExample()),
/// )
/// ```
class ExternalLinksAnalyticsExample extends StatefulWidget {
  const ExternalLinksAnalyticsExample({super.key});

  @override
  State<ExternalLinksAnalyticsExample> createState() =>
      _ExternalLinksAnalyticsExampleState();
}

class _ExternalLinksAnalyticsExampleState
    extends State<ExternalLinksAnalyticsExample> {
  bool _appInfoInitialized = false;
  String _appInfo = 'Loading...';
  // ignore: unused_field
  String _deviceInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _initializeAppInfo();
  }

  Future<void> _initializeAppInfo() async {
    try {
      await AppInfoService.initialize();
      setState(() {
        _appInfoInitialized = true;
        _appInfo = AppInfoService.getSupportInfo();
        _deviceInfo = AppInfoService.getAllInfo().toString();
      });
    } on Exception catch (e) {
      setState(() {
        _appInfo = 'Failed to load app info: $e';
        _deviceInfo = 'Failed to load device info: $e';
      });
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      await UrlLauncherService.openUrl(url);
      _showSuccess('Opened URL');
    } on Exception catch (e) {
      _showError('Failed to open URL: $e');
    }
  }

  Future<void> _sendEmail() async {
    try {
      await UrlLauncherService.sendEmail(
        'support@chekmate.com',
        subject: 'ChekMate Support',
        body: 'Hello, I need help with...',
      );
      _showSuccess('Opened email client');
    } on Exception catch (e) {
      _showError('Failed to send email: $e');
    }
  }

  Future<void> _makePhoneCall() async {
    try {
      await UrlLauncherService.makePhoneCall('+1234567890');
      _showSuccess('Opened phone dialer');
    } on Exception catch (e) {
      _showError('Failed to make phone call: $e');
    }
  }

  Future<void> _sendSms() async {
    try {
      await UrlLauncherService.sendSms(
        '+1234567890',
        message: 'Hello from ChekMate!',
      );
      _showSuccess('Opened SMS app');
    } on Exception catch (e) {
      _showError('Failed to send SMS: $e');
    }
  }

  Future<void> _openMaps() async {
    try {
      await UrlLauncherService.openMaps(
        37.7749,
        -122.4194,
        label: 'San Francisco',
      );
      _showSuccess('Opened maps');
    } on Exception catch (e) {
      _showError('Failed to open maps: $e');
    }
  }

  Future<void> _openWhatsApp() async {
    try {
      await UrlLauncherService.openWhatsApp(
        '+1234567890',
        message: 'Hello from ChekMate!',
      );
      _showSuccess('Opened WhatsApp');
    } on Exception catch (e) {
      _showError('Failed to open WhatsApp: $e');
    }
  }

  Future<void> _openInstagram() async {
    try {
      await UrlLauncherService.openInstagram('chekmate');
      _showSuccess('Opened Instagram');
    } on Exception catch (e) {
      _showError('Failed to open Instagram: $e');
    }
  }

  Future<void> _copyAppInfo() async {
    if (_appInfoInitialized) {
      await Clipboard.setData(ClipboardData(text: _appInfo));
      _showSuccess('App info copied to clipboard');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('External Links & Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Web URLs
          const Text(
            '1. Web URLs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _openUrl('https://flutter.dev'),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Open Flutter.dev'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _openUrl('https://github.com'),
            icon: const Icon(Icons.code),
            label: const Text('Open GitHub'),
          ),
          const SizedBox(height: 24),

          // Section 2: Communication
          const Text(
            '2. Communication',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _sendEmail,
            icon: const Icon(Icons.email),
            label: const Text('Send Email'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _makePhoneCall,
            icon: const Icon(Icons.phone),
            label: const Text('Make Phone Call'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _sendSms,
            icon: const Icon(Icons.sms),
            label: const Text('Send SMS'),
          ),
          const SizedBox(height: 24),

          // Section 3: Maps & Location
          const Text(
            '3. Maps & Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _openMaps,
            icon: const Icon(Icons.map),
            label: const Text('Open Maps (San Francisco)'),
          ),
          const SizedBox(height: 24),

          // Section 4: Social Media
          const Text(
            '4. Social Media',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _openWhatsApp,
            icon: const Icon(Icons.chat),
            label: const Text('Open WhatsApp'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _openInstagram,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Open Instagram'),
          ),
          const SizedBox(height: 24),

          // Section 5: App Information
          const Text(
            '5. App Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _appInfo,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _copyAppInfo,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy App Info'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section 6: Analytics Info
          const Text(
            '6. Analytics Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_appInfoInitialized) ...[
            _buildInfoTile('App Name', AppInfoService.appName),
            _buildInfoTile('Version', AppInfoService.fullVersion),
            _buildInfoTile('Package', AppInfoService.packageName),
            _buildInfoTile('Device', AppInfoService.deviceModel),
            _buildInfoTile('Manufacturer', AppInfoService.deviceManufacturer),
            _buildInfoTile(
              'OS',
              '${AppInfoService.osName} ${AppInfoService.osVersion}',
            ),
            _buildInfoTile('Platform', AppInfoService.platform),
            _buildInfoTile(
              'Physical Device',
              AppInfoService.isPhysicalDevice.toString(),
            ),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Loading analytics info...'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
        dense: true,
      ),
    );
  }
}
