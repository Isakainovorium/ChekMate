import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers/providers.dart';
import '../../core/services/file_picker_service.dart';
import '../../features/messages/domain/entities/message_entity.dart';
import '../../features/messages/domain/usecases/send_message_usecase.dart';
import '../../features/messages/presentation/providers/messages_providers.dart';

/// Chat Page - Individual conversation view
///
/// Displays messages for a specific conversation with another user.
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
  late final SendMessageUseCase _sendMessageUseCase;
  late final FirebaseStorage _storage;

  @override
  void initState() {
    super.initState();
    _sendMessageUseCase = SendMessageUseCase(ref.read(messagesRepositoryProvider));
    _storage = FirebaseStorage.instance;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to bottom of messages
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Show attachment options bottom sheet
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Share',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),

            // Attachment options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromGallery();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhotoWithCamera();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickVideoFromGallery();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam_outlined,
                  label: 'Record',
                  onTap: () {
                    Navigator.of(context).pop();
                    _recordVideoWithCamera();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Cancel button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build attachment option widget
  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final images = await FilePickerService.pickImages(maxFiles: 5);
      if (images.isNotEmpty) {
        await _sendImageMessage(images);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Take photo with camera
  Future<void> _takePhotoWithCamera() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Capture photo from camera
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Compress for faster upload and storage
        preferredCameraDevice: CameraDevice.rear, // Use rear camera by default
      );

      if (photo != null) {
        final photoFile = File(photo.path);

        // Send the captured photo as a message
        await _sendImageMessage([photoFile]);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured and sent!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick video from gallery
  Future<void> _pickVideoFromGallery() async {
    try {
      final video = await FilePickerService.pickVideo();
      if (video != null) {
        await _sendVideoMessage(video);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Record video with camera
  Future<void> _recordVideoWithCamera() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Record video from camera
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 90), // Limit video length to 1:30
        preferredCameraDevice: CameraDevice.rear,
      );

      if (video != null) {
        final videoFile = File(video.path);
        await _sendVideoMessage(videoFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Upload image to Firebase Storage for chat messages
  Future<String> _uploadChatImage({
    required String conversationId,
    required String senderId,
    required Uint8List imageData,
    required String messageId,
  }) async {
    final fileName = 'chat_${conversationId}_${messageId}_image.jpg';
    final ref = _storage.ref().child('messages/$conversationId/$fileName');

    await ref.putData(
      imageData,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return ref.getDownloadURL();
  }

  /// Upload video to Firebase Storage for chat messages
  Future<String> _uploadChatVideo({
    required String conversationId,
    required String senderId,
    required Uint8List videoData,
    required String messageId,
  }) async {
    final fileName = 'chat_${conversationId}_${messageId}_video.mp4';
    final ref = _storage.ref().child('messages/$conversationId/$fileName');

    await ref.putData(
      videoData,
      SettableMetadata(contentType: 'video/mp4'),
    );

    return ref.getDownloadURL();
  }

  /// Send text message
  Future<void> _sendTextMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      final currentUserId = ref.read(currentUserIdProvider).value;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get current user info (you might need to add this provider or get from user provider)
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User data not available');
      }

      await _sendMessageUseCase.call(
        conversationId: widget.conversationId,
        senderId: currentUserId,
        senderName: currentUser.username,
        senderAvatar: currentUser.avatar,
        receiverId: widget.otherUserId,
        content: content,
      );

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Send image message
  Future<void> _sendImageMessage(List<File> images) async {
    try {
      final currentUserId = ref.read(currentUserIdProvider).value;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User data not available');
      }

      for (final imageFile in images) {
        final imageData = await imageFile.readAsBytes();

        // Generate a temporary message ID for upload
        final messageId = DateTime.now().millisecondsSinceEpoch.toString();

        // Upload image
        final imageUrl = await _uploadChatImage(
          conversationId: widget.conversationId,
          senderId: currentUserId,
          imageData: imageData,
          messageId: messageId,
        );

        // Send message with image
        await _sendMessageUseCase.call(
          conversationId: widget.conversationId,
          senderId: currentUserId,
          senderName: currentUser.username,
          senderAvatar: currentUser.avatar,
          receiverId: widget.otherUserId,
          content: '', // Empty content for image messages
          imageUrl: imageUrl,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent ${images.length} image${images.length > 1 ? 's' : ''}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Send video message
  Future<void> _sendVideoMessage(File videoFile) async {
    try {
      final currentUserId = ref.read(currentUserIdProvider).value;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User data not available');
      }

      final videoData = await videoFile.readAsBytes();

      // Generate unique ID for upload
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload video
      final videoUrl = await _uploadChatVideo(
        conversationId: widget.conversationId,
        senderId: currentUserId,
        videoData: videoData,
        messageId: messageId,
      );

      // Send message with video
      await _sendMessageUseCase.call(
        conversationId: widget.conversationId,
        senderId: currentUserId,
        senderName: currentUser.username,
        senderAvatar: currentUser.avatar,
        receiverId: widget.otherUserId,
        content: '', // Empty content for video messages
        videoUrl: videoUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Start a video call with the other user
  Future<void> _startVideoCall() async {
    // Show coming soon dialog with basic call structure
    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Video Call'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                'Video calling with ${widget.otherUserName.isNotEmpty ? widget.otherUserName : "this user"}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'This feature is coming soon!',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Future Implementation:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Camera and microphone permissions\n'
                      '• WebRTC or third-party service integration\n'
                      '• Real-time video streaming\n'
                      '• Call controls (mute, hang up, etc.)\n'
                      '• Push notifications for incoming calls',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Start a voice call with the other user
  Future<void> _startVoiceCall() async {
    // Show coming soon dialog with basic call structure
    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Voice Call'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.phone,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Voice calling ${widget.otherUserName.isNotEmpty ? widget.otherUserName : "this user"}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'This feature is coming soon!',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Future Implementation:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Microphone permissions\n'
                      '• WebRTC or VoIP service integration\n'
                      '• Real-time audio streaming\n'
                      '• Call controls (mute, speaker, hang up)\n'
                      '• Push notifications for incoming calls\n'
                      '• Call history and duration tracking',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Build a message bubble widget
  Widget _buildMessageBubble(MessageEntity message) {
    final currentUserId = ref.watch(currentUserIdProvider).value;
    final isFromCurrentUser = message.senderId == currentUserId;

    return Align(
      alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isFromCurrentUser ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isFromCurrentUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isFromCurrentUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message content
            if (message.isTextMessage)
              Text(
                message.content,
                style: TextStyle(
                  color: isFromCurrentUser ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              )
            else if (message.isVoiceMessage)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: isFromCurrentUser ? Colors.white : Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message.formattedVoiceDuration ?? 'Voice message',
                    style: TextStyle(
                      color: isFromCurrentUser ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            else if (message.isImageMessage)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(message.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Text(
                'Unsupported message type',
                style: TextStyle(
                  color: isFromCurrentUser ? Colors.white : Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              ),

            // Timestamp
            const SizedBox(height: 4),
            Text(
              message.formattedTimestamp,
              style: TextStyle(
                color: isFromCurrentUser ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUserAvatar.isNotEmpty
                  ? NetworkImage(widget.otherUserAvatar)
                  : null,
              child: widget.otherUserAvatar.isEmpty
                  ? Text(widget.otherUserName.isNotEmpty
                      ? widget.otherUserName[0].toUpperCase()
                      : '?')
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName
                    : 'User',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _startVoiceCall,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // Scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error loading messages: $error'),
              ),
            ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAttachmentOptions,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        _sendTextMessage(_messageController.text.trim());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

