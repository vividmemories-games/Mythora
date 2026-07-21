import '../../../core/assets/game_assets.dart';

/// Meta prep items carried into boss battles (Content Architecture §3).
enum PrepItemId {
  vanguardTonic,
  aegisFlask,
  secondWind,
}

extension PrepItemIdX on PrepItemId {
  String get storageKey => switch (this) {
        PrepItemId.vanguardTonic => 'vanguard_tonic',
        PrepItemId.aegisFlask => 'aegis_flask',
        PrepItemId.secondWind => 'second_wind',
      };

  String get displayName => switch (this) {
        PrepItemId.vanguardTonic => 'Vanguard Tonic',
        PrepItemId.aegisFlask => 'Aegis Flask',
        PrepItemId.secondWind => 'Second Wind',
      };

  String get blurb => switch (this) {
        PrepItemId.vanguardTonic => '+1 Move this battle',
        PrepItemId.aegisFlask => 'Start with a small shield',
        PrepItemId.secondWind => 'Once/day: revive to ~30% HP',
      };

  String get assetPath => switch (this) {
        PrepItemId.vanguardTonic => GameAssets.prepVanguard,
        PrepItemId.aegisFlask => GameAssets.prepAegis,
        PrepItemId.secondWind => GameAssets.prepSecondWind,
      };

  static PrepItemId? tryParse(String key) {
    for (final id in PrepItemId.values) {
      if (id.storageKey == key) return id;
    }
    return null;
  }
}

/// Stub balance — Balancing Bible owns final numbers.
abstract final class PrepBalance {
  static const maxEquipped = 3;
  static const aegisShield = 15;
  static const vanguardBonusMoves = 1;
  static const secondWindHpFraction = 0.3;
  static const defaultMinMoves = 2;
  static const startingLives = 5;
  static const maxLives = 5;

  /// Effective moves for a battle turn budget.
  static int movesThisTurn({
    required int heroMoves,
    required int prepBonus,
    int levelModifier = 0,
    int bossDebuff = 0,
    int minMoves = defaultMinMoves,
  }) {
    final raw = heroMoves + prepBonus + levelModifier - bossDebuff;
    return raw < minMoves ? minMoves : raw;
  }
}

/// Tiny non-boss clear drop table (stub).
abstract final class PrepDrops {
  static const nonBossGrant = {
    PrepItemId.vanguardTonic: 1,
  };

  static Map<PrepItemId, int> forNonBossClear() => Map.of(nonBossGrant);
}
