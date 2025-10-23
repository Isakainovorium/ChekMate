import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// LoginForm - Authentication form for user login
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    this.onLogin,
    this.onForgotPassword,
    this.onSignUp,
    this.isLoading = false,
    this.errorMessage,
    this.showSocialLogin = true,
    this.showSignUpLink = true,
    this.showForgotPassword = true,
  });

  final Future<void> Function(String email, String password)? onLogin;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;
  final bool isLoading;
  final String? errorMessage;
  final bool showSocialLogin;
  final bool showSignUpLink;
  final bool showForgotPassword;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await widget.onLogin?.call(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppForm(
      onSubmit: (values) async {
        if (_formKey.currentState?.validate() ?? false) {
          await widget.onLogin?.call(
            (values['email'] as String?) ?? _emailController.text,
            (values['password'] as String?) ?? _passwordController.text,
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Welcome Back',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sign in to your account',
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
            textInputAction: TextInputAction.done,
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
            onSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Remember me & Forgot password
          Row(
            children: [
              AppCheckbox(
                value: _rememberMe,
                onChanged: widget.isLoading
                    ? null
                    : (value) => setState(() => _rememberMe = value ?? false),
                label: 'Remember me',
              ),
              const Spacer(),
              if (widget.showForgotPassword)
                TextButton(
                  onPressed: widget.isLoading ? null : widget.onForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Login button
          AppButton(
            onPressed: widget.isLoading ? null : _handleLogin,
            isLoading: widget.isLoading,
            child: const Text('Sign In'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Social login
          if (widget.showSocialLogin) ...[
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'Or continue with',
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
                  child: _SocialLoginButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            // Handle Google login
                          },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _SocialLoginButton(
                    icon: Icons.apple,
                    label: 'Apple',
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            // Handle Apple login
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Sign up link
          if (widget.showSignUpLink)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: widget.isLoading ? null : widget.onSignUp,
                  child: Text(
                    'Sign Up',
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

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
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

/// LoginFormConfig - Configuration for login form behavior
class LoginFormConfig {
  const LoginFormConfig({
    this.showSocialLogin = true,
    this.showSignUpLink = true,
    this.showForgotPassword = true,
    this.showRememberMe = true,
    this.minPasswordLength = 6,
    this.enableEmailValidation = true,
    this.socialProviders = const ['google', 'apple'],
  });

  final bool showSocialLogin;
  final bool showSignUpLink;
  final bool showForgotPassword;
  final bool showRememberMe;
  final int minPasswordLength;
  final bool enableEmailValidation;
  final List<String> socialProviders;
}

/// LoginFormController - Controller for managing login form state
class LoginFormController extends ChangeNotifier {
  LoginFormController({
    this.config = const LoginFormConfig(),
  });

  final LoginFormConfig config;

  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setRememberMe(bool remember) {
    _rememberMe = remember;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    setLoading(true);
    clearError();

    try {
      // Implement login logic here
      await Future<void>.delayed(
        const Duration(seconds: 2),
      ); // Simulate API call

      // Handle successful login
    } on Exception catch (e) {
      setError('Login failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
}
