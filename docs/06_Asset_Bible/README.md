# Asset Bible

| Field | Value |
|-------|-------|
| **Status** | Active — AB1 locked (chibi battle stage) |
| **Last Updated** | 2026-07-20 |
| **Related** | [Theme](../02_Design_System/Theme.md) · [Vision](../00_Project/Vision.md) · [Decisions](../00_Project/Decisions.md) · [Content Architecture](../01_Game_Design/Content_Architecture.md) |

Philosophy adapted from Labyrinth Legends AB0/AB5 — **without** maze tilesets or citadel world packs.

## Documents

| Doc | Status | Purpose |
|-----|--------|---------|
| **This README** | Active | Philosophy and index |
| [AB1 — Production Standards](AB1_Production_Standards.md) | **Active** | Sizes, naming, export, AI workflow, chibi lock |
| [AB1 — Leonardo Prompt Pack](AB1_Leonardo_Prompt_Pack.md) | **Active** | Style-board + Phase 1 beginner prompts |
| [Master Prompts](Master_Prompts.md) | **Active** | Checklist + path + P0–P4 priority + Leonardo prompt per artwork |
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

| Domain | Examples | Source |
|--------|----------|--------|
| Tiles | Five resource colors | AB1 + shipped |
| Heroes / trash / bosses | Full campaign roster | [Master Prompts](Master_Prompts.md) · [Content Architecture](../01_Game_Design/Content_Architecture.md) |
| Power-ups + meta prep | Rocket, bomb, tonic… | Master Prompts §7–§8 |
| BGs / maps | Chapter battle BGs + **4 act maps per chapter** (40 total) | Master Prompts · Content Architecture |
| VFX | Clear, create, hit, flee | Master Prompts §9 |

## Out of scope now

Semi-real bust portraits as primary art, unique painted BG per level, AB workshop chain beyond AB1.

## Start here

1. Read [Content Architecture](../01_Game_Design/Content_Architecture.md) for counts and priority
2. Generate from [Master Prompts](Master_Prompts.md) in priority order (§10)
3. Follow [AB1](AB1_Production_Standards.md) for export sizes and review
