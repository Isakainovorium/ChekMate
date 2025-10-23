import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Messaging Interface - Full-screen chat conversation view using design system components
/// Migrated to use AppInput, AppButton, AppScrollArea, AppAvatar, AppCard
class MessagingInterface extends StatefulWidget {
  const MessagingInterface({
    required this.recipientName,
    required this.recipientUsername,
    required this.recipientAvatar,
    super.key,
  });

  final String recipientName;
  final String recipientUsername;
  final String recipientAvatar;

  @override
  State<MessagingInterface> createState() => _MessagingInterfaceState();
}

class _MessagingInterfaceState extends State<MessagingInterface> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'Hey! I saw your latest video, it was amazing! 😍',
      timestamp: '2h ago',
      isOwn: false,
    ),
    ChatMessage(
      id: '2',
      text: 'Thank you so much! I really appreciate that 💕',
      timestamp: '2h ago',
      isOwn: true,
    ),
    ChatMessage(
      id: '3',
      text:
          'The way you told that story was so engaging. I was on the edge of my seat the whole time!',
      timestamp: '1h ago',
      isOwn: false,
    ),
    ChatMessage(
      id: '4',
      text:
          'That means the world to me! I put a lot of effort into making it compelling',
      timestamp: '1h ago',
      isOwn: true,
    ),
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          text: _messageController.text.trim(),
          timestamp: 'Just now',
          isOwn: true,
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: AppButton(
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.text,
          size: AppButtonSize.sm,
          child: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            AppAvatar(
              imageUrl: widget.recipientAvatar,
              name: widget.recipientName,
              size: AppAvatarSize.small,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '@${widget.recipientUsername}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            onPressed: () => _startVideoCall(),
            variant: AppButtonVariant.text,
            size: AppButtonSize.sm,
            child: const Icon(Icons.videocam, color: AppColors.primary),
          ),
          AppButton(
            onPressed: () => _startVoiceCall(),
            variant: AppButtonVariant.text,
            size: AppButtonSize.sm,
            child: const Icon(Icons.call, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: AppScrollArea(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _MessageBubble(
                    message: message.text,
                    isOwn: message.isOwn,
                    timestamp: message.timestamp,
                    showAvatar: !message.isOwn,
                    avatarUrl: message.isOwn ? null : widget.recipientAvatar,
                  );
                },
              ),
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                AppButton(
                  onPressed: () => _showAttachmentOptions(),
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.sm,
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: AppInput(
                    controller: _messageController,
                    hint: 'Type a message...',
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  onPressed: _sendMessage,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.sm,
                  child: const Icon(Icons.send, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    AppSheet.show<void>(
      context: context,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Photo Library'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('File'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _startVideoCall() {
    AppDialog.show<void>(
      context: context,
      title: const Text('Start Video Call'),
      content: Text('Start video call with ${widget.recipientName}?'),
      actions: [
        AppButton(
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.text,
          child: const Text('Cancel'),
        ),
        AppButton(
          onPressed: () {
            Navigator.pop(context);
            AppSnackBar.show(
              context: context,
              message:
                  'Video call with ${widget.recipientName} would start here',
            );
          },
          child: const Text('Start Call'),
        ),
      ],
    );
  }

  void _startVoiceCall() {
    AppDialog.show<void>(
      context: context,
      title: const Text('Start Voice Call'),
      content: Text('Start voice call with ${widget.recipientName}?'),
      actions: [
        AppButton(
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.text,
          child: const Text('Cancel'),
        ),
        AppButton(
          onPressed: () {
            Navigator.pop(context);
            AppSnackBar.show(
              context: context,
              message:
                  'Voice call with ${widget.recipientName} would start here',
            );
          },
          child: const Text('Start Call'),
        ),
      ],
    );
  }
}

/// Message Bubble Widget using design system components
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.timestamp,
    required this.showAvatar,
    this.avatarUrl,
  });

  final String message;
  final bool isOwn;
  final String timestamp;
  final bool showAvatar;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn && showAvatar)
            AppAvatar(
              imageUrl: avatarUrl,
              name: 'User',
              size: AppAvatarSize.small,
            )
          else if (!isOwn)
            const SizedBox(width: 32),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOwn) const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Chat message model
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isOwn,
  });

  final String id;
  final String text;
  final String timestamp;
  final bool isOwn;
}
