import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  int _resendSecondsLeft = 30;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSecondsLeft > 0) _resendSecondsLeft--;
      });
      return _resendSecondsLeft > 0;
    });
  }

  Future<void> _verify() async {
    if (_otpController.text.length != AppConstants.otpLength) return;
    setState(() => _isSubmitting = true);
    final notifier = ref.read(authNotifierProvider.notifier);
    final success = await notifier.verifyOtp(
      phone: widget.phone,
      otp: _otpController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (success) {
      // Auth state now holds the user; the router redirects to home.
      return;
    }
    final error = notifier.consumeLastError();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error?.toString() ?? 'Invalid OTP'),
        backgroundColor: AppColors.errorColor,
      ),
    );
    _otpController.clear();
  }

  Future<void> _resend() async {
    if (_resendSecondsLeft > 0) return;
    await ref.read(authNotifierProvider.notifier).sendOtp(phone: widget.phone);
    setState(() => _resendSecondsLeft = 30);
    _startResendTimer();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP resent successfully')));
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isSubmitting;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Enter verification code',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                children: [
                  const TextSpan(text: 'We sent a 6-digit code to '),
                  TextSpan(
                    text: widget.phone,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Pinput(
                controller: _otpController,
                length: AppConstants.otpLength,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                ),
                onCompleted: (_) => _verify(),
              ),
            ),
            const SizedBox(height: 40),
            AppButton(
              label: 'Verify',
              onPressed: _verify,
              isLoading: isLoading,
            ),
            const SizedBox(height: 24),
            Center(
              child: _resendSecondsLeft > 0
                  ? Text(
                      'Resend OTP in $_resendSecondsLeft seconds',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : TextButton(
                      onPressed: _resend,
                      child: const Text('Resend OTP'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
