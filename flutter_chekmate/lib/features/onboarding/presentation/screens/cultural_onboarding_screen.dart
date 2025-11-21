import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/services/cultural/cultural_vector_service.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/cultural/models/cultural_profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Free-form cultural onboarding screen
/// Allows users to express their cultural identity in their own words
class CulturalOnboardingScreen extends ConsumerStatefulWidget {
  const CulturalOnboardingScreen({super.key});

  @override
  ConsumerState<CulturalOnboardingScreen> createState() =>
      _CulturalOnboardingScreenState();
}

class _CulturalOnboardingScreenState
    extends ConsumerState<CulturalOnboardingScreen> {
  final _heritageController = TextEditingController();
  final _communitiesController = TextEditingController();
  final _generationController = TextEditingController();
  final _practicesController = TextEditingController();
  final _interestsController = TextEditingController();
  final _regionalController = TextEditingController();

  int _currentStep = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Your Cultural Story'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),

            // Main content
            Expanded(
              child: Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: theme.colorScheme.primary,
                  ),
                ),
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  controlsBuilder: _buildControls,
                  steps: [
                    Step(
                      title: const Text('Heritage'),
                      content: _buildHeritageStep(),
                      isActive: _currentStep >= 0,
                      state: _getStepState(0),
                    ),
                    Step(
                      title: const Text('Communities'),
                      content: _buildCommunitiesStep(),
                      isActive: _currentStep >= 1,
                      state: _getStepState(1),
                    ),
                    Step(
                      title: const Text('Generation'),
                      content: _buildGenerationStep(),
                      isActive: _currentStep >= 2,
                      state: _getStepState(2),
                    ),
                    Step(
                      title: const Text('Practices'),
                      content: _buildPracticesStep(),
                      isActive: _currentStep >= 3,
                      state: _getStepState(3),
                    ),
                    Step(
                      title: const Text('Interests'),
                      content: _buildInterestsStep(),
                      isActive: _currentStep >= 4,
                      state: _getStepState(4),
                    ),
                    Step(
                      title: const Text('Regional Influence'),
                      content: _buildRegionalStep(),
                      isActive: _currentStep >= 5,
                      state: _getStepState(5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == 5;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          if (isLastStep)
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitProfile,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Complete'),
            )
          else
            ElevatedButton(
              onPressed: details.onStepContinue,
              child: const Text('Continue'),
            ),
          const SizedBox(width: 12),
          if (_currentStep > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Back'),
            ),
          const Spacer(),
          TextButton(
            onPressed: isLastStep
                ? _submitProfile
                : () {
                    setState(() {
                      _currentStep++;
                    });
                  },
            child: Text(isLastStep ? 'Skip & Complete' : 'Skip'),
          ),
        ],
      ),
    );
  }

  StepState _getStepState(int step) {
    if (_currentStep > step) {
      return StepState.complete;
    } else if (_currentStep == step) {
      return StepState.editing;
    } else {
      return StepState.indexed;
    }
  }

  Widget _buildHeritageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where is your family from?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tell us about your heritage in your own words. '
          'This helps us understand your cultural background.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _heritageController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText:
                'e.g., "My parents are from Jamaica, I grew up in Brooklyn '
                'surrounded by Caribbean culture"',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildCommunitiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What communities do you belong to?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'List communities, groups, or cultures you identify with. '
          'Separate each with a comma.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _communitiesController,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'e.g., Caribbean diaspora, hip-hop culture, '
                'young Black professionals, Brooklyn natives',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildSuggestionChip('Caribbean diaspora'),
            _buildSuggestionChip('Hip-hop culture'),
            _buildSuggestionChip('Tech community'),
            _buildSuggestionChip('LGBTQ+'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How would you describe your generation?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tell us about your age group or generation in your own words.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _generationController,
          maxLines: 2,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'e.g., "Gen Z, born in 2005, grew up with social media '
                'and streaming culture"',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildPracticesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What cultural traditions matter to you?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'List cultural practices, traditions, or customs that are '
          'important to you. Separate with commas.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _practicesController,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            hintText:
                'e.g., Sunday dinners with family, Carnival celebrations, '
                'speaking patois, Caribbean cooking',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What cultural interests resonate with you?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'List cultural expressions, art forms, or interests. '
          'Be as specific as you like!',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _interestsController,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            hintText:
                'e.g., Afrobeats music, street fashion, natural hair care, '
                'Caribbean literature, dancehall parties',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildSuggestionChip('Music'),
            _buildSuggestionChip('Fashion'),
            _buildSuggestionChip('Food'),
            _buildSuggestionChip('Art'),
            _buildSuggestionChip('Dance'),
          ],
        ),
      ],
    );
  }

  Widget _buildRegionalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where did you grow up?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tell us about the place that shaped you.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regionalController,
          maxLines: 2,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'e.g., "Brooklyn, NYC - specifically Flatbush, '
                'surrounded by Caribbean culture"',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        // Add to appropriate controller
        if (_currentStep == 1) {
          // Communities
          final current = _communitiesController.text;
          _communitiesController.text =
              current.isEmpty ? label : '$current, $label';
        } else if (_currentStep == 4) {
          // Interests
          final current = _interestsController.text;
          _interestsController.text =
              current.isEmpty ? label : '$current, $label';
        }
      },
    );
  }

  void _onStepContinue() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _submitProfile();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitProfile() async {
    setState(() => _isSubmitting = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Parse comma-separated lists
      final communities = _communitiesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final practices = _practicesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final interests = _interestsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Generate cultural vector
      final vectorService = CulturalVectorService();

      // Combine all inputs into a single text for embedding
      final textParts = <String>[];
      if (_heritageController.text.isNotEmpty) {
        textParts.add('Heritage: ${_heritageController.text}');
      }
      if (communities.isNotEmpty) {
        textParts.add('Communities: ${communities.join(", ")}');
      }
      if (_generationController.text.isNotEmpty) {
        textParts.add('Generation: ${_generationController.text}');
      }
      if (practices.isNotEmpty) {
        textParts.add('Practices: ${practices.join(", ")}');
      }
      if (interests.isNotEmpty) {
        textParts.add('Interests: ${interests.join(", ")}');
      }
      if (_regionalController.text.isNotEmpty) {
        textParts.add('Regional: ${_regionalController.text}');
      }

      final combinedText = textParts.join('. ');
      final vector = combinedText.isNotEmpty
          ? await vectorService.generateEmbedding(combinedText)
          : null;

      // Create cultural profile
      final profile = CulturalProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        heritageDescription: _heritageController.text.isNotEmpty
            ? _heritageController.text
            : null,
        communityAffiliations: communities,
        generationalIdentity: _generationController.text.isNotEmpty
            ? _generationController.text
            : null,
        culturalPractices: practices,
        culturalInterests: interests,
        regionalInfluence: _regionalController.text.isNotEmpty
            ? _regionalController.text
            : null,
        culturalVector: vector,
        profileRichness: CulturalProfile.calculateRichness(
          CulturalProfile(
            id: '',
            userId: '',
            heritageDescription: _heritageController.text.isNotEmpty
                ? _heritageController.text
                : null,
            communityAffiliations: communities,
            generationalIdentity: _generationController.text.isNotEmpty
                ? _generationController.text
                : null,
            culturalPractices: practices,
            culturalInterests: interests,
            regionalInfluence: _regionalController.text.isNotEmpty
                ? _regionalController.text
                : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await _saveCulturalProfile(profile);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              profile.hasContent
                  ? 'Your cultural profile has been created!'
                  : 'Profile created! You can add more details anytime.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to next screen
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _saveCulturalProfile(CulturalProfile profile) async {
    await FirebaseFirestore.instance
        .collection('cultural_profiles')
        .doc(profile.userId)
        .set(profile.toJson());
  }

  @override
  void dispose() {
    _heritageController.dispose();
    _communitiesController.dispose();
    _generationController.dispose();
    _practicesController.dispose();
    _interestsController.dispose();
    _regionalController.dispose();
    super.dispose();
  }
}
