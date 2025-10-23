import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Share Profile Widget - converted from ShareProfile.tsx
/// Modal for sharing user profile via various methods
class ShareProfileWidget extends StatefulWidget {
  const ShareProfileWidget({
    required this.username, required this.bio, required this.avatar, required this.profileStats, super.key,
  });
  final String username;
  final String bio;
  final String avatar;
  final ProfileStats profileStats;

  @override
  State<ShareProfileWidget> createState() => _ShareProfileWidgetState();
}

class _ShareProfileWidgetState extends State<ShareProfileWidget> {
  bool _copied = false;
  bool _showQR = false;
  String _shareSuccess = '';

  String get _profileUrl => 'https://chekmate.app/profile/${widget.username}';

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _profileUrl));
    setState(() {
      _copied = true;
      _shareSuccess = 'Profile link copied to clipboard!';
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _copied = false;
          _shareSuccess = '';
        });
      }
    });
  }

  void _shareToSocialMedia(String platform) {
    // In a real app, this would open the respective platform's share dialog
    setState(() {
      _shareSuccess = 'Shared to $platform!';
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _shareSuccess = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 448),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildProfilePreview(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildProfileLink(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQuickShare(),
                    if (_showQR) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildQRCode(),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _buildSocialMedia(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildMessaging(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPrivacyNotice(),
                    if (_shareSuccess.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildSuccessMessage(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Share Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePreview() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Colors.pink],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(widget.avatar),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '@${widget.username}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.bio,
            style: TextStyle(
                fontSize: 14, color: AppColors.primary.withValues(alpha: 0.3),),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Followers', widget.profileStats.followers),
              _buildStat('Following', widget.profileStats.following),
              _buildStat('Posts', widget.profileStats.posts),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: AppColors.primary.withValues(alpha: 0.3),),
        ),
      ],
    );
  }

  Widget _buildProfileLink() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Link',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.link, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _profileUrl,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: _copyToClipboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _copied
                      ? Colors.green.shade100
                      : AppColors.primary.withValues(alpha: 0.2),
                  foregroundColor:
                      _copied ? Colors.green.shade700 : AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs,),
                  minimumSize: Size.zero,
                ),
                child: Icon(_copied ? Icons.check : Icons.copy, size: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickShare() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Share',
            style: TextStyle(fontWeight: FontWeight.w600),),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildShareButton(
                  Icons.share, 'Share', () => _shareToSocialMedia('share'),),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildShareButton(Icons.qr_code, 'QR Code',
                  () => setState(() => _showQR = !_showQR),),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('QR Code',
                  style: TextStyle(fontWeight: FontWeight.w600),),
              TextButton(
                onPressed: () {
                  setState(() => _shareSuccess = 'Profile card downloaded!');
                },
                child: const Text('Download Card',
                    style: TextStyle(color: AppColors.primary),),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
                child:
                    Text('QR Code\nPlaceholder', textAlign: TextAlign.center),),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Others can scan this QR code to view your profile',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMedia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Share to Social Media',
            style: TextStyle(fontWeight: FontWeight.w600),),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
                child: _buildSocialButton('Twitter', Colors.blue,
                    () => _shareToSocialMedia('Twitter'),),),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: _buildSocialButton('Instagram', Colors.pink,
                    () => _shareToSocialMedia('Instagram'),),),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: _buildSocialButton('Facebook', Colors.blue.shade800,
                    () => _shareToSocialMedia('Facebook'),),),
          ],
        ),
      ],
    );
  }

  Widget _buildMessaging() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Send Directly',
            style: TextStyle(fontWeight: FontWeight.w600),),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
                child: _buildSocialButton('WhatsApp', Colors.green,
                    () => _shareToSocialMedia('WhatsApp'),),),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: _buildSocialButton(
                    'SMS', Colors.blue, () => _shareToSocialMedia('SMS'),),),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: _buildSocialButton('Email', Colors.grey.shade600,
                    () => _shareToSocialMedia('Email'),),),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(Icons.share, size: 20, color: color),
            const SizedBox(height: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy & Safety',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade800,),
          ),
          const SizedBox(height: 4),
          Text(
            'Your profile link is public and can be viewed by anyone. Only share with people you trust.',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: Colors.green.shade600),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _shareSuccess,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile stats model
class ProfileStats {
  ProfileStats({
    this.followers = 0,
    this.following = 0,
    this.posts = 0,
  });
  final int followers;
  final int following;
  final int posts;
}
