# Hardcore Plus - Master Project Plan

> **Version:** 1.0-DRAFT
> **Last Updated:** 2026-03-10
> **Status:** Pre-Development / Concept Finalization
> **Target Platform:** World of Warcraft: The Burning Crusade (Client 2.4.3)

---

## Table of Contents

1. [Vision & Target Audience](#1-vision--target-audience)
2. [Core Features (Detailed)](#2-core-features-detailed)
3. [Monetization Strategy](#3-monetization-strategy)
4. [Development Phases](#4-development-phases)
5. [Technical Architecture](#5-technical-architecture)
6. [Competitor Analysis](#6-competitor-analysis)
7. [OnlyFangs 3 Requirements Mapping](#7-onlyfangs-3-requirements-mapping)
8. [Risk Assessment & Mitigations](#8-risk-assessment--mitigations)
9. [Open Questions & Decisions](#9-open-questions--decisions)
10. [Glossary](#10-glossary)

---

## 1. Vision & Target Audience

### 1.1 Who Is This For?

Hardcore Plus is designed to serve three distinct but overlapping audiences:

#### Guilds (Primary Target)
- Large organized community events such as **OnlyFangs 3**, **Sauercrowd**, and custom community-run hardcore events.
- Guild Masters and officers who need fine-grained control over rulesets, punishments, and rewards.
- Guilds that want internal competition structures (houses, teams, factions) without splitting into separate guild entities.
- Cross-guild events where multiple guilds share a common ruleset but maintain independent leaderboards.

#### Streamers (High-Value Target)
- Content creation tools that provide compelling on-screen overlays and narratives.
- Viewer engagement hooks: live leaderboard updates, death notifications, mini-game participation.
- Competitive narratives: house rivalries, draft picks, underdog stories, progression races.
- Clip-worthy moments: creative punishments, surprise achievements, dramatic deaths with full context.

#### Solo Players (Growth Target)
- Personal challenge modes with self-imposed rules and self-tracking.
- Global leaderboard participation even without a guild.
- Achievement hunting across thousands of micro-achievements.
- SSF (Solo Self-Found) enforcement for purist gameplay.

### 1.2 Core Concept: Hybrid Hardcore for TBC

TBC is widely considered too punishing for pure permadeath hardcore. The reasons are well-documented:

- **Random one-shots in dungeons:** Mechanics like Shattered Halls gauntlet, Shadow Labyrinth mind controls, and Arcatraz voidwalker explosions can instantly kill well-geared players through no fault of their own.
- **Unavoidable boss mechanics:** Many TBC boss encounters have raid-wide damage, unavoidable debuffs, or random target selection that makes zero-death runs statistically improbable in a raid setting.
- **The 58-70 grind:** Hellfire Peninsula and subsequent zones have significantly higher mob density and damage output compared to Classic content, making even overworld leveling dangerous.
- **Attunement chains:** Long, multi-step attunement quests that require dungeon runs create multiple points of failure.

**Hardcore Plus solves this with a hybrid approach:**

1. **Regular hardcore rules during leveling** (1-60 or 1-70, configurable per ruleset). Death means deletion or severe penalty as configured.
2. **Checkpoints and multiple lives in instances** to make raid content viable. GMs configure how many deaths are allowed per encounter, per instance, or per lockout.
3. **Fully customizable rulesets per guild/event** -- set by Guild Masters, synced automatically across all guild members running the addon.
4. **Cross-guild ruleset comparison and synchronization** so that players on different servers or in different guilds can still compete on normalized leaderboards.

### 1.3 Design Principles

- **Customization over prescription:** Never hardcode a rule that a GM might want to change.
- **Tracking everything, enforcing selectively:** The addon tracks all player activity but only enforces rules the GM has enabled.
- **Free must be functional:** The free tier must provide a complete hardcore experience. Premium adds control and creativity, never competitive advantage.
- **Performance first:** The addon must have zero measurable impact on gameplay performance. All tracking runs asynchronously where possible, UI updates are throttled, and communication is batched.
- **Privacy by default:** Player data is only shared within the guild unless the player opts into global leaderboards.

---

## 2. Core Features (Detailed)

### 2a. Ruleset Engine

The Ruleset Engine is the foundation of Hardcore Plus. It defines what rules are active, who can modify them, and how they are enforced.

#### Rule Categories

**Hard Rules (Immutable)**
These rules cannot be changed by GMs. They define the core identity of a mode:
- **Hardcore Mode:** Death = character deletion (or logout enforcement). No exceptions.
- **Hybrid Mode:** Death = deletion during leveling, lives system in instances.
- **Nullcore Mode:** Death tracking only, no enforcement. For guilds that want statistics without penalties.

**Soft Rules (GM-Configurable)**
These rules can be toggled, adjusted, or combined by GMs:
- **Self-Found (SSF):** No trading, no Auction House, no mailbox. Variants: SSF-Strict (no grouping), SSF-Guild (trading within guild allowed).
- **Trade Rules:** Whitelist/blacklist specific trade types. Example: consumables can be traded, gear cannot.
- **Dungeon Lockouts:** Limit how often a player can enter a specific dungeon per week/day.
- **Death Penalties (Instance):** Configure lives per boss, per instance, or per lockout period.
- **Level Brackets:** Define at what level hardcore rules activate and deactivate. Example: HC from 10-60, hybrid 60-70.
- **Buff Restrictions:** Disallow specific world buffs or consumables.
- **Spec Restrictions:** Limit allowed talent specializations per class.
- **Group Size Restrictions:** Maximum party size for specific content.

#### Ruleset Operations

- **Export/Import:** Rulesets can be serialized to a string and shared. A GM from Guild A can export their ruleset, and a GM from Guild B can import it to run the same event.
- **Versioning:** Each ruleset has a version number. When a GM updates rules mid-event, all members are notified and the change is logged with a timestamp.
- **Comparability Scoring:** Players running under different rulesets can still be compared via normalized scores. A stricter ruleset applies a multiplier to earned points.
- **Rule Violation Auto-Detection:** The addon monitors player actions against the active ruleset. Violations are logged with timestamps and the GM receives instant notification.

#### Ruleset Data Structure (Conceptual)

```lua
Ruleset = {
    id = "of3-hybrid-v2",
    name = "OnlyFangs 3 Hybrid",
    version = 3,
    mode = "hybrid",           -- "hardcore" | "hybrid" | "nullcore"
    createdBy = "Sodapoppin-Gehennas",
    createdAt = 1710000000,
    hardRules = {
        deathIsDeletion = true, -- during leveling bracket
        levelBracket = {10, 60},
    },
    softRules = {
        ssf = false,
        tradeRestrictions = {"gear"},
        instanceLives = 3,
        livesPer = "boss",     -- "boss" | "instance" | "lockout"
        dungeonLockouts = {},
        buffRestrictions = {},
    },
    difficultyMultiplier = 1.2, -- normalized scoring multiplier
}
```

---

### 2b. Tracking System

The Tracking System records all measurable player activity. Data is stored locally in SavedVariables and optionally synced to the backend via the companion app.

#### Tracked Data Points

| Category | Data Point | WoW API Source | Storage |
|----------|-----------|----------------|---------|
| **Deaths** | Cause of death, zone, level, killer name, killer level, overkill amount, timestamp | `COMBAT_LOG_EVENT_UNFILTERED`, `PLAYER_DEAD`, `UNIT_DIED` | Per-character log |
| **Movement** | Distance traveled (yards), zones visited, time per zone | `GetPlayerMapPosition()` polling (every 5 seconds) | Cumulative counter |
| **Playtime** | Total /played, session time, time per level, time per zone | `TIME_PLAYED_MSG`, session clock | Per-character stats |
| **Mob Kills** | Mob name, mob level, mob type, zone, timestamp, XP gained | `COMBAT_LOG_EVENT_UNFILTERED` (UNIT_DIED subtype) | Kill counter + log |
| **Fishing** | Total fish caught, fish by type, fishing time, fishing skill changes | `LOOT_OPENED` with fishing context, `SKILL_LINES_CHANGED` | Counter + log |
| **Dungeons** | Instance name, entry time, exit time, wipe count, clear status | `ZONE_CHANGED_NEW_AREA`, instance detection | Per-instance log |
| **Bosses** | Boss name, kill time, survivors count, damage dealt, healing done | `BOSS_KILL`, `ENCOUNTER_END`, combat log parsing | Per-boss log |
| **Equipment** | Gear snapshots at key moments (level up, boss kill, death) | `PLAYER_EQUIPMENT_CHANGED`, manual snapshot triggers | Snapshot array |
| **Trading** | Trade partner, items traded, gold traded, AH listings, mail sent | `TRADE_SHOW`, `MAIL_SHOW`, `AUCTION_HOUSE_SHOW` | Transaction log |
| **Combat** | DPS samples, healing samples, damage taken, combat duration | `COMBAT_LOG_EVENT_UNFILTERED` parsing | Rolling averages |

#### Data Integrity

- **Inventory Hash Snapshots:** Periodic hashes of player inventory state to detect item duplication or injection.
- **Cross-Verification:** When two players are in the same group, their addon instances cross-verify kill counts and loot drops.
- **Community Flagging:** Players can flag suspicious deaths or achievements for GM review.
- **Timestamp Anchoring:** All events are timestamped with both local time and server time to prevent clock manipulation.

#### Performance Considerations

- Combat log parsing runs on a per-event basis with early-exit checks to minimize overhead.
- Movement tracking uses a 5-second polling interval, not per-frame.
- Data serialization to SavedVariables is batched and runs during loading screens or logout.
- Historical data older than 30 days is compressed/archived to reduce SavedVariables file size.

---

### 2c. Scoring & Rating System

Two scoring systems are proposed. The community will vote on which to adopt (or both can coexist as GM-selectable options).

#### Option 1: Complex Scoring (Multiplier-Based)

Points are calculated dynamically based on context:

```
Score = BaseValue * LevelMultiplier * DifficultyMultiplier * SurvivorBonus
```

- **BaseValue:** Fixed value per action type (boss kill = 100, dungeon clear = 50, etc.).
- **LevelMultiplier:** Player level relative to content level. Killing a level-appropriate mob scores more than a gray mob.
- **DifficultyMultiplier:** Community-voted difficulty rating for each dungeon/boss (see Heroic Difficulty Ratings below).
- **SurvivorBonus:** Bonus points scaled by how many group members survived the encounter.

#### Option 2: Simple Scoring (Fixed Voted Values)

The community votes on fixed point values for specific actions:

- Prince Malchezaar kill: +500 points per surviving player
- Nightbane kill: +750 points per surviving player
- Heroic Shattered Halls clear: +300 points
- Reaching level 70 in HC mode: +1000 points
- Death at level 60+: -200 points

#### Point Sources

**Boss Kills (Scaled by Difficulty)**
- Each raid and dungeon boss has a community-voted difficulty rating.
- Points are awarded per surviving player to incentivize clean runs.

**Micro-Achievements (Thousands of Possibilities)**
- First player to reach fishing skill 375: +250 points
- First player to sit in every chair in Shattrath City: +100 points
- First player to kill a specific rare mob and loot a specific gray item: +150 points
- First player to complete all Nagrand quests without dying: +500 points
- First player to kill 5 named mobs in a specific zone: +250 points
- Kill 1000 Fel Orcs: +200 points
- Die to fatigue damage: -50 points (shame points)
- Survive a PvP gank in a contested zone: +75 points

**Heroic Difficulty Ratings (Community-Voted)**
Each heroic dungeon receives a difficulty rating voted on by the community:

| Dungeon | Estimated Difficulty | Points |
|---------|---------------------|--------|
| Heroic Blood Furnace | Medium-High | 20 pts |
| Heroic Shattered Halls | Very High | 35 pts |
| Heroic Shadow Labyrinth | High | 25 pts |
| Heroic Arcatraz | Very High | 35 pts |
| Heroic Mechanar | Medium | 15 pts |
| Heroic Botanica | Medium | 15 pts |
| Heroic Slave Pens | Low-Medium | 10 pts |
| Heroic Underbog | Medium | 15 pts |
| Heroic Steamvault | High | 25 pts |
| Heroic Mana-Tombs | Medium | 15 pts |
| Heroic Auchenai Crypts | Medium-High | 20 pts |
| Heroic Sethekk Halls | Medium | 15 pts |
| Heroic Old Hillsbrad | Low | 10 pts |
| Heroic Black Morass | High | 25 pts |

*(All values are drafts and subject to community vote.)*

#### Display

- **In-Game Panel:** A dockable, resizable panel similar to Details! or Deathlog. Shows personal score, guild leaderboard, house standings, and recent achievements.
- **Website:** Updated every few minutes via the companion app. Full leaderboards, historical charts, player profiles.

---

### 2d. Punishment System

The punishment system allows GMs to respond to rule violations with both automated and creative consequences.

#### Automated Tracking

- All rule violations are auto-detected and logged with timestamps.
- The GM receives an instant in-game notification: **who** violated, **what** rule, **when** it happened, and **what they were doing** at the time.
- Violations are categorized by severity: Minor (accidental AH browse), Major (completed a trade), Critical (used a disallowed buff in a raid).

#### Standard Punishments (Free Tier)

Available to all users:
- **Point Deduction:** Configurable point penalty per violation type.
- **Guild Notification:** Public announcement in guild chat that Player X violated Rule Y.
- **Strike System:** Accumulate strikes; configurable consequences at thresholds (3 strikes = kicked from house, 5 = removed from leaderboard).
- **Death Equivalent:** Violation treated as a death for scoring purposes.

#### Creative Punishments (Premium Tier)

Unlocked via Patreon premium tier:
- **Slow-Force (RP-Walk):** Player is forced to RP-walk for a configurable duration (e.g., 1 hour). Implemented by overriding movement speed via addon messaging and social enforcement.
- **Gear-Lock:** Player cannot change equipment for X minutes. The addon blocks equipment swap attempts and alerts the guild if the player attempts to circumvent.
- **Trade-Ban:** Temporary trade restriction beyond what the ruleset already enforces. Duration configurable.
- **Shame Walk:** Player must walk from point A to point B (e.g., Shattrath to Honor Hold) without mounting. Guild members can verify.
- **Duel Obligation:** Player must accept and fight the next duel request they receive.
- **Custom GM-Designed Punishments:** GMs can create custom punishment templates via the web dashboard with descriptions, durations, and verification methods.
- **Remote-Triggered:** GMs can trigger punishments from the web dashboard without being logged into WoW.

#### Punishment Data Structure

```lua
Punishment = {
    id = "pun_001",
    type = "slow_force",
    target = "PlayerName-Server",
    issuedBy = "GM-Name",
    reason = "Traded epic gear in SSF mode",
    duration = 3600,          -- seconds
    startTime = 1710000000,
    verified = false,
    verifiedBy = nil,
}
```

---

### 2e. Reward System

Rewards incentivize positive behavior and create memorable moments.

#### Reward Types

**Public Rewards**
- Announced to the guild when earned.
- Displayed on the player's profile and in the leaderboard.
- Examples: "First to kill Gruul," "Survived the entire leveling phase without a single death," "Top DPS in Prince kill."

**Hidden Rewards**
- Not announced until earned; the criteria are secret.
- Create surprise moments for players and viewers.
- Examples: "Die to a critter," "Fish for 2 hours straight," "Visit every flight path in Outland in a single session."

**GM-Created Rewards**
- GMs can define custom rewards via the web dashboard.
- Triggered manually or automatically on specific conditions.
- Can be tied to boss kills, dungeon clears, achievement completions, or arbitrary triggers.

**Guild-Wide Achievements**
- Announced to the entire guild with a special notification.
- Examples: "All members of House Aldor reached level 70," "Guild completed Karazhan with zero deaths."

**Point-Redeemable Rewards**
- Points accumulated through gameplay can be redeemed for guild rewards.
- Example: The winning house in a season gets first pick of BiS gear from the guild bank.
- GM configures the reward catalog and point costs.

---

### 2f. Houses (Sub-Guilds)

For large guilds like OnlyFangs with 100+ members, Houses provide internal competition structure.

#### House Structure

- Each guild can have 2-8 houses (configurable).
- Each house has a **House Leader** and optional **House Officers**.
- Houses compete within the guild for points on a house leaderboard.
- Individual player scores contribute to their house's total.

#### House Competition

- **Per-Activity Points:** When a house member kills a boss, clears a dungeon, or earns an achievement, the points are added to both the player's personal score and their house's total.
- **House vs. House Events:** GMs can create events where houses compete directly (e.g., "First house to clear Heroic Mechanar wins 500 bonus points").
- **Weekly/Monthly Standings:** Automated leaderboard snapshots for weekly guild meetings.

#### Team Aggregation (Aldor vs. Scryer Model)

- Houses can be grouped into teams for larger content.
- Example: Houses 1 and 2 form "Team Aldor," Houses 3 and 4 form "Team Scryer."
- For 25-man content (Gruul's Lair, Magtheridon's Lair), houses merge into their team.
- Points from 25-man content are split across the participating houses.

#### Draft System

For events like OnlyFangs 3 where house leaders draft players:

- **Player Ratings:** Each player is rated 1-10 based on prior performance, class, and experience.
- **Draft Budget:** Each house leader has a point budget (e.g., 60 points for a 10-man roster).
- **Draft Rules:** Top-rated players cost more (a 10-rated player costs 10 budget points, a 5-rated player costs 5).
- **Draft Order:** Determined by GM (random, reverse standings, auction, snake draft, etc.).
- **Draft UI:** In-game panel showing available players, ratings, and remaining budget. Web dashboard provides a richer draft experience.

#### House Data Structure

```lua
House = {
    id = "house_aldor_1",
    name = "Aldor Vanguard",
    team = "aldor",
    leader = "PlayerName-Server",
    officers = {"Officer1-Server", "Officer2-Server"},
    members = {},              -- populated from guild roster
    totalScore = 0,
    weeklyScore = 0,
    seasonScore = 0,
}
```

---

### 2g. Mini-Games

Mini-games provide spontaneous entertainment and additional point-earning opportunities.

#### Built-In Mini-Games

- **Race to Location:** GM picks a destination, first player to /say a keyword at the location wins.
- **Scavenger Hunt:** GM defines a list of items to collect; first player to collect all wins.
- **First to X:** First player to reach a specific milestone (level, skill level, kill count) earns bonus points.
- **Survival Challenge:** All participants enter a dangerous area; last one alive wins.
- **Trivia:** GM asks WoW lore questions in guild chat; first correct answer wins points.
- **Hide and Seek:** One player hides, others seek. Implemented via proximity detection.

#### Mini-Game Framework

- GMs can create custom mini-games via a template system.
- Each mini-game defines: name, description, start condition, win condition, point reward, maximum participants.
- Mini-games can be scheduled or triggered spontaneously.
- Results are logged and contribute to the leaderboard.

#### Mini-Game Data Structure

```lua
MiniGame = {
    id = "mg_race_001",
    type = "race",
    name = "Race to the Dark Portal",
    description = "First player to /say 'ARRIVED' at the Dark Portal wins!",
    reward = 200,
    maxParticipants = 0,       -- 0 = unlimited
    startTime = 1710000000,
    endTime = nil,             -- nil = ends when won
    winner = nil,
    participants = {},
}
```

---

### 2h. Web Interface (Premium)

The web dashboard provides guild management tools that exceed what is possible within the WoW addon UI.

#### Dashboard Sections

**Guild Overview**
- Total members, active members, houses, current season standings.
- Recent activity feed (deaths, achievements, punishments).
- Quick actions for GMs (trigger punishment, announce reward, start mini-game).

**Ruleset Manager**
- Visual ruleset editor with toggles, sliders, and dropdowns.
- Ruleset comparison tool (diff two rulesets side by side).
- Export/import functionality with shareable links.
- Version history with rollback capability.

**Leaderboard & Statistics**
- Player leaderboard with filtering (by house, by class, by level bracket).
- House leaderboard with historical charts.
- Death statistics (heatmaps by zone, cause-of-death breakdown, deadliest mobs).
- Progression timeline (guild progress through raid tiers).
- Player profiles with achievement showcases.

**Punishment & Reward Designer**
- Create custom punishment templates with descriptions, durations, verification methods.
- Create custom reward definitions with trigger conditions.
- Schedule automated punishments and rewards.
- View punishment/reward history.

**House Management**
- Create, edit, delete houses.
- Assign leaders and officers.
- Draft interface with drag-and-drop player assignment.
- Budget tracker for draft system.

**Voting System**
- Heroic difficulty rating votes with live results.
- Scoring system vote (complex vs. simple).
- Custom polls for guild decisions.
- Vote history and analytics.

**Analytics (Deep Dive)**
- Player performance trends over time.
- Optimal group compositions based on historical data.
- Risk assessment for specific content (death probability by class/spec).
- Engagement metrics (session frequency, playtime trends).

---

## 3. Monetization Strategy

### 3.1 Free Tier (CurseForge Distribution)

The free tier provides a complete hardcore experience:

| Feature | Included |
|---------|----------|
| Death tracking (cause, zone, level, killer) | Yes |
| Basic scoring (boss kills, deaths, levels) | Yes |
| Preset rulesets (HC / Hybrid / Nullcore) | Yes |
| In-game leaderboard panel | Yes |
| Guild communication (death notifications, sync) | Yes |
| SSF enforcement (trade/mail/AH blocking) | Yes |
| Standard punishments (point deduction, notifications) | Yes |
| Micro-achievements (basic set) | Yes |
| Donation link via CurseForge | Yes |

### 3.2 Premium Tier (Patreon Distribution)

Premium is unlocked by uploading a special file (provided to Patreon subscribers) into the addon directory. The addon detects the file on load and enables premium features.

| Feature | Free | Premium |
|---------|------|---------|
| Creative punishments (RP-walk, gear-lock, etc.) | No | Yes |
| Extended statistics and analytics | No | Yes |
| Houses system (sub-guild management) | No | Yes |
| Draft system | No | Yes |
| Web dashboard access | No | Yes |
| Mini-game framework | No | Yes |
| Custom achievement designer | No | Yes |
| Custom punishment & reward designer | No | Yes |
| Priority support | No | Yes |
| Companion app backend sync | Limited | Full |

### 3.3 Pricing Tiers (Proposed)

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | Core HC experience |
| Supporter | $5/month | Premium addon features for individual |
| Guild | $15/month | Premium for entire guild (up to 50 members) |
| Event | $25/month | Premium for large events (unlimited members) + priority support |

### 3.4 Key Monetization Principle

**Free MUST remain comparable.** Death and score tracking works identically for everyone. A free player and a premium player on the same leaderboard are scored by the same system. Premium adds more **control** (custom rules, punishments, rewards) and more **creativity** (mini-games, web dashboard), but NEVER competitive advantage. A free player can win the leaderboard.

---

## 4. Development Phases

### Phase 0: Final Draft Concept (1-2 weeks)

**Goal:** Solidify the plan, make all architectural decisions, and prepare for development.

- [ ] Finalize this document with team consensus.
- [ ] Create detailed feature matrix: Free vs. Premium, with every feature explicitly categorized.
- [ ] Technical architecture decisions:
  - [ ] Choose primary Ace3 libraries (AceAddon, AceDB, AceGUI, AceComm, AceSerializer).
  - [ ] Decide on SavedVariables schema (per-character vs. per-account vs. hybrid).
  - [ ] Choose backend database (MongoDB vs. PostgreSQL).
  - [ ] Choose companion app framework (Electron vs. Tauri).
- [ ] Competitor deep-analysis:
  - [ ] Install and test Sauercrowd addon, document all features and limitations.
  - [ ] Install and test HardcoreTBC addon, document all features and limitations.
  - [ ] Install and test Deathlog addon, document all features and limitations.
  - [ ] Review base HC addon source code for reusable patterns.
- [ ] Map OnlyFangs 3 requirements to features (see Section 7).
- [ ] Define Minimum Viable Addon (MVA): the smallest set of features that is useful and testable.
- [ ] Set up development environment:
  - [ ] CMaNGOS TBC Docker container with multiple test accounts.
  - [ ] Git repository with branching strategy (main, develop, feature branches).
  - [ ] CI/CD pipeline for addon packaging (zip, .toc validation).
  - [ ] Issue tracker setup (GitHub Issues or similar).

**Deliverable:** Approved project plan, development environment ready, issue tracker populated with Phase 1 tasks.

---

### Phase 1: PoC - Basic WoW Menu (1-2 weeks)

**Goal:** Prove that we can create a functioning addon in the TBC 2.4.3 client.

- [ ] Create `.toc` file with correct TBC interface number (20400).
- [ ] Create `Core.lua` with addon initialization using AceAddon-3.0.
- [ ] Implement simple AceGUI frame with:
  - [ ] Title bar with addon name and version.
  - [ ] One tab for "Score" showing a placeholder value.
  - [ ] One tab for "Settings" with a placeholder checkbox.
  - [ ] One button that prints the player's current score (hardcoded 0) to chat.
- [ ] Implement slash command `/hcp` to toggle the main frame.
- [ ] Set up CMaNGOS TBC Docker as the test environment.
  - [ ] Document setup steps for all developers.
  - [ ] Create test accounts and characters at various levels.
- [ ] Write first unit test: addon loads without errors.

**Deliverable:** Addon loads in TBC client, shows a menu, button prints to chat, slash command works.

**Acceptance Criteria:**
1. `/hcp` opens and closes the main frame.
2. The frame displays correctly at 1920x1080 and 1280x720 resolutions.
3. The button prints "Hardcore Plus: Score = 0" to chat.
4. No Lua errors on load or interaction.

---

### Phase 2: Tracking Library (2-3 weeks)

**Goal:** Build a modular, performant tracking library that captures all relevant player activity.

- [ ] Catalog all relevant WoW API events for TBC 2.4.3:
  - [ ] Death events: `COMBAT_LOG_EVENT_UNFILTERED` (SWING_DAMAGE, SPELL_DAMAGE, etc. with UNIT_DIED), `PLAYER_DEAD`, `PLAYER_ALIVE`, `PLAYER_UNGHOST`.
  - [ ] Level events: `PLAYER_LEVEL_UP`, `PLAYER_XP_UPDATE`.
  - [ ] Combat events: Full `COMBAT_LOG_EVENT_UNFILTERED` parsing with subevent routing.
  - [ ] Inventory events: `BAG_UPDATE`, `PLAYER_EQUIPMENT_CHANGED`, `ITEM_LOCK_CHANGED`.
  - [ ] Trade events: `TRADE_SHOW`, `TRADE_ACCEPT_UPDATE`, `MAIL_SHOW`, `MAIL_SEND_SUCCESS`, `AUCTION_HOUSE_SHOW`.
  - [ ] Movement: `GetPlayerMapPosition()` availability and limitations in TBC.
  - [ ] Instance events: `ZONE_CHANGED_NEW_AREA`, `ZONE_CHANGED`, instance detection via `IsInInstance()`.
  - [ ] Boss events: `BOSS_KILL` (if available in TBC), `CHAT_MSG_MONSTER_YELL` for boss pull detection.
- [ ] Build modular tracking library with individual tracker modules:
  - [ ] `DeathTracker.lua`: Detect player death, capture killer info from combat log, record zone/level/timestamp.
  - [ ] `MobTracker.lua`: Count mob kills by name/type/level/zone, track XP gained per kill.
  - [ ] `MoveTracker.lua`: Poll player position every 5 seconds, calculate distance traveled, track zones visited.
  - [ ] `TradeTracker.lua`: Monitor all trade windows, mail sends, AH interactions. Log items and gold transferred.
  - [ ] `DungeonTracker.lua`: Detect instance entry/exit, track time spent, detect boss encounters.
  - [ ] `GearTracker.lua`: Snapshot equipment at key moments (level up, zone change, boss kill, death).
- [ ] Implement SavedVariables serialization:
  - [ ] Define schema for each tracker's data.
  - [ ] Implement data migration system for schema changes between addon versions.
  - [ ] Implement data compression for historical records.
- [ ] Write unit tests for each tracker module (where possible within WoW's Lua environment).
- [ ] Performance benchmarking: Measure CPU time per event handler, establish performance budgets.

**Deliverable:** All trackers record data correctly, data persists across sessions, no performance impact.

**Acceptance Criteria:**
1. Player death is recorded with correct killer, zone, level, and timestamp.
2. Mob kills are counted accurately (verified against manual count in test session).
3. Equipment snapshots match actual equipped items.
4. SavedVariables file size remains under 500KB after 10 hours of play.
5. No frame rate drop (>1fps) during normal gameplay with all trackers active.

---

### Phase 3: PoC - Guild Communication ("Guild Bank") (2-3 weeks)

**Goal:** Establish reliable addon-to-addon communication within a guild.

- [ ] Implement `SendAddonMessage` / `CHAT_MSG_ADDON` communication layer:
  - [ ] Message serialization using AceSerializer-3.0.
  - [ ] Message compression using LibCompress (or similar).
  - [ ] Message chunking for payloads exceeding the 255-byte limit.
  - [ ] Message queuing to avoid chat throttling.
- [ ] Define message protocol:
  - [ ] `SYNC_REQUEST`: Request current state from other addon instances.
  - [ ] `SYNC_RESPONSE`: Send current state in response.
  - [ ] `DEATH_NOTIFY`: Broadcast death event to guild.
  - [ ] `RULE_UPDATE`: GM broadcasts ruleset change.
  - [ ] `SCORE_UPDATE`: Periodic score synchronization.
  - [ ] `PUNISHMENT`: GM issues punishment to a player.
  - [ ] `ACHIEVEMENT`: Broadcast achievement earned.
  - [ ] `HEARTBEAT`: Periodic alive signal with basic status.
- [ ] Implement data synchronization:
  - [ ] Initial sync on login (request current state from online members).
  - [ ] Incremental updates (only send changes, not full state).
  - [ ] Conflict resolution (latest timestamp wins, GM overrides player data).
- [ ] Implement ruleset broadcast:
  - [ ] GM pushes ruleset to all online members.
  - [ ] Offline members receive ruleset on next login via sync.
  - [ ] Ruleset hash verification to ensure all members are on the same version.
- [ ] Build communication layer as a reusable module (`Communication.lua`).
- [ ] Security considerations:
  - [ ] Validate sender is in the same guild.
  - [ ] Validate GM commands come from a character with GM rank.
  - [ ] Rate-limit incoming messages to prevent spam.

**Deliverable:** Two addon instances can exchange data, rulesets sync from GM to members, deaths are broadcast guild-wide.

**Acceptance Criteria:**
1. Player A's death is visible in Player B's addon within 5 seconds.
2. GM updates a ruleset; all online members receive the update within 10 seconds.
3. A player logging in after a ruleset change receives the current ruleset on sync.
4. Message queue does not cause chat throttle disconnects.
5. Communication works across all guild chat channels (GUILD, OFFICER).

---

### Phase 4: Website Voting Feature (1-2 weeks)

**Goal:** Create a web-based voting system for community decisions.

- [ ] Design and implement voting pages:
  - [ ] Heroic dungeon difficulty rating votes (slider 1-10 per dungeon).
  - [ ] Scoring system vote (Complex vs. Simple, with detailed explanations of each).
  - [ ] Custom polls (GM can create arbitrary yes/no or multiple-choice polls).
- [ ] Backend implementation:
  - [ ] Node.js server with Express.
  - [ ] SQLite database for vote storage (upgrade to PostgreSQL later if needed).
  - [ ] REST API endpoints: `POST /vote`, `GET /results`, `POST /poll` (admin).
  - [ ] Anti-manipulation: one vote per Battle.net account or Discord account (OAuth).
  - [ ] Vote period management (start date, end date, results visibility).
- [ ] Frontend implementation:
  - [ ] Simple, clean UI (no framework needed at this stage; vanilla HTML/CSS/JS or minimal React).
  - [ ] Real-time results display (percentage bars, total votes).
  - [ ] Mobile-responsive design.

**Deliverable:** Working vote page accessible via web browser, results stored in database, anti-manipulation in place.

**Acceptance Criteria:**
1. A user can vote on heroic dungeon difficulty.
2. A user cannot vote twice on the same poll.
3. Results update in real-time as votes come in.
4. GM can create a custom poll via the admin interface.

---

### Phase 5: Rudimentary HC Addon with Examples from All Categories (3-4 weeks)

**Goal:** Create the first playable version of Hardcore Plus with at least one example feature from every category.

- [ ] **Tracking:** Basic death tracking with guild-wide notifications (from Phase 2 + 3).
- [ ] **Scoring:** Simple scoring: death = configurable point deduction, boss kill = configurable points, level up = points.
- [ ] **Punishments:** One creative punishment implemented (RP-walk force as proof of concept).
- [ ] **Rules:** Ruleset selection UI: Hardcore / Hybrid / Nullcore with basic soft rule toggles (SSF on/off).
- [ ] **Leaderboard:** Basic in-game leaderboard panel showing top 20 players by score.
- [ ] **SSF Enforcement:** Block trade window, mail sending, and AH interaction when SSF rule is active.
- [ ] **Achievements:** 10-20 micro-achievements implemented as examples.
- [ ] **UI Polish:** Clean up all panels, consistent styling, proper scaling.
- [ ] **Testing:** End-to-end test with 3+ players in a CMaNGOS environment.

**Deliverable:** A playable addon that demonstrates every feature category. Suitable for early feedback from advisors.

**Acceptance Criteria:**
1. A new player can install the addon, select a ruleset, and start playing.
2. Deaths are tracked and announced in guild chat.
3. Scores update correctly on kills and deaths.
4. SSF mode blocks trading.
5. At least one punishment can be triggered by a GM and affects the target player.
6. The leaderboard displays accurate rankings.

---

### Phase 6: Alpha to Beta (4-6 weeks)

**Goal:** Implement all remaining features and reach feature-complete beta status.

- [ ] **Houses System:** Full implementation of houses, leaders, officers, member assignment, house leaderboard, team aggregation.
- [ ] **Draft System:** Player rating UI, draft budget, draft order, draft interface (in-game and web).
- [ ] **Mini-Game Framework:** At least 3 built-in mini-games, custom mini-game template system.
- [ ] **All Creative Punishments:** RP-walk, gear-lock, trade-ban, shame walk, duel obligation, custom templates.
- [ ] **Reward System:** Public rewards, hidden rewards, GM-created rewards, guild-wide achievements.
- [ ] **Full Scoring:** Both scoring options implemented, GM selects which to use.
- [ ] **Full Achievement Set:** 100+ micro-achievements covering all categories.
- [ ] **Web Dashboard MVP:**
  - [ ] Guild overview page.
  - [ ] Leaderboard page with filters.
  - [ ] Ruleset editor.
  - [ ] Punishment and reward designer.
  - [ ] House management.
  - [ ] Player profiles.
- [ ] **Companion App (Electron):**
  - [ ] Watches SavedVariables file for changes.
  - [ ] Sends data to backend via HTTPS.
  - [ ] HMAC-SHA256 payload signing for data integrity.
  - [ ] Configurable sync interval (default: every 2 minutes).
  - [ ] System tray icon with status indicator.
- [ ] **Anti-Cheat Basics:**
  - [ ] Inventory hash snapshots at regular intervals.
  - [ ] Cross-verification between group members.
  - [ ] Suspicious activity flagging (impossible level speed, impossible kill counts).
  - [ ] GM review queue for flagged activities.
- [ ] **Bug Fixing and Performance Optimization:**
  - [ ] Address all known bugs from Phase 5 testing.
  - [ ] Profile addon memory usage and optimize.
  - [ ] Profile network message volume and optimize.
  - [ ] Ensure all UI elements scale correctly at common resolutions.

**Deliverable:** Feature-complete beta addon with web dashboard and companion app.

---

### Phase 7: Playtesting (2-4 weeks)

**Goal:** Validate all features with real players, balance scoring, and stress-test the system.

- [ ] **Closed Beta Recruitment:**
  - [ ] Select 20-50 testers from target communities (OnlyFangs alumni, HC streamers, TBC guilds).
  - [ ] Provide testers with installation guide, feedback form, and bug report template.
  - [ ] Set up a dedicated Discord channel for beta feedback.
- [ ] **Feedback Collection:**
  - [ ] Weekly feedback surveys (feature satisfaction, bugs encountered, suggestions).
  - [ ] In-game feedback command (`/hcp feedback <message>`).
  - [ ] Automated crash/error reporting (Lua error capture and transmission).
- [ ] **Balancing:**
  - [ ] Review scoring data: are any achievements too easy/hard to earn?
  - [ ] Adjust heroic difficulty ratings based on actual player performance data.
  - [ ] Balance punishment durations and severity.
  - [ ] Ensure free vs. premium feature split feels fair.
- [ ] **Stress Testing:**
  - [ ] Simulate 100+ concurrent users syncing data.
  - [ ] Test backend API under load (target: 1000 requests/minute sustained).
  - [ ] Test companion app with large SavedVariables files (10MB+).
  - [ ] Test guild communication with 40+ addon instances in a raid.
- [ ] **Security Testing:**
  - [ ] Attempt to spoof addon messages from non-guild members.
  - [ ] Attempt to manipulate SavedVariables to inflate scores.
  - [ ] Attempt to bypass SSF restrictions.
  - [ ] Penetration testing on the web dashboard.

**Deliverable:** Balanced, tested, stable addon ready for public release.

---

### Phase 8: Launch Preparation (2 weeks)

**Goal:** Prepare all distribution channels, documentation, and marketing materials.

- [ ] **CurseForge:**
  - [ ] Create CurseForge project page with screenshots, description, and feature list.
  - [ ] Upload addon package (free tier).
  - [ ] Set up automatic update notifications.
- [ ] **Patreon:**
  - [ ] Create Patreon page with tier descriptions and rewards.
  - [ ] Set up premium file distribution system.
  - [ ] Write welcome messages for new patrons.
- [ ] **Documentation:**
  - [ ] Installation guide (addon + companion app).
  - [ ] GM quickstart guide (creating a guild, setting rules, managing houses).
  - [ ] Player guide (understanding scores, achievements, rules).
  - [ ] API documentation for the companion app/backend.
  - [ ] FAQ with common questions and troubleshooting.
- [ ] **Marketing:**
  - [ ] Trailer video (2-3 minutes, showing key features in action).
  - [ ] Feature highlight clips for social media (30 seconds each).
  - [ ] Reddit posts on r/classicwow, r/wow, r/classicwowhc.
  - [ ] Discord announcements in relevant communities.
  - [ ] Reach out to HC streamers for early access coverage.
- [ ] **Launch Day Checklist:**
  - [ ] Backend scaled for launch traffic (estimate 10x normal load).
  - [ ] Support team briefed on common issues.
  - [ ] Hotfix process documented (how to push an emergency update).
  - [ ] Rollback plan in case of critical bugs.

**Deliverable:** Public release on CurseForge, Patreon live, documentation published, marketing campaign launched.

---

## 5. Technical Architecture

### 5.1 WoW Addon (Lua 5.1 / TBC 2.4.3 API)

#### Directory Structure

```
HardcorePlus/
├── HardcorePlus.toc              -- Addon metadata, load order, SavedVariables declaration
├── Core.lua                      -- Initialization, event bus, slash commands, module loader
├── Constants.lua                 -- Static data (zone IDs, boss names, achievement definitions)
├── Utils.lua                     -- Shared utility functions (string manipulation, time formatting)
│
├── Tracking/
│   ├── DeathTracker.lua          -- Death detection, killer identification, combat log parsing
│   ├── MobTracker.lua            -- Kill counting by mob name/type/level/zone
│   ├── MoveTracker.lua           -- Movement distance calculation, zone visit tracking
│   ├── TradeTracker.lua          -- Mail, AH, trade window monitoring
│   ├── DungeonTracker.lua        -- Instance entry/exit, time tracking, boss encounter detection
│   ├── GearTracker.lua           -- Equipment snapshot system
│   └── FishingTracker.lua        -- Fishing skill and catch tracking
│
├── Rules/
│   ├── RuleEngine.lua            -- Core rule evaluation logic
│   ├── Rulesets.lua              -- Preset ruleset definitions and import/export
│   ├── Enforcement.lua           -- Action blocking (SSF trade prevention, buff restrictions)
│   └── Violations.lua            -- Violation detection and logging
│
├── Scoring/
│   ├── ScoreEngine.lua           -- Point calculation (both complex and simple modes)
│   ├── Achievements.lua          -- Micro-achievement definitions and tracking
│   ├── Leaderboard.lua           -- In-game leaderboard data management and sorting
│   └── Normalization.lua         -- Cross-ruleset score normalization
│
├── Social/
│   ├── Communication.lua         -- SendAddonMessage wrapper, serialization, chunking
│   ├── Protocol.lua              -- Message types, versioning, validation
│   ├── Houses.lua                -- Sub-guild management, house leaderboards
│   ├── GuildSync.lua             -- Ruleset and data synchronization logic
│   └── Draft.lua                 -- Player rating and draft system
│
├── Gameplay/
│   ├── Punishments.lua           -- Punishment definitions, application, and verification
│   ├── Rewards.lua               -- Reward definitions, triggers, and announcements
│   └── MiniGames.lua             -- Mini-game framework and built-in games
│
├── UI/
│   ├── MainPanel.lua             -- Main settings and configuration window
│   ├── ScorePanel.lua            -- Score display and personal stats
│   ├── DeathLog.lua              -- Death log browser window
│   ├── LeaderboardPanel.lua      -- Leaderboard display
│   ├── HousePanel.lua            -- House management and standings
│   ├── DraftPanel.lua            -- Draft interface
│   ├── MiniGamePanel.lua         -- Mini-game UI
│   ├── Alerts.lua                -- Notification popups and toast messages
│   └── Widgets.lua               -- Custom reusable UI components
│
├── Libs/                         -- Embedded libraries
│   ├── AceAddon-3.0/
│   ├── AceDB-3.0/
│   ├── AceGUI-3.0/
│   ├── AceComm-3.0/
│   ├── AceSerializer-3.0/
│   ├── AceEvent-3.0/
│   ├── AceTimer-3.0/
│   ├── LibCompress/
│   ├── LibDataBroker-1.1/
│   └── CallbackHandler-1.0/
│
└── Data/
    ├── BossData.lua              -- Boss names, IDs, instance mappings
    ├── AchievementData.lua       -- Achievement definitions (name, criteria, points)
    ├── DungeonData.lua           -- Dungeon metadata (difficulty ratings, point values)
    └── ZoneData.lua              -- Zone metadata for tracking
```

#### Key Technical Decisions

- **Event Bus Pattern:** All modules communicate through a central event bus (AceEvent). This decouples modules and makes testing easier.
- **Module Lifecycle:** Each module registers with AceAddon and has `OnInitialize()` and `OnEnable()` hooks. Modules can be individually disabled without affecting others.
- **SavedVariables Strategy:** Use AceDB-3.0 with per-character profiles for tracking data and a global (account-wide) profile for settings and rulesets.
- **Memory Management:** Recycle tables where possible. Use object pools for frequently created/destroyed data structures (e.g., combat log events).
- **Combat Log Parsing:** Register for `COMBAT_LOG_EVENT_UNFILTERED` once in Core.lua and route subevents to the appropriate tracker module. This avoids multiple registrations of the same expensive event.

### 5.2 Companion App (Electron)

The companion app bridges the gap between the WoW addon (which cannot make HTTP requests) and the web backend.

#### Architecture

```
CompanionApp/
├── main.js                       -- Electron main process
├── renderer/
│   ├── index.html                -- Minimal UI (status, last sync, settings)
│   └── renderer.js               -- UI logic
├── services/
│   ├── FileWatcher.js            -- Watches SavedVariables file for changes (fs.watch)
│   ├── DataParser.js             -- Parses Lua SavedVariables into JSON
│   ├── ApiClient.js              -- HTTPS client for backend communication
│   ├── AuthManager.js            -- JWT token management, HMAC signing
│   └── SyncManager.js            -- Diff calculation, sync scheduling
└── config/
    └── settings.json             -- User configuration (WoW install path, sync interval, API key)
```

#### Data Flow

1. WoW addon writes data to `SavedVariables/HardcorePlus.lua` on logout, zone change, or periodic timer.
2. Companion app detects file change via `fs.watch`.
3. `DataParser` converts Lua table syntax to JSON.
4. `SyncManager` calculates diff against last synced state.
5. `ApiClient` sends diff to backend API with HMAC-SHA256 signature.
6. Backend validates signature, processes data, updates leaderboards.

#### Security

- **HMAC-SHA256 Signing:** Each payload is signed with a per-user secret key. The backend verifies the signature before processing.
- **Rate Limiting:** Companion app rate-limits itself to 1 sync per minute minimum.
- **Data Validation:** Backend validates all incoming data for consistency (e.g., a level 20 player cannot have killed Gruul).

### 5.3 Backend (Node.js)

#### API Structure

```
Backend/
├── server.js                     -- Express server setup, middleware
├── routes/
│   ├── auth.js                   -- Registration, login, JWT issuance
│   ├── sync.js                   -- Data sync endpoints (POST /sync)
│   ├── leaderboard.js            -- Leaderboard queries (GET /leaderboard)
│   ├── guild.js                  -- Guild management (rules, houses, members)
│   ├── vote.js                   -- Voting system endpoints
│   ├── punishment.js             -- Remote punishment triggers
│   └── webhook.js                -- Discord webhook integration
├── models/
│   ├── Player.js                 -- Player data model
│   ├── Guild.js                  -- Guild data model
│   ├── House.js                  -- House data model
│   ├── Score.js                  -- Score records
│   ├── Death.js                  -- Death records
│   ├── Vote.js                   -- Vote records
│   └── Achievement.js            -- Achievement records
├── middleware/
│   ├── auth.js                   -- JWT verification
│   ├── hmac.js                   -- HMAC-SHA256 verification
│   ├── rateLimit.js              -- Rate limiting
│   └── validation.js             -- Input validation
├── services/
│   ├── LeaderboardService.js     -- Leaderboard calculation and caching
│   ├── SyncService.js            -- Data sync processing
│   ├── NotificationService.js    -- Discord/webhook notifications
│   └── AntiCheatService.js       -- Data integrity checks
└── config/
    └── config.js                 -- Database connection, API keys, feature flags
```

#### Database Schema (Key Collections/Tables)

- **players**: Character name, server, class, race, level, total score, house, guild, status (alive/dead), created, last_seen.
- **deaths**: Player reference, timestamp, zone, level, killer, cause, overkill, verified.
- **scores**: Player reference, timestamp, source (boss kill, achievement, etc.), points, metadata.
- **guilds**: Name, server, ruleset, houses, members, settings, premium_status.
- **houses**: Name, guild reference, team, leader, officers, members, scores.
- **votes**: Poll reference, voter, choice, timestamp.
- **achievements**: Player reference, achievement ID, timestamp, verified.

### 5.4 Web Dashboard (React)

#### Technology Stack

- **React 18** with TypeScript
- **TanStack Query** for server state management
- **Tailwind CSS** for styling
- **React Router** for navigation
- **Chart.js** or **Recharts** for statistics visualization
- **Socket.io** for real-time updates

#### Key Pages

| Route | Page | Description |
|-------|------|-------------|
| `/` | Landing | Feature overview, login/register |
| `/dashboard` | Guild Overview | Activity feed, quick stats, GM actions |
| `/leaderboard` | Leaderboard | Player/House rankings with filters |
| `/player/:id` | Player Profile | Detailed stats, achievements, history |
| `/rules` | Ruleset Editor | Visual rule configuration |
| `/houses` | House Management | Create/edit houses, assign members |
| `/draft` | Draft Interface | Draft setup and execution |
| `/punishments` | Punishment Designer | Create/manage punishment templates |
| `/rewards` | Reward Designer | Create/manage reward definitions |
| `/voting` | Voting | Active polls and results |
| `/analytics` | Analytics | Deep-dive statistics and charts |

---

## 6. Competitor Analysis

### 6.1 Sauercrowd (German HC Event Addon)

**Overview:** Sauercrowd is a German-language addon built for the Sauercrowd community's hardcore events on Classic Era.

**Strengths:**
- Solid death tracking and notification system.
- Chat prefix system for identifying hardcore players.
- Content creator features (streamer mode, overlay data).
- PvP flagging warnings for hardcore players.
- Active community with regular events.

**Weaknesses:**
- Rules are hardcoded; GMs cannot customize without modifying source code.
- No scoring or point system.
- No houses or sub-guild competition.
- Classic Era only; no TBC support.
- No web backend or dashboard.
- German-only UI and documentation.
- No creative punishment system.

**Our Edge Over Sauercrowd:**
- Fully customizable rulesets via the Ruleset Engine.
- Comprehensive scoring and achievement system.
- Houses for internal guild competition.
- TBC-native design from day one.
- Web dashboard for advanced management.
- English-first with internationalization support.
- Creative punishment and reward systems.

### 6.2 HardcoreTBC (by mocktailtv, 33k+ downloads)

**Overview:** The most popular TBC-specific hardcore addon. Simple and focused on enforcing permadeath in TBC.

**Strengths:**
- TBC-specific design and compatibility.
- Established user base (33,000+ downloads on CurseForge).
- Death = character deletion enforcement.
- Simple and lightweight.

**Weaknesses:**
- No multi-mode support (hardcore only, no hybrid or nullcore).
- No scoring system.
- No customization of rules.
- No guild communication beyond death notifications.
- No houses or sub-guild features.
- Extremely basic feature set.
- No web backend.
- No creative punishments or rewards.

**Our Edge Over HardcoreTBC:**
- Multi-mode support (HC, Hybrid, Nullcore) makes TBC hardcore actually viable for endgame.
- Full scoring and leaderboard system.
- Customizable rulesets for different event types.
- Houses, mini-games, and creative punishments add depth.
- Web dashboard for management and analytics.

### 6.3 Base HC Addon (Classic Era)

**Overview:** The original hardcore addon for WoW Classic. The gold standard for Classic Era hardcore with a large community.

**Strengths:**
- Massive community and adoption.
- Well-maintained and regularly updated.
- Comprehensive death verification system.
- Integration with the official HC community (classichc.net).
- Mature codebase with years of bug fixes.

**Weaknesses:**
- Classic Era only; no TBC support and no plans for it.
- Rigid, non-customizable rules.
- No scoring beyond binary alive/dead.
- No house or sub-guild features.
- No creative punishments.

**Our Edge Over Base HC Addon:**
- TBC-native design.
- Customizable rulesets.
- Scoring, achievements, and leaderboards.
- Modern feature set (houses, mini-games, web dashboard).
- Addresses the fundamental problem that pure HC does not work well in TBC.

### 6.4 Deathlog

**Overview:** A tracking and statistics addon focused on recording and displaying death data across the server.

**Strengths:**
- Excellent death UI with detailed statistics.
- Faction-wide death notifications.
- Historical death data with heatmaps and analytics.
- Clean, well-designed interface.

**Weaknesses:**
- Tracking only; no enforcement of any rules.
- No penalties for death.
- No scoring system.
- No guild management features.
- No customization.

**Our Edge Over Deathlog:**
- Full system: tracking + enforcement + scoring + social features.
- Rule-based penalties and creative punishments.
- Guild-centric design with houses and competition.
- Web dashboard for deeper analytics.

### 6.5 Our Unique Value Proposition (Summary)

| Feature | Sauercrowd | HardcoreTBC | Base HC | Deathlog | **Hardcore Plus** |
|---------|-----------|-------------|---------|----------|-------------------|
| Customizable Rulesets | No | No | No | No | **Yes** |
| Houses / Sub-Guilds | No | No | No | No | **Yes** |
| Creative Punishments | No | No | No | No | **Yes** |
| Web Dashboard | No | No | Partial | No | **Yes** |
| Mini-Games | No | No | No | No | **Yes** |
| Companion App + Backend | No | No | Partial | No | **Yes** |
| TBC-Native Design | No | Yes | No | Partial | **Yes** |
| Scoring System | No | No | No | No | **Yes** |
| Hybrid HC Mode | No | No | No | No | **Yes** |
| Multi-Mode Support | No | No | No | No | **Yes** |

Hardcore Plus is the **only** addon that combines all of these features into a single, cohesive system designed specifically for TBC.

---

## 7. OnlyFangs 3 Requirements Mapping

Based on Punching Down Episode 33 (Sodapoppin & NMP discussion about OnlyFangs 3 format):

| # | OF3 Requirement | Hardcore Plus Feature | Phase | Priority |
|---|----------------|----------------------|-------|----------|
| 1 | Houses within Aldor vs Scryer faction split | Houses system with team aggregation (houses grouped into Aldor/Scryer teams) | Phase 6 | Critical |
| 2 | Point system for heroics with difficulty ratings | Scoring engine with community-voted heroic difficulty ratings | Phase 5 | Critical |
| 3 | Thousands of micro-achievements for points | Achievement tracker with extensible definition system (100+ at launch, framework for unlimited additions) | Phase 5 | High |
| 4 | Player rating system (1-10) for fair drafts | Player rating system with draft point budget and draft UI | Phase 6 | High |
| 5 | Cross-house competition and leaderboards | House leaderboard with weekly/monthly/seasonal standings | Phase 6 | Critical |
| 6 | Points redeemable for guild rewards (BiS gear) | GM reward designer with point-cost catalog | Phase 6 | Medium |
| 7 | Weekly guild meeting tallies and reports | Automated weekly report generation (top players, house standings, notable events) | Phase 6 | Medium |
| 8 | Death tracking with meaningful consequences | Multi-mode death system: HC (deletion), Hybrid (lives in instances), Nullcore (tracking only) | Phase 5 | Critical |
| 9 | Random event points (first to fish 375, etc.) | Micro-achievement framework with "first to X" tracking | Phase 5 | High |
| 10 | Non-WoW tournament tracking (side events) | Extensible scoring API that allows manual point entry by GMs for external events | Future | Low |
| 11 | Fun punishments for rule violations | Creative punishment system (RP-walk, gear-lock, trade-ban, custom) | Phase 5-6 | High |
| 12 | Hidden surprises and rewards | Hidden reward system with secret criteria | Phase 6 | Medium |
| 13 | Spectator-friendly data for streams | Real-time data export for stream overlays via companion app | Phase 6 | Medium |
| 14 | Easy setup for GMs (not too technical) | Web dashboard with visual ruleset editor and one-click guild setup | Phase 6 | High |

### Coverage Assessment

- **Critical requirements covered:** 4/4 (Houses, Scoring, Death Tracking, Leaderboards)
- **High-priority requirements covered:** 5/5 (Achievements, Draft, Punishments, GM Tools, Random Events)
- **Medium-priority requirements covered:** 4/4 (Rewards, Weekly Reports, Hidden Surprises, Stream Data)
- **Low-priority (future):** 1/1 (Non-WoW Events)

**Total: 14/14 identified requirements have a planned solution.**

---

## 8. Risk Assessment & Mitigations

### 8.1 Technical Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TBC 2.4.3 API limitations prevent key features | High | Medium | Early PoC phase tests all critical API calls; fallback designs for each feature |
| SavedVariables file corruption | High | Low | Automated backups before each write; data validation on load; recovery mode |
| Addon communication throttling causes data loss | Medium | Medium | Message queuing with retry; priority system for critical messages (deaths); batch non-critical updates |
| Performance impact during raids (40+ addon instances) | High | Medium | Aggressive throttling in raid context; disable non-essential tracking during boss encounters; benchmark early |
| Companion app file watcher reliability | Medium | Low | Fallback to polling if fs.watch fails; manual sync button; robust error handling |

### 8.2 Community Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Community rejects paid tier as "pay-to-win" | High | Medium | Crystal-clear messaging: free is fully functional, premium is convenience/creativity only; community input on tier split |
| Low adoption due to established competitors | Medium | Medium | Focus on unique features (customization, houses); partner with streamers for visibility; offer migration tools from competitor addons |
| Cheating undermines leaderboard integrity | High | Medium | Multi-layer verification (inventory hashes, cross-player verification, companion app validation); GM review tools; community flagging |
| Feature creep delays launch | High | High | Strict MVP definition; phase gating; no new features added to a phase once development begins |

### 8.3 Business Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Blizzard TOS changes affect addon functionality | High | Low | Monitor Blizzard announcements; design features to be TOS-compliant; no automation of gameplay |
| Server hosting costs exceed revenue | Medium | Medium | Start with minimal infrastructure (single VPS); scale only with demand; use serverless functions where possible |
| Key developer leaves project | High | Medium | Comprehensive documentation; modular codebase with clear interfaces; no single points of knowledge |

---

## 9. Open Questions & Decisions

The following questions need to be resolved before or during Phase 0:

### Architecture Decisions

1. **Database choice:** MongoDB (flexible schema, fast prototyping) vs. PostgreSQL (relational integrity, complex queries)? **Recommendation:** Start with MongoDB for speed, migrate to PostgreSQL if relational queries become critical.

2. **Companion app framework:** Electron (large community, proven) vs. Tauri (smaller binary, Rust backend, newer)? **Recommendation:** Electron for reliability and developer familiarity, despite larger binary size.

3. **Real-time updates:** WebSocket (persistent connection, true real-time) vs. polling (simpler, less infrastructure)? **Recommendation:** WebSocket for the dashboard, polling for the companion app sync.

### Design Decisions

4. **Scoring system:** Should both Complex and Simple scoring coexist as GM-selectable options, or should the community vote lock in one system for all? **Recommendation:** Both coexist; GM selects per guild.

5. **Premium file distribution:** Patreon download + manual install vs. license key system vs. OAuth-gated download? **Recommendation:** Patreon download for simplicity at launch; evaluate license key system post-launch.

6. **Death verification in Hybrid mode:** How do we verify instance deaths vs. overworld deaths when the distinction matters for scoring? **Recommendation:** Use `IsInInstance()` check at time of death, cross-verified by group members.

### Community Decisions (Require Voting)

7. **Heroic difficulty ratings:** What scale? 1-5 (simple) vs. 1-10 (granular) vs. point values directly?

8. **Achievement point values:** Should the community vote on individual achievement values, or should a formula determine them?

9. **Draft format:** Snake draft vs. auction draft vs. random assignment with trade period?

---

## 10. Glossary

| Term | Definition |
|------|-----------|
| **HC** | Hardcore. Traditional permadeath mode where death means character deletion. |
| **Hybrid** | A mode where HC rules apply during leveling, but instances allow multiple deaths. |
| **Nullcore** | A mode with no death penalties. Tracking and scoring only. |
| **SSF** | Solo Self-Found. A restriction mode where trading, mail, and the AH are disabled. |
| **House** | A sub-guild within a larger guild. Houses compete against each other for points. |
| **Team** | A grouping of houses (e.g., Aldor vs. Scryer). Used for content that requires more players than a single house. |
| **GM** | Guild Master. The player with administrative control over the guild's Hardcore Plus settings. |
| **MVA** | Minimum Viable Addon. The smallest feature set that is useful and testable. |
| **Ruleset** | A complete configuration of hard and soft rules that defines how Hardcore Plus behaves for a guild. |
| **Soft Rule** | A rule that can be toggled or configured by the GM. |
| **Hard Rule** | A rule that is immutable and defines the core identity of a mode. |
| **Companion App** | A desktop application that bridges the WoW addon and the web backend by reading SavedVariables and sending data via HTTPS. |
| **SavedVariables** | WoW's persistence mechanism. Lua tables written to disk that survive between sessions. |
| **HMAC-SHA256** | A cryptographic signing method used to verify data integrity between the companion app and backend. |
| **AceAddon** | A popular WoW addon framework library that provides module management, event handling, and UI components. |
| **CMaNGOS** | Continued MaNGOS. An open-source WoW server emulator used for development and testing. |
| **OF3** | OnlyFangs 3. A large-scale community hardcore event organized by Sodapoppin and NMP. |
| **BiS** | Best in Slot. The optimal gear piece for a specific equipment slot and class/spec combination. |
| **Draft** | A system where house leaders take turns selecting players for their roster, similar to sports drafts. |
| **Micro-Achievement** | A small, specific accomplishment that awards a modest number of points. Thousands of these exist. |

---

## Appendix A: Estimated Timeline Summary

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 0: Final Draft Concept | 1-2 weeks | Week 2 |
| Phase 1: PoC - Basic WoW Menu | 1-2 weeks | Week 4 |
| Phase 2: Tracking Library | 2-3 weeks | Week 7 |
| Phase 3: PoC - Guild Communication | 2-3 weeks | Week 10 |
| Phase 4: Website Voting Feature | 1-2 weeks | Week 12 |
| Phase 5: Rudimentary HC Addon | 3-4 weeks | Week 16 |
| Phase 6: Alpha to Beta | 4-6 weeks | Week 22 |
| Phase 7: Playtesting | 2-4 weeks | Week 26 |
| Phase 8: Launch Preparation | 2 weeks | Week 28 |

**Total estimated development time: 18-28 weeks (4.5-7 months)**

*Note: These estimates assume a small team (2-3 developers) working part-time. Full-time development could compress the timeline significantly. Estimates include buffer for unexpected challenges.*

---

## Appendix B: Technology Stack Summary

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| WoW Addon | Lua 5.1 (TBC 2.4.3 API) | Required by WoW client |
| Addon Libraries | Ace3 (AceAddon, AceDB, AceGUI, AceComm, AceSerializer, AceEvent, AceTimer) | Industry standard for WoW addons |
| Companion App | Electron (Node.js + Chromium) | Cross-platform, mature ecosystem |
| Backend Runtime | Node.js (Express) | Fast development, async I/O, JavaScript across stack |
| Database | MongoDB (initial), PostgreSQL (future option) | Flexible schema for rapid iteration |
| Web Dashboard | React 18 + TypeScript + Tailwind CSS | Modern, performant, large ecosystem |
| Real-time | Socket.io (WebSocket) | Bidirectional communication for live updates |
| Authentication | JWT + HMAC-SHA256 | Stateless auth + payload integrity |
| CI/CD | GitHub Actions | Free for open-source, good integration |
| Hosting | VPS (initial), AWS/GCP (scaling) | Cost-effective start, scalable path |

---

*This document is the single source of truth for the Hardcore Plus project. All development decisions should reference this plan. Updates to this document require team consensus and version incrementing.*

*Document version: 1.0-DRAFT | Last updated: 2026-03-10*
