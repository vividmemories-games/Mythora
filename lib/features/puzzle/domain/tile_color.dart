/// Tile colors that generate battle resources.
enum TileColor {
  red,
  blue,
  green,
  yellow,
  purple,
}

extension TileColorResource on TileColor {
  /// Resource generated when this tile is matched.
  String get resourceId => switch (this) {
        TileColor.red => 'attack',
        TileColor.blue => 'mana',
        TileColor.green => 'healing',
        TileColor.yellow => 'shield',
        TileColor.purple => 'ultimate',
      };
}
