import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/api_error.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/error_snackbar.dart';
import '../../../widgets/loading_overlay.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  int _cooldown = 0;
  Timer? _timer;
  // PLAN: 10 min OTP display (countdown from open)
  late int _otpRemainingSec;

  @override
  void initState() {
    super.initState();
    _otpRemainingSec = 10 * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_otpRemainingSec > 0) _otpRemainingSec--;
        if (_cooldown > 0) _cooldown--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  String get _email => widget.email?.trim() ?? '';

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    if (_email.isEmpty) {
      showErrorSnackbar(context, 'Missing email');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).verifyEmail(
            email: _email,
            code: _code.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified — you can sign in')),
      );
      context.go('/login');
    } on ApiError catch (e) {
      if (mounted) showErrorSnackbar(context, e.message);
    } catch (e) {
      if (mounted) showErrorSnackbar(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resend() {
    // PLAN has no /resend endpoint — cooldown UI + inbox reminder (YAGNI).
    if (_cooldown > 0) return;
    setState(() => _cooldown = AppConstants.otpResendCooldownSec);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Use the 6-digit code from your registration email (valid 10 minutes).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: LoadingOverlay(
        visible: _loading,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _email.isEmpty ? 'Enter the code sent to your email' : 'Code sent to $_email',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Code expires in ${_fmt(_otpRemainingSec)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: AppConstants.otpLength,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: '6-digit code',
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.length != AppConstants.otpLength) {
                      return 'Enter the 6-digit code';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _verify,
                  child: const Text('Verify'),
                ),
                TextButton(
                  onPressed: _cooldown > 0 ? null : _resend,
                  child: Text(
                    _cooldown > 0
                        ? 'Resend OTP (${_cooldown}s)'
                        : 'Resend OTP',
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
