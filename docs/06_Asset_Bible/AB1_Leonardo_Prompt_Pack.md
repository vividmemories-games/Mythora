# AB1 — Leonardo Prompt Pack

| Field | Value |
|-------|-------|
| **Status** | Active |
| **Last Updated** | 2026-07-10 |
| **Use with** | [AB1 Production Standards](AB1_Production_Standards.md) |
| **Audience** | First-time Leonardo users generating Mythora Phase 1 assets |

Copy prompts **exactly** from this doc. Do not use Leonardo’s “Prompt Enhance” until you have one approved style-board image — it tends to drift away from Dusk palette.

---

## 1. First session (10 minutes)

1. Sign up at [leonardo.ai](https://leonardo.ai) → choose **Premium** if batch-generating (see prior tier notes).
2. Left sidebar → **AI Image Generation**.
3. Set **Private Mode** ON (paid plans).
4. Model: **Leonardo Phoenix** (best prompt adherence for game art).
5. Turn **Alchemy** ON for finals; OFF while exploring (saves tokens).
6. Image dimensions — use the table in §3 for each asset type.
7. Generate **4 images** per run while exploring; **1 image** for finals.
8. After each good result → **Download** → rename per [AB1 §6](AB1_Production_Standards.md#6-naming-conventions).

---

## 2. Universal negative prompt

Paste this into the **Negative Prompt** field for **every** Mythora generation:

```text
text, words, letters, numbers, watermark, logo, signature, username, frame, border, UI, caption,
blurry, low quality, jpeg artifacts, noisy, pixelated, oversaturated, neon colors, cyan glow, magenta glow,
photorealistic, photograph, 3d render, octane, unreal engine, plastic skin,
anime, chibi, cartoon network, disney, pixar, manga,
multiple characters, crowd, duplicate face, extra limbs, deformed hands, bad anatomy,
full body, legs, feet, wide shot, tiny character,
busy background, detailed environment, castle, cathedral, stone fortress, dungeon corridor,
bright white background, harsh spotlight, lens flare,
modern clothing, sci-fi, cyberpunk, guns, robots
```

---

## 3. Universal settings by asset type

| Asset type | Size | Alchemy | Guidance | Notes |
|------------|------|---------|----------|-------|
| Style board portraits | 1024 × 1024 | ON | None (first pass) | Pick best of 4 |
| Production portraits | 1024 × 1024 | ON | Style Ref @ Mid after board locked | Use approved mage as ref |
| Puzzle tiles | 768 × 768 | ON | None | Then Remove Background |
| Tile shape overlays | 768 × 768 | OFF | None | White glyph, transparent |
| Skill icons | 768 × 768 | ON | Style Ref @ Low–Mid | Keep simple |
| VFX | 768 × 768 | ON | None | Transparent preferred |

### Image Guidance (after style board approved)

1. Click **Image Guidance** → upload `style_board_hero_mage.png`
2. Type: **Style Reference**
3. Strength: **Mid** (first try) → **High** if palette drifts
4. For a specific character match: **Character Reference** @ Mid using that portrait

Do **not** stack Style + Character above **High** on both — causes muddy output.

---

## 4. Production order

```text
Day 1 — Style board (§5) → approve 5 PNGs
Day 2 — Train Dusk Element OR use Style Reference only
Day 3 — Tiles + shapes (§6)
Day 4 — Heroes (§7)
Day 5 — Enemies (§8)
Day 6 — Skills (§9)
Day 7 — Review checklist AB1 §11 → export to assets/
```

---

## 5. Style board prompts (generate first)

Run each prompt **4 times**. Pick one winner. Save to `assets/images/style_board/`.

### 5.1 `style_board_hero_mage.png`

**Prompt:**

```text
Single character portrait bust, young arcane mage, hooded deep teal cloak, pale parchment skin,
focused battle-ready expression, faint purple arcane glow on fingertips,
head and shoulders only, facing slightly right, centered composition,
solid flat background color deep teal #123A44, warm amber gold rim light from upper left,
painterly 2D mobile game illustration, clean readable silhouette,
premium fantasy RPG hero portrait, soft brushwork, not photorealistic,
dusk adventure mood, ink and teal shadows, no environment details
```

**Negative:** §2 universal

**Save as:** `assets/images/style_board/style_board_hero_mage.png`

---

### 5.2 `style_board_enemy_goblin.png`

**Prompt:**

```text
Single enemy character portrait bust, goblin scout, green-grey skin, large pointed ears,
crude rusty dagger visible at shoulder, wary mischievous grin, menacing but readable,
head and shoulders only, facing slightly left, centered composition,
solid flat background color deep teal #123A44, subtle ember orange accent light,
painterly 2D mobile game illustration, clean readable silhouette,
premium fantasy RPG enemy portrait, soft brushwork, not photorealistic,
dusk adventure mood, no gore, no environment details
```

**Negative:** §2 universal

**Save as:** `assets/images/style_board/style_board_enemy_goblin.png`

---

### 5.3 `style_board_tile_red.png`

**Prompt:**

```text
Single square puzzle game gem icon, one object only, centered,
red attack energy crystal, rich red color #C94B4B, soft inner glow,
subtle faceted gem cut, slight highlight on top facet,
simple mobile match-3 tile, minimal detail, bold readable shape,
painterly 2D game asset, transparent background, no shadow floor, no text,
dusk fantasy style, premium mobile puzzle game
```

**Negative:** §2 universal + `multiple gems, grid, board, hand, frame`

**Post:** Leonardo **Remove Background** → verify transparency

**Save as:** `assets/images/style_board/style_board_tile_red.png`

---

### 5.4 `style_board_skill_fireball.png`

**Prompt:**

```text
Single square RPG skill icon, one centered symbol only,
fireball spell glyph, orange and amber flames forming a compact sphere,
soft gold accent highlights #E6C87A, simple bold shape readable at 64 pixels,
painterly 2D mobile game icon, transparent background, no circle border, no text,
premium fantasy RPG ability icon, dusk adventure palette, not photorealistic
```

**Negative:** §2 universal + `square frame, button, UI panel, runes text`

**Save as:** `assets/images/style_board/style_board_skill_fireball.png`

---

### 5.5 `style_board_ui_panel.png` (optional — or use Flutter only)

Use **ForgeGUI** for this one if Leonardo struggles with flat UI. If staying in Leonardo:

**Prompt:**

```text
Game UI panel texture swatch, square canvas, dusk fantasy mobile RPG,
deep teal panel fill #123A44, subtle mist border #1E4D57,
small amber gold corner ornament top-left and bottom-right only,
flat empty center area for stretching, no text, no buttons, no icons,
2D hand-painted UI texture, top-down flat view, symmetrical margins
```

**Negative:** §2 universal + `mockup, phone, screenshot, multiple panels`

**Save as:** `assets/images/style_board/style_board_ui_panel.png`

---

## 6. Puzzle tiles (after style board)

**Settings:** 768 × 768, Alchemy ON, Style Reference = `style_board_tile_red.png` @ **Low** (tiles should stay colorful; don’t over-stylize).

### 6.1 Base tiles → `assets/images/tiles/`

#### `tile_red.png`

```text
Single square puzzle game gem icon, one object only, centered,
red attack energy crystal, rich red color #C94B4B, soft inner glow,
subtle faceted gem cut, simple mobile match-3 tile, minimal detail,
painterly 2D, transparent background, premium mobile puzzle game, dusk fantasy
```

#### `tile_blue.png`

```text
Single square puzzle game gem icon, one object only, centered,
blue mana crystal, rich blue color #3D7CC9, soft inner glow,
subtle faceted gem cut, simple mobile match-3 tile, minimal detail,
painterly 2D, transparent background, premium mobile puzzle game, dusk fantasy
```

#### `tile_green.png`

```text
Single square puzzle game gem icon, one object only, centered,
green healing crystal, rich green color #3FA86A, soft inner glow,
subtle faceted gem cut, simple mobile match-3 tile, minimal detail,
painterly 2D, transparent background, premium mobile puzzle game, dusk fantasy
```

#### `tile_yellow.png`

```text
Single square puzzle game gem icon, one object only, centered,
yellow shield energy crystal, rich gold-yellow color #D4B03C, soft inner glow,
subtle faceted gem cut, simple mobile match-3 tile, minimal detail,
painterly 2D, transparent background, premium mobile puzzle game, dusk fantasy
```

#### `tile_purple.png`

```text
Single square puzzle game gem icon, one object only, centered,
purple ultimate energy crystal, rich purple color #8B5CB8, soft inner glow,
subtle faceted gem cut, simple mobile match-3 tile, minimal detail,
painterly 2D, transparent background, premium mobile puzzle game, dusk fantasy
```

**Negative (all tiles):** §2 + `multiple gems, grid, match-3 board, explosion`

**Post each:** Remove Background → crop square → export 256 × 256 delivery size

---

### 6.2 Shape overlays → `assets/images/tiles/`

White silhouette on transparent. Alchemy **OFF**. No Style Reference.

#### `tile_red_shape.png`

```text
Single white flat icon silhouette, simple sword chevron symbol, centered,
pure white #FFFFFF glyph only, transparent background, no gem, no color, no shading,
bold readable shape for colorblind accessibility overlay, mobile game UI icon
```

#### `tile_blue_shape.png`

```text
Single white flat icon silhouette, simple mana droplet symbol, centered,
pure white #FFFFFF glyph only, transparent background, no gem, no color, no shading,
bold readable shape for colorblind accessibility overlay, mobile game UI icon
```

#### `tile_green_shape.png`

```text
Single white flat icon silhouette, simple leaf cross healing symbol, centered,
pure white #FFFFFF glyph only, transparent background, no gem, no color, no shading,
bold readable shape for colorblind accessibility overlay, mobile game UI icon
```

#### `tile_yellow_shape.png`

```text
Single white flat icon silhouette, simple heater shield symbol, centered,
pure white #FFFFFF glyph only, transparent background, no gem, no color, no shading,
bold readable shape for colorblind accessibility overlay, mobile game UI icon
```

#### `tile_purple_shape.png`

```text
Single white flat icon silhouette, simple star crown ultimate symbol, centered,
pure white #FFFFFF glyph only, transparent background, no gem, no color, no shading,
bold readable shape for colorblind accessibility overlay, mobile game UI icon
```

**Negative:** §2 + `color, gradient, 3d, gem, crystal, background gray`

---

## 7. Hero portraits

**Settings:** 1024 × 1024, Alchemy ON, Style Reference = `style_board_hero_mage.png` @ **Mid**

**Negative:** §2 universal

### `hero_mage.png`

```text
Single character portrait bust, young arcane mage, hooded deep teal cloak, pale parchment skin,
focused confident expression, faint purple arcane glow on hands,
head and shoulders only, facing slightly right, centered,
solid flat background deep teal #123A44, warm amber gold rim light,
painterly 2D mobile game hero portrait, clean silhouette, premium fantasy RPG,
dusk adventure, same art style as reference, no environment
```

### `hero_knight.png`

```text
Single character portrait bust, sturdy armored knight, teal-steel chest plate with amber trim,
short beard, calm protective expression, shield edge visible at shoulder,
head and shoulders only, facing slightly right, centered,
solid flat background deep teal #123A44, warm amber gold rim light,
painterly 2D mobile game hero portrait, clean silhouette, premium fantasy RPG,
dusk adventure, same art style as reference, no environment
```

**Save to:** `assets/heroes/`

---

## 8. Enemy portraits

**Settings:** 1024 × 1024, Alchemy ON, Style Reference = `style_board_enemy_goblin.png` @ **Mid**

**Negative:** §2 universal

### `enemy_goblin.png`

```text
Single enemy portrait bust, goblin scout, green-grey skin, large pointed ears,
crude rusty dagger at shoulder, wary mischievous grin,
head and shoulders only, facing slightly left, centered,
solid flat background deep teal #123A44, subtle ember accent light,
painterly 2D mobile game enemy portrait, clean silhouette, no gore
```

### `enemy_wolf.png`

```text
Single enemy portrait bust, dusk wolf, dark grey fur, amber glowing eyes,
snarling but readable expression, faint mist on fur tips,
head and shoulders only, facing forward, centered,
solid flat background deep teal #123A44, subtle ember accent light,
painterly 2D mobile game enemy portrait, clean silhouette, fantasy wolf not realistic photo
```

### `enemy_shaman.png`

```text
Single enemy portrait bust, bog shaman goblinoid, moss and bone talismans,
glowing green-teal hex eyes, hunched mystical expression,
head and shoulders only, facing slightly right, centered,
solid flat background deep teal #123A44, subtle ember and green mist accent,
painterly 2D mobile game enemy portrait, clean silhouette, witch doctor fantasy
```

### `enemy_brute.png`

```text
Single enemy portrait bust, stone brute ogre, rocky skin patches, heavy brow,
slow angry expression, thick neck and shoulders,
head and shoulders only, facing forward, centered,
solid flat background deep teal #123A44, subtle ember accent light,
painterly 2D mobile game enemy portrait, clean silhouette, heavy tank enemy
```

### `enemy_warchief.png`

```text
Single enemy portrait bust, orc warchief Ruk, battle scars, crude iron jaw guard,
fierce commanding glare, small trophy bone on strap,
head and shoulders only, facing slightly left, centered,
solid flat background deep teal #123A44, stronger ember rim light, mini-boss presence,
painterly 2D mobile game boss portrait, clean silhouette, no gore
```

**Save to:** `assets/enemies/`

---

## 9. Skill icons

**Settings:** 768 × 768, Alchemy ON, Style Reference = `style_board_skill_fireball.png` @ **Low–Mid**

**Negative:** §2 + `character face, full scene, button, square frame`

**Save to:** `assets/images/skills/`

### Hero skills

#### `skill_fireball.png`

```text
Single square RPG skill icon, centered fireball spell, orange amber flame sphere,
compact bold shape, soft gold highlights, transparent background, no border, no text,
painterly 2D mobile game ability icon, readable at small size
```

#### `skill_arcane_bolt.png`

```text
Single square RPG skill icon, centered purple-blue arcane bolt streak,
sharp magical arrow shape, soft gold accent sparks, transparent background, no text,
painterly 2D mobile game ability icon, readable at small size
```

#### `skill_basic_slash.png`

```text
Single square RPG skill icon, centered sword slash arc, silver blade trail,
amber gold motion accent, transparent background, no text,
painterly 2D mobile game ability icon, readable at small size
```

#### `skill_shield_wall.png`

```text
Single square RPG skill icon, centered heraldic shield with glowing barrier,
yellow-gold shield energy #D4B03C, transparent background, no text,
painterly 2D mobile game ability icon, readable at small size
```

### Enemy skills (optional P1)

Use ember accents instead of amber. Prefix filename `enemy_skill_`.

#### `enemy_skill_nick.png`

```text
Single square RPG skill icon, centered small dagger nick slash, short red ember trail,
simple aggressive shape, transparent background, no text, enemy ability icon
```

#### `enemy_skill_slash.png`

```text
Single square RPG skill icon, centered curved blade slash, ember orange arc,
simple bold shape, transparent background, no text, enemy ability icon
```

#### `enemy_skill_heavy.png`

```text
Single square RPG skill icon, centered heavy spiked mace swing, thick ember motion arc,
strong bold shape, transparent background, no text, enemy ability icon
```

---

## 10. VFX (optional P2)

**Settings:** 768 × 768, Alchemy ON, transparent background

**Save to:** `assets/images/vfx/`

### `fx_match_clear.png`

```text
Single soft particle burst, small gem fragments dissolving, circular explosion,
warm white and pale gold sparkles, transparent background, one-shot VFX sprite,
painterly 2D mobile game effect, no character, no text, centered
```

### `fx_hit.png`

```text
Single impact hit flash, short red-orange ember slash burst, radial sparks,
transparent background, one-shot VFX sprite, painterly 2D mobile game effect,
no character, centered, readable at small size
```

---

## 11. When output goes wrong

| Problem | Fix |
|---------|-----|
| Neon / cyberpunk colors | Strengthen §2 negative; add `neon, cyan, magenta` again; lower Style Ref to Low |
| Full body shown | Add to prompt: `head and shoulders only, cropped at chest` |
| Two faces / twins | Add negative: `multiple characters, duplicate`; generate 1 image not 4 |
| Text / runes on image | Increase negative `text, runes, letters`; regenerate |
| Wrong background | Add: `solid flat background deep teal #123A44 only` |
| Too photorealistic | Add negative `photograph`; add prompt `painterly 2D illustration` |
| Tile has gray checkerboard | Run **Remove Background**; don’t screenshot canvas |
| Style drift on enemy #4 | Re-attach Style Reference; switch ref to best prior enemy |
| Hands look broken | Portraits shouldn’t show hands — crop tighter or add `hands hidden` |

---

## 12. Post-processing checklist

1. **Remove Background** (tiles, icons, VFX)
2. **Crop** to content; portraits keep 10% margin
3. **Resize** to AB1 delivery sizes (portraits 512, tiles 256, skills 128)
4. **Rename** exactly per AB1 §6
5. Place in correct `assets/` folder
6. Squint test at phone size — reject if unreadable
7. Mark approved in `assets/images/style_board/README.md`

---

## 13. Training Dusk Element (optional, Premium+)

After 5 style-board images are approved:

1. **Training & Datasets** → New Dataset
2. Upload all 5 style-board PNGs + any extra good rejects from same session (max ~15)
3. Name: `Mythora_Dusk_Style`
4. Train on **Flux Dev** or platform-recommended base for Elements
5. Apply Element strength **0.55–0.70** for portraits; **0.45–0.55** for tiles/icons

If training fails or wastes your monthly slot, **Style Reference alone is enough** for Phase 1.

---

## Quick reference — filenames

| Prompt section | Output path |
|----------------|-------------|
| §5 Style board | `assets/images/style_board/` |
| §6 Tiles | `assets/images/tiles/` |
| §7 Heroes | `assets/heroes/` |
| §8 Enemies | `assets/enemies/` |
| §9 Skills | `assets/images/skills/` |
| §10 VFX | `assets/images/vfx/` |
