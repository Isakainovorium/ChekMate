import 'package:flutter/material.dart';

import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/components/app_button.dart';
import 'package:flutter_chekmate/shared/widgets/app_avatar.dart';
import 'package:flutter_chekmate/shared/widgets/app_card.dart';
import 'package:flutter_chekmate/shared/widgets/app_text_field.dart';

/// Component Showcase Page
/// Displays all reusable components for testing and demonstration
class ComponentShowcasePage extends StatefulWidget {
  const ComponentShowcasePage({super.key});

  @override
  State<ComponentShowcasePage> createState() => _ComponentShowcasePageState();
}

class _ComponentShowcasePageState extends State<ComponentShowcasePage> {
  final _textController = TextEditingController();
  bool _isLiked = false;
  bool _isChekked = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Showcase'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSection('Buttons', _buildButtonShowcase()),
          _buildSection('Text Fields', _buildTextFieldShowcase()),
          _buildSection('Avatars', _buildAvatarShowcase()),
          _buildSection('Badges', _buildBadgeShowcase()),
          _buildSection('Cards', _buildCardShowcase()),
          _buildSection('Flippable Post Card', _buildFlippableCardShowcase()),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        content,
        const Divider(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildButtonShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Buttons
        const Text(
          'Primary Buttons',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          size: AppButtonSize.lg,
          onPressed: () {},
          child: const Text('Primary Large'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          onPressed: () {},
          child: const Text('Primary Medium'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          size: AppButtonSize.sm,
          onPressed: () {},
          child: const Text('Primary Small'),
        ),
        const SizedBox(height: AppSpacing.md),

        // Secondary Buttons
        const Text(
          'Secondary Buttons',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          variant: AppButtonVariant.secondary,
          onPressed: () {},
          child: const Text('Secondary Button'),
        ),
        const SizedBox(height: AppSpacing.md),

        // Outline Buttons
        const Text(
          'Outline Buttons',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          variant: AppButtonVariant.outline,
          onPressed: () {},
          child: const Text('Outline Button'),
        ),
        const SizedBox(height: AppSpacing.md),

        // Text Buttons
        const Text(
          'Text Buttons',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          variant: AppButtonVariant.text,
          onPressed: () {},
          child: const Text('Text Button'),
        ),
        const SizedBox(height: AppSpacing.md),

        // Icon Buttons
        const Text(
          'Icon Buttons',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            AppButton(
              size: AppButtonSize.sm,
              onPressed: () {},
              child: const Icon(Icons.favorite),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              size: AppButtonSize.sm,
              onPressed: () {},
              child: const Icon(Icons.share),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              size: AppButtonSize.sm,
              onPressed: () {},
              child: const Icon(Icons.bookmark),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Loading State
        const Text(
          'Loading State',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          onPressed: () {},
          isLoading: true,
          child: const Text('Loading...'),
        ),
      ],
    );
  }

  Widget _buildTextFieldShowcase() {
    return Column(
      children: [
        AppTextField(
          label: 'Email',
          hint: 'Enter your email',
          controller: _textController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          obscureText: true,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: Icon(Icons.visibility),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppTextField(
          label: 'Bio',
          hint: 'Tell us about yourself',
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.md),
        const AppTextField(
          label: 'Disabled Field',
          hint: 'This field is disabled',
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildAvatarShowcase() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avatar Sizes', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            AppAvatar(
              name: 'John Doe',
              size: AvatarSize.small,
            ),
            SizedBox(width: AppSpacing.sm),
            AppAvatar(
              name: 'Jane Smith',
            ),
            SizedBox(width: AppSpacing.sm),
            AppAvatar(
              name: 'Bob Johnson',
              size: AvatarSize.large,
            ),
            SizedBox(width: AppSpacing.sm),
            AppAvatar(
              name: 'Alice Williams',
              size: AvatarSize.extraLarge,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Avatar with Badge',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            AppAvatar(
              name: 'Online User',
              size: AvatarSize.large,
              showBadge: true,
              badgeColor: Colors.green,
            ),
            SizedBox(width: AppSpacing.sm),
            AppAvatar(
              name: 'Busy User',
              size: AvatarSize.large,
              showBadge: true,
              badgeColor: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeShowcase() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _buildSimpleBadge('LIVE', Colors.red),
        _buildSimpleBadge('Premium', Colors.orange, Icons.star),
        _buildSimpleBadge('Verified', Colors.blue, Icons.verified),
        _buildSimpleBadge('New', Colors.green),
        _buildSimpleBadge('5 notifications', Colors.grey),
      ],
    );
  }

  Widget _buildSimpleBadge(String text, Color color, [IconData? icon]) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardShowcase() {
    return Column(
      children: [
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Card',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.sm),
              Text('This is a basic card with shadow and border.'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PostCard(
          authorName: 'John Doe',
          authorAvatar: 'https://i.pravatar.cc/150?img=1',
          timeAgo: '2 hours ago',
          content: 'This is a sample post card with all the features!',
          likes: 42,
          comments: 12,
          shares: 5,
          isLiked: _isLiked,
          onLike: () => setState(() => _isLiked = !_isLiked),
        ),
      ],
    );
  }

  Widget _buildFlippableCardShowcase() {
    return FlippablePostCard(
      authorName: 'Jane Smith',
      authorAvatar: 'https://i.pravatar.cc/150?img=2',
      timeAgo: '1 hour ago',
      content:
          'Check out this amazing flippable card! Tap "Read Description" to flip it.',
      description:
          'This is the back side of the card with a detailed description. '
          'The card flips with a smooth 3D animation. You can add as much text as you need here. '
          'The reaction bar below has haptic feedback when you interact with it!',
      imageUrl: 'https://picsum.photos/400/300',
      likes: 128,
      comments: 34,
      shares: 12,
      cheks: 56,
      isLiked: _isLiked,
      isChekked: _isChekked,
      onLike: () => setState(() => _isLiked = !_isLiked),
      onChek: () => setState(() => _isChekked = !_isChekked),
      onComment: () {},
      onShare: () {},
    );
  }
}
