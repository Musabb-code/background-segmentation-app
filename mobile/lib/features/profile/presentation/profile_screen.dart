import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/validators.dart';
import '../../../models/api_error.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/error_snackbar.dart';
import '../../../widgets/loading_overlay.dart';
import '../../auth/widgets/auth_form_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loading = false;

  Future<void> _editName() async {
    final user = ref.read(authProvider).user;
    final controller = TextEditingController(text: user?.fullName ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Full name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final err = Validators.fullName(controller.text);
    if (err != null) {
      showErrorSnackbar(context, err);
      return;
    }
    setState(() => _loading = true);
    try {
      final updated = await ref
          .read(userRepositoryProvider)
          .updateFullName(controller.text);
      await ref.read(authProvider.notifier).applyUser(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated')),
        );
      }
    } on ApiError catch (e) {
      if (mounted) showErrorSnackbar(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (x == null) return;
    setState(() => _loading = true);
    try {
      final updated = await ref
          .read(userRepositoryProvider)
          .uploadProfileImage(File(x.path));
      await ref.read(authProvider.notifier).applyUser(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo updated')),
        );
      }
    } on ApiError catch (e) {
      if (mounted) showErrorSnackbar(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthFormField(
                controller: current,
                label: 'Current password',
                obscure: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 12),
              AuthFormField(
                controller: next,
                label: 'New password',
                obscure: true,
                validator: Validators.passwordStrong,
              ),
              const SizedBox(height: 12),
              AuthFormField(
                controller: confirm,
                label: 'Confirm new password',
                obscure: true,
                validator: (v) => Validators.confirmPassword(v, next.text),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _loading = true);
    try {
      await ref.read(userRepositoryProvider).changePassword(
            currentPassword: current.text,
            newPassword: next.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated')),
        );
      }
    } on ApiError catch (e) {
      if (mounted) showErrorSnackbar(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final scheme = Theme.of(context).colorScheme;
    final verified = user?.isVerified ?? false;
    final imageUrl = user?.profileImageUrl;
    final width = MediaQuery.sizeOf(context).width;
    final maxW = width > 600 ? 480.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: LoadingOverlay(
        visible: _loading,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: scheme.primaryContainer,
                        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl == null || imageUrl.isEmpty
                            ? Icon(Icons.person, size: 48, color: scheme.onPrimaryContainer)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          onPressed: _uploadPhoto,
                          icon: const Icon(Icons.camera_alt, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  title: const Text('Name'),
                  subtitle: Text(user?.fullName ?? '—'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _editName,
                  ),
                ),
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(user?.email ?? '—'),
                ),
                ListTile(
                  title: const Text('Verification'),
                  subtitle: Text(verified ? 'Verified' : 'Pending'),
                  leading: Icon(
                    verified ? Icons.verified : Icons.schedule,
                    color: verified ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _changePassword,
                  child: const Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
