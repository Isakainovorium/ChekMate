import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:go_router/go_router.dart';

/// Two-factor authentication verification page
class TwoFactorVerificationPage extends StatefulWidget {
  const TwoFactorVerificationPage({
    super.key,
    this.phoneNumber,
    this.email,
    this.onVerified,
  });

  final String? phoneNumber;
  final String? email;
  final VoidCallback? onVerified;

  @override
  State<TwoFactorVerificationPage> createState() =>
      _TwoFactorVerificationPageState();
}

class _TwoFactorVerificationPageState extends State<TwoFactorVerificationPage> {
  bool _isVerifying = false;
  bool _canResend = false;
  int _resendCountdown = 60;
  String? _errorMessage;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyCode(String code) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual verification logic
      if (code == '123456') {
        if (mounted) {
          widget.onVerified?.call();
          context.go('/');
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid verification code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    // TODO: Implement resend logic
    _startCountdown();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destination = widget.phoneNumber ?? widget.email ?? 'your device';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navyBlue),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Verification',
          style: TextStyle(
            color: AppColors.navyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              const Icon(
                Icons.security,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                'Enter Verification Code',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              Text(
                'We sent a 6-digit code to $destination',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Error message
              if (_errorMessage != null) ...[
                AppAlert(
                  message: _errorMessage!,
                  variant: AppAlertVariant.error,
                  showIcon: true,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // OTP Input
              AppInputOTP(
                length: 6,
                onCompleted: _isVerifying ? null : _verifyCode,
                autofocus: true,
                enabled: !_isVerifying,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Loading indicator
              if (_isVerifying) ...[
                const Center(
                  child: AppLoadingSpinner(
                    size: AppLoadingSize.medium,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Verifying code...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_canResend)
                    TextButton(
                      onPressed: _resendCode,
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Resend in ${_resendCountdown}s',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
