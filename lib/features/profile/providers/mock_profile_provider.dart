import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../heroes/domain/hero_def.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main()');
});

/// Local profile until Firebase is wired (see docs/PHASES.md).
class PlayerProfile {
  const PlayerProfile({
    this.displayName = 'Wanderer',
    this.coins = 500,
    this.gems = 50,
    this.selectedHeroId = 'mage',
    this.completedNodeIds = const {},
  });

  final String displayName;
  final int coins;
  final int gems;
  final String selectedHeroId;
  final Set<String> completedNodeIds;

  HeroDef get selectedHero => HeroCatalog.byId(selectedHeroId);

  PlayerProfile copyWith({
    String? displayName,
    int? coins,
    int? gems,
    String? selectedHeroId,
    Set<String>? completedNodeIds,
  }) {
    return PlayerProfile(
      displayName: displayName ?? this.displayName,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      selectedHeroId: selectedHeroId ?? this.selectedHeroId,
      completedNodeIds: completedNodeIds ?? this.completedNodeIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'coins': coins,
        'gems': gems,
        'selectedHeroId': selectedHeroId,
        'completedNodeIds': completedNodeIds.toList(),
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final ids = (json['completedNodeIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {};
    return PlayerProfile(
      displayName: json['displayName'] as String? ?? 'Wanderer',
      coins: json['coins'] as int? ?? 500,
      gems: json['gems'] as int? ?? 50,
      selectedHeroId: json['selectedHeroId'] as String? ?? 'mage',
      completedNodeIds: ids,
    );
  }
}

class ProfileNotifier extends StateNotifier<PlayerProfile> {
  ProfileNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static const _key = 'mythora_profile_v1';

  static PlayerProfile _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
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

  Future<void> applyVictory({
    required String nodeId,
    required int coinReward,
  }) async {
    final completed = {...state.completedNodeIds, nodeId};
    state = state.copyWith(
      coins: state.coins + coinReward,
      completedNodeIds: completed,
    );
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
