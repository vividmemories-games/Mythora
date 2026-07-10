# Heroes

| Field | Value |
|-------|-------|
| **Status** | Phase 1 stubs |
| **Last Updated** | 2026-07-10 |
| **Authority** | Identity & roster notes; numbers → [Balancing Bible](Balancing_Bible.md) |
| **Code** | `lib/features/heroes/domain/hero_def.dart` |
| **Related** | [GAMEPLAY](../GAMEPLAY.md) |

## Rules (from GAMEPLAY)

- Skills cost **resources + AP**
- Phase 1: **1 hero** in battle
- Primary resources define fantasy, not exclusive access

## Design roster (GAMEPLAY)

| Hero | Moves | Max AP | Role | Primary resources |
|------|------:|-------:|------|-------------------|
| Knight | 4 | 6 | Tank | attack, shield |
| Mage | 5 | 8 | Spell damage | mana, ultimate |
| Rogue | 6 | 4 | Fast damage | attack, ultimate |
| Priest | 5 | 6 | Support / heal | healing, mana |

## Implemented in code (Phase 1)

| Id | Name | Moves | Max AP | Max HP | Skills |
|----|------|------:|-------:|-------:|--------|
| `mage` | Mage | 5 | 8 | 80 | Fireball (8 mana + 2 AP → 24 dmg), Arcane Bolt (4 mana + 1 AP → 12 dmg) |
| `knight` | Knight | 4 | 6 | 120 | Basic Slash (4 attack + 1 AP → 14 dmg), Shield Wall (8 shield + 2 AP → +20 shield) |

Rogue and Priest are design-only until authored.

## Content pipeline note

Prefer stable string IDs (`mage`, `fireball`). Later: JSON / Firestore editors per [PHASES](../PHASES.md) Phase 2.
