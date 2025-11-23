import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/services/cultural/translation_service.dart';

/// Translation interface widget
class TranslationInterface extends StatefulWidget {
  final String contentId;
  final String originalText;
  final String sourceCulture;

  const TranslationInterface({
    super.key,
    required this.contentId,
    required this.originalText,
    required this.sourceCulture,
  });

  @override
  State<TranslationInterface> createState() => _TranslationInterfaceState();
}

class _TranslationInterfaceState extends State<TranslationInterface> {
  String? _selectedTargetCulture;
  String? _translatedText;
  bool _isTranslating = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Translate Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedTargetCulture,
              decoration: const InputDecoration(
                labelText: 'Target Language',
                border: OutlineInputBorder(),
              ),
              items: TranslationService.instance
                  .getSupportedCultures()
                  .map((culture) => DropdownMenuItem(
                        value: culture,
                        child: Text(culture),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTargetCulture = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selectedTargetCulture == null || _isTranslating
                  ? null
                  : _translate,
              icon: _isTranslating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.translate),
              label: Text(_isTranslating ? 'Translating...' : 'Translate'),
            ),
            if (_translatedText != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_translatedText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _translate() async {
    setState(() {
      _isTranslating = true;
    });

    try {
      final translation = await TranslationService.instance.translateWithContext(
        contentId: widget.contentId,
        text: widget.originalText,
        sourceCulture: widget.sourceCulture,
        targetCulture: _selectedTargetCulture!,
      );

      setState(() {
        _translatedText = translation.translatedText;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }
}
