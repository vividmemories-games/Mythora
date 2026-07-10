import 'tile_color.dart';

/// Special tiles from shape matches / merges.
enum TileSpecial {
  none,
  /// Clears its column when activated. Created by horizontal line of 4.
  rocketVertical,
  /// Clears its row when activated. Created by vertical line of 4.
  rocketHorizontal,
  /// Clears a 3×3 area when activated.
  bomb,
  /// Clears all tiles of a color (tap = random, swap = that tile's color).
  fireball,
  /// Clears 8 random playable tiles (including self).
  seeker,
}

extension TileSpecialPriority on TileSpecial {
  /// Higher wins when multiple shapes claim the same creation cell.
  int get creationRank => switch (this) {
        TileSpecial.fireball => 40,
        TileSpecial.bomb => 30,
        TileSpecial.seeker => 20,
        TileSpecial.rocketVertical || TileSpecial.rocketHorizontal => 10,
        TileSpecial.none => 0,
      };

  bool get isRocket =>
      this == TileSpecial.rocketVertical || this == TileSpecial.rocketHorizontal;
}

/// A single cell on the puzzle board.
class BoardCell {
  const BoardCell({
    this.id,
    this.color,
    this.special = TileSpecial.none,
    this.masked = false,
    this.obstacleLayers = 0,
  });

  final int? id;

  /// Tint / clear identity. Power-ups may keep a tint for fireball chaining
  /// but never participate in color matching ([matchColor] is null when special).
  final TileColor? color;
  final TileSpecial special;
  final bool masked;
  final int obstacleLayers;

  bool get hasSpecial => special != TileSpecial.none;
  bool get isEmpty => !masked && color == null && !hasSpecial;
  bool get isPlayable => !masked && (hasSpecial || color != null);
  bool get isMatchable => !masked && !hasSpecial && color != null;
  bool get hasObstacle => obstacleLayers > 0;

  /// Color used for shape matching — always null for power-ups.
  TileColor? get matchColor => hasSpecial ? null : color;

  static BoardCell empty() => const BoardCell();

  static BoardCell tile({
    required int id,
    required TileColor color,
    TileSpecial special = TileSpecial.none,
    int obstacleLayers = 0,
  }) {
    if (special != TileSpecial.none) {
      return BoardCell.powerUp(
        id: id,
        special: special,
        tint: color,
        obstacleLayers: obstacleLayers,
      );
    }
    return BoardCell(
      id: id,
      color: color,
      obstacleLayers: obstacleLayers,
    );
  }

  static BoardCell powerUp({
    required int id,
    required TileSpecial special,
    TileColor? tint,
    int obstacleLayers = 0,
  }) {
    assert(special != TileSpecial.none);
    return BoardCell(
      id: id,
      color: tint,
      special: special,
      obstacleLayers: obstacleLayers,
    );
  }

  BoardCell copyWith({
    int? id,
    TileColor? color,
    TileSpecial? special,
    bool? masked,
    int? obstacleLayers,
    bool clearTile = false,
    bool clearColor = false,
  }) {
    if (clearTile) {
      return BoardCell(
        masked: masked ?? this.masked,
        obstacleLayers: obstacleLayers ?? this.obstacleLayers,
      );
    }
    return BoardCell(
      id: id ?? this.id,
      color: clearColor ? null : (color ?? this.color),
      special: special ?? this.special,
      masked: masked ?? this.masked,
      obstacleLayers: obstacleLayers ?? this.obstacleLayers,
    );
  }
}
