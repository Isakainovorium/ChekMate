import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_constants.dart';
import '../../../shared/ui/components/app_alert.dart';
import '../../../shared/ui/components/app_breadcrumb.dart';
import '../../../shared/ui/components/app_button.dart';
import '../../../shared/ui/components/app_input_otp.dart';
import '../../../shared/ui/components/app_loading_spinner.dart';

/// Two-Factor Verification Page
/// 
/// Allows users to verify their identity using a 6-digit OTP code
/// sent via SMS or email. Includes resend functionality with countdown timer.
/// 
/// Date: 11/13/2025
class TwoFactorVerificationPage extends ConsumerStatefulWidget {
  const TwoFactorVerificationPage({super.key});

  @override
  ConsumerState<TwoFactorVerificationPage> createState() =>
      _TwoFactorVerificationPageState();
}

class _TwoFactorVerificationPageState
    extends ConsumerState<TwoFactorVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  String _otpCode = '';
  bool _isLoading = false;
  bool _isResending = false;
  int _countdownSeconds = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdownSeconds = 60;
    });
    _updateCountdown();
  }

  void _updateCountdown() {
    if (_countdownSeconds > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _countdownSeconds--;
          });
          _updateCountdown();
        }
      });
    }
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual OTP verification with Firebase Auth
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Navigate to home on success
        context.go(RouteConstants.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Invalid verification code. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (_countdownSeconds > 0) {
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual resend OTP functionality
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _startCountdown();
        setState(() {
          _isResending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to resend code. Please try again.';
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBreadcrumb(
                  items: const [
                    AppBreadcrumbItem(label: 'Authentication'),
                    AppBreadcrumbItem(label: 'Two-Factor Verification'),
                  ],
                ),
                const SizedBox(height: 32),
                const Icon(
                  Icons.security,
                  size: 64,
                  color: Colors.purple,
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter Verification Code',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit code to your registered email or phone number.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppInputOTP(
                  length: 6,
                  onChanged: (value) {
                    setState(() {
                      _otpCode = value;
                      _errorMessage = null;
                    });
                  },
                  onCompleted: (value) {
                    setState(() {
                      _otpCode = value;
                    });
                    _handleVerify();
                  },
                  autofocus: true,
                  errorText: _errorMessage,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  AppAlert(
                    message: _errorMessage!,
                    variant: AppAlertVariant.error,
                  ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  onPressed: _isLoading ? null : _handleVerify,
                  isLoading: _isLoading,
                  fullWidth: true,
                  child: const Text('Verify'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed:
                          _isResending || _countdownSeconds > 0
                              ? null
                              : _handleResendCode,
                      child: _isResending
                          ? const AppLoadingSpinner(size: AppLoadingSize.small)
                          : Text(
                              _countdownSeconds > 0
                                  ? 'Resend in ${_countdownSeconds}s'
                                  : 'Resend Code',
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

