import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';
import 'package:flutter_chekmate/features/profile/presentation/widgets/voice_prompt_player.dart';
import 'package:flutter_chekmate/features/profile/presentation/widgets/voice_prompt_recorder.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:uuid/uuid.dart';

/// Edit Profile page - converted from EditProfile.tsx
/// Modal for editing username and bio
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    required this.currentUsername,
    required this.currentBio,
    required this.userAvatar,
    required this.userId,
    super.key,
    this.onSave,
    this.currentVoicePrompts,
    this.currentBirthdate,
  });
  final String currentUsername;
  final String currentBio;
  final String userAvatar;
  final String userId;
  final void Function(
    String username,
    String bio,
    List<VoicePromptEntity> voicePrompts,
    DateTime? birthdate,
  )? onSave;
  final List<VoicePromptEntity>? currentVoicePrompts;
  final DateTime? currentBirthdate;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String _usernameError = '';
  bool _isUsernameValid = true;
  bool _hasChanges = false;
  List<VoicePromptEntity> _voicePrompts = [];
  bool _isUploading = false;
  DateTime? _birthdate;

  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;
  static const int maxVoicePrompts = 3;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    _bioController = TextEditingController(text: widget.currentBio);
    _voicePrompts = List.from(widget.currentVoicePrompts ?? []);
    _birthdate = widget.currentBirthdate;
    _usernameController.addListener(_checkChanges);
    _bioController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    setState(() {
      _hasChanges = _usernameController.text != widget.currentUsername ||
          _bioController.text != widget.currentBio ||
          _voicePrompts.length != (widget.currentVoicePrompts?.length ?? 0);
    });
  }

  bool _validateUsername(String value) {
    if (value.length < minUsernameLength) {
      setState(() {
        _usernameError =
            'Username must be at least $minUsernameLength characters';
        _isUsernameValid = false;
      });
      return false;
    }

    if (value.length > maxUsernameLength) {
      setState(() {
        _usernameError =
            'Username must be $maxUsernameLength characters or less';
        _isUsernameValid = false;
      });
      return false;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      setState(() {
        _usernameError =
            'Username can only contain letters, numbers, and underscores';
        _isUsernameValid = false;
      });
      return false;
    }

    if (value.startsWith('_') || value.endsWith('_')) {
      setState(() {
        _usernameError = 'Username cannot start or end with underscore';
        _isUsernameValid = false;
      });
      return false;
    }

    setState(() {
      _usernameError = '';
      _isUsernameValid = true;
    });
    return true;
  }

  void _handleSave() {
    if (!_isUsernameValid || !_hasChanges || _isUploading) return;

    if (_validateUsername(_usernameController.text)) {
      widget.onSave?.call(
        _usernameController.text.trim(),
        _bioController.text.trim(),
        _voicePrompts,
        _birthdate,
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleCancel() async {
    if (_hasChanges) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } else {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: _handleCancel,
          icon: const Icon(Icons.close),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: (_isUsernameValid && _hasChanges) ? _handleSave : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: (_isUsernameValid && _hasChanges)
                    ? AppColors.primary
                    : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Profile picture preview
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(widget.userAvatar),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Profile picture can be changed from settings',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Username field
            AppInput(
              controller: _usernameController,
              label: 'Username',
              hint: 'Enter your username',
              maxLength: maxUsernameLength,
              errorText: _usernameError.isEmpty ? null : _usernameError,
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              suffixIcon:
                  _isUsernameValid && _usernameController.text.isNotEmpty
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        )
                      : _usernameError.isNotEmpty
                          ? const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 20,
                            )
                          : null,
              onChanged: _validateUsername,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Bio field
            AppTextarea(
              controller: _bioController,
              label: 'Bio',
              hint: 'Tell us about yourself...',
              maxLength: maxBioLength,
              minLines: 4,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Birthdate field
            AppDateInput(
              initialDate: _birthdate,
              label: 'Birth Date',
              hint: 'Select your birth date',
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onDateChanged: (date) {
                setState(() {
                  _birthdate = date;
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Voice Prompts Section
            _buildVoicePromptsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildVoicePromptsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.mic, size: 16),
                SizedBox(width: 8),
                Text(
                  'Voice Prompts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '${_voicePrompts.length}/$maxVoicePrompts',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Add voice answers to prompts (max $maxVoicePrompts)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Display existing voice prompts
        ..._voicePrompts.map(
          (prompt) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Stack(
              children: [
                VoicePromptPlayer(
                  voicePrompt: prompt,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _deleteVoicePrompt(prompt),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Add voice prompt button
        if (_voicePrompts.length < maxVoicePrompts)
          OutlinedButton(
            onPressed: _isUploading ? null : _showQuestionSelector,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isUploading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.add, size: 18),
                const SizedBox(width: 8),
                Text(_isUploading ? 'Uploading...' : 'Add Voice Prompt'),
              ],
            ),
          ),
      ],
    );
  }

  void _showQuestionSelector() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a Prompt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                itemCount: VoicePromptQuestions.questions.length,
                itemBuilder: (context, index) {
                  final question = VoicePromptQuestions.getQuestion(index);
                  return ListTile(
                    leading: const Icon(Icons.mic_outlined),
                    title: Text(question),
                    onTap: () {
                      Navigator.pop(context);
                      _showVoicePromptRecorder(question);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoicePromptRecorder(String question) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoicePromptRecorder(
        question: question,
        onRecordingComplete: (voicePrompt) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          Navigator.pop(context);

          // Upload to Firebase Storage
          setState(() {
            _isUploading = true;
          });

          try {
            final uploadedPrompt = await _uploadVoicePrompt(voicePrompt);

            if (!mounted) return;

            setState(() {
              _voicePrompts.add(uploadedPrompt);
              _isUploading = false;
              _checkChanges();
            });

            // Show success message
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Voice prompt added!'),
                backgroundColor: Colors.green,
              ),
            );
          } on Exception catch (e) {
            if (!mounted) return;

            setState(() {
              _isUploading = false;
            });

            // Show error message
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Failed to upload voice prompt: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<VoicePromptEntity> _uploadVoicePrompt(
    VoicePromptEntity voicePrompt,
  ) async {
    try {
      // Generate unique ID for the prompt
      const uuid = Uuid();
      final promptId = uuid.v4();

      // Upload audio file to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('voice_prompts')
          .child(widget.userId)
          .child('$promptId.m4a');

      // Upload the file
      final file = File(voicePrompt.audioUrl); // Local file path
      await storageRef.putFile(file);

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Delete local file
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        await file.delete();
      }

      // Return updated voice prompt with Firebase Storage URL
      return VoicePromptEntity(
        id: promptId,
        question: voicePrompt.question,
        audioUrl: downloadUrl,
        duration: voicePrompt.duration,
        createdAt: voicePrompt.createdAt,
      );
    } on Exception catch (e) {
      debugPrint('Error uploading voice prompt: $e');
      rethrow;
    }
  }

  Future<void> _deleteVoicePrompt(VoicePromptEntity prompt) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Voice Prompt?'),
        content: const Text(
          'Are you sure you want to delete this voice prompt? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Delete from Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(prompt.audioUrl);
      await storageRef.delete();

      // Remove from local state
      setState(() {
        _voicePrompts.remove(prompt);
        _checkChanges();
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice prompt deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } on Exception catch (e) {
      debugPrint('Error deleting voice prompt: $e');

      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete voice prompt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
