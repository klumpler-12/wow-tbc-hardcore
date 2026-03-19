# Website Logic Errors & Inconsistencies — Future Fix List

> **Status:** Noted, not blocking. Fix when website gets next update pass.
> **Last Updated:** 2026-03-17

---

## Instance Lifes Model Mismatch (MAJOR)

**Current state:** The website markets a tiered lifes system (easy: 2 lifes, hard: 3 lifes) that does NOT match the addon's actual implementation (+1 bonus life for hardest content only).

**What to do:**
- Website should be updated to reflect the addon's model OR the addon should be expanded
- For now: add "WIP / subject to change" note on the instance lifes section
- Decision needed: which model is the final one?

**Affected files:**
- `web/index.html` — Instance Lifes section (lines ~259-340)
- `web/js/data.js` — `instanceLives.heroic` and `instanceLives.raids`
- `addon/HardcorePlus/Constants.lua` — `BonusLifeHeroics`, `BonusLifeRaids`, `GetBonusLives()`

---

## Dungeon Difficulty Classifications Don't Match

| Dungeon | Website | PROJECT_PLAN | Addon |
|---------|---------|--------------|-------|
| HC Old Hillsbrad | Hard (3 lifes) | Low (10 pts) | Not in bonus list |
| HC Mechanar | Easy (2 lifes) | Medium (15 pts) | Not in bonus list |
| HC Underbog | Hard (3 lifes) | Medium (15 pts) | Not in bonus list |
| HC Slave Pens | Easy (2 lifes) | Low-Med (10 pts) | Not in bonus list |

**Resolution:** Unify when scoring system is implemented in Phase 3.

---

## Phase Numbering Mismatch

| Source | Phases |
|--------|--------|
| `web/js/data.js` | 5 phases (Alpha → WotLK+) |
| `web/roadmap.html` | 7+ phases (Concept → Launch + 5b) |
| `docs/PROJECT_PLAN_EN.md` (original) | 9 phases (0-8) |
| `docs/PROJECT_PLAN_REVISED.md` (new) | 6 phases (0, 0.5, 1, 2, 3, 4, 5) |
| `addon/Constants.lua` debug defaults | 7 internal phases |

**Resolution:** Update website phases to match REVISED plan when website gets rebuilt.

---

## Status States Gap

- Addon has 7 states: PENDING, UNVERIFIED, VERIFIED, TARNISHED, DEAD, SOFT_RESET, LATE_REG
- Website guild-profile.html shows only 3: Verified, Tarnished, Dead
- Missing: PENDING, UNVERIFIED, SOFT_RESET, LATE_REG badges

**Resolution:** Add missing status badges when guild profile gets connected to real data.

---

## Checkpoint Level Display

- `web/js/customization.js` cycles through levels 40, 50, 70, 58 — implying configurable checkpoint levels
- Addon hardcodes checkpoint at 58 only
- Configurable checkpoints are a future feature, not current

**Resolution:** Either remove the animation cycling through other levels or label it as "future feature."

---

## Scoring System Display

- Website shows only the "Simple" scoring (fixed point values)
- The plan describes two systems (Complex Multiplier + Simple Fixed)
- Addon has zero scoring implementation

**Resolution:** Non-issue until Phase 3 when scoring is implemented.

---

## "Houses" vs "Fractions" Terminology

- `docs/onlyfangs3.md` uses "Fractions"
- `web/js/data.js` uses `fraction` as property, "House" as display name
- Most docs use "Houses"

**Resolution:** Standardize to "Houses" (sub-groups within a guild) and "Fractions/Teams" (groups of houses). Update onlyfangs3.md.

---

## Minor Issues

1. `web/transitions.html` is a dev test page in the production web folder — move to `/tests/` or remove
2. Some JS files use IIFE, others don't — inconsistent module pattern
3. Dark portal animation is GPU-heavy — add `prefers-reduced-motion` fallback
4. Profile/guild-profile pages have hardcoded data, not driven by `HCData` object
5. Review annotation system uses `localStorage` which won't persist across containers
