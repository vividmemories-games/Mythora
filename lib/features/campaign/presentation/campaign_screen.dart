import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/game_assets.dart';
import '../../../core/theme/app_theme.dart';
import '../../battle/domain/enemy_def.dart';
import '../../prep/presentation/prep_picker_sheet.dart';
import '../../profile/providers/mock_profile_provider.dart';
import '../data/campaign_repository.dart';
import '../domain/campaign_models.dart';

class CampaignScreen extends ConsumerWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterAsync = ref.watch(campaignChapterProvider);
    final profile = ref.watch(profileProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: MythoraColors.ink.withValues(alpha: 0.4),
        title: const Text('Campaign'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: chapterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load campaign: $e')),
        data: (chapter) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                GameAssets.mapTwilightRoad,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: MythoraColors.ink),
              ),
              Container(color: MythoraColors.ink.withValues(alpha: 0.55)),
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 96, 20, 32),
                children: [
                  Text(chapter.title, style: textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(chapter.subtitle, style: textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    'H4→V rocket · V4→H rocket · 2×2/T→bomb · L5→seeker · line5→fireball',
                    style: textTheme.bodyMedium?.copyWith(
                      color: MythoraColors.softGold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...chapter.nodes.map((node) {
                    final unlocked =
                        chapter.isUnlocked(node.id, profile.completedNodeIds);
                    final completed =
                        chapter.isCompleted(node.id, profile.completedNodeIds);
                    final enemy = EnemyCatalog.byId(node.enemyId);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: unlocked
                            ? MythoraColors.deepTeal.withValues(alpha: 0.9)
                            : MythoraColors.ink.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap:
                              unlocked ? () => _openNode(context, node) : null,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 52,
                                    height: 52,
                                    child: Image.asset(
                                      GameAssets.enemy(node.enemyId),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        completed
                                            ? Icons.check_circle
                                            : unlocked
                                                ? Icons.play_circle_outline
                                                : Icons.lock_outline,
                                        color: completed
                                            ? MythoraColors.amber
                                            : unlocked
                                                ? MythoraColors.softGold
                                                : MythoraColors.muted,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${node.order + 1}. ${node.name}',
                                        style: textTheme.titleMedium?.copyWith(
                                          color: unlocked
                                              ? MythoraColors.parchment
                                              : MythoraColors.muted,
                                        ),
                                      ),
                                      Text(
                                        '${enemy.name} · ${enemy.maxHp} HP · ${node.coinReward} coins',
                                        style: textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  completed
                                      ? Icons.check_circle
                                      : unlocked
                                          ? Icons.chevron_right
                                          : Icons.lock_outline,
                                  color: completed
                                      ? MythoraColors.amber
                                      : unlocked
                                          ? MythoraColors.softGold
                                          : MythoraColors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openNode(BuildContext context, CampaignNode node) async {
    if (node.isBoss) {
      final enemy = EnemyCatalog.byId(node.enemyId);
      final ok = await showPrepPickerSheet(
        context,
        bossName: enemy.name,
      );
      if (!ok || !context.mounted) return;
    }
    if (!context.mounted) return;
    context.push('/battle/${node.id}');
  }
}
