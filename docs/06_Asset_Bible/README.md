# Asset Bible

| Field | Value |
|-------|-------|
| **Status** | Active — AB1 locked (chibi battle stage) |
| **Last Updated** | 2026-07-11 |
| **Related** | [Theme](../02_Design_System/Theme.md) · [Vision](../00_Project/Vision.md) · [Decisions](../00_Project/Decisions.md) |

Philosophy adapted from Labyrinth Legends AB0/AB5 — **without** maze tilesets or citadel world packs.

## Documents

| Doc | Status | Purpose |
|-----|--------|---------|
| **This README** | Active | Philosophy and index |
| [AB1 — Production Standards](AB1_Production_Standards.md) | **Active** | Sizes, naming, export, AI workflow, chibi lock |
| [AB1 — Leonardo Prompt Pack](AB1_Leonardo_Prompt_Pack.md) | **Active** | Copy-paste Leonardo prompts + beginner workflow |
| AB2 — Animation & VFX | Planned | Idle/attack sheets for battle stage |
| AB3 — Cosmetics & rarity | Planned | Shop frames, skins |
| AB4 — Store & marketing | Planned | Screenshots, icons |

## Principles

1. **Systems over bespoke art** — reusable frames, rarity borders, skill icons
2. **Readability first** — board tiles and staged characters beat illustration detail
3. **One style on the battle screen** — chibi characters + glossy tiles + dusk palette
4. **Dusk identity** — follow [Theme](../02_Design_System/Theme.md)
5. **AI-assisted production OK** — human review required before ship ([AB1 §11](AB1_Production_Standards.md#11-review-checklist-required-before-ship))
6. **Stable IDs & naming** — `hero_mage.png`, `enemy_goblin.png`, `tile_red.png`

## Planned asset domains

| Domain | Examples | AB1 section |
|--------|----------|-------------|
| Tiles | Five resource colors + shape overlays | §8.2 |
| Heroes | Full-body chibi battle sprites (stage left + roster) | §8.1 |
| Enemies | Full-body chibi battle sprites (stage right + campaign) | §8.1 |
| UI | Panels, buttons, resource chips (prefer Flutter) | §7.1, §8 |
| VFX | Match clear, skill cast, hit (lightweight) | §8.4 |
| Marketing | Store screenshots | AB4 (later) |

## Out of scope now

Semi-real bust portraits as primary art, full environment battle scenes, AB workshop chain beyond AB1.

## Start here

1. Read [AB1 — Production Standards](AB1_Production_Standards.md)
2. Open [AB1 — Leonardo Prompt Pack](AB1_Leonardo_Prompt_Pack.md) — use `style_seed_battle_mage.png` + §5.1
3. Follow the [Phase 1 production order](AB1_Production_Standards.md#13-phase-1-production-order)
