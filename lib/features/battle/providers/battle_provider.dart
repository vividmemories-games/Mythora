import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../campaign/data/campaign_repository.dart';
import '../../heroes/domain/hero_def.dart';
import '../../prep/domain/prep_item.dart';
import '../../profile/providers/mock_profile_provider.dart';
import '../../puzzle/domain/puzzle_engine.dart';
import '../domain/battle_state.dart';
import '../domain/enemy_def.dart';

final battleProvider = StateNotifierProvider.autoDispose
    .family<BattleNotifier, BattleState, String>((ref, nodeId) {
  // Watch only hero id so prep inventory updates do not reset the battle.
  final heroId = ref.watch(profileProvider.select((p) => p.selectedHeroId));
  final hero = HeroCatalog.byId(heroId);
  final chapter = ref.watch(campaignChapterProvider).valueOrNull;
  final node = chapter?.nodeById(nodeId);
  final enemy = EnemyCatalog.byId(node?.enemyId ?? 'goblin');
  final isBoss = node?.isBoss ?? enemy.id == 'warchief';

  // Inventory already consumed by prep picker; apply modifiers then clear.
  final equipped = isBoss
      ? List<PrepItemId>.from(ref.read(pendingBossPrepProvider))
      : const <PrepItemId>[];
  if (equipped.isNotEmpty) {
    ref.read(pendingBossPrepProvider.notifier).state = const [];
  }

  return BattleNotifier(
    hero: hero,
    enemy: enemy,
    nodeId: nodeId,
    nodeName: node?.name,
    coinReward: node?.coinReward ?? 0,
    equippedPrep: equipped,
    onSecondWindUsed: () {
      ref.read(profileProvider.notifier).markSecondWindUsed();
    },
  );
});

class BattleNotifier extends StateNotifier<BattleState> {
  BattleNotifier({
    HeroDef? hero,
    EnemyDef? enemy,
    String? nodeId,
    String? nodeName,
    int coinReward = 0,
    List<PrepItemId> equippedPrep = const [],
    void Function()? onSecondWindUsed,
  })  : _onSecondWindUsed = onSecondWindUsed,
        _equippedPrep = List.unmodifiable(equippedPrep),
        super(
          _initialState(
            hero: hero ?? HeroCatalog.mage,
            enemy: enemy ?? EnemyCatalog.goblin,
            nodeId: nodeId,
            nodeName: nodeName,
            coinReward: coinReward,
            equippedPrep: equippedPrep,
          ),
        ) {
    _controller = BattleController(state);
  }

  late BattleController _controller;
  int _actionGen = 0;
  final List<PrepItemId> _equippedPrep;
  final void Function()? _onSecondWindUsed;

  static BattleState _initialState({
    required HeroDef hero,
    required EnemyDef enemy,
    String? nodeId,
    String? nodeName,
    required int coinReward,
    required List<PrepItemId> equippedPrep,
  }) {
    var bonusMoves = 0;
    var bonusShield = 0;
    var secondWind = false;
    final notes = <String>[];
    for (final id in equippedPrep) {
      switch (id) {
        case PrepItemId.vanguardTonic:
          bonusMoves += PrepBalance.vanguardBonusMoves;
          notes.add('Vanguard Tonic: +${PrepBalance.vanguardBonusMoves} Move');
        case PrepItemId.aegisFlask:
          bonusShield += PrepBalance.aegisShield;
          notes.add('Aegis Flask: +${PrepBalance.aegisShield} shield');
        case PrepItemId.secondWind:
          secondWind = true;
          notes.add('Second Wind armed');
      }
    }
    return BattleState.initial(
      hero: hero,
      enemy: enemy,
      nodeId: nodeId,
      nodeName: nodeName,
      coinReward: coinReward,
      bonusMoves: bonusMoves,
      bonusShield: bonusShield,
      secondWindArmed: secondWind,
      prepLogNotes: notes,
    );
  }

  void tapCell(int row, int col) {
    if (state.inputLocked || state.movesLeft <= 0) return;
    if (!state.board.inBounds(row, col)) return;
    if (!state.board.at(row, col).isPlayable) return;

    final cell = state.board.at(row, col);
    final selected = state.selectedCell;

    if (selected == null && cell.hasSpecial) {
      _runActivate((row, col));
      return;
    }

    if (selected == null) {
      state = state.copyWith(selectedCell: (row, col));
      return;
    }

    if (selected == (row, col)) {
      if (cell.hasSpecial) {
        _runActivate((row, col));
      } else {
        state = state.copyWith(clearSelected: true);
      }
      return;
    }

    if (!PuzzleEngine.areAdjacent(selected, (row, col))) {
      if (cell.hasSpecial) {
        _runActivate((row, col));
      } else {
        state = state.copyWith(selectedCell: (row, col));
      }
      return;
    }

    _runSwap(selected, (row, col));
  }

  Future<void> _runActivate((int, int) pos) async {
    final gen = ++_actionGen;
    _controller.state = state;
    final cascade = _controller.beginActivate(pos);
    state = _controller.state;
    if (cascade == null) return;
    await _playCascade(cascade, gen);
  }

  Future<void> _runSwap((int, int) a, (int, int) b) async {
    final gen = ++_actionGen;
    _controller.state = state;
    final cascade = _controller.beginSwap(a, b);
    state = _controller.state;
    if (cascade == null) return;
    await _playCascade(cascade, gen);
  }

  Future<void> _playCascade(CascadeResult cascade, int gen) async {
    var knownIds = state.board.tilePositions().keys.toSet();

    final swapped = cascade.boardAfterSwap;
    if (swapped != null && swapped != state.board) {
      state = state.copyWith(board: swapped, phase: BattlePhase.resolving);
      knownIds = swapped.tilePositions().keys.toSet();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted || gen != _actionGen) return;
    }

    var boardWithMatches = swapped ?? state.board;

    for (final step in cascade.steps) {
      _controller.state = state;
      _controller.applyMatchRewards(step.match);
      _controller.showClearing(boardWithMatches, step.clearingCells);
      final powerNote = [
        if (step.match.mergeLabel != null) step.match.mergeLabel!,
        if (step.match.rocketsCreated > 0)
          '+${step.match.rocketsCreated} rocket',
        if (step.match.bombsCreated > 0) '+${step.match.bombsCreated} bomb',
        if (step.match.fireballsCreated > 0)
          '+${step.match.fireballsCreated} fireball',
        if (step.match.seekersCreated > 0)
          '+${step.match.seekersCreated} seeker',
      ].join(' · ');
      state = _controller.state.copyWith(
        log: [
          ..._controller.state.log,
          'Matched ${step.match.matchedCells.length} · +${step.match.apGained} AP'
              '${powerNote.isEmpty ? '' : ' · $powerNote'}',
        ],
      );
      await Future<void>.delayed(BattleController.clearDuration);
      if (!mounted || gen != _actionGen) return;

      _controller.state = state;
      _controller.showHoles(step.boardAfterClear);
      state = _controller.state;
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted || gen != _actionGen) return;

      _controller.state = state;
      _controller.showDrop(step.boardAfterDrop);
      state = _controller.state;
      await Future<void>.delayed(BattleController.fallDuration);
      if (!mounted || gen != _actionGen) return;

      final afterIds = step.boardAfterFill.tilePositions().keys.toSet();
      final spawned = afterIds.difference(knownIds);
      knownIds = afterIds;

      _controller.state = state;
      _controller.showSpawn(step.boardAfterFill, spawned);
      state = _controller.state;
      await Future<void>.delayed(BattleController.spawnDuration);
      if (!mounted || gen != _actionGen) return;

      boardWithMatches = step.boardAfterFill;
    }

    _controller.state = state;
    _controller.finishPlayerAction(movesSpent: 1);
    state = _controller.state;

    if (state.phase == BattlePhase.enemyTurn) {
      await _runEnemyTurn(gen);
    }
  }

  Future<void> _runEnemyTurn(int gen) async {
    state = state.copyWith(
      phase: BattlePhase.enemyTurn,
      clearEnemySkill: true,
    );
    await Future<void>.delayed(BattleController.enemyTelegraph);
    if (!mounted || gen != _actionGen) return;

    final armedBefore = state.secondWindArmed;
    _controller.state = state;
    final skill = _controller.pickEnemySkill();
    _controller.applyEnemySkill(skill);
    state = _controller.state;

    if (armedBefore && !state.secondWindArmed && state.heroHp > 0) {
      _onSecondWindUsed?.call();
    }

    await Future<void>.delayed(BattleController.combatFxDuration);
    if (!mounted || gen != _actionGen) return;
    _controller.state = state;
    _controller.clearCombatFx();
    state = _controller.state;
  }

  Future<void> castSkill(SkillDef skill) async {
    if (state.phase != BattlePhase.playerTurn) return;
    final gen = ++_actionGen;
    _controller.state = state;
    _controller.castSkill(skill);
    state = _controller.state;

    await Future<void>.delayed(BattleController.combatFxDuration);
    if (!mounted || gen != _actionGen) return;
    _controller.state = state;
    _controller.clearCombatFx();
    state = _controller.state;
  }

  bool canCast(SkillDef skill) {
    _controller.state = state;
    return _controller.canCast(skill);
  }

  void restart() {
    _actionGen++;
    // Restart does not re-consume prep; keep same battle modifiers.
    _controller = BattleController(
      _initialState(
        hero: state.hero,
        enemy: state.enemy,
        nodeId: state.nodeId,
        nodeName: state.nodeName,
        coinReward: state.coinReward,
        equippedPrep: _equippedPrep,
      ),
    );
    state = _controller.state;
  }
}
