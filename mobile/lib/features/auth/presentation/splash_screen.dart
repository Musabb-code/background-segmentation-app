import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final started = DateTime.now();
    // ponytail: hard ceiling so splash never sticks if bootstrap hangs.
    try {
      await ref
          .read(authProvider.notifier)
          .bootstrap()
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      ref.read(authProvider.notifier).markLoggedOut();
    }
    final elapsed = DateTime.now().difference(started);
    final wait = const Duration(milliseconds: AppConstants.splashMaxMs) - elapsed;
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    if (!mounted) return;
    final authed = ref.read(authProvider).isAuthenticated;
    context.go(authed ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_fix_high, size: 72, color: scheme.primary),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
