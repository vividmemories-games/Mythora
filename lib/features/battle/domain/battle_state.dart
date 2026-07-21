import 'dart:math';

import '../../heroes/domain/hero_def.dart';
import '../../prep/domain/prep_item.dart';
import '../../puzzle/domain/puzzle_board.dart';
import '../../puzzle/domain/puzzle_engine.dart';
import '../../puzzle/domain/tile_id_gen.dart';
import 'enemy_def.dart';

enum BattlePhase {
  playerTurn,
  resolving,
  enemyTurn,
  victory,
  defeat,
}

/// Visual feedback flags for combat juice.
enum CombatFx { none, heroHit, enemyHit, heroCast }

class BattleState {
  const BattleState({
    required this.hero,
    required this.enemy,
    required this.board,
    required this.heroHp,
    required this.enemyHp,
    required this.movesLeft,
    required this.movesPerTurn,
    required this.ap,
    required this.resources,
    required this.shield,
    required this.phase,
    this.nodeId,
    this.nodeName,
    this.coinReward = 0,
    this.secondWindArmed = false,
    this.selectedCell,
    this.clearingCells = const {},
    this.spawningIds = const {},
    this.combatFx = CombatFx.none,
    this.lastEnemySkillName,
    this.log = const [],
  });

  final HeroDef hero;
  final EnemyDef enemy;
  final PuzzleBoard board;
  final int heroHp;
  final int enemyHp;
  final int movesLeft;

  /// Turn move budget after prep / level / boss modifiers.
  final int movesPerTurn;
  final int ap;
  final Map<String, int> resources;
  final int shield;
  final BattlePhase phase;
  final String? nodeId;
  final String? nodeName;
  final int coinReward;

  /// Equipped Second Wind for this battle (once-per-day gate is profile-side).
  final bool secondWindArmed;
  final (int, int)? selectedCell;

  /// Cells currently playing destroy animation.
  final Set<(int, int)> clearingCells;

  /// Tile ids that just spawned (drop-in from above).
  final Set<int> spawningIds;

  final CombatFx combatFx;
  final String? lastEnemySkillName;
  final List<String> log;

  bool get inputLocked =>
      phase == BattlePhase.resolving ||
      phase == BattlePhase.enemyTurn ||
      phase == BattlePhase.victory ||
      phase == BattlePhase.defeat;

  factory BattleState.initial({
    HeroDef hero = HeroCatalog.mage,
    EnemyDef enemy = EnemyCatalog.goblin,
    String? nodeId,
    String? nodeName,
    int coinReward = 0,
    int bonusMoves = 0,
    int bonusShield = 0,
    bool secondWindArmed = false,
    PuzzleBoard? board,
    TileIdGen? ids,
    Random? random,
    List<String> prepLogNotes = const [],
  }) {
    final idGen = ids ?? TileIdGen();
    final effectiveMoves = PrepBalance.movesThisTurn(
      heroMoves: hero.movesPerTurn,
      prepBonus: bonusMoves,
    );
    final notes = [
      'Battle started. Match tiles to fuel your skills.',
      ...prepLogNotes,
    ];
    return BattleState(
      hero: hero,
      enemy: enemy,
      nodeId: nodeId,
      nodeName: nodeName,
      coinReward: coinReward,
      board: board ??
          PuzzleBoard.squareNoMatches(random: random ?? Random(), ids: idGen),
      heroHp: hero.maxHp,
      enemyHp: enemy.maxHp,
      movesLeft: effectiveMoves,
      movesPerTurn: effectiveMoves,
      ap: 0,
      resources: const {
        'attack': 0,
        'mana': 0,
        'healing': 0,
        'shield': 0,
        'ultimate': 0,
      },
      shield: bonusShield,
      secondWindArmed: secondWindArmed,
      phase: BattlePhase.playerTurn,
      log: notes,
    );
  }

  BattleState copyWith({
    PuzzleBoard? board,
    int? heroHp,
    int? enemyHp,
    int? movesLeft,
    int? movesPerTurn,
    int? ap,
    Map<String, int>? resources,
    int? shield,
    BattlePhase? phase,
    bool? secondWindArmed,
    (int, int)? selectedCell,
    bool clearSelected = false,
    Set<(int, int)>? clearingCells,
    Set<int>? spawningIds,
    CombatFx? combatFx,
    String? lastEnemySkillName,
    bool clearEnemySkill = false,
    List<String>? log,
  }) {
    return BattleState(
      hero: hero,
      enemy: enemy,
      nodeId: nodeId,
      nodeName: nodeName,
      coinReward: coinReward,
      board: board ?? this.board,
      heroHp: heroHp ?? this.heroHp,
      enemyHp: enemyHp ?? this.enemyHp,
      movesLeft: movesLeft ?? this.movesLeft,
      movesPerTurn: movesPerTurn ?? this.movesPerTurn,
      ap: ap ?? this.ap,
      resources: resources ?? this.resources,
      shield: shield ?? this.shield,
      secondWindArmed: secondWindArmed ?? this.secondWindArmed,
      phase: phase ?? this.phase,
      selectedCell: clearSelected ? null : (selectedCell ?? this.selectedCell),
      clearingCells: clearingCells ?? this.clearingCells,
      spawningIds: spawningIds ?? this.spawningIds,
      combatFx: combatFx ?? this.combatFx,
      lastEnemySkillName: clearEnemySkill
          ? null
          : (lastEnemySkillName ?? this.lastEnemySkillName),
      log: log ?? this.log,
    );
  }
}

class BattleController {
  BattleController(
    this.state, {
    Random? random,
    TileIdGen? ids,
  })  : _random = random ?? Random(),
        ids = ids ?? TileIdGen(1000);

  BattleState state;
  final Random _random;
  final TileIdGen ids;

  static const clearDuration = Duration(milliseconds: 220);
  static const fallDuration = Duration(milliseconds: 260);
  static const spawnDuration = Duration(milliseconds: 280);
  static const combatFxDuration = Duration(milliseconds: 320);
  static const enemyTelegraph = Duration(milliseconds: 400);

  /// Returns cascade if swap is valid; updates selection clear. Does not mutate board yet.
  CascadeResult? beginSwap((int, int) a, (int, int) b) {
    final cascade = PuzzleEngine.trySwap(
      state.board,
      a,
      b,
      random: _random,
      ids: ids,
    );
    if (cascade == null) {
      state = state.copyWith(
        clearSelected: true,
        log: [...state.log, 'No match — try another swap.'],
      );
      return null;
    }
    state = state.copyWith(
      phase: BattlePhase.resolving,
      clearSelected: true,
    );
    return cascade;
  }

  /// Tap-activate a power-up in place (costs the move when cascade finishes).
  CascadeResult? beginActivate((int, int) pos) {
    final cascade = PuzzleEngine.activateSpecial(
      state.board,
      pos,
      random: _random,
      ids: ids,
    );
    if (cascade == null) return null;
    state = state.copyWith(
      phase: BattlePhase.resolving,
      clearSelected: true,
    );
    return cascade;
  }

  void applyMatchRewards(MatchResult match) {
    final resources = Map<String, int>.from(state.resources);
    match.resourceGains.forEach((key, value) {
      resources[key] = (resources[key] ?? 0) + value;
    });
    final ap = (state.ap + match.apGained).clamp(0, state.hero.maxAp);
    state = state.copyWith(resources: resources, ap: ap);
  }

  /// Highlight matches still on [board]; tiles animate out before gravity.
  void showClearing(PuzzleBoard board, Set<(int, int)> matched) {
    state = state.copyWith(
      board: board,
      clearingCells: matched,
      spawningIds: {},
    );
  }

  void showHoles(PuzzleBoard boardAfterClear) {
    state = state.copyWith(
      board: boardAfterClear,
      clearingCells: {},
      spawningIds: {},
    );
  }

  void showDrop(PuzzleBoard boardAfterDrop) {
    state = state.copyWith(
      board: boardAfterDrop,
      clearingCells: {},
      spawningIds: {},
    );
  }

  void showSpawn(PuzzleBoard boardAfterFill, Set<int> newIds) {
    state = state.copyWith(
      board: boardAfterFill,
      clearingCells: {},
      spawningIds: newIds,
    );
  }

  void finishPlayerAction({required int movesSpent}) {
    final movesLeft = state.movesLeft - movesSpent;
    state = state.copyWith(
      movesLeft: movesLeft,
      clearingCells: {},
      spawningIds: {},
      phase: movesLeft <= 0 ? BattlePhase.enemyTurn : BattlePhase.playerTurn,
    );
  }

  bool canCast(SkillDef skill) {
    if (state.phase != BattlePhase.playerTurn) return false;
    if (state.ap < skill.apCost) return false;
    for (final entry in skill.resourceCosts.entries) {
      if ((state.resources[entry.key] ?? 0) < entry.value) return false;
    }
    return true;
  }

  void castSkill(SkillDef skill) {
    if (!canCast(skill)) return;

    final resources = Map<String, int>.from(state.resources);
    skill.resourceCosts.forEach((key, cost) {
      resources[key] = resources[key]! - cost;
    });

    var enemyHp = state.enemyHp - skill.damage;
    var heroHp = state.heroHp + skill.heal;
    if (heroHp > state.hero.maxHp) heroHp = state.hero.maxHp;
    final shield = state.shield + skill.shield;
    final ap = state.ap - skill.apCost;

    final logs = [...state.log, 'Cast ${skill.name}!'];
    var phase = state.phase;
    var fx = CombatFx.none;

    if (skill.damage > 0) {
      fx = CombatFx.enemyHit;
      logs.add('${skill.name} hits for ${skill.damage}');
    } else {
      fx = CombatFx.heroCast;
    }

    if (enemyHp <= 0) {
      enemyHp = 0;
      phase = BattlePhase.victory;
      logs.add('Victory!');
    }

    state = state.copyWith(
      resources: resources,
      enemyHp: enemyHp,
      heroHp: heroHp,
      shield: shield,
      ap: ap,
      phase: phase,
      combatFx: fx,
      log: logs,
    );
  }

  void clearCombatFx() {
    state = state.copyWith(combatFx: CombatFx.none);
  }

  EnemySkill pickEnemySkill() {
    final skills = state.enemy.skills;
    final total = skills.fold<int>(0, (sum, s) => sum + s.weight);
    var roll = _random.nextInt(total);
    for (final skill in skills) {
      roll -= skill.weight;
      if (roll < 0) return skill;
    }
    return skills.last;
  }

  void applyEnemySkill(EnemySkill skill) {
    var damage = skill.damage;
    var shield = state.shield;
    if (shield > 0) {
      final absorbed = damage < shield ? damage : shield;
      shield -= absorbed;
      damage -= absorbed;
    }
    final heroHp = (state.heroHp - damage).clamp(0, state.hero.maxHp);
    final logs = [
      ...state.log,
      '${state.enemy.name} uses ${skill.name}!',
      if (damage > 0) '${skill.name} hits for $damage',
      if (damage == 0 && skill.damage > 0) 'Shield absorbed the blow',
    ];

    if (heroHp <= 0) {
      if (state.secondWindArmed) {
        final reviveHp =
            (state.hero.maxHp * PrepBalance.secondWindHpFraction).round();
        final hp = reviveHp < 1 ? 1 : reviveHp;
        state = state.copyWith(
          heroHp: hp,
          shield: shield,
          secondWindArmed: false,
          movesLeft: state.movesPerTurn,
          phase: BattlePhase.playerTurn,
          combatFx: CombatFx.heroCast,
          lastEnemySkillName: skill.name,
          log: [
            ...logs,
            'Second Wind! Revived to $hp HP.',
            'Your turn — ${state.movesPerTurn} moves',
          ],
        );
        return;
      }
      state = state.copyWith(
        heroHp: 0,
        shield: shield,
        phase: BattlePhase.defeat,
        combatFx: CombatFx.heroHit,
        lastEnemySkillName: skill.name,
        log: [...logs, 'Defeat…'],
      );
      return;
    }

    state = state.copyWith(
      heroHp: heroHp,
      shield: shield,
      movesLeft: state.movesPerTurn,
      phase: BattlePhase.playerTurn,
      combatFx: CombatFx.heroHit,
      lastEnemySkillName: skill.name,
      log: [...logs, 'Your turn — ${state.movesPerTurn} moves'],
    );
  }
}
