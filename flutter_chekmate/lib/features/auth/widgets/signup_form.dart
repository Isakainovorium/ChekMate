import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// SignupForm - User registration form with validation
class SignupForm extends StatefulWidget {
  const SignupForm({
    super.key,
    this.onSignUp,
    this.onLogin,
    this.isLoading = false,
    this.errorMessage,
    this.showSocialSignup = true,
    this.showLoginLink = true,
    this.requireTermsAcceptance = true,
    this.showNewsletterOption = true,
  });

  final Future<void> Function(SignupData data)? onSignUp;
  final VoidCallback? onLogin;
  final bool isLoading;
  final String? errorMessage;
  final bool showSocialSignup;
  final bool showLoginLink;
  final bool requireTermsAcceptance;
  final bool showNewsletterOption;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _subscribeNewsletter = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (widget.requireTermsAcceptance && !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Conditions'),
        ),
      );
      return;
    }

    final signupData = SignupData(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      acceptTerms: _acceptTerms,
      subscribeNewsletter: _subscribeNewsletter,
    );

    await widget.onSignUp?.call(signupData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppForm(
      onSubmit: (values) async {
        if ((_formKey.currentState?.validate() ?? false) && _acceptTerms) {
          final signupData = SignupData(
            firstName: (values['firstName'] as String?) ??
                _firstNameController.text.trim(),
            lastName: (values['lastName'] as String?) ??
                _lastNameController.text.trim(),
            email: (values['email'] as String?) ?? _emailController.text.trim(),
            password:
                (values['password'] as String?) ?? _passwordController.text,
            acceptTerms: _acceptTerms,
            subscribeNewsletter: _subscribeNewsletter,
          );
          await widget.onSignUp?.call(signupData);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Create Account',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Join us and start your journey',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Error message
          if (widget.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Name fields
          Row(
            children: [
              Expanded(
                child: AppInput(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Enter first name',
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) => _validateName(value, 'First name'),
                  enabled: !widget.isLoading,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppInput(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Enter last name',
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validateName(value, 'Last name'),
                  enabled: !widget.isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Email field
          AppInput(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: _validateEmail,
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Password field
          AppInput(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: _validatePassword,
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Confirm password field
          AppInput(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: _validateConfirmPassword,
            enabled: !widget.isLoading,
            onSubmitted: (_) => _handleSignUp(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Password requirements
          _PasswordRequirements(password: _passwordController.text),
          const SizedBox(height: AppSpacing.lg),

          // Terms and newsletter
          Column(
            children: [
              if (widget.requireTermsAcceptance)
                AppCheckbox(
                  value: _acceptTerms,
                  onChanged: widget.isLoading
                      ? null
                      : (value) =>
                          setState(() => _acceptTerms = value ?? false),
                  label: 'I accept the Terms and Conditions and Privacy Policy',
                ),
              if (widget.showNewsletterOption) ...[
                const SizedBox(height: AppSpacing.sm),
                AppCheckbox(
                  value: _subscribeNewsletter,
                  onChanged: widget.isLoading
                      ? null
                      : (value) =>
                          setState(() => _subscribeNewsletter = value ?? false),
                  label: 'Subscribe to newsletter for updates',
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Sign up button
          AppButton(
            onPressed: widget.isLoading ? null : _handleSignUp,
            isLoading: widget.isLoading,
            child: const Text('Create Account'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Social signup
          if (widget.showSocialSignup) ...[
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'Or sign up with',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _SocialSignupButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            // Handle Google signup
                          },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _SocialSignupButton(
                    icon: Icons.apple,
                    label: 'Apple',
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            // Handle Apple signup
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Login link
          if (widget.showLoginLink)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: widget.isLoading ? null : widget.onLogin,
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _RequirementItem(
            text: 'At least 8 characters',
            isValid: hasMinLength,
          ),
          _RequirementItem(
            text: 'One uppercase letter',
            isValid: hasUppercase,
          ),
          _RequirementItem(
            text: 'One lowercase letter',
            isValid: hasLowercase,
          ),
          _RequirementItem(
            text: 'One number',
            isValid: hasNumber,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({
    required this.text,
    required this.isValid,
  });

  final String text;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isValid
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isValid
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SocialSignupButton extends StatelessWidget {
  const _SocialSignupButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// SignupData - Data structure for user registration
class SignupData {
  const SignupData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.acceptTerms,
    this.subscribeNewsletter = false,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final bool acceptTerms;
  final bool subscribeNewsletter;

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'acceptTerms': acceptTerms,
      'subscribeNewsletter': subscribeNewsletter,
    };
  }
}

/// SignupFormController - Controller for managing signup form state
class SignupFormController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signUp(SignupData data) async {
    setLoading(true);
    clearError();

    try {
      // Implement signup logic here
      await Future<void>.delayed(
        const Duration(seconds: 2),
      ); // Simulate API call

      // Handle successful signup
    } on Exception catch (e) {
      setError('Signup failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
}
