# Balancing Bible

| Field | Value |
|-------|-------|
| **Status** | Phase 2 stub — outline only |
| **Last Updated** | 2026-07-10 |
| **Authority** | Numbers & formulas (must not contradict [GAMEPLAY](../GAMEPLAY.md) rules) |
| **Related** | [Heroes](Heroes.md) · [Enemies](Enemies.md) · [Economy](Economy.md) · [PHASES](../PHASES.md) |

## Purpose

Single place for tunable combat and progression numbers. Phase 1 uses placeholders from GAMEPLAY and code catalogs; this document becomes authoritative in the Phase 2 session.

## In scope (Phase 2)

- Hero HP, Moves, max AP, skill costs/damage/heal/shield
- Resource generation rates (tiles → meters)
- AP generation formula (match size, cascades)
- Enemy HP, skill weights, damage caps
- XP curves, loot tables, rarity
- Equipment rule modifiers (not only flat stats)

## Out of scope here

- Combat loop structure (GAMEPLAY)
- Firebase schemas (Technical / content pipeline session)
- Art production (Asset Bible)

## Phase 1 stub pointers (replace later)

| Area | Current source |
|------|----------------|
| Hero roster | `lib/features/heroes/domain/hero_def.dart` + [Heroes](Heroes.md) |
| Enemy skills | `lib/features/battle/domain/enemy_def.dart` + [Enemies](Enemies.md) |
| AP placeholder | `matched.length ~/ 3` (min 1) in `PuzzleEngine.resolveMatches` |
| Board size | 6×6 |

## Working principles

1. Stub numbers are allowed until playtests say otherwise.
2. Prefer data/config over hardcoded magic once Phase 2 lands.
3. Cap enemy damage; prefer weighted skill tables over pure RNG spikes.
4. Record formula changes in [Decisions](../00_Project/Decisions.md).
