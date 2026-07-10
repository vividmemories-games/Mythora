import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../heroes/domain/hero_def.dart';
import '../../profile/providers/mock_profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Mythora',
                    style: textTheme.displayLarge?.copyWith(fontSize: 32),
                  ),
                  const Spacer(),
                  _ResourceChip(
                    label: '${profile.coins}',
                    icon: Icons.monetization_on_outlined,
                  ),
                  const SizedBox(width: 8),
                  _ResourceChip(
                    label: '${profile.gems}',
                    icon: Icons.diamond_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Match tiles. Fuel skills. Outlast the enemy.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Text('Choose hero', style: textTheme.headlineMedium),
              const SizedBox(height: 12),
              ...HeroCatalog.all.map((hero) {
                final selected = hero.id == profile.selectedHeroId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: selected
                        ? MythoraColors.mist
                        : MythoraColors.deepTeal,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => ref
                          .read(profileProvider.notifier)
                          .selectHero(hero.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: MythoraColors.amber,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hero.name, style: textTheme.titleMedium),
                                  Text(
                                    '${hero.movesPerTurn} moves · ${hero.maxAp} max AP · ${hero.maxHp} HP',
                                    style: textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/campaign'),
                child: const Text('Twilight Road'),
              ),
              const SizedBox(height: 8),
              Text(
                '${profile.completedNodeIds.length} / 5 nodes cleared',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(profileProvider.notifier).resetProgress(),
                child: const Text('Reset progress'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceChip extends StatelessWidget {
  const _ResourceChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MythoraColors.deepTeal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MythoraColors.mist),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: MythoraColors.amber),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
