import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/settings_service.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final settings = ref.watch(appSettingsProvider);
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final width = MediaQuery.sizeOf(context).width;
    final maxW = width > 600 ? 480.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: ListView(
            children: [
              ListTile(
                title: const Text('Camera Resolution'),
                subtitle: Text(switch (settings.resolution) {
                  CameraResolution.p480 => '480p',
                  CameraResolution.p720 => '720p',
                  CameraResolution.p1080 => '1080p',
                }),
                trailing: DropdownButton<CameraResolution>(
                  value: settings.resolution,
                  items: const [
                    DropdownMenuItem(
                      value: CameraResolution.p480,
                      child: Text('480p'),
                    ),
                    DropdownMenuItem(
                      value: CameraResolution.p720,
                      child: Text('720p'),
                    ),
                    DropdownMenuItem(
                      value: CameraResolution.p1080,
                      child: Text('1080p'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(appSettingsProvider.notifier).setResolution(v);
                    }
                  },
                ),
              ),
              SwitchListTile(
                title: const Text('Processing Quality'),
                subtitle: Text(
                  settings.quality == ProcessingQuality.high
                      ? 'High (every frame)'
                      : 'Standard (may skip frames)',
                ),
                value: settings.quality == ProcessingQuality.high,
                onChanged: (high) {
                  ref.read(appSettingsProvider.notifier).setQuality(
                        high ? ProcessingQuality.high : ProcessingQuality.standard,
                      );
                },
              ),
              SwitchListTile(
                title: const Text('Dark mode'),
                value: isDark,
                onChanged: (v) =>
                    ref.read(themeModeProvider.notifier).setDark(v),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _showPrivacy(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SelectableText(
          'Pixel Lift processes camera frames on-device for live preview. '
          'HQ captures may be sent to your configured ML service.\n\n'
          '${SettingsService.privacyPolicyUrl}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                const ClipboardData(text: SettingsService.privacyPolicyUrl),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied')),
              );
            },
            child: const Text('Copy link'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
