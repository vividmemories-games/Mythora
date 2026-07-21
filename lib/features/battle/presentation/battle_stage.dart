import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/assets/game_assets.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/battle_state.dart';

/// Chibi hero (left) + enemy (right) with Flutter HP overlays.
class BattleStage extends StatelessWidget {
  const BattleStage({
    super.key,
    required this.battle,
  });

  final BattleState battle;

  @override
  Widget build(BuildContext context) {
    final intent = battle.enemy.heaviestSkill;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 148,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _FighterSlot(
                  assetPath: GameAssets.hero(battle.hero.id),
                  name: battle.hero.name,
                  subtitle:
                      battle.shield > 0 ? 'shield ${battle.shield}' : null,
                  hp: battle.heroHp,
                  maxHp: battle.hero.maxHp,
                  barColor: MythoraColors.amber,
                  flash: battle.combatFx == CombatFx.heroHit ||
                      battle.combatFx == CombatFx.heroCast,
                  shake: battle.combatFx == CombatFx.heroHit,
                  showHitFx: battle.combatFx == CombatFx.heroHit,
                  align: Alignment.bottomLeft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FighterSlot(
                  assetPath: GameAssets.enemy(battle.enemy.id),
                  name: battle.enemy.name,
                  hp: battle.enemyHp,
                  maxHp: battle.enemy.maxHp,
                  barColor: MythoraColors.ember,
                  flash: battle.combatFx == CombatFx.enemyHit,
                  shake: battle.combatFx == CombatFx.enemyHit,
                  showHitFx: battle.combatFx == CombatFx.enemyHit,
                  align: Alignment.bottomRight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Threat up to ${intent.damage} (${intent.name})',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MythoraColors.softGold,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _FighterSlot extends StatelessWidget {
  const _FighterSlot({
    required this.assetPath,
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.barColor,
    required this.align,
    this.subtitle,
    this.flash = false,
    this.shake = false,
    this.showHitFx = false,
  });

  final String assetPath;
  final String name;
  final String? subtitle;
  final int hp;
  final int maxHp;
  final Color barColor;
  final Alignment align;
  final bool flash;
  final bool shake;
  final bool showHitFx;

  @override
  Widget build(BuildContext context) {
    final t = (hp / maxHp).clamp(0.0, 1.0);
    Widget sprite = Image.asset(
      assetPath,
      fit: BoxFit.contain,
      alignment: align,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.person,
        size: 72,
        color: MythoraColors.muted,
      ),
    );

    if (flash) {
      sprite = ColorFiltered(
        colorFilter: ColorFilter.mode(
          barColor.withValues(alpha: 0.35),
          BlendMode.srcATop,
        ),
        child: sprite,
      );
    }

    sprite = Stack(
      fit: StackFit.expand,
      children: [
        sprite,
        if (showHitFx)
          IgnorePointer(
            child: Image.asset(
              GameAssets.fxHit,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
      ],
    );

    if (shake) {
      sprite = TweenAnimationBuilder<double>(
        key: ValueKey('shake-$name-$hp-$flash'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 320),
        builder: (context, value, child) {
          final dx = math.sin(value * math.pi * 6) * (1 - value) * 8;
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: sprite,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: sprite),
        const SizedBox(height: 4),
        Text(
          subtitle == null ? name : '$name · $subtitle',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('hp-$name-$hp-$maxHp'),
                  tween: Tween(begin: 0, end: t),
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 7,
                      backgroundColor: MythoraColors.mist,
                      color: flash ? MythoraColors.parchment : barColor,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$hp/$maxHp',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
