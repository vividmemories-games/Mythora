/// Balance knobs for match resolution: resource + AP generation.
///
/// Pure data so it can later be loaded from Firestore/Remote Config.
/// Defaults mirror the values from docs/GAMEPLAY.md.
class MatchBalanceConfig {
  const MatchBalanceConfig({
    this.schemaVersion = 1,
    this.resourcePerTile = 1,
    this.tilesPerAp = 3,
    this.minApPerMatch = 1,
    this.maxApPerWave = 99,
    this.apPerRocket = 1,
    this.apPerBomb = 2,
    this.apPerFireball = 3,
    this.apPerSeeker = 2,
  });

  final int schemaVersion;

  /// Resource units generated per matched tile of a color.
  final int resourcePerTile;

  /// One AP per this many tiles cleared in a wave.
  final int tilesPerAp;

  /// A non-empty match always grants at least this much AP.
  final int minApPerMatch;

  /// Cap on AP from a single wave (safety valve for huge blasts).
  final int maxApPerWave;

  /// Bonus AP for creating power-ups.
  final int apPerRocket;
  final int apPerBomb;
  final int apPerFireball;
  final int apPerSeeker;

  static const defaults = MatchBalanceConfig();

  factory MatchBalanceConfig.fromJson(Map<String, dynamic> json) {
    const d = defaults;
    return MatchBalanceConfig(
      schemaVersion: json['schemaVersion'] as int? ?? d.schemaVersion,
      resourcePerTile: json['resourcePerTile'] as int? ?? d.resourcePerTile,
      tilesPerAp: json['tilesPerAp'] as int? ?? d.tilesPerAp,
      minApPerMatch: json['minApPerMatch'] as int? ?? d.minApPerMatch,
      maxApPerWave: json['maxApPerWave'] as int? ?? d.maxApPerWave,
      apPerRocket: json['apPerRocket'] as int? ?? d.apPerRocket,
      apPerBomb: json['apPerBomb'] as int? ?? d.apPerBomb,
      apPerFireball: json['apPerFireball'] as int? ?? d.apPerFireball,
      apPerSeeker: json['apPerSeeker'] as int? ?? d.apPerSeeker,
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'resourcePerTile': resourcePerTile,
        'tilesPerAp': tilesPerAp,
        'minApPerMatch': minApPerMatch,
        'maxApPerWave': maxApPerWave,
        'apPerRocket': apPerRocket,
        'apPerBomb': apPerBomb,
        'apPerFireball': apPerFireball,
        'apPerSeeker': apPerSeeker,
      };
}
