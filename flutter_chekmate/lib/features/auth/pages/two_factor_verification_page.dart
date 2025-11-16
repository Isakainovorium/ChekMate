import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String? _verificationId; // For phone verification

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _sendInitialVerificationCode();
  }

  /// Send initial verification code when page loads
  Future<void> _sendInitialVerificationCode() async {
    if (widget.phoneNumber != null) {
      await _sendPhoneVerificationCode();
    } else if (widget.email != null) {
      await _sendEmailVerificationCode();
    }
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

  /// Validate verification code format (6 digits)
  bool _isValidVerificationCode(String code) {
    // Check if code is exactly 6 digits
    final digitRegex = RegExp(r'^\d{6}$');
    return digitRegex.hasMatch(code);
  }

  /// Verify code with Firebase Authentication
  Future<void> _verifyWithAuthService(String code) async {
    if (widget.phoneNumber != null) {
      // Phone verification
      await _verifyPhoneCode(code);
    } else if (widget.email != null) {
      // Email verification (using custom token or backend)
      await _verifyEmailCode(code);
    } else {
      throw Exception('No phone number or email provided for verification');
    }
  }

  /// Verify phone code using Firebase PhoneAuthProvider
  Future<void> _verifyPhoneCode(String code) async {
    if (_verificationId == null) {
      throw Exception('Verification ID not available. Please request a new code.');
    }

    try {
      // Create credential with verification ID and SMS code
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      // Sign in with the credential (for verification purposes)
      // Note: This might sign the user in, depending on the flow
      await FirebaseAuth.instance.signInWithCredential(credential);

      // If we get here, verification was successful
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          throw Exception('Invalid verification code. Please check and try again.');
        case 'invalid-verification-id':
          throw Exception('Verification expired. Please request a new code.');
        case 'code-expired':
          throw Exception('Verification code has expired. Please request a new code.');
        default:
          throw Exception('Verification failed: ${e.message}');
      }
    }
  }

  /// Verify email code (custom implementation since Firebase email verification uses links)
  Future<void> _verifyEmailCode(String code) async {
    // For email verification, we would typically need a backend service
    // that sends codes and verifies them. Since Firebase email verification
    // uses links by default, this is a placeholder for custom email code verification.

    // This would need to be implemented with a backend service that:
    // 1. Generates and stores verification codes for email addresses
    // 2. Sends codes via email
    // 3. Verifies codes against stored values

    // For now, simulate the verification process
    await Future<void>.delayed(const Duration(seconds: 1));

    // In a real implementation, this would call your backend API
    // Example: await _backendService.verifyEmailCode(widget.email!, code);

    // Simulate verification result
    if (code == '123456') { // This would be removed in production
      // Verification successful
      return;
    } else {
      throw Exception('Invalid verification code for email');
    }
  }

  Future<void> _verifyCode(String code) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // Validate code format first
      if (!_isValidVerificationCode(code)) {
        setState(() {
          _errorMessage = 'Please enter a valid 6-digit verification code.';
        });
        return;
      }

      // Verify with authentication service
      await _verifyWithAuthService(code);

      // Success - call callback and navigate
      if (mounted) {
        widget.onVerified?.call();
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please check your code and try again.';
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

    try {
      if (widget.phoneNumber != null) {
        await _sendPhoneVerificationCode();
      } else if (widget.email != null) {
        await _sendEmailVerificationCode();
      }

      _startCountdown();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send code: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Send phone verification code using Firebase
  Future<void> _sendPhoneVerificationCode() async {
    if (widget.phoneNumber == null) return;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber!,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification completed (Android only)
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) {
          widget.onVerified?.call();
          context.go('/');
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to send SMS: ${e.message}';
          });
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // Store verification ID for later use
        _verificationId = verificationId;
        if (mounted) {
          setState(() {
            _errorMessage = null;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  /// Send email verification code (requires backend service)
  Future<void> _sendEmailVerificationCode() async {
    if (widget.email == null) return;

    // This would need to be implemented with a backend service
    // Example: await _backendService.sendEmailVerificationCode(widget.email!);

    // For now, simulate sending
    await Future<void>.delayed(const Duration(seconds: 1));

    // In production, remove this simulation
    debugPrint('Email verification code sent to: ${widget.email}');
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
