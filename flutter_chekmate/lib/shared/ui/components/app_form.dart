import 'package:flutter/material.dart';

/// AppForm - Form wrapper with validation, submission, and error handling
class AppForm extends StatefulWidget {
  const AppForm({
    required this.child, super.key,
    this.onSubmit,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.initialValues = const {},
    this.validators = const {},
    this.enabled = true,
  });

  final Widget child;
  final void Function(Map<String, dynamic> values)? onSubmit;
  final void Function(Map<String, dynamic> values)? onChanged;
  final AutovalidateMode autovalidateMode;
  final Map<String, dynamic> initialValues;
  final Map<String, String? Function(dynamic)> validators;
  final bool enabled;

  @override
  State<AppForm> createState() => _AppFormState();

  /// Get the form state from context
  static AppFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AppFormState>();
  }
}

class _AppFormState extends State<AppForm> implements AppFormState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};
  final Map<String, String?> _errors = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _values.addAll(widget.initialValues);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: widget.autovalidateMode,
      child: AppFormScope(
        state: this,
        child: widget.child,
      ),
    );
  }

  @override
  Map<String, dynamic> get values => Map.unmodifiable(_values);

  @override
  Map<String, String?> get errors => Map.unmodifiable(_errors);

  @override
  bool get isSubmitting => _isSubmitting;

  @override
  bool get isValid => _formKey.currentState?.validate() ?? false;

  @override
  void setValue(String key, dynamic value) {
    setState(() {
      _values[key] = value;
      _errors.remove(key); // Clear error when value changes
    });
    widget.onChanged?.call(_values);
  }

  @override
  void setError(String key, String? error) {
    setState(() {
      if (error != null) {
        _errors[key] = error;
      } else {
        _errors.remove(key);
      }
    });
  }

  @override
  void clearErrors() {
    setState(() {
      _errors.clear();
    });
  }

  @override
  dynamic getValue(String key) {
    return _values[key];
  }

  @override
  String? getError(String key) {
    return _errors[key];
  }

  @override
  bool validate() {
    clearErrors();
    
    // Run Flutter form validation
    final isFormValid = _formKey.currentState?.validate() ?? false;
    
    // Run custom validators
    var hasCustomErrors = false;
    for (final entry in widget.validators.entries) {
      final key = entry.key;
      final validator = entry.value;
      final value = _values[key];
      final error = validator(value);
      
      if (error != null) {
        setError(key, error);
        hasCustomErrors = true;
      }
    }
    
    return isFormValid && !hasCustomErrors;
  }

  @override
  Future<void> submit() async {
    if (!widget.enabled || _isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      if (validate()) {
        widget.onSubmit?.call(_values);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void reset() {
    setState(() {
      _values.clear();
      _values.addAll(widget.initialValues);
      _errors.clear();
      _isSubmitting = false;
    });
    _formKey.currentState?.reset();
  }
}

/// Form state interface
abstract class AppFormState {
  Map<String, dynamic> get values;
  Map<String, String?> get errors;
  bool get isSubmitting;
  bool get isValid;
  
  void setValue(String key, dynamic value);
  void setError(String key, String? error);
  void clearErrors();
  dynamic getValue(String key);
  String? getError(String key);
  bool validate();
  Future<void> submit();
  void reset();
}

/// Form scope for providing form state to descendants
class AppFormScope extends InheritedWidget {
  const AppFormScope({
    required this.state, required super.child, super.key,
  });

  final AppFormState state;

  static AppFormState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppFormScope>()?.state;
  }

  @override
  bool updateShouldNotify(AppFormScope oldWidget) {
    return state != oldWidget.state;
  }
}

/// AppFormField - Base form field that integrates with AppForm
abstract class AppFormField<T> extends StatefulWidget {
  const AppFormField({
    required this.name, super.key,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.enabled,
  });

  final String name;
  final T? initialValue;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final bool? enabled;

  @override
  State<AppFormField<T>> createState() => AppFormFieldState<T>();
}

class AppFormFieldState<T> extends State<AppFormField<T>> {
  late T? _value;
  AppFormState? _formState;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formState = AppFormScope.of(context);
    
    // Initialize form value
    if (_formState != null && _value != null) {
      _formState!.setValue(widget.name, _value);
    }
  }

  T? get value => _value;
  
  String? get error => _formState?.getError(widget.name);
  
  bool get enabled => widget.enabled ?? _formState?.isValid != false;

  void setValue(T? newValue) {
    setState(() {
      _value = newValue;
    });
    
    _formState?.setValue(widget.name, newValue);
    widget.onChanged?.call(newValue);
  }

  String? validate(T? value) {
    return widget.validator?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError('AppFormField subclasses must implement build');
  }
}

/// AppSubmitButton - Button that integrates with form submission
class AppSubmitButton extends StatelessWidget {
  const AppSubmitButton({
    required this.child, super.key,
    this.onPressed,
    this.style,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final formState = AppFormScope.of(context);
    final isSubmitting = formState?.isSubmitting ?? false;
    
    return ElevatedButton(
      onPressed: isSubmitting 
          ? null 
          : onPressed ?? () => formState?.submit(),
      style: style,
      child: isSubmitting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : child,
    );
  }
}
