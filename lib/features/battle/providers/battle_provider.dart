import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../campaign/data/campaign_repository.dart';
import '../../heroes/domain/hero_def.dart';
import '../../profile/providers/mock_profile_provider.dart';
import '../../puzzle/domain/puzzle_engine.dart';
import '../domain/battle_state.dart';
import '../domain/enemy_def.dart';

final battleProvider = StateNotifierProvider.autoDispose
    .family<BattleNotifier, BattleState, String>((ref, nodeId) {
  final hero = ref.watch(profileProvider).selectedHero;
  final chapter = ref.watch(campaignChapterProvider).valueOrNull;
  final node = chapter?.nodeById(nodeId);
  final enemy = EnemyCatalog.byId(node?.enemyId ?? 'goblin');
  return BattleNotifier(
    hero: hero,
    enemy: enemy,
    nodeId: nodeId,
    nodeName: node?.name,
    coinReward: node?.coinReward ?? 0,
  );
});

class BattleNotifier extends StateNotifier<BattleState> {
  BattleNotifier({
    HeroDef? hero,
    EnemyDef? enemy,
    String? nodeId,
    String? nodeName,
    int coinReward = 0,
  }) : super(
          BattleState.initial(
            hero: hero ?? HeroCatalog.mage,
            enemy: enemy ?? EnemyCatalog.goblin,
            nodeId: nodeId,
            nodeName: nodeName,
            coinReward: coinReward,
          ),
        ) {
    _controller = BattleController(state);
  }

  late BattleController _controller;
  int _actionGen = 0;

  void tapCell(int row, int col) {
    if (state.inputLocked || state.movesLeft <= 0) return;
    if (!state.board.inBounds(row, col)) return;
    if (!state.board.at(row, col).isPlayable) return;

    final cell = state.board.at(row, col);
    final selected = state.selectedCell;

    // Tap a power-up with nothing selected → activate in place.
    if (selected == null && cell.hasSpecial) {
      _runActivate((row, col));
      return;
    }

    if (selected == null) {
      state = state.copyWith(selectedCell: (row, col));
      return;
    }

    if (selected == (row, col)) {
      // Second tap on the same power-up also activates.
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

    _controller.state = state;
    final skill = _controller.pickEnemySkill();
    _controller.applyEnemySkill(skill);
    state = _controller.state;

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
    _controller = BattleController(
      BattleState.initial(
        hero: state.hero,
        enemy: state.enemy,
        nodeId: state.nodeId,
        nodeName: state.nodeName,
        coinReward: state.coinReward,
      ),
    );
    state = _controller.state;
  }
}
