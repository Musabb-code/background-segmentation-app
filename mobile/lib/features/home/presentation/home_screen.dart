import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/api_error.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/error_snackbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await ref.read(authProvider.notifier).refreshProfile();
    } on ApiError catch (e) {
      if (mounted) showErrorSnackbar(context, e.message);
    } catch (_) {
      // Keep cached auth user if refresh fails.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final width = MediaQuery.sizeOf(context).width;
    final maxW = width > 600 ? 480.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _ProfileCard(user: user),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () => context.push('/camera'),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Open Pixel Lift'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/profile'),
                      child: const Text('View Profile'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final User? user;

  String get _initials {
    final n = user?.fullName.trim() ?? '';
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final verified = user?.isVerified ?? false;
    final imageUrl = user?.profileImageUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: scheme.primaryContainer,
              backgroundImage:
                  imageUrl != null && imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl == null || imageUrl.isEmpty
                  ? Text(
                      _initials,
                      style: TextStyle(
                        fontSize: 22,
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName.isNotEmpty == true ? user!.fullName : 'User',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        verified ? Icons.verified : Icons.schedule,
                        size: 18,
                        color: verified ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        verified ? 'Verified' : 'Pending verification',
                        style: TextStyle(
                          color: verified ? Colors.green.shade700 : Colors.orange.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
