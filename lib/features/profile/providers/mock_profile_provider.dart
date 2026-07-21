import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../heroes/domain/hero_def.dart';
import '../../prep/domain/prep_item.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main()');
});

/// Local profile until Firebase is wired (see docs/PHASES.md).
class PlayerProfile {
  const PlayerProfile({
    this.displayName = 'Wanderer',
    this.coins = 500,
    this.gems = 50,
    this.lives = PrepBalance.startingLives,
    this.selectedHeroId = 'mage',
    this.completedNodeIds = const {},
    this.prepInventory = const {
      PrepItemId.vanguardTonic: 2,
      PrepItemId.aegisFlask: 1,
      PrepItemId.secondWind: 1,
    },
    this.secondWindUsedDay = '',
    this.hintsEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final String displayName;
  final int coins;
  final int gems;
  final int lives;
  final String selectedHeroId;
  final Set<String> completedNodeIds;
  final Map<PrepItemId, int> prepInventory;

  /// `yyyy-MM-dd` of last Second Wind revive (empty = never).
  final String secondWindUsedDay;

  final bool hintsEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;

  HeroDef get selectedHero => HeroCatalog.byId(selectedHeroId);

  int prepCount(PrepItemId id) => prepInventory[id] ?? 0;

  bool get secondWindAvailableToday {
    final today = _todayKey();
    return secondWindUsedDay != today && prepCount(PrepItemId.secondWind) > 0;
  }

  PlayerProfile copyWith({
    String? displayName,
    int? coins,
    int? gems,
    int? lives,
    String? selectedHeroId,
    Set<String>? completedNodeIds,
    Map<PrepItemId, int>? prepInventory,
    String? secondWindUsedDay,
    bool? hintsEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return PlayerProfile(
      displayName: displayName ?? this.displayName,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      lives: lives ?? this.lives,
      selectedHeroId: selectedHeroId ?? this.selectedHeroId,
      completedNodeIds: completedNodeIds ?? this.completedNodeIds,
      prepInventory: prepInventory ?? this.prepInventory,
      secondWindUsedDay: secondWindUsedDay ?? this.secondWindUsedDay,
      hintsEnabled: hintsEnabled ?? this.hintsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  /// Bump when the persisted shape changes; readers stay tolerant of older
  /// payloads. Mirrors the planned Firestore `users` doc (see
  /// docs/04_Technical/Firestore_Schema.md).
  static const schemaVersion = 4;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'displayName': displayName,
        'coins': coins,
        'gems': gems,
        'lives': lives,
        'selectedHeroId': selectedHeroId,
        'completedNodeIds': completedNodeIds.toList(),
        'prepInventory': {
          for (final e in prepInventory.entries) e.key.storageKey: e.value,
        },
        'secondWindUsedDay': secondWindUsedDay,
        'hintsEnabled': hintsEnabled,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final ids = (json['completedNodeIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {};
    final rawPrep = json['prepInventory'] as Map<String, dynamic>?;
    final prep = <PrepItemId, int>{
      for (final id in PrepItemId.values) id: 0,
    };
    if (rawPrep != null) {
      for (final e in rawPrep.entries) {
        final id = PrepItemIdX.tryParse(e.key);
        if (id != null) prep[id] = (e.value as num).toInt();
      }
    } else {
      // Fresh / migrated profiles get a small starter stash.
      prep[PrepItemId.vanguardTonic] = 2;
      prep[PrepItemId.aegisFlask] = 1;
      prep[PrepItemId.secondWind] = 1;
    }
    return PlayerProfile(
      displayName: json['displayName'] as String? ?? 'Wanderer',
      coins: json['coins'] as int? ?? 500,
      gems: json['gems'] as int? ?? 50,
      lives: json['lives'] as int? ?? PrepBalance.startingLives,
      selectedHeroId: json['selectedHeroId'] as String? ?? 'mage',
      completedNodeIds: ids,
      prepInventory: prep,
      secondWindUsedDay: json['secondWindUsedDay'] as String? ?? '',
      hintsEnabled: json['hintsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }

  static String _todayKey() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }
}

class ProfileNotifier extends StateNotifier<PlayerProfile> {
  ProfileNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static const _key = 'mythora_profile_v2';

  static PlayerProfile _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key) ?? prefs.getString('mythora_profile_v1');
    if (raw == null) return const PlayerProfile();
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return PlayerProfile.fromJson(decoded);
    } catch (_) {
      return const PlayerProfile();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  void selectHero(String heroId) {
    state = state.copyWith(selectedHeroId: heroId);
    _persist();
  }

  void setHintsEnabled(bool value) {
    state = state.copyWith(hintsEnabled: value);
    _persist();
  }

  void setSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
    _persist();
  }

  void setHapticsEnabled(bool value) {
    state = state.copyWith(hapticsEnabled: value);
    _persist();
  }

  /// Consume equipped prep before a boss battle. Returns false if inventory short.
  bool consumePrep(List<PrepItemId> equipped) {
    final inv = Map<PrepItemId, int>.from(state.prepInventory);
    for (final id in equipped) {
      final n = inv[id] ?? 0;
      if (n <= 0) return false;
      inv[id] = n - 1;
    }
    state = state.copyWith(prepInventory: inv);
    _persist();
    return true;
  }

  void markSecondWindUsed() {
    state = state.copyWith(secondWindUsedDay: PlayerProfile._todayKey());
    _persist();
  }

  Future<void> applyVictory({
    required String nodeId,
    required int coinReward,
    bool isBoss = false,
  }) async {
    final completed = {...state.completedNodeIds, nodeId};
    var inv = Map<PrepItemId, int>.from(state.prepInventory);
    final drops = <String>[];
    if (!isBoss) {
      for (final e in PrepDrops.forNonBossClear().entries) {
        inv[e.key] = (inv[e.key] ?? 0) + e.value;
        drops.add('+${e.value} ${e.key.displayName}');
      }
    }
    state = state.copyWith(
      coins: state.coins + coinReward,
      completedNodeIds: completed,
      prepInventory: inv,
    );
    await _persist();
  }

  Future<void> applyDefeat() async {
    // Campaign HP-loss does not spend lives (weekly will). Keep hook for later.
    await _persist();
  }

  Future<void> resetProgress() async {
    state = const PlayerProfile();
    await _persist();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, PlayerProfile>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileNotifier(prefs);
});

/// Back-compat alias.
final mockProfileProvider = profileProvider;

/// Prep selected for the next boss launch (cleared after battle starts).
final pendingBossPrepProvider =
    StateProvider<List<PrepItemId>>((ref) => const []);
