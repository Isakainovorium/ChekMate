import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppInputOTP - OTP/PIN input with consistent styling
class AppInputOTP extends StatefulWidget {
  const AppInputOTP({
    required this.length, super.key,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.validator,
    this.errorText,
    this.spacing = AppSpacing.sm,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool obscureText;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? errorText;
  final double spacing;

  @override
  State<AppInputOTP> createState() => _AppInputOTPState();
}

class _AppInputOTPState extends State<AppInputOTP> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    // Auto-focus first field if enabled
    if (widget.autofocus && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste operation
      _handlePaste(value, index);
      return;
    }

    _controllers[index].text = value;

    // Move to next field if value entered
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Update current value
    _updateCurrentValue();
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          // Move to previous field if current is empty
          _focusNodes[index - 1].requestFocus();
        }
      }
    }
  }

  void _handlePaste(String pastedText, int startIndex) {
    final cleanText = pastedText.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
    
    for (var i = 0; i < widget.length && i < cleanText.length; i++) {
      final targetIndex = startIndex + i;
      if (targetIndex < widget.length) {
        _controllers[targetIndex].text = cleanText[i];
      }
    }

    // Focus last filled field or next empty field
    final lastFilledIndex = (startIndex + cleanText.length - 1).clamp(0, widget.length - 1);
    if (lastFilledIndex < widget.length - 1) {
      _focusNodes[lastFilledIndex + 1].requestFocus();
    }

    _updateCurrentValue();
  }

  void _updateCurrentValue() {
    final newValue = _controllers.map((c) => c.text).join();
    if (newValue != _currentValue) {
      _currentValue = newValue;
      widget.onChanged?.call(_currentValue);
      
      if (_currentValue.length == widget.length) {
        widget.onCompleted?.call(_currentValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            return Container(
              margin: EdgeInsets.only(
                right: index < widget.length - 1 ? widget.spacing : 0,
              ),
              child: SizedBox(
                width: 48,
                height: 56,
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onKeyPressed(index, event),
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: widget.enabled,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      ...?widget.inputFormatters,
                    ],
                    onChanged: (value) => _onChanged(index, value),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: hasError 
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: hasError 
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: hasError 
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.sm),
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        
        if (hasError) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// AppPinInput - Specialized PIN input with dots
class AppPinInput extends StatelessWidget {
  const AppPinInput({
    super.key,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.autofocus = false,
    this.errorText,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool autofocus;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AppInputOTP(
      length: length,
      onChanged: onChanged,
      onCompleted: onCompleted,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: true,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      errorText: errorText,
    );
  }
}
