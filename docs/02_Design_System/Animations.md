# Animations

| Field | Value |
|-------|-------|
| **Status** | Active (Phase 1 timings) |
| **Last Updated** | 2026-07-10 |
| **Code** | `BattleController` durations · `AnimatedPuzzleBoard` |
| **Related** | [Theme](Theme.md) · `.cursor/rules/06-ui-ux-polish.mdc` |

## Temperament

- Satisfying but **short** — battle stays readable
- Cascade motion leads; HUD motion stays minimal
- Prefer ease-out curves; avoid elastic bounce on core HUD
- Character idle/attack sheets deferred to **AB2** (chibi stage sprites are still PNGs in AB1)

## Phase 1 duration roles

| Role | Duration | Code constant / note |
|------|----------|----------------------|
| Swap settle | ~100ms | Brief pause after swap before clear |
| Match destroy | 220ms | `BattleController.clearDuration` |
| Gravity fall | 260ms | `fallDuration` |
| Spawn drop-in | 280ms | `spawnDuration` |
| Combat FX (hit flash/shake) | 320ms | `combatFxDuration` |
| Enemy telegraph | 400ms | `enemyTelegraph` |
| Selection chrome | 120ms | Tile border `AnimatedContainer` |

## Reduced motion

When `MediaQuery.disableAnimationsOf(context)` is true (future hardening):

- Skip multi-step cascade delays where safe; snap to final board
- Keep state changes comprehensible without motion
- Prefer fade over shake

## Out of scope for now

Hero/enemy sprite animation, particle VFX libraries, ceremonial victory sequences — polish after art pass.
