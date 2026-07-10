# Theme (Dusk)

| Field | Value |
|-------|-------|
| **Status** | Active |
| **Last Updated** | 2026-07-10 |
| **Code** | `lib/core/theme/app_theme.dart` |
| **Related** | [Vision](../00_Project/Vision.md) · [Animations](Animations.md) |

## Identity

Dusk adventure: deep teal / ink surfaces, parchment text, amber / soft-gold accents, ember for danger.

**Not** Dot Clash neon. **Not** Labyrinth Legends stone-citadel LLDL.

## Color tokens (`MythoraColors`)

| Token | Hex | Use |
|-------|-----|-----|
| `ink` | `#0B1C24` | Scaffold / deepest bg |
| `deepTeal` | `#123A44` | Panels, board chrome |
| `mist` | `#1E4D57` | Borders, track fills |
| `parchment` | `#E8DFC8` | Primary text / selection |
| `amber` | `#D4A24C` | Primary actions, hero HP |
| `softGold` | `#E6C87A` | Phase labels, accents |
| `ember` | `#C45C3A` | Enemy HP / danger |
| `muted` | `#8FA6AD` | Secondary text |

### Tile colors

| Token | Hex | Resource |
|-------|-----|----------|
| `tileRed` | `#C94B4B` | attack |
| `tileBlue` | `#3D7CC9` | mana |
| `tileGreen` | `#3FA86A` | healing |
| `tileYellow` | `#D4B03C` | shield |
| `tilePurple` | `#8B5CB8` | ultimate |

## Typography

Display / headlines: Georgia (expressive, not Inter/system default). Body: clean sans via ThemeData defaults with parchment/muted colors.

## Accessibility note

Do not rely on tile **color alone** forever — plan icons/shapes for color-vision support ([GAMEPLAY](../GAMEPLAY.md) resources stay color-mapped mechanically).
