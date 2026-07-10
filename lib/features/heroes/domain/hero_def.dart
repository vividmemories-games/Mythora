/// Stub hero definition for Phase 1 (single hero in battle).
class HeroDef {
  const HeroDef({
    required this.id,
    required this.name,
    required this.movesPerTurn,
    required this.maxAp,
    required this.maxHp,
    required this.primaryResources,
    required this.skills,
  });

  final String id;
  final String name;
  final int movesPerTurn;
  final int maxAp;
  final int maxHp;
  final List<String> primaryResources;
  final List<SkillDef> skills;
}

class SkillDef {
  const SkillDef({
    required this.id,
    required this.name,
    required this.apCost,
    required this.resourceCosts,
    required this.damage,
    this.heal = 0,
    this.shield = 0,
  });

  final String id;
  final String name;
  final int apCost;

  /// resourceId → amount (attack, mana, healing, shield, ultimate)
  final Map<String, int> resourceCosts;
  final int damage;
  final int heal;
  final int shield;
}

/// Placeholder roster — numbers from docs/GAMEPLAY.md.
abstract final class HeroCatalog {
  static const mage = HeroDef(
    id: 'mage',
    name: 'Mage',
    movesPerTurn: 5,
    maxAp: 8,
    maxHp: 80,
    primaryResources: ['mana', 'ultimate'],
    skills: [
      SkillDef(
        id: 'fireball',
        name: 'Fireball',
        apCost: 2,
        resourceCosts: {'mana': 8},
        damage: 24,
      ),
      SkillDef(
        id: 'arcane_bolt',
        name: 'Arcane Bolt',
        apCost: 1,
        resourceCosts: {'mana': 4},
        damage: 12,
      ),
    ],
  );

  static const knight = HeroDef(
    id: 'knight',
    name: 'Knight',
    movesPerTurn: 4,
    maxAp: 6,
    maxHp: 120,
    primaryResources: ['attack', 'shield'],
    skills: [
      SkillDef(
        id: 'basic_slash',
        name: 'Basic Slash',
        apCost: 1,
        resourceCosts: {'attack': 4},
        damage: 14,
      ),
      SkillDef(
        id: 'shield_wall',
        name: 'Shield Wall',
        apCost: 2,
        resourceCosts: {'shield': 8},
        damage: 0,
        shield: 20,
      ),
    ],
  );

  static const all = [mage, knight];

  static HeroDef byId(String id) =>
      all.firstWhere((h) => h.id == id, orElse: () => mage);
}
