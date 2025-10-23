import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/messages/presentation/providers/messages_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chat Page - One-on-one chat interface with design system components
/// Migrated to use AppInput, AppButton, AppScrollArea, AppAvatar, AppEmptyState
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    super.key,
  });

  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isOtherUserTyping = false;

  @override
  void initState() {
    super.initState();
    // Simulate typing indicator for demo (in production, listen to real-time typing events)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isOtherUserTyping = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _isOtherUserTyping = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(messagesStreamProvider(widget.conversationId));
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            HeroAvatar(
              tag: HeroTags.messageAvatar(widget.otherUserId),
              imageUrl: widget.otherUserAvatar,
              name: widget.otherUserName,
              radius: 16,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
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
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const AppEmptyState(
                    type: AppEmptyStateType.noMessages,
                    title: 'No messages yet',
                    message: 'Send a message to start the conversation',
                  );
                }

                return AppScrollArea(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    reverse: true,
                    itemCount: messages.length + (_isOtherUserTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show typing indicator at the top (index 0 in reverse list)
                      if (_isOtherUserTyping && index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                            left: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.sm,
                                ),
                                child: HeroAvatar(
                                  tag: HeroTags.messageAvatar(
                                    '${widget.otherUserId}_typing',
                                  ),
                                  imageUrl: widget.otherUserAvatar,
                                  name: widget.otherUserName,
                                  radius: 16,
                                ),
                              ),
                              const TypingIndicator(),
                            ],
                          ),
                        );
                      }

                      // Adjust index for actual messages
                      final messageIndex =
                          _isOtherUserTyping ? index - 1 : index;
                      final message = messages[messageIndex];
                      final isMe = message.senderId == currentUserId;
                      final showAvatar = messageIndex == 0 ||
                          messages[messageIndex - 1].senderId !=
                              message.senderId;

                      return _MessageBubble(
                        message: message.content,
                        isMe: isMe,
                        time: _formatTime(message.createdAt),
                        showAvatar: showAvatar,
                        userId:
                            isMe ? (currentUserId ?? 'me') : widget.otherUserId,
                        avatar: isMe ? null : widget.otherUserAvatar,
                        imageUrl: message.imageUrl,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: AppLoadingSpinner()),
              error: (Object error, StackTrace stack) => AppEmptyState(
                type: AppEmptyStateType.noConnection,
                title: 'Error loading messages',
                message: 'Error: $error',
                action: AppButton(
                  onPressed: () => ref.invalidate(
                    messagesStreamProvider(widget.conversationId),
                  ),
                  child: const Text('Retry'),
                ),
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
                  onPressed: () => _attachFile(),
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
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  onPressed: () => _sendMessage(),
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

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final messagesController = ref.read(messagesControllerProvider.notifier);

    try {
      await messagesController.sendMessage(
        conversationId: widget.conversationId,
        receiverId: widget.otherUserId,
        content: content,
      );

      _messageController.clear();
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } on Exception catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context: context,
          message: 'Failed to send message: $e',
          variant: AppAlertVariant.error,
        );
      }
    }
  }

  void _attachFile() {
    // Attach file functionality
  }

  void _startVideoCall() {
    // Video call functionality
  }

  void _startVoiceCall() {
    // Voice call functionality
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Message Bubble Widget using design system components
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.time,
    required this.showAvatar,
    required this.userId,
    this.avatar,
    this.imageUrl,
  });

  final String message;
  final bool isMe;
  final String time;
  final bool showAvatar;
  final String userId;
  final String? avatar;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar && avatar != null)
            HeroAvatar(
              tag: HeroTags.messageAvatar(userId),
              imageUrl: avatar!,
              name: 'User',
              radius: 16,
            )
          else if (!isMe)
            const SizedBox(width: 32),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl!,
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}
