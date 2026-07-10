/// Enemy skill stub — weights/damage refined in Phase 2 Balancing Bible.
class EnemySkill {
  const EnemySkill({
    required this.id,
    required this.name,
    required this.damage,
    required this.weight,
  });

  final String id;
  final String name;
  final int damage;
  final int weight;
}

class EnemyDef {
  const EnemyDef({
    required this.id,
    required this.name,
    required this.maxHp,
    required this.skills,
    this.blurb = '',
  });

  final String id;
  final String name;
  final int maxHp;
  final List<EnemySkill> skills;
  final String blurb;

  /// Highest-damage skill — used as intent telegraph stub.
  EnemySkill get heaviestSkill {
    var best = skills.first;
    for (final s in skills) {
      if (s.damage > best.damage) best = s;
    }
    return best;
  }
}

abstract final class EnemyCatalog {
  static const goblin = EnemyDef(
    id: 'goblin',
    name: 'Goblin Scout',
    maxHp: 50,
    blurb: 'A skittish scout with a mean nick.',
    skills: [
      EnemySkill(id: 'nick', name: 'Nick', damage: 4, weight: 45),
      EnemySkill(id: 'slash', name: 'Slash', damage: 8, weight: 40),
      EnemySkill(id: 'heavy', name: 'Heavy Swing', damage: 14, weight: 15),
    ],
  );

  static const wolf = EnemyDef(
    id: 'wolf',
    name: 'Dusk Wolf',
    maxHp: 70,
    blurb: 'Fast bites; watch your shield.',
    skills: [
      EnemySkill(id: 'snap', name: 'Snap', damage: 6, weight: 40),
      EnemySkill(id: 'maul', name: 'Maul', damage: 11, weight: 40),
      EnemySkill(id: 'pounce', name: 'Pounce', damage: 16, weight: 20),
    ],
  );

  static const shaman = EnemyDef(
    id: 'shaman',
    name: 'Bog Shaman',
    maxHp: 85,
    blurb: 'Hexes that sting harder than they look.',
    skills: [
      EnemySkill(id: 'hex', name: 'Hex', damage: 7, weight: 45),
      EnemySkill(id: 'bolt', name: 'Bog Bolt', damage: 12, weight: 35),
      EnemySkill(id: 'curse', name: 'Curse', damage: 18, weight: 20),
    ],
  );

  static const brute = EnemyDef(
    id: 'brute',
    name: 'Stone Brute',
    maxHp: 110,
    blurb: 'Slow, heavy, and hard to ignore.',
    skills: [
      EnemySkill(id: 'shove', name: 'Shove', damage: 8, weight: 40),
      EnemySkill(id: 'smash', name: 'Smash', damage: 14, weight: 40),
      EnemySkill(id: 'quake', name: 'Quake', damage: 22, weight: 20),
    ],
  );

  static const warchief = EnemyDef(
    id: 'warchief',
    name: 'Warchief Ruk',
    maxHp: 140,
    blurb: 'Chapter boss — punish hesitation.',
    skills: [
      EnemySkill(id: 'bark', name: 'War Bark', damage: 10, weight: 35),
      EnemySkill(id: 'cleave', name: 'Cleave', damage: 16, weight: 40),
      EnemySkill(id: 'execute', name: 'Execute', damage: 26, weight: 25),
    ],
  );

  static const all = [goblin, wolf, shaman, brute, warchief];

  static EnemyDef byId(String id) =>
      all.firstWhere((e) => e.id == id, orElse: () => goblin);
}
