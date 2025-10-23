# Voice Content Integration Examples

This document provides complete integration examples for the voice content creation features implemented in Group 2.3.

---

## 📹 Voiceover for Videos Integration

### **Option 1: Add to VideoEditorPage as a Tab**

Update `lib/features/feed/pages/create_post/pages/video_editor_page.dart`:

```dart
import 'package:flutter_chekmate/features/voice_messages/presentation/widgets/voiceover_recorder.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';

class _VideoEditorPageState extends State<VideoEditorPage> {
  // ... existing state variables
  VoiceMessageEntity? _voiceoverAudio;

  Widget _buildEditingTools() {
    return DefaultTabController(
      length: 6, // Changed from 5 to 6
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Effects'),
              Tab(text: 'Green Screen'),
              Tab(text: 'Text'),
              Tab(text: 'Speed'),
              Tab(text: 'Music'),
              Tab(text: 'Voiceover'), // NEW TAB
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildEffectsTab(),
                _buildGreenScreenTab(),
                _buildTextTab(),
                _buildSpeedTab(),
                _buildMusicTab(),
                _buildVoiceoverTab(), // NEW TAB VIEW
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceoverTab() {
    if (_voiceoverAudio != null) {
      // Show voiceover preview
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Voiceover Added!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Duration: ${_voiceoverAudio!.formatDuration()}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              onPressed: () {
                setState(() {
                  _voiceoverAudio = null;
                });
              },
              variant: AppButtonVariant.outline,
              child: const Text('Remove Voiceover'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mic,
            color: AppColors.primary,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Add Voiceover',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Record audio narration over your video',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            onPressed: _showVoiceoverRecorder,
            child: const Text('Start Recording'),
          ),
        ],
      ),
    );
  }

  void _showVoiceoverRecorder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceoverRecorder(
        videoPath: widget.videoPath,
        videoDuration: 60, // Get actual video duration
        onRecordingComplete: (voiceMessage) {
          setState(() {
            _voiceoverAudio = voiceMessage;
          });
          Navigator.pop(context);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voiceover added! Tap Done to mix audio with video.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _saveVideo() async {
    // ... existing save logic
    
    if (_voiceoverAudio != null) {
      // Mix voiceover with video
      await _mixAudioWithVideo();
    }
    
    // ... rest of save logic
  }

  Future<void> _mixAudioWithVideo() async {
    // TODO: Implement audio mixing using FFmpeg or video_editor package
    // Example using FFmpeg:
    // 
    // final ffmpeg = FFmpegKit.execute(
    //   '-i ${widget.videoPath} -i ${_voiceoverAudio!.filePath} '
    //   '-filter_complex "[0:a][1:a]amix=inputs=2:duration=first:dropout_transition=2" '
    //   '-c:v copy output.mp4'
    // );
    //
    // For now, just show a placeholder message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio mixing will be implemented with FFmpeg'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
```

---

### **Option 2: Add to CreatePostPage as a Button**

Update `lib/features/feed/pages/create_post/pages/create_post_page.dart`:

```dart
import 'package:flutter_chekmate/features/voice_messages/presentation/widgets/voiceover_recorder.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  // ... existing state variables
  VoiceMessageEntity? _voiceoverAudio;

  Widget _buildMediaPreview() {
    if (_selectedMedia == null) return const SizedBox.shrink();

    return Column(
      children: [
        // ... existing media preview code
        
        // Add voiceover button for videos
        if (_selectedMediaType == 'video')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppButton(
              onPressed: _showVoiceoverRecorder,
              variant: _voiceoverAudio != null 
                  ? AppButtonVariant.filled 
                  : AppButtonVariant.outline,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _voiceoverAudio != null ? Icons.check_circle : Icons.mic,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _voiceoverAudio != null 
                        ? 'Voiceover Added (${_voiceoverAudio!.formatDuration()})' 
                        : 'Add Voiceover',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showVoiceoverRecorder() {
    if (_selectedMedia == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceoverRecorder(
        videoPath: _selectedMedia!.path,
        videoDuration: 60, // Get actual video duration
        onRecordingComplete: (voiceMessage) {
          setState(() {
            _voiceoverAudio = voiceMessage;
          });
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

---

## 🎤 Voice Prompts Integration

### **1. Add to EditProfilePage**

Update `lib/features/feed/subfeatures/profile/pages/edit_profile_page.dart`:

```dart
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';
import 'package:flutter_chekmate/features/profile/presentation/widgets/voice_prompt_recorder.dart';
import 'package:flutter_chekmate/features/profile/presentation/widgets/voice_prompt_player.dart';

class _EditProfilePageState extends State<EditProfilePage> {
  // ... existing state variables
  List<VoicePromptEntity> _voicePrompts = [];
  static const int maxVoicePrompts = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... existing scaffold code
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // ... existing profile fields (avatar, username, bio)
            
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
        ..._voicePrompts.map((prompt) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Stack(
            children: [
              VoicePromptPlayer(
                voicePrompt: prompt,
                autoPlay: false,
                showWaveform: true,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _voicePrompts.remove(prompt);
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(4),
                  ),
                ),
              ),
            ],
          ),
        )),
        
        // Add voice prompt button
        if (_voicePrompts.length < maxVoicePrompts)
          AppButton(
            onPressed: _showQuestionSelector,
            variant: AppButtonVariant.outline,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 18),
                SizedBox(width: 8),
                Text('Add Voice Prompt'),
              ],
            ),
          ),
      ],
    );
  }

  void _showQuestionSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoicePromptRecorder(
        question: question,
        onRecordingComplete: (voicePrompt) async {
          // Upload to Firebase Storage
          // For now, just add to local state
          setState(() {
            _voicePrompts.add(voicePrompt);
          });
          Navigator.pop(context);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voice prompt added!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleSave() {
    // ... existing save logic
    
    // TODO: Save voice prompts to user profile
    // await userService.updateVoicePrompts(userId, _voicePrompts);
  }
}
```

---

### **2. Display on ProfilePage**

Update `lib/features/feed/subfeatures/profile/pages/profile_page.dart`:

```dart
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';
import 'package:flutter_chekmate/features/profile/presentation/widgets/voice_prompt_player.dart';

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // ... existing state variables
  
  // Mock voice prompts (replace with actual data from user profile)
  final List<VoicePromptEntity> _voicePrompts = [
    VoicePromptEntity(
      id: '1',
      question: "What's your ideal date?",
      audioUrl: 'https://example.com/audio1.m4a',
      duration: 25,
      createdAt: DateTime.now(),
    ),
    VoicePromptEntity(
      id: '2',
      question: "What makes you laugh?",
      audioUrl: 'https://example.com/audio2.m4a',
      duration: 18,
      createdAt: DateTime.now(),
    ),
  ];

  Widget _buildProfileHeader(UserEntity user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // ... existing profile header code (avatar, name, bio, stats)
          
          // Voice Prompts Section
          if (_voicePrompts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Voice Prompts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._voicePrompts.map((prompt) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: VoicePromptPlayer(
                voicePrompt: prompt,
                autoPlay: false,
                showWaveform: true,
              ),
            )),
          ],
        ],
      ),
    );
  }
}
```

---

## 🔧 Additional Integration Notes

### **Firebase Storage Upload**

When saving voice prompts or voiceovers, upload to Firebase Storage:

```dart
Future<String> _uploadVoicePrompt(VoicePromptEntity prompt) async {
  final storageService = ref.read(storageServiceProvider);
  final currentUser = ref.read(currentUserProvider);
  
  if (currentUser == null) throw Exception('User not authenticated');
  
  // Upload audio file
  final audioUrl = await storageService.uploadFile(
    file: File(prompt.audioUrl), // Local file path
    path: 'voice_prompts/${currentUser.uid}/${prompt.id}.m4a',
  );
  
  return audioUrl;
}
```

### **Update UserModel**

Add voice prompts field to UserModel:

```dart
class UserModel {
  // ... existing fields
  final List<Map<String, dynamic>>? voicePrompts;
  
  Map<String, dynamic> toJson() {
    return {
      // ... existing fields
      'voicePrompts': voicePrompts,
    };
  }
}
```

---

## ✅ Integration Checklist

**Voiceover for Videos:**
- [ ] Add VoiceoverRecorder to VideoEditorPage or CreatePostPage
- [ ] Implement audio mixing with FFmpeg or video_editor package
- [ ] Upload mixed video to Firebase Storage
- [ ] Delete temporary files after upload
- [ ] Add error handling for audio mixing failures

**Voice Prompts:**
- [ ] Add voice prompts section to EditProfilePage
- [ ] Implement question selector
- [ ] Upload voice prompts to Firebase Storage
- [ ] Update UserModel to include voicePrompts field
- [ ] Display voice prompts on ProfilePage
- [ ] Add delete functionality for voice prompts
- [ ] Enforce max 3 prompts per profile limit

---

**Last Updated:** October 17, 2025

