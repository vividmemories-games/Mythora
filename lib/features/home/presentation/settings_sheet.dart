import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../profile/providers/mock_profile_provider.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: MythoraColors.deepTeal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MythoraColors.mist,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Match hints'),
              subtitle: const Text(
                'Highlight a move after 5 seconds of idle play',
              ),
              activeThumbColor: MythoraColors.amber,
              value: profile.hintsEnabled,
              onChanged: notifier.setHintsEnabled,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound'),
              subtitle: const Text('Battle and UI sound effects (coming soon)'),
              activeThumbColor: MythoraColors.amber,
              value: profile.soundEnabled,
              onChanged: notifier.setSoundEnabled,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Haptics'),
              subtitle: const Text('Light vibration on matches (coming soon)'),
              activeThumbColor: MythoraColors.amber,
              value: profile.hapticsEnabled,
              onChanged: notifier.setHapticsEnabled,
            ),
          ],
        ),
      ),
    );
  }
}
