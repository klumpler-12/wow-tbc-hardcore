# TESTAMENT — Hardcore Plus Source of Truth

> Canonical reference for all core rulesets and parameters.
> Checked against during every final verification pass.
> Update this file FIRST when any core rule changes.

**Last verified:** 2026-03-12

---

## Game Mode: Hybrid Hardcore

There is **one mode**: Hybrid HC. It has a **base ruleset** (always active), **free customization options** (minor toggles like SSF), and **premium customization options** (guild management, guild-wide rulesets, advanced features).

### Base Ruleset (Always Active)
- Permadeath 1–70 in open world
- Instance lives system (see below)
- Checkpoint at level 58 (see below)
- Death tracking with full context
- Scoring system enabled
- Addon verification required

### Free Customization
- Self-found toggle: Full SSF / Guildfound (guild trading only) / Off
- PvP rules (Scored / Exempt / Disabled)
- Minor rule toggles
- Soft reset eligibility (requires SSF or Guildfound from start)

### Premium Customization
- Guild-wide ruleset management (GM sets rules for all members)
- Lives for self or whole guild (purchasable extra lives)
- Checkpoint level selection (any level, not just 58)
- Class-wide checkpoints (unlock checkpoint for entire class, not just one character)
- Multiple checkpoints
- Houses & draft system
- Custom achievements (GM-created)
- Guild web sites & player profiles
- Export tools & config files

---

## Checkpoints

- **Default checkpoint: level 58**
- When a character reaches the checkpoint level, that **class** is checkpointed
- On death after checkpoint, 2 restart options:
  1. **Blizzard boost**: Buy official 58 boost for a new character of that class
  2. **Soft reset**: Strip dead character of all progress (see below), re-register as HC with "Soft Reset ×N" flag. Only available after lvl 58.
- **Premium**: choose any checkpoint level, set class-wide or character-specific, enable multiple checkpoints
- **Dynamic checkpoints**: experimental/future feature, not in current scope

### Soft Reset

Soft reset allows a dead character to re-enter HC without creating a new character or buying a boost. The addon enforces full progress deletion to simulate a fresh start.

**What must be deleted:**
- **Items**: All equipped gear, bags, bank contents, inventory (addon verifies empty slots)
- **Gold**: Must be below 1g (addon checks < 1g)
- **Professions**: Unlearn both at trainer (addon checks 0 professions)
- **Talents**: Full respec at trainer (addon verifies 0 spent points)
- **Active quests**: Abandon all (addon checks quest log empty)

**Cannot be reset in TBC 2.4.3:** Completed quests, reputation, flight paths, learned spells/skills, honor/arena points history. These remain — this is the trade-off vs. a fresh character.

**Addon verification:** Scans inventory/bank/professions/talents/quest log/gold → all must be zero/empty (gold < 1g) before allowing re-registration. Character is flagged "Soft Reset ×N" permanently.

**Eligibility restriction (early concept):**
- Soft reset is **only available to SSF or Guildfound (GF) characters**
- Guildfound = base addon feature (not premium) — allows guild trading only, no AH/external trade
- The SSF/GF mode must be active **from character creation or from boost** — cannot be enabled later
- If a character ever circumvents SSF/GF rules (flagged by addon), they lose soft reset eligibility permanently
- Rationale: without this restriction, players could bank gear/gold on alts before soft resetting, trivializing the penalty

---

## Instance Lives (Base Mode)

Lives make TBC raid/dungeon content viable despite one-shot mechanics.

### Heroic Dungeons (Level 70) — DRAFT

| Difficulty | Lives | Dungeons |
|-----------|-------|----------|
| Easy | 2 | Mechanar, Slave Pens, Ramparts, Blood Furnace |
| Hard | 3 | Shadow Lab, Arcatraz, Black Morass, Underbog, Old Hillsbrad, Botanica, Steamvault, Auchenai Crypts, Sethekk Halls, Mana-Tombs |
| Brutal | 5 | Shattered Halls, Magisters' Terrace |

### Raids — DRAFT

| Difficulty | Lives | Raids |
|-----------|-------|-------|
| Entry & Mid | 3 | Karazhan (10), Gruul's Lair (25), Magtheridon (25), Zul'Aman (10), SSC (25), TK (25), Hyjal (25) |
| Brutal | 5 | Black Temple (25), Sunwell Plateau (25) |

### Life Rules
- Lives are **per character per instance**
- 0 lives = **permadeath**
- Normal dungeons: deaths tracked for scoring only (no lives consumed)
- Life reset behavior: **GM configurable** (base default TBD — needs community testing)
- Options: reset on leave, persist per lockout, persist permanently

---

## Hard Rules (Immutable — cannot be changed by GM)

1. Permadeath is always enforced during leveling (1–70 open world)
2. All deaths are tracked with full context (time, location, cause, killer)
3. Anti-cheat verification active at all times
4. Addon verification required for participation
5. Death log is public and permanent

## Soft Rules (GM-Configurable)

| Rule | Default | Range |
|------|---------|-------|
| Instance lives (heroic easy) | 2 | 1–5 |
| Instance lives (heroic hard) | 3 | 1–5 |
| Instance lives (brutal) | 5 | 1–5 |
| Instance lives (raid entry) | 3 | 1–5 |
| Instance lives (raid brutal) | 5 | 1–10 |
| Life reset behavior | TBD | Per-leave / Per-lockout / Permanent |
| Scoring | Enabled | On/Off |
| Houses | Disabled | On/Off |
| Self-found | Guild trading | Full SSF / Guild / Off |
| PvP rules | Exempt | Scored / Exempt / Disabled |
| Custom achievements | Disabled | On/Off |
| Death penalties | Score deduction + life loss | Configurable |

---

## Scoring Categories

### Character Progression
- Leveling milestones: 58, 60, 65, 70
- Professions: 14 trackable (all TBC crafts + secondary)
- Reputation: 12 TBC factions
- Gear thresholds: Green, Blue, Purple, Orange

### PvE Content
- Dungeon clears: Normal + Heroic (18 dungeons)
- Raid content: Boss kills, Full clears, Speed clears (8 raids)
- World content: Elites, Rares, World Bosses

### PvP Content (optional)
- Battlegrounds: wins, captures, kills
- Arena: rating thresholds, streaks
- World PvP: zone objectives, HKs

### Guild Achievements
- Public achievements (visible to all)
- Hidden achievements (surprise on completion, GM-created)

### Penalties
- Life lost (instance death)
- Score deduction (configurable amount)
- Rule violation (GM-flagged)
- Inactive decay (optional, 7-day timer)

---

## Punishment System (Base Mode Defaults)

| Category | Rule | Severity | Active |
|----------|------|----------|--------|
| Death | Instance Death | Critical | Yes |
| Death | Open World Death | Fatal | Yes |
| Infraction | GM Flagged Violation | High | Yes |
| Infraction | AFK/Inactive Timer | Low | No |
| Reward | Deathless Streak | High (+500/week) | Yes |
| Reward | Weekly MVP | Bonus | Yes |
| Custom | First Boss Kill | Bonus (+200) | Yes |

---

## Fractions & Houses

**Hierarchy:** Guild → 2 Fractions (premium) → Houses per Fraction (premium)

- **Fractions** = the two competing sides within a guild
  - Each Fraction is led by a **GM + Co-GM** (or designated Fraction Leader)
  - Fraction leaders choose their own Fraction name (no hardcoded defaults)
- **Houses** = sub-teams within each Fraction
  - Each House has a **House Leader**
  - House Leaders can choose their own House/subgroup name
  - Max house size: **1/8 of guild member cap**
- **Draft system**: Addon provides draft tools with player ratings for fair distribution across Houses
- Weekly scoring + total scoring (toggleable view)
- Weekly resolve: winning Fraction announced
- Super Guild: link multiple WoW guilds as one (addon-only, gchat stays separate)
- Open question: max guilds that can link (currently supports 4)

---

## Monetization

| Feature | Free (CurseForge) | Premium (Patreon) |
|---------|-------------------|-------------------|
| Base ruleset (permadeath, lives, checkpoint at 58) | Yes | Yes |
| Death tracking & scoring | Yes | Yes |
| Instance lives system | Yes | Yes |
| Guild roster integration | Yes | Yes |
| Extra lives (self / guild-wide) | No | Yes |
| Custom checkpoint levels / multi-checkpoint | No | Yes |
| Full rule customization | No | Yes |
| Houses & draft system | No | Yes |
| Guild web sites | No | Yes |
| Player profiles | No | Yes |
| Custom achievements | No | Yes |
| Export tools & config files | No | Yes |

**Pricing:** $5/month individual, $15/month guild, $25/month event
**Never pay-to-win** — free players participate fully in base gameplay

---

## Technical Stack

- **Addon:** Lua 5.1, WoW TBC 2.4.3 API, Ace3 libraries
- **Backend (planned):** Node.js/Express, MongoDB/SQLite
- **Dashboard (planned):** React 18
- **Companion App (planned):** Electron
- **Presentation Site:** Static HTML/CSS/JS, no build step

---

## Consistency Check Targets

When verifying, check these values match across:
1. `web/index.html` — Concept Timeline, Instance Lives, Rule Manager, Death Sequence, Houses, Scoring Tree, Punishments
2. `web/profile.html` — Player stats, gear, achievements
3. `web/guild-profile.html` — Guild stats, house standings, roster
4. `web/roadmap.html` — Phase definitions and status
5. `docs/` — All documentation files
6. This file (TESTAMENT.md) — the authoritative source
