import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../puzzle/domain/board_cell.dart';
import '../../puzzle/domain/tile_color.dart';
import '../domain/battle_state.dart';

/// Match-3 board with destroy / fall / spawn motion.
class AnimatedPuzzleBoard extends StatelessWidget {
  const AnimatedPuzzleBoard({
    super.key,
    required this.battle,
    required this.onTap,
  });

  final BattleState battle;
  final void Function(int row, int col) onTap;

  @override
  Widget build(BuildContext context) {
    final board = battle.board;
    return Container(
      decoration: BoxDecoration(
        color: MythoraColors.deepTeal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MythoraColors.mist),
      ),
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 3.0;
          final cellW =
              (constraints.maxWidth - gap * (board.width - 1)) / board.width;
          final cellH =
              (constraints.maxHeight - gap * (board.height - 1)) / board.height;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              for (var row = 0; row < board.height; row++)
                for (var col = 0; col < board.width; col++)
                  if (board.at(row, col).isEmpty)
                    Positioned(
                      left: col * (cellW + gap),
                      top: row * (cellH + gap),
                      width: cellW,
                      height: cellH,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: MythoraColors.ink.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
              for (var row = 0; row < board.height; row++)
                for (var col = 0; col < board.width; col++)
                  if (board.at(row, col).isPlayable &&
                      board.at(row, col).id != null)
                    _BoardTile(
                      key: ValueKey('tile-${board.at(row, col).id}'),
                      id: board.at(row, col).id!,
                      row: row,
                      col: col,
                      color: board.at(row, col).color,
                      special: board.at(row, col).special,
                      cellW: cellW,
                      cellH: cellH,
                      gap: gap,
                      selected: battle.selectedCell == (row, col),
                      clearing: battle.clearingCells.contains((row, col)),
                      spawning:
                          battle.spawningIds.contains(board.at(row, col).id),
                      interactive: !battle.inputLocked,
                      onTap: () => onTap(row, col),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _BoardTile extends StatefulWidget {
  const _BoardTile({
    super.key,
    required this.id,
    required this.row,
    required this.col,
    required this.color,
    required this.special,
    required this.cellW,
    required this.cellH,
    required this.gap,
    required this.selected,
    required this.clearing,
    required this.spawning,
    required this.interactive,
    required this.onTap,
  });

  final int id;
  final int row;
  final int col;
  final TileColor? color;
  final TileSpecial special;
  final double cellW;
  final double cellH;
  final double gap;
  final bool selected;
  final bool clearing;
  final bool spawning;
  final bool interactive;
  final VoidCallback onTap;

  @override
  State<_BoardTile> createState() => _BoardTileState();
}

class _BoardTileState extends State<_BoardTile> {
  late double _left;
  late double _top;
  var _spawnDropPending = false;

  double get _targetLeft => widget.col * (widget.cellW + widget.gap);
  double get _targetTop => widget.row * (widget.cellH + widget.gap);

  @override
  void initState() {
    super.initState();
    _left = _targetLeft;
    if (widget.spawning) {
      _top = _targetTop - (widget.cellH + widget.gap) * (widget.row + 3);
      _spawnDropPending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_spawnDropPending) return;
        setState(() {
          _top = _targetTop;
          _spawnDropPending = false;
        });
      });
    } else {
      _top = _targetTop;
    }
  }

  @override
  void didUpdateWidget(covariant _BoardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row != widget.row ||
        oldWidget.col != widget.col ||
        oldWidget.cellW != widget.cellW ||
        oldWidget.cellH != widget.cellH) {
      _left = _targetLeft;
      _top = _targetTop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(
        milliseconds: widget.clearing
            ? 100
            : (widget.spawning || _spawnDropPending ? 280 : 260),
      ),
      curve: Curves.easeOutCubic,
      left: _left,
      top: _top,
      width: widget.cellW,
      height: widget.cellH,
      child: GestureDetector(
        onTap: widget.interactive ? widget.onTap : null,
        child: AnimatedScale(
          scale: widget.clearing ? 0.15 : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInBack,
          child: AnimatedOpacity(
            opacity: widget.clearing ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: MythoraColors.ink.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: widget.selected
                    ? Border.all(color: MythoraColors.parchment, width: 2)
                    : Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: widget.clearing
                    ? [
                        BoxShadow(
                          color: _accentColor(widget.color)
                              .withValues(alpha: 0.75),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              clipBehavior: Clip.none,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Transform.scale(
                    scale: 1.22,
                    child: _TileArt(
                      color: widget.color,
                      special: widget.special,
                    ),
                  ),
                  if (widget.special != TileSpecial.none)
                    Center(
                      child: Icon(
                        switch (widget.special) {
                          TileSpecial.rocketVertical => Icons.south,
                          TileSpecial.rocketHorizontal => Icons.east,
                          TileSpecial.bomb => Icons.brightness_high,
                          TileSpecial.fireball => Icons.whatshot,
                          TileSpecial.seeker => Icons.gps_fixed,
                          TileSpecial.none => Icons.circle,
                        },
                        color: MythoraColors.parchment,
                        size: widget.cellW * 0.42,
                        shadows: const [
                          Shadow(blurRadius: 4, color: Colors.black87),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _accentColor(TileColor? color) => switch (color) {
        TileColor.red => MythoraColors.tileRed,
        TileColor.blue => MythoraColors.tileBlue,
        TileColor.green => MythoraColors.tileGreen,
        TileColor.yellow => MythoraColors.tileYellow,
        TileColor.purple => MythoraColors.tilePurple,
        null => MythoraColors.amber,
      };
}

/// Puzzle gem art from AB1 tile PNGs; falls back to tint if asset missing.
class _TileArt extends StatelessWidget {
  const _TileArt({
    required this.color,
    required this.special,
  });

  final TileColor? color;
  final TileSpecial special;

  static String? assetFor(TileColor? color) => switch (color) {
        TileColor.red => 'assets/images/tiles/tile_red.png',
        TileColor.blue => 'assets/images/tiles/tile_blue.png',
        TileColor.green => 'assets/images/tiles/tile_green.png',
        TileColor.yellow => 'assets/images/tiles/tile_yellow.png',
        TileColor.purple => 'assets/images/tiles/tile_purple.png',
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final path = assetFor(color);
    if (path == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: special == TileSpecial.none
              ? MythoraColors.ink
              : MythoraColors.mist,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: switch (color) {
          TileColor.red => MythoraColors.tileRed,
          TileColor.blue => MythoraColors.tileBlue,
          TileColor.green => MythoraColors.tileGreen,
          TileColor.yellow => MythoraColors.tileYellow,
          TileColor.purple => MythoraColors.tilePurple,
          null => MythoraColors.ink,
        },
      ),
    );
  }
}
