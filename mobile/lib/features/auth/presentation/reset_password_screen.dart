import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../models/api_error.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/error_snackbar.dart';
import '../../../widgets/loading_overlay.dart';
import '../widgets/auth_form_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.email});

  final String? email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.email ?? '');
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).resetPassword(
            email: _email.text,
            code: _code.text,
            newPassword: _password.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset — sign in with your new password')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: LoadingOverlay(
        visible: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthFormField(
                  controller: _email,
                  label: 'Email',
                  readOnly: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  maxLength: AppConstants.otpLength,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'OTP code',
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.length != AppConstants.otpLength) {
                      return 'Enter the 6-digit code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _password,
                  label: 'New Password',
                  obscure: true,
                  validator: Validators.passwordStrong,
                ),
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _confirm,
                  label: 'Confirm Password',
                  obscure: true,
                  validator: (v) =>
                      Validators.confirmPassword(v, _password.text),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: const Text('Reset password'),
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
