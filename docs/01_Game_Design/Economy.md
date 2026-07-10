# Economy

| Field | Value |
|-------|-------|
| **Status** | Draft — Phase 1 mock / Phase 3–4 Firebase |
| **Last Updated** | 2026-07-10 |
| **Related** | [Progression](Progression.md) · [PHASES](../PHASES.md) · `.cursor/rules/08-monetization-economy.mdc` |

## Philosophy

Premium feel first. Monetization supports convenience and cosmetics — not pay-to-win combat power. Align with Mythora monetization rules (no unlimited paid revives, no client-side currency grants).

## Currencies (planned)

| Currency | Earn | Spend |
|----------|------|-------|
| Coins | Battle rewards, campaign, ads (later) | Soft shop, conveniences |
| Gems | Milestones, IAP (later), sparse rewards | Premium shop, cosmetics, limited boosts |

## Phase 1 mock defaults

From `MockProfile`:

| Resource | Default |
|----------|---------|
| Coins | 500 |
| Gems | 50 |

No real spend sinks yet.

## Anti-patterns

- Client-trusted reward amounts
- Interstitials during an active player turn
- Pay-to-win PvP (when PvP exists)

## Later hooks

- Rewarded ads at natural decision points (post-battle, optional revive with caps)
- Remote Config for costs / ad cadence
- Server-validated settlement (Firebase)

See Labyrinth-style structure adapted; numbers are Mythora-specific stubs.
