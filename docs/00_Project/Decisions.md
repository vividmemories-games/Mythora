# Decisions

Log material decisions here. Format: date, decision, reason, status.

Authority: product/engineering choices that override or clarify [PHASES](../PHASES.md) / [GAMEPLAY](../GAMEPLAY.md).

---

## 2026-07-10 — New Flutter app (not Dot Clash)

**Decision:** Build Mythora as a standalone Flutter app at `Documents/Personal Projects/Mythora`.

**Reason:** Different genre, identity, and Firebase project needs; reuse patterns only.

**Status:** Accepted

---

## 2026-07-10 — Combat model locked

**Decision:** Puzzle generates resources; skills cost resources + AP; Moves are the turn budget; then enemy turn. See [GAMEPLAY](../GAMEPLAY.md).

**Reason:** Core product differentiator vs match-3 that deals damage on match.

**Status:** Accepted

---

## 2026-07-10 — Phase 1 scope: 1 hero, 6×6, mock profile

**Decision:** Single hero in battle; first boards 6×6; mock/local profile until the loop feels good.

**Reason:** Prove feel before parties, Firebase, and content pipeline.

**Status:** Accepted

---

## 2026-07-10 — Cascade + no-match spawn

**Decision:** Boards spawn with zero matches. After a successful swap, resolve clear → gravity → spawn in a loop until stable. Cascades grant resources/AP; only the player swap spends a Move.

**Reason:** Leftover on-board matches and in-place refill felt broken.

**Status:** Accepted — implemented in `PuzzleEngine` / `BattleNotifier`

---

## 2026-07-10 — Weighted enemy skill stubs

**Decision:** Enemies pick from weighted skills (e.g. Goblin: Nick / Slash / Heavy Swing). Numbers are Phase 1 stubs for the [Balancing Bible](../01_Game_Design/Balancing_Bible.md).

**Reason:** Flat damage every turn felt lifeless; full AI/balance deferred to Phase 2.

**Status:** Accepted — stub in `EnemyCatalog`

---

## 2026-07-10 — Docs system adapted from Labyrinth Legends

**Decision:** Adopt LL’s lean documentation taxonomy (Vision → Gameplay → Design → Tech → Asset Bible) without maze/LLDL content.

**Reason:** Keep solo-dev + AI discipline without importing the wrong game.

**Status:** Accepted

---

## 2026-07-10 — Vertical slice: campaign + power-ups + persistence

**Decision:** Ship a playable product path: Home → Twilight Road (5 nodes) → battle → result (coins / unlock) with local profile persistence. Match-4 creates a rocket (row+col blast when matched); match-5+ creates a bomb (3×3).

**Reason:** Move from sandbox stub to a closable 10-minute loop before Phase 2 Balancing Bible.

**Impact:** `assets/levels/twilight_road.json`, campaign screens, `profileProvider` + SharedPreferences, puzzle specials, battle result flow.

**Status:** Accepted — implemented

---

## 2026-07-10 — Shape catalog, four specials, merges

**Decision:** Matches follow the spreadsheet catalog (lines, 2×2, mix-of-five L/T/plus). Specials: V/H rocket, bomb, fireball, seeker (L → seeker; T/plus/2×2 → bomb; H4 → V-rocket; V4 → H-rocket; line5 → fireball). Create at swap destination. Special↔special uses the merge matrix.

**Reason:** Richer match-3 feel; Seeker is the 4th special for L pentominoes.

**Status:** Accepted — implemented

---

## 2026-07-10 — Colorless power-ups, fireball rules, bomb+rocket cross

**Decision:** Power-ups do not participate in color matching. Activate by tap or by swapping with any adjacent tile. Fireball tap clears a random board color; fireball swap clears the swapped tile’s color; cleared power-ups chain. Bomb + V-rocket and bomb + H-rocket both produce the same fat 3×3 cross (3 rows + 3 cols).

**Reason:** Clearer activation UX; fireball feels intentional on swap vs lucky on tap; rocket+bomb should not be direction-dependent.

**Status:** Accepted — implemented

---

## 2026-07-10 — AB1 production standards locked

**Decision:** Adopt [AB1 — Production Standards](../06_Asset_Bible/AB1_Production_Standards.md) for the first art pass: Dusk style board, Leonardo AI + ForgeGUI workflow, stable `{category}_{id}.png` naming, export sizes, and human review checklist.

**Reason:** Lock specs before generating hero/enemy/tile assets so AI output stays consistent and Flutter-ready.

**Impact:** `docs/06_Asset_Bible/AB1_Production_Standards.md`, `assets/images/*` subfolders, style board in `assets/images/style_board/`.

**Status:** Accepted
