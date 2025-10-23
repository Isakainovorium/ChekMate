import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Post Creation Modal - converted from PostCreationModal.tsx
/// Full-screen modal for creating new posts
class PostCreationModal extends StatefulWidget {
  const PostCreationModal({
    required this.userAvatar,
    required this.onCreatePost,
    super.key,
  });
  final String userAvatar;
  final void Function(String) onCreatePost;

  @override
  State<PostCreationModal> createState() => _PostCreationModalState();
}

class _PostCreationModalState extends State<PostCreationModal> {
  final TextEditingController _controller = TextEditingController();
  static const int maxLength = 280;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty &&
        _controller.text.length <= maxLength) {
      widget.onCreatePost(_controller.text.trim());
      Navigator.of(context).pop();
    }
  }

  void _handleClose() {
    _controller.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
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
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Create Post',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: _handleClose,
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(widget.userAvatar),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    maxLength: maxLength,
                    maxLines: 4,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Share your dating story...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.sm),
                      counterText: '',
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        '${_controller.text.length}/$maxLength',
                        style: TextStyle(
                          fontSize: 12,
                          color: _controller.text.length > maxLength
                              ? Colors.red
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Divider(color: Colors.grey.shade100),
        const SizedBox(height: AppSpacing.md),
        _buildActionButtons(),
        const SizedBox(height: AppSpacing.md),
        _buildPostButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _buildActionButton(Icons.camera_alt, 'Photo'),
        _buildActionButton(Icons.image, 'Gallery'),
        _buildActionButton(Icons.emoji_emotions, 'Feeling'),
        _buildActionButton(Icons.location_on, 'Location'),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () => debugPrint('Action: $label'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostButtons() {
    final canPost = _controller.text.trim().isNotEmpty &&
        _controller.text.length <= maxLength;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _handleClose,
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ElevatedButton(
          onPressed: canPost ? _handleSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade200,
            disabledForegroundColor: Colors.grey.shade400,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child:
              const Text('Post', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
