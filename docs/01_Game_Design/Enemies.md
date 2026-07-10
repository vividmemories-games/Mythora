# Enemies

| Field | Value |
|-------|-------|
| **Status** | Phase 1 stubs |
| **Last Updated** | 2026-07-10 |
| **Authority** | Behavior notes; numbers → [Balancing Bible](Balancing_Bible.md) |
| **Code** | `lib/features/battle/domain/enemy_def.dart` |
| **Related** | [GAMEPLAY](../GAMEPLAY.md) · [Decisions](../00_Project/Decisions.md) |

## Rules

- Enemy turn after Moves reach zero
- Prefer **weighted skill tables** over a single flat attack
- Cap damage; avoid one-shot spikes until bosses are designed
- Bosses should change **board rules**, not only HP ([GAMEPLAY](../GAMEPLAY.md))

## Implemented enemies (Twilight Road)

| Id | Name | Max HP |
|----|------|-------:|
| `goblin` | Goblin Scout | 50 |
| `wolf` | Dusk Wolf | 70 |
| `shaman` | Bog Shaman | 85 |
| `brute` | Stone Brute | 110 |
| `warchief` | Warchief Ruk | 140 |

Each uses a weighted skill table (see `EnemyCatalog`). Goblin example:

| Skill id | Name | Damage | Weight |
|----------|------|-------:|-------:|
| `nick` | Nick | 4 | 45 |
| `slash` | Slash | 8 | 40 |
| `heavy` | Heavy Swing | 14 | 15 |

Pick = weighted random among skills. Intent UI shows heaviest skill damage as a threat hint.

## Future

- Buffs / debuffs / summons
- Intent telegraph UI
- Boss modifiers (lose Move, poison tiles, armor phases, etc.)
