# AB1 — Production Standards

| Field | Value |
|-------|-------|
| **Status** | Active — first art pass |
| **Last Updated** | 2026-07-10 |
| **Authority** | Sizes, naming, export, AI workflow; visual identity → [Theme](../02_Design_System/Theme.md) |
| **Related** | [Asset Bible README](README.md) · [Heroes](../01_Game_Design/Heroes.md) · [Enemies](../01_Game_Design/Enemies.md) · [Theme](../02_Design_System/Theme.md) |

AB1 locks how Mythora assets are **named, sized, exported, reviewed, and wired into Flutter**. Use it before generating the first hero/enemy/tile pass.

---

## 1. Scope

### In scope (Phase 1 art pass)

| Domain | Purpose | Priority |
|--------|---------|----------|
| Style board | Lock Dusk look before batch generation | P0 |
| Puzzle tiles | 5 resource colors + shape overlay | P0 |
| Hero portraits | Battle header + roster bust | P0 |
| Enemy portraits | Battle header + campaign node | P0 |
| Skill icons | Hero + enemy skill buttons | P1 |
| UI chrome | Optional panel/button textures (prefer Flutter widgets) | P2 |
| VFX | Match clear, hit flash, cast puff (single-frame or 2–3 frames) | P2 |

### Out of scope (AB1)

- Animated character spritesheets
- Full environment / map art
- Store marketing packs (AB4+)
- 3D meshes
- Per-campaign world kits

---

## 2. Art direction lock (Dusk)

All generated assets must read as **dusk adventure** — not neon arcade, not stone citadel.

### Do

- Deep teal / ink backgrounds (`#0B1C24`, `#123A44`)
- Parchment skin tones and warm highlights (`#E8DFC8`, `#D4A24C`, `#E6C87A`)
- Ember only for enemy danger accents (`#C45C3A`)
- Painterly 2D with **clean silhouettes** readable at phone scale
- Soft rim light; restrained detail on faces at bust scale

### Don't

- Cyan/magenta neon glow (Dot Clash territory)
- Grey stone fortress / LLDL citadel motifs
- Photorealistic faces or busy backgrounds behind portraits
- Text baked into PNGs (Flutter renders all copy)
- Gradients so dark tiles disappear on `deepTeal` board chrome

### Style anchor sentence

Use this verbatim in AI prompts until a custom LoRA exists:

> Mobile game art, dusk fantasy adventure, deep teal and ink palette, parchment and amber gold accents, painterly 2D illustration, clean readable silhouette, premium mobile RPG, no neon, no photorealism.

---

## 3. Tooling

| Role | Tool | Use for |
|------|------|---------|
| **Primary** | [Leonardo AI](https://leonardo.ai) | Heroes, enemies, tiles, skill icons, VFX |
| **UI batch** | [ForgeGUI](https://forgegui.com) or [UI Forge](https://uiforge.vikings.studio) | Panel textures, decorative frames (if not pure Flutter) |
| **Concept only** | Midjourney | Mood boards, store hero art — **not** production batches |
| **Scale later** | Scenario.gg | 100+ assets with trained private model |

### Production workflow

```text
1. Generate style board (§8) → human approve
2. Upload style board to Leonardo as Image Guidance / train LoRA (optional)
3. Batch generate by domain using prompt templates (§10)
4. Human review checklist (§11)
5. Export to assets/ paths (§5–§6)
6. Wire assetPath in HeroDef / EnemyDef when UI consumes images
```

**Rule:** No asset ships without passing §11 review.

---

## 4. Golden reference set (style board)

Create **five** approved PNGs before batch production. Store sources in `assets/images/style_board/` (generated) and keep editable masters off-repo if needed.

| File | Content | Tool |
|------|---------|------|
| `style_board_hero_mage.png` | Mage bust, neutral pose, teal bg | Leonardo |
| `style_board_enemy_goblin.png` | Goblin bust, slight menace, teal bg | Leonardo |
| `style_board_tile_red.png` | Red attack tile with gem/sword shape | Leonardo |
| `style_board_skill_fireball.png` | Fireball skill icon, square | Leonardo |
| `style_board_ui_panel.png` | Panel corner sample OR full chip row mock | ForgeGUI |

These five define palette, line weight, and contrast. Every later asset should be compared side-by-side against this set.

---

## 5. Directory layout

```text
assets/
├── heroes/              # hero_{id}.png
├── enemies/             # enemy_{id}.png
├── images/
│   ├── style_board/     # AB1 golden references (§4)
│   ├── tiles/           # tile_{color}.png, tile_{color}_shape.png
│   ├── skills/          # skill_{id}.png, enemy_skill_{id}.png
│   ├── icons/           # resource chips, intent badges, status
│   ├── ui/              # optional 9-slice panel PNGs
│   └── vfx/             # fx_{name}.png or fx_{name}_{frame}.png
└── levels/              # JSON only — not art
```

`pubspec.yaml` already declares `assets/heroes/`, `assets/enemies/`, and `assets/images/` (recursive via folder registration — add subfolders to pubspec when first PNG lands).

---

## 6. Naming conventions

Pattern: `{category}_{stable_id}.png` — lowercase, underscores, **no spaces**, IDs match domain models.

### Heroes & enemies

| Pattern | Example | Maps to |
|---------|---------|---------|
| `hero_{id}.png` | `hero_mage.png` | `HeroDef.id` |
| `enemy_{id}.png` | `enemy_goblin.png` | `EnemyDef.id` |

Phase 1 roster:

| Asset file | Code id |
|------------|---------|
| `hero_mage.png` | `mage` |
| `hero_knight.png` | `knight` |
| `enemy_goblin.png` | `goblin` |
| `enemy_wolf.png` | `wolf` |
| `enemy_shaman.png` | `shaman` |
| `enemy_brute.png` | `brute` |
| `enemy_warchief.png` | `warchief` |

### Tiles

| Pattern | Example | Maps to |
|---------|---------|---------|
| `tile_{color}.png` | `tile_red.png` | `TileColor.red` |
| `tile_{color}_shape.png` | `tile_red_shape.png` | Accessibility overlay (§9) |

Colors: `red`, `blue`, `green`, `yellow`, `purple`.

### Skills

| Pattern | Example | Maps to |
|---------|---------|---------|
| `skill_{id}.png` | `skill_fireball.png` | `SkillDef.id` |
| `enemy_skill_{id}.png` | `enemy_skill_nick.png` | `EnemySkill.id` |

### Icons & UI

| Pattern | Example | Use |
|---------|---------|-----|
| `icon_resource_{id}.png` | `icon_resource_mana.png` | Resource chip |
| `icon_intent_attack.png` | — | Enemy intent telegraph |
| `ui_panel_{name}.png` | `ui_panel_battle.png` | Optional 9-slice |
| `fx_{name}.png` | `fx_match_clear.png` | VFX sprite |

### Forbidden

- Display names in filenames (`Fireball Skill!!!.png`)
- Random hashes (`hero_mage_v2_final_FINAL.png`)
- Mixed casing (`Hero_Mage.png`)

---

## 7. Export specifications

### Global rules

| Property | Value |
|----------|-------|
| Format | PNG-24, sRGB |
| Alpha | Straight alpha; no premultiplied unless pipeline requires |
| Color profile | sRGB IEC61966-2.1 |
| Max file size (guideline) | ≤ 300 KB per portrait; ≤ 80 KB per tile @2x |
| Compression | TinyPNG or pngquant after review — visually lossless |
| DPI metadata | 72 DPI (Flutter uses logical pixels) |

### Master vs delivery

Generate at **master** size, then export **delivery** PNG. Keep masters at 2× delivery where noted.

| Asset | Master (px) | Delivery @2x (px) | Display @1x (logical pt) | Notes |
|-------|------------:|------------------:|-------------------------:|-------|
| Hero portrait | 1024 × 1024 | 512 × 512 | 256 × 256 | Bust centered; safe margin 10% |
| Enemy portrait | 1024 × 1024 | 512 × 512 | 256 × 256 | Same frame as hero for alignment |
| Puzzle tile | 512 × 512 | 256 × 256 | ~44–56 pt (6×6 board) | Square; corner radius applied in UI |
| Tile shape overlay | 512 × 512 | 256 × 256 | Same as tile | White glyph, full alpha |
| Skill icon | 512 × 512 | 128 × 128 | 64 × 64 | Simple icon; no text |
| Resource icon | 256 × 256 | 64 × 64 | 32 × 32 | HUD chip |
| UI panel (9-slice) | 512 × 512 min | — | — | See §7.1 |
| VFX single | 512 × 512 | 256 × 256 | — | Center-origin |
| VFX sheet | 2048 × 512 max | — | — | Horizontal strip, ≤8 frames |

**Flutter note:** Phase 1 may load delivery @2x PNGs directly via `Image.asset` without `@2x` suffixes; name files without density suffix for simplicity.

### 7.1 Nine-slice UI panels

If using raster panels:

- Canvas includes visible corner ornament + stretchable center
- **Fixed corners:** 48 × 48 px @2x (24 pt @1x)
- **Minimum center:** 32 × 32 px repeatable
- Export with transparent outside the panel bounds
- Document slice insets in filename sidecar: `ui_panel_battle.nine.json` (optional AB1.1)

Prefer **Flutter `DecoratedBox` + `MythoraColors`** over raster panels when possible.

---

## 8. Domain specs

### 8.1 Hero & enemy portraits

- **Framing:** Head + shoulders bust; eyes in upper third
- **Background:** Solid `#123A44` or soft teal gradient — **no** busy scenes
- **Lighting:** Warm key from upper left; subtle amber rim
- **Expression:** Readable emotion at 256 pt width on iPhone SE
- **Alignment:** Face center ±5% horizontal; chin above bottom 15%

Enemy portraits may use slightly more ember in accents; heroes use amber/gold.

### 8.2 Puzzle tiles

Board is **6×6**, cells sized responsively in `AnimatedPuzzleBoard`. Tiles must read at ~44 pt.

Each color tile includes:

1. **Base gem** — fill close to `MythoraColors.tile*` (see [Theme](../02_Design_System/Theme.md))
2. **Inner highlight** — lighter core for depth
3. **Shape overlay** (separate PNG or drawn in Flutter Phase 1.1):

| Color | Resource | Shape |
|-------|----------|-------|
| red | attack | sword / chevron |
| blue | mana | droplet / arcane swirl |
| green | healing | leaf / cross |
| yellow | shield | shield |
| purple | ultimate | star / crown |

Until shape overlays ship, **do not rely on color alone** for accessibility — plan the `_shape` files in the same pass.

### 8.3 Skill icons

- Square, 80% glyph / 20% padding
- Single focal object; no tiny detail
- Hero skills: amber accent border optional (can be Flutter `Container` border)
- Enemy skills: ember accent optional

### 8.4 VFX (lightweight)

Match animation timings in [Animations](../02_Design_System/Animations.md):

| FX | Duration target | Frames |
|----|-----------------|--------|
| Match clear | 220 ms | 1–3 |
| Combat hit | 320 ms | 1–2 |
| Skill cast | 320 ms | 2–3 |

Prefer **Flutter opacity/scale tweens** over sprite animation when a single PNG + code motion suffices.

---

## 9. Accessibility

- Every tile color has a paired `tile_{color}_shape.png` (white silhouette, alpha)
- Minimum contrast between tile base and `deepTeal` board: **3:1** for distinguishability
- Portrait expressions and skill icons should remain recognizable when desaturated — test in Photopea

---

## 10. Prompt templates

Replace `{SUBJECT}` and `{DETAIL}`. Append the style anchor sentence (§2).

### Leonardo — hero portrait

```text
Character portrait bust, {SUBJECT}, {DETAIL}, facing slightly right,
shoulders visible, neutral battle-ready expression,
solid deep teal background #123A44,
warm amber rim light, painterly mobile game illustration,
clean silhouette, no text, no watermark.
Mobile game art, dusk fantasy adventure, deep teal and ink palette,
parchment and amber gold accents, painterly 2D illustration,
clean readable silhouette, premium mobile RPG, no neon, no photorealism.
```

**Mage example:** `{SUBJECT}` = young arcane mage with hooded cloak; `{DETAIL}` = faint purple arcane glow on hands.

### Leonardo — enemy portrait

```text
Enemy character portrait bust, {SUBJECT}, {DETAIL}, menacing but readable,
solid deep teal background #123A44, subtle ember accent lighting,
painterly mobile game illustration, clean silhouette, no text.
Mobile game art, dusk fantasy adventure, deep teal and ink palette,
parchment and amber gold accents, painterly 2D illustration,
clean readable silhouette, premium mobile RPG, no neon, no photorealism.
```

**Goblin example:** `{SUBJECT}` = goblin scout with crude dagger; `{DETAIL}` = large ears, wary grin.

### Leonardo — puzzle tile

```text
Single square game gem icon, {COLOR_NAME} resource crystal,
color hex {HEX}, soft inner glow, subtle faceted gem shape,
centered on transparent background, mobile puzzle game tile,
no text, minimal detail, readable at small size.
Mobile game art, dusk fantasy adventure, deep teal and ink palette,
parchment and amber gold accents, painterly 2D illustration,
clean readable silhouette, premium mobile RPG, no neon, no photorealism.
```

| Color | `{COLOR_NAME}` | `{HEX}` |
|-------|----------------|---------|
| red | attack energy | `#C94B4B` |
| blue | mana | `#3D7CC9` |
| green | healing | `#3FA86A` |
| yellow | shield | `#D4B03C` |
| purple | ultimate | `#8B5CB8` |

### Leonardo — skill icon

```text
Square skill icon, {SKILL_DESCRIPTION}, centered glyph,
transparent background, amber gold accent details,
simple readable shape, mobile RPG ability icon, no text border.
Mobile game art, dusk fantasy adventure, deep teal and ink palette,
parchment and amber gold accents, painterly 2D illustration,
clean readable silhouette, premium mobile RPG, no neon, no photorealism.
```

### ForgeGUI — UI panel sample

```text
Game UI panel corner texture, dusk fantasy mobile RPG,
deep teal panel #123A44, mist border #1E4D57,
subtle amber gold corner ornament, parchment-friendly,
flat center area for 9-slice stretch, no text, no buttons.
```

---

## 11. Review checklist (required before ship)

Every asset batch must pass **all** items:

- [ ] Matches style board (§4) in palette and line weight
- [ ] Correct filename and folder (§5–§6)
- [ ] Delivery dimensions (§7)
- [ ] Readable at target display size on 375 × 667 (iPhone SE class)
- [ ] No baked text, logos, or watermarks
- [ ] Alpha clean — no halos on teal background
- [ ] File size within guideline
- [ ] ID matches code catalog ([Heroes](../01_Game_Design/Heroes.md), [Enemies](../01_Game_Design/Enemies.md))
- [ ] Compared desaturated for shape readability (tiles/skills)

**Reject and regenerate** if style drift, wrong ID, or illegibility at phone scale.

---

## 12. Flutter integration (when wiring)

Optional `assetPath` on defs (future):

```dart
// hero_def.dart — pattern only; not required until UI loads PNGs
final String? portraitAsset; // 'assets/heroes/hero_mage.png'
```

Load convention:

```dart
Image.asset('assets/heroes/hero_${hero.id}.png')
Image.asset('assets/enemies/enemy_${enemy.id}.png')
Image.asset('assets/images/tiles/tile_red.png')
Image.asset('assets/images/skills/skill_${skill.id}.png')
```

Until portraits land, UI continues using color blocks + typography from `MythoraColors`.

---

## 13. Phase 1 production order

| Step | Deliverables |
|------|--------------|
| 1 | Style board (§4) approved |
| 2 | Five tiles + five shape overlays |
| 3 | `hero_mage`, `hero_knight` |
| 4 | Twilight Road enemies (5) |
| 5 | Mage/knight skills (4 icons) |
| 6 | Goblin enemy skills (3 icons) — optional P1 |
| 7 | `fx_match_clear`, `fx_hit` — optional P2 |

---

## 14. What comes next (AB2+)

| Doc | When |
|-----|------|
| AB2 — Animation & VFX sheets | When multi-frame VFX replace tweens |
| AB3 — Cosmetic / rarity frames | When shop cosmetics ship |
| AB4 — Store & marketing | Before App Store / Play listing |

---

## Changelog

| Date | Change |
|------|--------|
| 2026-07-10 | AB1 initial lock — sizes, naming, tooling, prompts, style board |
