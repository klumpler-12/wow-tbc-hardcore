# TBC Hybrid Hardcore - Revised Master Project Plan

> **Version:** 2.0-REVISED
> **Last Updated:** 2026-03-17
> **Status:** Pre-Alpha → Public Alpha (6-week sprint)
> **Target Platform:** World of Warcraft: The Burning Crusade (Client 2.4.3)
> **Critical Deadline:** Public Alpha release by end of April 2026 (April 30, 2026)

---

## Table of Contents

1. [Executive Summary (NEW)](#executive-summary)
2. [Vision & Target Audience](#vision--target-audience)
3. [Core Features (Detailed)](#core-features-detailed)
4. [Phase Structure (REVISED)](#phase-structure-revised)
5. [Tracking Fundamentals (NEW)](#tracking-fundamentals)
6. [What Other Addons Track (NEW)](#what-other-addons-track)
7. [Deferred Features (NEW)](#deferred-features)
8. [Monetization Strategy (UPDATED)](#monetization-strategy)
9. [Technical Architecture](#technical-architecture)
10. [Competitor Analysis](#competitor-analysis)
11. [OnlyFangs 3 Requirements Mapping](#onlyfangs-3-requirements-mapping)
12. [Risk Assessment & Mitigations](#risk-assessment--mitigations)
13. [Open Questions & Decisions](#open-questions--decisions)
14. [Glossary](#glossary)

---

## Executive Summary

**STATUS CHANGE:** This project transitions from exploratory pre-alpha to a focused 6-week sprint ending in **public alpha release on April 30, 2026**.

### The Hard Constraint
- **ONE developer (mostly), PART-TIME**
- **6 weeks to public alpha** (March 17 — April 30)
- **Small trusted test base NOW** (solo/duo PoC phase)
- **Larger test base BEFORE public** (Phase 1: 10-20 testers)
- **Public release BY END OF APRIL** (Phase 2)

### What Ships by April 30
A **CurseForge-listed** public alpha addon with:
- ✅ Death tracking + permadeath enforcement
- ✅ Checkpoint system (boosted 58s, GF/SSF soft reset)
- ✅ Instance lifes (addon's +1 bonus model)
- ✅ Network/peer verification (optional, toggleable)
- ✅ **Comprehensive tracking fundamentals** (record everything, calculate nothing yet)
- ❌ NO scoring system
- ❌ NO houses
- ❌ NO web dashboard
- ❌ NO companion app

### What Defers to Later
**Phase 3 (Summer 2026):** Scoring, houses, web dashboard, mini-games, creative punishments.
**Phase 4 (Fall 2026):** Companion app, CurseForge stable release.
**Phase 5+ (End of 2026+):** Classic+, WotLK ports.

### Philosophy
- **Track EVERYTHING now** — every death, mob kill, item interaction, trade, zone visit, level gain, distance, XP, gold, professions.
- **Enforce selectively** — only permadeath + checkpoint system for Phase 1.
- **Calculate scoring LATER** — data sits in SavedVariables, ready to backtest scoring once system is finalized.
- **Test with trusted community** — 10-20 dedicated testers validate core mechanics before public release.

---

## 1. Vision & Target Audience

### 1.1 Who Is This For?

TBC Hybrid Hardcore is designed to serve three distinct but overlapping audiences:

#### Guilds (Primary Target)
- Large organized community events such as **OnlyFangs 3**, **Sauercrowd**, and custom community-run hardcore events.
- Guild Masters and officers who need fine-grained control over rulesets and death tracking.
- Guilds that want internal competition structures (houses, teams) added in later phases.
- Cross-guild events where multiple guilds share a common ruleset but maintain independent leaderboards.

#### Streamers (High-Value Target — Phase 3+)
- Content creation tools (mini-games, overlays, punch-list punishments) added in Phase 3.
- Early adopters interested in raw death tracking and checkpoint validation.

#### Solo Players (Growth Target — Phase 1+)
- Personal hardcore runs with self-imposed rules and automatic tracking.
- Ability to validate runs with friends (peer verification layer).

### 1.2 Core Concept: Hybrid Hardcore for TBC

TBC is widely considered too punishing for pure permadeath hardcore. The reasons are well-documented:

- **Random one-shots in dungeons:** Mechanics like Shattered Halls gauntlet, Shadow Labyrinth mind controls, and Arcatraz voidwalker explosions can instantly kill well-geared players through no fault of their own.
- **Unavoidable boss mechanics:** Many TBC boss encounters have raid-wide damage, unavoidable debuffs, or random target selection that makes zero-death runs statistically improbable in a raid setting.
- **The 58-70 grind:** Hellfire Peninsula and subsequent zones have significantly higher mob density and damage output compared to Classic content, making even overworld leveling dangerous.

**TBC Hybrid Hardcore solves this with a hybrid approach:**

1. **Permadeath during leveling** (1-60 or 1-70, configurable per ruleset). Death = deletion or logout enforcement.
2. **Checkpoints and multiple lives in instances** to make raid content viable:
   - **Boosted 58s:** Start at level 58 with gold + gear to skip the brutal early grind.
   - **Gold Finder (GF):** 60+ respec or level a fresh 58 via gold-farming soft reset.
   - **SSF Soft Reset:** Solo self-found reset for purists (can team with others for instances).
3. **Fully customizable rulesets per guild/event** set by Guild Masters, synced automatically across all guild members.
4. **Instance lifes** using the addon's +1 bonus model (simple death counter per instance).

### 1.3 Design Principles

- **Customization over prescription:** Never hardcode a rule that a GM might want to change.
- **Tracking everything, enforcing selectively:** The addon tracks all player activity but only enforces rules the GM has enabled.
- **Free must be functional:** The free tier provides a complete hardcore experience. Premium adds control and creativity, never competitive advantage.
- **Performance first:** The addon must have zero measurable impact on gameplay performance. All tracking runs asynchronously where possible.
- **Privacy by default:** Player data is only shared within the guild unless the player opts into global leaderboards.

---

## 2. Core Features (Detailed)

### 2a. Ruleset Engine

The Ruleset Engine defines what rules are active, who can modify them, and how they are enforced.

#### Rule Categories

**Hard Rules (Immutable)**
These rules define the core identity of a mode:
- **Hardcore Mode:** Death = character deletion (or logout enforcement). No exceptions.
- **Hybrid Mode:** Death = deletion during leveling, lives system in instances.
- **Nullcore Mode:** Death tracking only, no enforcement. For testing and statistics.

**Soft Rules (GM-Configurable)**
- **Self-Found (SSF):** No trading, no Auction House, no mailbox. Variants: SSF-Strict (solo only), SSF-Guild (guild trading allowed), SSF-Flex (instances allow borrowed gear).
- **Trade Rules:** Whitelist/blacklist specific trade types.
- **Checkpoint System:** Configure which checkpoint types are allowed (boosted 58, GF, SSF reset).
- **Level Brackets:** Define at what level hardcore rules activate. Example: HC from 10-60, hybrid 60-70.
- **Instance Lives:** Lives per boss, per instance, or per lockout period.
- **Buff Restrictions:** Disallow specific world buffs or consumables.
- **Spec Restrictions:** Limit allowed talent specializations per class.

#### Ruleset Data Structure

```lua
Ruleset = {
    id = "of3-hybrid-v2",
    name = "OnlyFangs 3 Hybrid",
    version = 3,
    mode = "hybrid",
    createdBy = "GM-Name-Server",
    createdAt = 1710000000,
    hardRules = {
        deathIsDeletion = true,
        levelBracket = {10, 60},
    },
    softRules = {
        ssf = false,
        checkpointTypes = {"boosted_58", "gf"},
        instanceLives = 3,
        livesPer = "boss",
    },
}
```

---

### 2b. Death Tracking + Permadeath Enforcement

The foundation of TBC Hybrid Hardcore: reliable death detection and enforcement.

#### Death Detection
- Monitor `COMBAT_LOG_EVENT_UNFILTERED` for player death events.
- Capture killer name, killer level, killer type (mob/player/environment).
- Record zone, level at death, timestamp, overkill amount.
- Store full death context in SavedVariables.

#### Enforcement Options
- **Character Deletion:** GM can manually delete character or auto-delete on death (with confirmation prompt).
- **Logout Enforcement:** On death, character logs out and login is blocked until GM confirms deletion.
- **Permadeath Broadcast:** Death announced to guild with full context (killer, zone, XP level).

#### Death Context Stored (for retrospective scoring)
```lua
Death = {
    timestamp = 1710000000,
    level = 45,
    zone = "Blade's Edge Mountains",
    killerName = "Bladereaver",
    killerLevel = 67,
    killerType = "elite_npc",
    overkill = 523,
    character = "PlayerName",
    server = "ServerName",
    xpAtDeath = 150000,
    equippedGear = {...},  -- snapshot
}
```

---

### 2c. Checkpoint System

Multiple checkpoint types allow players to reset without losing the entire character.

#### Checkpoint Types (GM-Configurable per Ruleset)

**Boosted 58**
- Start at level 58 with preset gold (50-100g) and basic quest gear.
- Used for skipping 1-58 grind.
- Only usable once per event/season.
- Recorded in SavedVariables as a "soft reset" event.

**Gold Finder (GF)**
- Reach level 60 in hardcore, then respec from combat to gold-farming spec.
- Farm gold and materials for 1-2 weeks.
- Reset to level 1 with farmed gold + crafted gear.
- Allows building fresh character with capital.
- Recorded as a "GF reset" event with starting capital.

**SSF Soft Reset**
- After reaching level 60+ in SSF hardcore, reset to level 1.
- SSF rules remain active — no trades, no AH, no mail except personal transfers.
- Can still group for instances (borrowing gear is allowed).
- Recorded as "SSF reset" event.

#### Checkpoint Data Structure
```lua
Checkpoint = {
    id = "checkpoint_001",
    character = "PlayerName",
    type = "boosted_58",  -- "boosted_58" | "gf" | "ssf_reset"
    timestamp = 1710000000,
    startingLevel = 58,
    startingGold = 75,
    startingGear = {...},
}
```

---

### 2d. Instance Lifes System

Simple death counter for dungeon/raid encounters.

#### The +1 Bonus Model
- Each player gets **one extra life per instance** (hence +1).
- First death in an instance is forgiven. Second death = character deleted (or logout).
- Applies per instance, per lockout period, or per boss (GM configurable).
- Tracked in SavedVariables per instance entry.

#### Life Tracking
```lua
InstanceLife = {
    instanceId = "tempest_keep_001",
    character = "PlayerName",
    entranceTime = 1710000000,
    livesRemaining = 1,
    deaths = 0,
    maxDeaths = 1,
}
```

#### Enforcement
- On first death in an instance: announce to group, deduct one life.
- On second death: enforce permadeath (deletion or logout).
- Guild is notified of any death in an instance.

---

### 2e. Network Verification & Peer Validation

Experimental peer-verification layer for cross-validation of deaths and kills.

#### What It Does
- When two players are in the same group, their addon instances record the same events.
- On logout or periodically, players can "verify" with each other via `SendAddonMessage`.
- If death records don't match, flag for GM review (intentional false death claim prevention).

#### Toggleable Feature
- **Default: OFF** in Phase 1. Players can enable per-ruleset.
- GM can mandate verification for specific rulesets (e.g., OnlyFangs).
- Verification data stored locally, sent to guild on sync.

#### Data Flow
```
Player A dies → logs death locally
Player B in same group → sees Player A death in combat log
On next sync → both players compare death records
If mismatch → flag event for GM review
If match → proceed normally
```

---

### 2f. Comprehensive Tracking Fundamentals

The addon records EVERYTHING possible, without calculating scores yet. Data sits in SavedVariables, ready for retrospective analysis and scoring system design.

#### What to Track (Phase 1 Minimum)

| Category | Data Point | Storage | Priority |
|----------|-----------|---------|----------|
| **Deaths** | Cause, zone, level, killer, timestamp, context | Per-character death log | P0 |
| **Kills** | Mob name, level, zone, timestamp, XP gained | Kill counter + log | P0 |
| **Levels** | Level achieved, timestamp, XP total, /played | Per-level snapshots | P0 |
| **Playtime** | Total /played, session start/end, playtime per level | Session log | P1 |
| **Gold** | Current gold, snapshots at key moments (level, boss kill, death) | Periodic snapshots | P1 |
| **Inventory** | Periodic hash of inventory state (detect duplication) | Hash + item list snapshots | P1 |
| **Professions** | Profession counts, skill levels, timestamp of changes | Profession snapshots | P1 |
| **Distance** | Polling every 5-10 sec, cumulative counter per zone | Distance counter | P1 |
| **Online Time** | Session tracking, login/logout timestamps | Session log | P1 |
| **Dungeons** | Instance name, entry/exit time, clear status, wipes | Instance log | P1 |
| **Equipment** | Snapshots at level up, boss kill, death, checkpoint | Equipment snapshots | P1 |
| **Trades** | Trade partner, items/gold exchanged, timestamp | Trade transaction log | P1 |
| **Mail** | Sender, receiver, items, gold, timestamp | Mail transaction log | P1 |
| **AH** | Listings posted, items bought/sold, prices, timestamp | AH transaction log | P1 |

#### Storage Schema (SavedVariables)

```lua
HardcorePlusDB = {
    characters = {
        ["PlayerName-ServerName"] = {
            level = 45,
            playtime = 123456,
            playedCurrentLevel = 45600,
            gold = 12345,
            deaths = {
                {
                    timestamp = 1710000000,
                    level = 45,
                    zone = "Blade's Edge Mountains",
                    killer = "Bladereaver",
                    ...
                }
            },
            kills = {
                {
                    name = "Bladereaver",
                    level = 67,
                    zone = "Blade's Edge Mountains",
                    timestamp = 1710000000,
                    xpGained = 1250,
                }
            },
            levelSnapshots = {
                [58] = {timestamp = 1710000000, xpTotal = 1234567},
                [59] = {timestamp = 1710000100, xpTotal = 1250000},
            },
            goldSnapshots = {
                {timestamp = 1710000000, gold = 12345},
                {timestamp = 1710000100, gold = 15000},
            },
            inventoryHashes = {
                {timestamp = 1710000000, hash = "abc123def456"},
            },
            equipmentSnapshots = {
                {timestamp = 1710000000, items = {...}},
            },
            sessions = {
                {startTime = 1710000000, endTime = 1710003600, duration = 3600},
            },
            dungeonLogs = {
                {
                    instanceId = "tempest_keep_001",
                    name = "The Eye",
                    entryTime = 1710000000,
                    exitTime = 1710003600,
                    cleared = true,
                    wipes = 2,
                }
            },
            trades = {
                {
                    timestamp = 1710000000,
                    partner = "OtherPlayer-Server",
                    itemsGiven = {...},
                    itemsReceived = {...},
                    goldGiven = 0,
                    goldReceived = 500,
                }
            },
            mails = {...},
            ahTransactions = {...},
        }
    }
}
```

---

## 3. What Other Addons Track

Before building custom tracking, cross-reference existing addons to avoid duplication and identify potential data sources.

### Addon Tracking Inventory (Research Phase)

| Addon | Primary Function | Tracked Data | SavedVariables Access? | Notes |
|-------|-----------------|--------------|----------------------|-------|
| **Details!** | Damage meter | DPS, HPS, threat, combat log | Yes (LibDataBroker) | Excellent combat data; consider reading for scoring retrospectively |
| **Recount** | Classic damage meter | DPS, HPS, damage taken, threat | Yes (lua table dump) | Good alternative to Details!; lower overhead |
| **AtlasLoot** | Loot database | Boss loot tables, item drops | Yes (local copies) | Already maintains loot database; can cross-reference |
| **DBM** | Boss timers & alerts | Encounter duration, mechanics cast | No (doesn't track kills) | Real-time encounter info; not useful for retrospective tracking |
| **Omen** | Threat meter | Threat history in combat | Yes (local storage) | Could provide threat data for retrospective scoring |
| **TinyDPS** | Lightweight DPS meter | DPS, damage breakdown | Yes (simple format) | Lower overhead than Details!; easier to read |
| **WoWLua Debugger** | Lua environment | Player stats on demand | No (not persistent) | Can query on-demand but doesn't persist |
| **Armory Sync** | Character gear tracking | Equipped items, stats, enchants | Yes (character snapshots) | Already tracks gear snapshots; potential data source |
| **Deathlog** | Death tracking | Death cause, killer, context | Yes (death log table) | **CRITICAL:** This is the main competitor; study its format |
| **Hardcore TC** | HC enforcement | Death tracking, HC rules | Yes (encrypted) | Main competitor; reverse-engineer if possible |
| **Sauercrowd** | Sauercrowd event tracking | Custom event data | Yes (guild-specific) | Event-tracking patterns; useful for PM design |

### Key Insights
1. **Don't duplicate Details!/Recount:** These addons already track DPS/HPS well. We can read their SavedVariables post-session for retrospective scoring.
2. **Deathlog analysis:** Study Deathlog's death structure and format. Ensure our death tracking is compatible or superior.
3. **Hardcore TC reverse-engineering:** If source is available, analyze their HC enforcement mechanism.
4. **Armor/Equipment snapshots:** Armory Sync already tracks gear; consider reading their data for integrity checks.

---

## 4. Phase Structure (REVISED)

### Timeline Overview

| Phase | Name | Duration | Dates | Goal | Status |
|-------|------|----------|-------|------|--------|
| **0** | Pre-Alpha PoC | NOW | Mar 17 - Mar 23 | Solo/duo testing, validation | In Progress |
| **0.5** | Clean Rebuild | Week 1 | Mar 24 - Mar 30 | Modular architecture, phase-ready codebase | Pending |
| **1** | Semi-Private Alpha | Weeks 2-4 | Mar 31 - Apr 20 | 10-20 testers, core features, final bugs | Pending |
| **2** | Public Alpha | Week 5-6 | Apr 21 - Apr 30 | **CurseForge release** | Pending |
| **3** | Beta (Deferred) | Summer | May - Jun 2026 | Scoring, houses, dashboard | Future |
| **4** | Release (Deferred) | Fall | Jul - Sep 2026 | Stable, companion app, full features | Future |
| **5+** | Expansions (Deferred) | End 2026+ | Oct+ 2026 | Classic+, WotLK ports | Future |

---

### Phase 0: Pre-Alpha PoC (NOW — March 17-23)

**STATUS:** In Progress (solo/duo testing of existing PoC)

**Goal:** Validate core mechanics with small group before major rebuild.

#### Objectives
- [ ] Test existing PoC death tracking with 2-3 players in CMaNGOS.
- [ ] Validate checkpoint system logic (boosted 58, instance lifes +1).
- [ ] Create comprehensive testing checklist for Phase 1.
- [ ] Identify critical bugs in PoC.
- [ ] Finalize tracking data structure (SavedVariables schema).

#### Deliverables
- Testing checklist (markdown file listing all test cases).
- Bug report (any issues found in PoC, prioritized).
- Finalized SavedVariables schema (from section 2f above).
- Decision on Phase 0.5 scope (what to rebuild vs. port).

#### Done in PoC?
- ✅ Basic death tracking (COMBAT_LOG_EVENT_UNFILTERED)
- ✅ Permadeath enforcement (logout)
- ✅ Ruleset selection UI
- ⚠️ Guild sync (needs validation under load)
- ❌ Checkpoint system (needs implementation)
- ❌ Instance lifes (needs implementation)
- ❌ Comprehensive tracking (tracking only deaths)
- ❌ Peer verification (not implemented)

---

### Phase 0.5: Clean Rebuild (March 24-30 — Week 1)

**Goal:** Create a clean, modular codebase from scratch. Port working features from PoC. Build foundation for all future phases.

**Why rebuild?** The PoC was proof-of-concept; a production addon needs:
- Modular architecture (separate files for each tracker, rules engine, UI).
- Scalable data structures (ready for 100s of achievements, houses, mini-games).
- Performance optimizations (batched syncs, throttled UI updates).
- Clear separation of concerns (tracking ≠ enforcement ≠ UI).

#### Objectives

**Module Setup**
- [ ] Create `.toc` file with correct TBC interface number (20400).
- [ ] Create `Core.lua` — addon initialization, version check, database load.
- [ ] Create module loader system (load specific modules based on what's needed).
- [ ] Create `SavedVariables.lua` — database schema, migration system, compression.

**Tracking Modules** (from Phase 2f: Comprehensive Tracking)
- [ ] `DeathTracker.lua` — death detection, context capture.
- [ ] `MobTracker.lua` — mob kill logging, XP tracking.
- [ ] `LevelTracker.lua` — level-up logging, playtime snapshots.
- [ ] `GoldTracker.lua` — periodic gold snapshots.
- [ ] `InventoryTracker.lua` — periodic inventory hash + item list.
- [ ] `ProfessionTracker.lua` — profession skill snapshots.
- [ ] `MovementTracker.lua` — distance polling, zone tracking.
- [ ] `SessionTracker.lua` — login/logout, session duration.
- [ ] `DungeonTracker.lua` — instance entry/exit, clear status, wipes.
- [ ] `EquipmentTracker.lua` — equipment snapshots at key moments.
- [ ] `TradeTracker.lua` — trade, mail, AH logging.

**Rules & Enforcement Modules**
- [ ] `RulesetEngine.lua` — load, validate, apply rules.
- [ ] `DeathEnforcement.lua` — apply hard death rules (deletion, logout).
- [ ] `CheckpointSystem.lua` — validate checkpoints, prevent reuse, track resets.
- [ ] `InstanceLifeSystem.lua` — manage +1 lives per instance, enforce second death.
- [ ] `SSFEnforcement.lua` — block trades, mail, AH when SSF active.

**Communication Modules**
- [ ] `Communication.lua` — addon message protocol, serialization, chunking.
- [ ] `GuildSync.lua` — initial sync on login, incremental updates, conflict resolution.
- [ ] `RulesetSync.lua` — GM pushes ruleset, members receive on sync.
- [ ] `DeathBroadcast.lua` — announce deaths to guild.
- [ ] `PeerVerification.lua` — experimental: cross-validate events with groupmates.

**UI Modules**
- [ ] `MainFrame.lua` — main addon frame, tabbed interface.
- [ ] `RulesetUI.lua` — ruleset selection and soft-rule toggles.
- [ ] `StatsPanel.lua` — display personal stats, playtime, deaths.
- [ ] `LeaderboardPanel.lua` — basic guild leaderboard (deferred for Phase 1).
- [ ] `SettingsUI.lua` — addon configuration.

**Testing & Validation**
- [ ] Create unit test framework for tracker modules.
- [ ] Test each tracker in isolation (death detection, kill logging, etc.).
- [ ] Test SavedVariables persistence across sessions.
- [ ] Performance profiling (ensure <1ms overhead per event).

#### Code Organization Example
```
WowTbcHardcore/
├── WowTbcHardcore.toc
├── Core.lua
├── SavedVariables.lua
├── Trackers/
│   ├── DeathTracker.lua
│   ├── MobTracker.lua
│   ├── LevelTracker.lua
│   ├── ... (other trackers)
├── Rules/
│   ├── RulesetEngine.lua
│   ├── DeathEnforcement.lua
│   ├── CheckpointSystem.lua
│   ├── ... (other rule modules)
├── Communication/
│   ├── Communication.lua
│   ├── GuildSync.lua
│   ├── ... (other comm modules)
├── UI/
│   ├── MainFrame.lua
│   ├── RulesetUI.lua
│   ├── ... (other UI modules)
└── Tests/
    ├── DeathTrackerTest.lua
    ├── RulesetEngineTest.lua
    └── ... (other tests)
```

#### Deliverables
- Modular codebase matching above structure.
- All PoC features ported (death tracking, ruleset selection).
- All Phase 1 features ready to integrate (checkpoint system, instance lifes, peer verification).
- No UI polish needed yet; functionality first.

---

### Phase 1: Semi-Private Alpha (March 31 — April 20, Weeks 2-4)

**Goal:** Expand from solo/duo to 10-20 trusted testers. Validate all core features under real-world conditions.

**Target Testers:**
- OnlyFangs alumni
- HC streamers / content creators
- Guild leaders from TBC hardcore communities
- Balancing council members

#### Objectives

**Core Feature Implementation**
- [ ] Finish all tracking modules from Phase 0.5 (mob kills, levels, gold, inventory, professions, etc.).
- [ ] Implement checkpoint system (boosted 58, GF, SSF reset). Test all reset types.
- [ ] Implement instance lifes +1 system. Enforce second death.
- [ ] Implement peer verification layer (optional, toggleable).
- [ ] Implement basic guild communication (death notifications, ruleset sync).
- [ ] Implement SSF enforcement (block trades, mail, AH).

**Ruleset & Rules**
- [ ] Finalize ruleset templates: HC, Hybrid (with checkpoint variants), Nullcore.
- [ ] Allow GMs to toggle: SSF on/off, checkpoint types, instance lives count.
- [ ] Ensure ruleset syncs correctly across all guild members.

**Testing Infrastructure**
- [ ] Set up Discord channel for tester feedback.
- [ ] Create testing checklist with all test cases (60+ items).
- [ ] Implement in-game feedback command (`/hcp feedback <message>`).
- [ ] Implement crash reporter (capture Lua errors, send to Discord or log file).
- [ ] Create bug prioritization system (P0 blocker, P1 critical, P2 important, P3 nice-to-have).

**Bug Fixes & Polish**
- [ ] Fix all P0 blocker bugs found during testing.
- [ ] Fix all P1 critical bugs.
- [ ] Fix as many P2 bugs as possible given time constraints.
- [ ] UI polish (scaling, alignment, color scheme consistency).

**Tester Onboarding**
- [ ] Write installation guide (addon + CMaNGOS setup instructions).
- [ ] Write GM quickstart guide (how to set rules, manage guild, understand reports).
- [ ] Write player guide (how to join, understand checkpoints, track your character).
- [ ] Record 5-10 minute video walkthrough of key features.

#### Deliverables
- Addon with all Phase 1 features (tracking, checkpoints, instance lifes, enforcement, sync).
- Testing checklist (all test cases).
- Bug tracker with prioritized issues.
- Installation + quickstart guides.
- Discord feedback channel with weekly summaries.

#### Testing Checklist (Examples)
- [ ] Create character at level 1, die, confirm deletion/logout.
- [ ] Create character with boosted_58 checkpoint, confirm starts at level 58.
- [ ] Enter dungeon, die once, confirm character stays alive.
- [ ] Enter same dungeon, die twice, confirm deletion/logout.
- [ ] Set SSF rule active, try to trade item, confirm blocked.
- [ ] Set SSF rule active, try to access AH, confirm blocked.
- [ ] 4 players enter group, one dies, verify death is recorded for all 4.
- [ ] GM updates ruleset version 1 to version 2, offline player logs in, confirm receives v2.
- [ ] Player reaches level 50, confirm level snapshot is created.
- [ ] Player reaches level 60, can now reset to level 1 with GF gold, confirm gold transfers.
- [ ] Player performs 100 trades, confirm all recorded in SavedVariables.
- [ ] SavedVariables file exceeds 1MB, confirm compression doesn't corrupt data.
- [ ] Addon processes 1000 kills in one session, confirm no performance impact.
- [ ] 10 guild members online, confirm death broadcasts don't spam guild chat.
- [ ] Player toggles peer verification on/off, confirm communication layer handles both.

---

### Phase 2: Public Alpha (April 21-30 — Week 5-6)

**Goal:** Release on CurseForge. Expand to community testing. Gather feedback for Phase 3 planning.

**Target Audience:** Anyone interested in TBC hardcore. Expect 50-200 downloads first week.

#### Objectives

**CurseForge Preparation**
- [ ] Create CurseForge project page (write description, feature list, FAQ).
- [ ] Prepare addon package (zip with all files, ensure .toc is valid).
- [ ] Write CurseForge installation guide.
- [ ] Set up automatic update notifications.

**Documentation**
- [ ] Finalize README.md with feature overview, links to guides.
- [ ] Write GM guide: create guild, set rules, manage events.
- [ ] Write player guide: install addon, join guild, understand rulesets.
- [ ] Write troubleshooting FAQ (top 20 common issues + fixes).
- [ ] Create video playlist (installation, GM setup, gameplay walkthrough).

**Marketing & Outreach**
- [ ] Post on r/classicwow, r/wow, r/classicwowhc with feature highlights.
- [ ] Reach out to HC streamers for early coverage (clips, reviews).
- [ ] Post in relevant Discord servers (OnlyFangs, Sauercrowd, HC communities).
- [ ] Write blog post with vision, timeline, and how to contribute feedback.

**Launch Day Prep**
- [ ] Create hotfix process (how to push emergency updates).
- [ ] Document rollback plan (in case critical bugs discovered).
- [ ] Set up support email / Discord channel for bug reports.
- [ ] Brief team on common issues and how to respond.

**Post-Launch (Weeks 5-6)**
- [ ] Monitor CurseForge comments and Discord for bug reports.
- [ ] Triage bugs: P0 (break addon), P1 (critical), P2 (important), P3 (QoL).
- [ ] Push hotfixes for P0 bugs within 24 hours.
- [ ] Collect feedback on which Phase 3 features matter most to community.

#### Deliverables
- CurseForge project live with addon listed.
- Complete documentation (guides, FAQ, videos).
- Working addon with all Phase 1 features.
- Bug triage process and support channel.
- Community feedback summary (for Phase 3 planning).

---

## 5. Tracking Fundamentals (Deep Dive)

This section expands on Section 2f and is crucial for Phase 0.5 implementation.

### Why Track Everything?
- **Retrospective Scoring:** Once scoring system is finalized, we can backtest against historical data.
- **Anti-Cheat:** Comprehensive logs make cheating obvious (e.g., impossible level speed, item duplication).
- **Content Analysis:** Understand which content is hardest, balance future events.
- **Player Analytics:** Build profiles on player behavior, progression speed, etc.

### Tracking Frequency & Overhead

| Data Point | Frequency | Overhead | Notes |
|-----------|-----------|----------|-------|
| Death | On event | Negligible | 1 event per death |
| Mob kill | On event | ~1ms | Parsed from combat log |
| Level up | On event | Negligible | WoW API event |
| Gold | Every 5 min | <1ms | Simple read from API |
| Inventory | Every 10 min or on change | ~2ms | Hash + item list |
| Professions | On change | Negligible | WoW API event |
| Distance | Every 5-10 sec poll | <1ms | Math calculation |
| Online time | On login/logout | Negligible | Session clock |
| Dungeons | On zone change | ~1ms | Detect instance type |
| Equipment | On change or key moment | <1ms | Read equipped items |
| Trades | On trade complete | <1ms | Trade event hook |
| Mail | On mail send | <1ms | Mail event hook |
| AH | On listing/purchase | <1ms | AH event hook |

**Total overhead:** <10ms per second during active gameplay, likely <1ms average.

### Data Retention Policy

- **Current session:** All data in memory (fast access).
- **Last 30 days:** Stored in SavedVariables, uncompressed.
- **Older than 30 days:** Compressed/archived locally (optional; can be deleted if space needed).
- **Backup:** One backup taken on logout (in case SavedVariables corruption).

### Integrity Checks

- **Inventory hash:** Detect item duplication or injection.
- **Gold delta:** Flag if gold changes by >50% in one session (impossible gains).
- **Level speed:** Flag if level gained in <10 minutes (impossible grind speed).
- **Death anomalies:** Flag if character dies but has zero overkill (suggests logout faking).
- **Cross-verification:** If two players group and record different kill counts, flag for GM review.

---

## 6. Deferred Features

Everything listed below moves to **Phase 3 (Summer 2026)** or later. This is intentional; they are not needed for public alpha.

### Features Deferred to Phase 3: Beta

**Scoring System**
- ❌ Complex multiplier-based scoring (holds until data validates the model)
- ❌ Simple fixed-point scoring (holds until community votes on values)
- ❌ Heroic difficulty ratings (holds until Phase 1 players provide data)
- ❌ Micro-achievements (100+ unique achievements)
- ❌ Leaderboard calculations and rankings

**Houses & Teams**
- ❌ House creation and management
- ❌ House leaderboards
- ❌ Team aggregation (Aldor vs. Scryer model)
- ❌ House member contribution tracking

**Draft System**
- ❌ Player rating system (1-10)
- ❌ Draft budget and cost allocation
- ❌ Draft order determination
- ❌ Draft UI (in-game and web)

**Creative Punishments**
- ❌ RP-walk (slow-force)
- ❌ Gear-lock
- ❌ Trade-ban
- ❌ Shame-walk
- ❌ Duel obligation
- ❌ Custom GM-designed punishments

**Mini-Games**
- ❌ Race to location
- ❌ Scavenger hunt
- ❌ First to X milestone
- ❌ Survival challenge
- ❌ Trivia
- ❌ Hide and seek
- ❌ Mini-game framework and GM builder

**Reward System**
- ❌ Public rewards and announcements
- ❌ Hidden rewards (secret criteria)
- ❌ GM-created custom rewards
- ❌ Guild-wide achievements
- ❌ Point-redeemable rewards

**Web Dashboard**
- ❌ Guild overview page
- ❌ Leaderboard filtering and viewing
- ❌ Ruleset editor and comparison
- ❌ Punishment/reward designer
- ❌ House management UI
- ❌ Player profiles
- ❌ Voting system
- ❌ Analytics and trends

**Companion App**
- ❌ Electron/Tauri application
- ❌ SavedVariables file watching
- ❌ Backend sync and HMAC signing
- ❌ System tray integration
- ❌ Auto-update

**Anti-Cheat (Advanced)**
- ❌ Community flagging system
- ❌ GM review queue for suspicious activity
- ❌ Automated cheating detection (machine learning optional)
- ❌ Punishment execution from web dashboard

**Expansions**
- ❌ Classic+ port
- ❌ WotLK port
- ❌ Compatibility with other HC addons

**Advanced Tracking**
- ❌ Real-time raid composition optimization
- ❌ DPS/HPS recording (read from Details! if available)
- ❌ Buff uptime tracking
- ❌ Spell rotation analysis
- ❌ Threat tracking

---

## 7. Monetization Strategy (UPDATED)

### 7.1 Free Tier (CurseForge Distribution)

The free tier provides a complete hardcore experience for solo/small guild play:

| Feature | Phase 1 (Public Alpha) |
|---------|----------------------|
| Death tracking (cause, zone, level, killer) | ✅ Included |
| Basic stat tracking (level, gold, playtime) | ✅ Included |
| Checkpoint system (boosted 58, GF, SSF) | ✅ Included |
| Instance lifes (+1 system) | ✅ Included |
| Preset rulesets (HC / Hybrid / Nullcore) | ✅ Included |
| SSF enforcement (trade/mail/AH blocking) | ✅ Included |
| Ruleset customization (soft rules toggles) | ✅ Included |
| Guild synchronization (death broadcasts, ruleset sync) | ✅ Included |
| Peer verification (optional, toggleable) | ✅ Included |
| In-game death log | ✅ Included |
| Donation link via CurseForge | ✅ Included |
| **Scoring system** | ❌ Deferred to Phase 3 |
| **Houses/teams** | ❌ Deferred to Phase 3 |
| **Mini-games** | ❌ Deferred to Phase 3 |
| **Web dashboard** | ❌ Deferred to Phase 3 |
| **Creative punishments** | ❌ Deferred to Phase 3 |

### 7.2 Premium Tier (Patreon Distribution) — POSTPONED

Premium will launch in **Phase 3** with all advanced features. For Phase 1-2, the addon remains fully free.

**Future Premium Features (Phase 3+):**
- Houses system (sub-guild management)
- Draft system (player rating and budget)
- Web dashboard (full guild management)
- Mini-game framework
- Creative punishments
- Custom achievement designer
- Custom punishment & reward designer
- Priority support
- Companion app backend sync

### 7.3 Pricing Tiers (Phase 3 Proposal)

| Tier | Price | Features | For |
|------|-------|----------|-----|
| Free | $0 | Core HC experience | Solo players, small guilds |
| Supporter | $5/month | Premium addon features | Individual guild members |
| Guild | $15/month | Premium for entire guild (up to 50 members) | Guild leaders |
| Event | $25/month | Premium for large events (unlimited members) + priority support | Event organizers (OnlyFangs, etc.) |

### 7.4 Monetization Principle (UNCHANGED)

**Free MUST remain competitive.** Death and checkpoint tracking work identically for everyone. A free player and a premium player on the same leaderboard are scored by the same system (once scoring exists in Phase 3). Premium adds **control** (houses, draft, dashboard) and **creativity** (mini-games, custom punishments), but NEVER competitive advantage.

---

## 8. Technical Architecture

*(Inherited from original plan; updated for Phase 1 scope.)*

### 8.1 Addon Architecture

**Tech Stack:**
- **Language:** Lua (WoW API)
- **Framework:** Ace3 (AceAddon-3.0, AceDB-3.0, AceGUI-3.0, AceComm-3.0, AceSerializer-3.0)
- **Client:** TBC 2.4.3
- **SavedVariables:** Per-character + per-account hybrid (character-specific data per character, guild data per account)

**Core Modules (Phase 0.5):**
1. **Core.lua** — Initialization, version check, data loading.
2. **SavedVariables.lua** — Database schema, migration, compression.
3. **Tracker modules** — Death, mobs, levels, gold, inventory, professions, movement, sessions, dungeons, equipment, trades.
4. **Rules modules** — Ruleset engine, enforcement (death, checkpoint, instance lifes, SSF), sync.
5. **Communication.lua** — Addon messaging, serialization, guild sync.
6. **UI modules** — Main frame, ruleset selection, stats panel, settings.

### 8.2 Backend Architecture (Deferred to Phase 3)

For Phase 1, no backend is required. All data stays in SavedVariables locally.

Phase 3+ will add:
- Node.js backend (Express)
- PostgreSQL database
- REST API for web dashboard
- Voting system
- Leaderboard storage
- Companion app sync

### 8.3 Communication Protocol

**Addon-to-Addon (Guild Wide):**
- Prefix: `"HCP"` (TBC Hybrid Hardcore)
- Serialization: AceSerializer-3.0 (Lua tables → strings)
- Compression: LibCompress (optional, for large payloads)
- Chunking: Split payloads >255 bytes into multiple messages
- Throttling: Queue messages during combat, batch during downtime

**Message Types:**
- `SYNC_REQUEST` — Request current guild state
- `SYNC_RESPONSE` — Send character/guild data
- `DEATH_NOTIFY` — Broadcast death event
- `RULE_UPDATE` — GM broadcasts ruleset change
- `CHECKPOINT_USED` — Announce checkpoint reset
- `VERIFY_REQUEST` — Ask groupmate to verify event
- `VERIFY_RESPONSE` — Send verification data

---

## 9. Competitor Analysis

*(Inherited; no major changes, but competitive landscape shifts in Phase 3.)*

### 9.1 Main Competitors

**Deathlog Addon**
- Strengths: Excellent death tracking, minimal overhead, widely used.
- Weaknesses: No ruleset system, no guild enforcement, no checkpoints.
- Threat: Low for Phase 1 (we do everything Deathlog does + more). Medium for Phase 3 (if they add features).
- Strategy: Study their death data format; ensure compatibility or superiority.

**Hardcore TC Addon**
- Strengths: HC enforcement, permadeath, some guild features.
- Weaknesses: Outdated, not maintained, limited to TC.
- Threat: Low (essentially unmaintained).
- Strategy: Port relevant code patterns where useful.

**Sauercrowd Addon**
- Strengths: Guild-specific features, event management, custom rules.
- Weaknesses: Only works for Sauercrowd events; not generalizable.
- Threat: Low (niche, not a generic addon).
- Strategy: Ensure our system is flexible enough to support Sauercrowd-style events.

### 9.2 Competitive Advantages (Phase 1)

1. **Checkpoint system:** No competitor offers this. Unique value.
2. **Comprehensive tracking:** We track everything; competitors track deaths only.
3. **Modular design:** Easy to extend and customize (future Mini-games, scoring).
4. **Free + premium clear division:** Competitive gameplay never locked behind paywall.
5. **Active development:** Showing momentum and community commitment.

---

## 10. OnlyFangs 3 Requirements Mapping

*(From original plan; revisited for Phase 1-2 scope.)*

### What OnlyFangs Needs (By Public Alpha)

| Requirement | Phase 1 Support? | Deferred? | Notes |
|-------------|-----------------|----------|-------|
| Death tracking with full context | ✅ Yes | No | Core feature |
| Permadeath enforcement (deletion) | ✅ Yes | No | Core feature |
| Hybrid mode (lives in instances) | ✅ Yes | No | +1 system |
| Boosted 58 checkpoint | ✅ Yes | No | Core feature |
| GF reset checkpoint | ✅ Yes | No | Core feature |
| SSF enforcement | ✅ Yes | No | Core feature |
| Guild synchronization | ✅ Yes | No | Core feature |
| Ruleset management | ✅ Yes | No | Core feature |
| Leaderboard (basic) | ⚠️ Manual | Partial | No real-time leaderboard yet; death logs visible in-game |
| Scoring system | ❌ No | Phase 3 | Defer to Phase 3 |
| Houses (Aldor/Scryer) | ❌ No | Phase 3 | Defer to Phase 3 |
| Draft system | ❌ No | Phase 3 | Defer to Phase 3 |
| Creative punishments | ❌ No | Phase 3 | Defer to Phase 3 |
| Web dashboard | ❌ No | Phase 3 | Defer to Phase 3 |
| Mini-games | ❌ No | Phase 3 | Defer to Phase 3 |

### How OnlyFangs 3 Uses the Addon (Phase 1-2)

1. **Ruleset Creation:** OF3 leader creates ruleset with custom rules (HC 1-60, Hybrid 60-70, specific checkpoint types).
2. **Guild Setup:** 50-100 participants install addon, join guild.
3. **Death Tracking:** All deaths logged and visible to guild (GM can monitor).
4. **Checkpoint Enforcement:** Players can use allowed checkpoints; GM confirms reset and updates character level.
5. **Instance Lives:** Raids use +1 lives per boss; second death = character deleted.
6. **Ruleset Sync:** GM updates rules mid-event; all members sync automatically.
7. **Manual Leaderboard:** GMs track scores on external spreadsheet, pulling from addon death logs and checkpoint records.

---

## 11. Risk Assessment & Mitigations

### R1: Development Schedule Risk (HIGH)

**Risk:** 6 weeks is tight for a solo/mostly-solo developer. Scope creep or unexpected bugs could delay launch.

**Mitigation:**
1. **Clear scope definition:** Only features listed in Phase 1 get implemented. Phase 3+ features are explicitly deferred.
2. **Modular development:** Each tracker/rule module is independent; can be tested in isolation.
3. **Automated testing:** Unit tests catch regressions early.
4. **Time boxing:** Each phase has a fixed end date. If features slip, they move to Phase 3.
5. **Buffer week:** April 21-30 is buffer time for final bugs and polish; Phase 2 doesn't require new features.

### R2: Data Integrity Risk (MEDIUM)

**Risk:** SavedVariables corruption could lose player data. Anti-cheat evasion could invalidate leaderboards.

**Mitigation:**
1. **Backup on logout:** Save backup copy of SavedVariables before overwriting.
2. **Inventory hash snapshots:** Detect item injection/duplication.
3. **Cross-verification:** If groupmates report different events, flag for GM review.
4. **Data validation:** On load, validate all data against schema (fix corrupt records).
5. **Compression testing:** Test data compression doesn't corrupt large datasets.

### R3: Performance Risk (MEDIUM)

**Risk:** Combat log parsing or frequent polling could cause frame rate drops.

**Mitigation:**
1. **Performance budgets:** Each tracker has a <1ms overhead budget. Profiling validates.
2. **Event-driven design:** Use WoW API events instead of polling where possible.
3. **Polling intervals:** Movement tracking polls every 5-10 seconds, not every frame.
4. **Batched syncs:** Save data to SavedVariables in batches, not on every event.
5. **Early-exit checks:** Skip processing if not relevant (e.g., don't parse combat log if death tracking is disabled).

### R4: Guild Sync Reliability (MEDIUM)

**Risk:** Addon messages could fail to deliver, leaving guild out of sync on rulesets or deaths.

**Mitigation:**
1. **Heartbeat system:** Periodic "alive" messages indicate addon health.
2. **Resync on login:** Full state sync on every login catches missed updates.
3. **Message queuing:** Queue failed messages and retry.
4. **Conflict resolution:** Latest timestamp wins; GM overrides always win.
5. **Manual override:** GM can force-sync ruleset to specific member.

### R5: Community Feedback Risk (MEDIUM)

**Risk:** Phase 1 feedback might reveal fundamental design flaws, requiring major rebuilds.

**Mitigation:**
1. **Early testing:** Phase 0 validates core mechanics with small group before expanding to 20 testers.
2. **Flexible architecture:** Modular design makes it easy to swap out tracking modules or enforcement logic.
3. **Feedback prioritization:** Distinguish between feature requests (defer to Phase 3) and bugs (fix in Phase 2).
4. **Public roadmap:** Communicate what's deferred to manage expectations.

### R6: Patreon Monetization Risk (LOW for Phase 1)

**Risk:** Premium tier launch is postponed to Phase 3; no revenue generated in Phase 1-2.

**Mitigation:**
1. **Free tier is high-value:** Death tracking + checkpoint system are strong enough to build community.
2. **Donation link on CurseForge:** Optional donations for motivated users.
3. **Phase 3 pricing:** Premium tier will be compelling enough to justify wait.
4. **Patience:** This is an investment in long-term success, not quick revenue.

---

## 12. Open Questions & Decisions

### D1: Checkpoint Reset Logic

**Question:** When a player uses a GF reset, does their old character stay in the leaderboard, or merge with the new character?

**Options:**
- **A:** Old character deleted, new character tracked separately (simpler).
- **B:** Both tracked; leaderboard shows "Character Name (Reset 1)" and "Character Name (Reset 2)" (more granular).
- **C:** Merge into single leaderboard entry; track resets as events (most complex, for Phase 3).

**Recommendation:** Option A for Phase 1. Revisit in Phase 3 once scoring exists.

---

### D2: Inventory Hash Sensitivity

**Question:** How sensitive should inventory hashing be? Flag every change or only suspicious ones?

**Options:**
- **A:** Flag every change (noisy, but catches all cheating).
- **B:** Flag changes >50% inventory value (less noisy, misses minor cheating).
- **C:** Manual GM review only (simplest, but relies on GM diligence).

**Recommendation:** Option C for Phase 1. Automated flagging in Phase 3 once we have more data.

---

### D3: Peer Verification Opt-In vs. Mandatory

**Question:** Should peer verification be toggleable per-ruleset, or always on?

**Options:**
- **A:** Toggleable per-ruleset (default: off, OnlyFangs mandates it).
- **B:** Always on for all players (maximum integrity, harder to disable cheating).
- **C:** Opt-in per-player (trusting players to be honest).

**Recommendation:** Option A. OnlyFangs can enable for their event; other guilds can decide.

---

### D4: SavedVariables Compression

**Question:** When should SavedVariables be compressed? Automatically, or on GM demand?

**Options:**
- **A:** Automatic compression every 30 days (simplest).
- **B:** On-demand compression via `/hcp compress` command (player control).
- **C:** Server-side compression (Phase 3 when backend exists).

**Recommendation:** Option A. Automatic compression keeps SavedVariables <500KB.

---

### D5: Scoring System Direction

**Question:** Which scoring approach resonates more: complex multiplier-based or simple fixed-point?

**Options:**
- **A:** Complex (boss level * difficulty * survivor bonus = points).
- **B:** Simple (community votes on fixed values per boss).
- **C:** Hybrid (fixed base value, then adjusted by difficulty).

**Recommendation:** Defer to Phase 3. Collect Phase 1-2 data first; let community vote.

---

## 13. Glossary

- **Addon:** The WoW client-side application distributed via CurseForge.
- **Backend:** Server-side API for web dashboard, leaderboards, companion app sync (Phase 3).
- **Checkpoint:** A reset mechanism (boosted 58, GF, SSF reset) that allows characters to restart with some advantage.
- **Companion App:** Desktop application that syncs SavedVariables to backend (Phase 4).
- **CurseForge:** WoW addon distribution platform.
- **Death Tracking:** Recording all player deaths with full context (killer, zone, level, timestamp).
- **GF (Gold Finder):** Checkpoint type; level 60 HC character farms gold, resets to level 1 with capital.
- **GM (Guild Master):** Player with authority to set rules, manage guild, approve checkpoints.
- **Guild Sync:** Synchronizing ruleset and death data across all guild members.
- **Hardcore Mode:** Death = character deletion. No exceptions.
- **TBC Hybrid Hardcore:** This addon (product name).
- **Hybrid Mode:** Death = deletion during leveling; lives system in instances.
- **Instance Lifes:** Lives in dungeons/raids. +1 system: one free death per instance, second death = deletion.
- **Leaderboard:** Ranked list of players by score (Phase 3).
- **Nullcore Mode:** Death tracking only, no enforcement.
- **Peer Verification:** Cross-validation of events between groupmates to prevent cheating.
- **Permadeath:** Character deleted on death (or logout enforcement).
- **Premium Tier:** Advanced features (houses, draft, web dashboard) locked behind Patreon subscription (Phase 3).
- **Ruleset:** Configuration defining which rules are active (HC vs. Hybrid, SSF on/off, etc.).
- **SavedVariables:** WoW's persistent data storage (addon settings and character data stored in Lua tables).
- **Scoring System:** Calculation of points based on achievements, bosses, deaths, etc. (Phase 3).
- **SSF (Solo Self-Found):** No trading, no AH, no mail (except personal transfers). Can group for instances.
- **SSF Soft Reset:** SSF player reaches level 60+, resets to level 1 with SSF rules still active.
- **Soft Rules:** GM-configurable rules (SSF on/off, instance lives count, checkpoint types).
- **TBC:** The Burning Crusade expansion.
- **Tracker:** Addon module that records a specific data point (deaths, kills, levels, etc.).
- **Web Dashboard:** Guild management UI accessible via browser (Phase 3).

---

## Appendix A: Weekly Timeline (Revised)

| Week | Dates | Phase | Milestones |
|------|-------|-------|-----------|
| 0 | Mar 17-23 | Phase 0 | PoC testing, testing checklist, finalized schema |
| 1 | Mar 24-30 | Phase 0.5 | Clean rebuild, modular codebase, tracker modules ready |
| 2-3 | Mar 31 - Apr 13 | Phase 1 | Core features (checkpoints, instance lifes, tracking), tester onboarding |
| 4 | Apr 14-20 | Phase 1 | Bug fixes, testing completion, final polish |
| 5-6 | Apr 21-30 | Phase 2 | CurseForge release, launch, community feedback, hotfixes |

**End Goal:** CurseForge listing live by April 30, 2026.

---

## Appendix B: Feature Checklist (Phase 1-2)

### Must-Have (P0: Blockers)
- [ ] Death tracking with full context
- [ ] Permadeath enforcement (deletion or logout)
- [ ] Ruleset selection UI
- [ ] Ruleset synchronization (GM → guild)
- [ ] Checkpoint system (boosted 58, GF, SSF reset)
- [ ] Instance lifes +1 system
- [ ] SSF enforcement (block trades, mail, AH)
- [ ] Guild death notifications
- [ ] SavedVariables persistence

### Important (P1: Critical)
- [ ] Mob kill tracking
- [ ] Level tracking with timestamps
- [ ] Gold snapshots
- [ ] Inventory hash snapshots
- [ ] Equipment snapshots
- [ ] Trade/mail/AH logging
- [ ] Distance traveled tracking
- [ ] Session tracking (login/logout)
- [ ] Dungeon instance tracking
- [ ] Peer verification (optional, toggleable)
- [ ] Basic crash reporting
- [ ] In-game feedback command
- [ ] Installation guide
- [ ] GM quickstart guide

### Nice-to-Have (P2: Important)
- [ ] Leaderboard panel (basic)
- [ ] Death heatmap by zone
- [ ] Player profile page
- [ ] Profession tracking
- [ ] DPS/HPS reading from Details! (if available)
- [ ] UI scaling at different resolutions
- [ ] Color scheme consistency

### Can-Defer (P3: Phase 3)
- [ ] Scoring system (any variant)
- [ ] Houses system
- [ ] Draft system
- [ ] Mini-games
- [ ] Creative punishments
- [ ] Web dashboard
- [ ] Companion app
- [ ] Voting system
- [ ] Reward system
- [ ] Advanced anti-cheat

---

**END OF REVISED PROJECT PLAN**

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-10 | Original | Initial exploratory plan, feature-complete vision |
| 2.0 | 2026-03-17 | Revised | Scope reduction to Phase 1 public alpha by April 30, 6-week sprint, single developer constraint, tracking-first philosophy |

