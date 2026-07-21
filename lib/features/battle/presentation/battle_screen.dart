import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/game_assets.dart';
import '../../../core/theme/app_theme.dart';
import '../../heroes/domain/hero_def.dart';
import '../domain/battle_state.dart';
import '../providers/battle_provider.dart';
import 'animated_puzzle_board.dart';
import 'battle_result_screen.dart';
import 'battle_stage.dart';

class BattleScreen extends ConsumerWidget {
  const BattleScreen({super.key, required this.nodeId});

  final String nodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(battleProvider(nodeId));
    final notifier = ref.read(battleProvider(nodeId).notifier);
    final textTheme = Theme.of(context).textTheme;

    ref.listen(battleProvider(nodeId), (prev, next) {
      if (prev == null) return;
      if (prev.phase == next.phase) return;
      if (next.phase != BattlePhase.victory &&
          next.phase != BattlePhase.defeat) {
        return;
      }
      final args = BattleResultArgs(
        won: next.phase == BattlePhase.victory,
        nodeId: next.nodeId ?? nodeId,
        nodeName: next.nodeName ?? 'Battle',
        enemyName: next.enemy.name,
        coinReward: next.coinReward,
      );
      context.pushReplacement('/result', extra: args);
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: MythoraColors.ink.withValues(alpha: 0.45),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(battle.nodeName ?? battle.enemy.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.restart,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            GameAssets.battleTwilightRoad,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: MythoraColors.ink),
          ),
          Container(color: MythoraColors.ink.withValues(alpha: 0.42)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight - 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: BattleStage(battle: battle),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _StatPill(label: 'Moves', value: '${battle.movesLeft}'),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'AP',
                        value: '${battle.ap}/${battle.hero.maxAp}',
                      ),
                      const Spacer(),
                      Text(
                        _phaseLabel(battle),
                        style: textTheme.titleMedium?.copyWith(
                          color: MythoraColors.softGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: battle.resources.entries.map((e) {
                      return _StatPill(
                        label: e.key,
                        value: '${e.value}',
                        compact: true,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AnimatedPuzzleBoard(
                        battle: battle,
                        onTap: notifier.tapCell,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 56,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: battle.hero.skills.map((skill) {
                      final enabled = notifier.canCast(skill);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilledButton(
                          onPressed:
                              enabled ? () => notifier.castSkill(skill) : null,
                          child: Text(
                            '${skill.name}\n${_skillCost(skill)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, height: 1.2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 64,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: battle.log.reversed.take(3).map((line) {
                      return Text(line, style: textTheme.bodyMedium);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _phaseLabel(BattleState battle) => switch (battle.phase) {
        BattlePhase.playerTurn => 'Your turn',
        BattlePhase.resolving => 'Matching…',
        BattlePhase.enemyTurn => 'Enemy turn',
        BattlePhase.victory => 'Victory',
        BattlePhase.defeat => 'Defeat',
      };

  String _skillCost(SkillDef skill) {
    final parts = skill.resourceCosts.entries
        .map((e) => '${e.value} ${e.key}')
        .join(' · ');
    return '$parts · ${skill.apCost} AP';
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: MythoraColors.deepTeal.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MythoraColors.mist),
      ),
      child: Text(
        compact ? '$label $value' : '$label: $value',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12),
      ),
    );
  }
}
