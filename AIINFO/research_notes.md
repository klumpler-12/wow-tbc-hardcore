# WoW TBC Hardcore Addon - Research Notes
**Created:** 2026-03-03
**Last Updated:** 2026-03-03

## OnlyFangs 3 Event
- **Game:** WoW TBC (Burning Crusade)
- **Event type:** Community hardcore challenge event, starts later in TBC lifecycle (multiple raids available)
- **Death Rules Under Discussion:** Permadeath, restart from 58, gear-loss options
- **58 Boost:** Possibly allowed for alts
- **Goal:** Avoid "stale gaps" that plagued previous Classic progression

## Competitive Landscape — TBC Addons Updated 2026
### Direct Competitors (HC/Death Tracking)
| Addon | Last Updated | Key Features | Gap vs Our Addon |
|---|---|---|---|
| **HardcoreTBC** | Jan 2026 | Death=delete, guild-only trade, AH ban, rule auditing | No multi-mode, no scoring, no Gear Battle |
| **Deathlog** | 2026 (TBC Anniversary) | Death UI/stats, faction-wide notifs, Soul of Iron support | Tracking only, no penalties, no scoring |
| **DeathRecap TBC** | Feb 2026 | Retail-style death recap, CC tracking for PvP | Only shows HOW you died, no consequences |
| **ActionTracker** | Feb 2026 | Passive stats: deaths, damage, kills | Generic tracker, no HC rules |
| **Hardcore (base addon)** | Active | Death reports, guild chat, mailbox/AH block | Classic-only focus, rigid rules |
| **Guild Death Log** | Active | Memorial UI, zone/class stats, Hall of Fame | No penalty system, no modes |

### Adjacent Addons (PvP/Duel)
| Addon | Features |
|---|---|
| **Gladdy / sArena** | Arena frames, enemy CDs, DRs |
| **OmniBar** | Enemy cooldown tracking |
| **BigDebuffs** | Large CC icons on unit frames |
| **Diminish** | DR tracking |

### Utility Addons (TBC 2026 Updated)
- AtlasLoot TBC Anniversary, Leatrix Plus (Feb 2026), Questie, Bagnon, Details! (Mar 2026), WeakAuras, DBM/BigWigs, Plater (Mar 2026)

### Our Competitive Edge
1. **Multi-mode HC** (Classic/Plus/Softcore/Nullcore) — NO other addon does this
2. **Gear Battle** duels (optional) — completely novel mechanic
3. **Scoring/leaderboard system** — no competitor has competitive scoring
4. **Community voting on rules** — democratic rule-setting
5. **Configurable penalties** — not one-size-fits-all
6. **Backend verification layer** — two-step anti-cheat (planned)
7. **Desktop/browser setup** — no in-game config needed (planned)
8. **Discord integration** — event management + notifications (planned)

## Anti-Cheat & Verification Research (2026-03-03)
### The Gear Restoration Problem
- **Blizzard's Item Restoration** allows players to recover destroyed/vendored items via web service (once every 24h per character)
- This is a **direct cheating vector** — players penalized with gear deletion can just restore items
- **Countermeasures:**
  1. **Inventory Hash Snapshots:** Addon stores hashed inventory state at penalty time → periodically re-checks if "deleted" items reappear
  2. **Cross-verification:** Guild members' addons verify each other's gear state
  3. **Backend verification:** External companion app can log gear states with timestamps, making restoration detectable
  4. **Social enforcement:** Public flagging + guild notification if suspiciously "restored" gear detected

### Offline Verification (addon not running)
- **SavedVariables persist** between sessions → addon can check last-known state on login
- **Cannot track what happened while addon was off** — but can detect discrepancies (e.g., "dead" player has new gear)
- **Backend companion app** can monitor SavedVariables file on disk even when WoW is closed
- **Verification flow:** Backend reads SavedVariables → compares against known states → flags anomalies

### Backend Communication Architecture
- **WoW addons CANNOT make HTTP requests** — sandboxed environment, no network access
- **Solution: Companion App Pattern:**
  1. Addon writes data to SavedVariables (persisted to disk)
  2. Companion app (runs on player's PC) watches SavedVariables file
  3. Companion app sends data to backend API (REST)
  4. Backend responds by writing data back to a file addon can read
  5. On next login/reload, addon reads the response file
- **Real-time:** NOT truly real-time, but near-real-time if companion polls frequently
- **Alternative for tournaments:** Require companion app running before WoW launch, acts as gatekeeper

### Two-Step Verification (Tournament Mode)
1. Player launches companion app → app generates session token
2. App writes token to addon's SavedVariables
3. Player launches WoW → addon reads token and validates
4. Addon starts transmitting gear/death/score data via SavedVariables
5. Companion app reads and posts to backend
6. Backend cross-references, detects anomalies, flags cheaters
- **Optional layer** — only for tournaments or competitive events requiring integrity

## WoW Addon Development (Lua API)
- **Language:** Lua 5.1 subset
- **Key API Events:**
  - `COMBAT_LOG_EVENT_UNFILTERED` — all combat events
  - `PLAYER_DEAD` — player death event
  - `PLAYER_UNGHOST` — resurrection
  - `GUILD_ROSTER_UPDATE` — guild roster changes
  - `DUEL_REQUESTED` / `DUEL_FINISHED` — duel events (Gear Battle)
  - `PLAYER_EQUIPMENT_CHANGED` — gear swap detection
  - `BAG_UPDATE` — inventory changes
- **Key Functions:**
  - `UnitIsDead("player")` — check dead
  - `DeleteCursorItem()` — delete item on cursor
  - `PickupInventoryItem(slot)` — pick up equipped item
  - `GetInventoryItemLink(unit, slot)` — get item link for inventory snapshot
  - `GetContainerItemLink(bag, slot)` — get bag item link
  - `GuildRemove(name)` / `GuildUninvite(name)` — guild management
  - `SendAddonMessage(prefix, msg, type, target)` — inter-addon comms
  - `C_ChatInfo.RegisterAddonMessagePrefix(prefix)` — register prefix
- **Cannot Programmatically:**
  - Delete a character
  - Make HTTP requests
  - Access filesystem
  - Force client actions without user interaction

## Brainstorm / Ideas
### PvP Integration Ideas
- PvP deaths ≠ PvE deaths — different penalty tiers
- **Bounty system:** Killing a high-score player earns bounty points
- **Honor-based penalties:** Lose honor points on death instead of gear
- **Temporary gear lock:** PvP death locks gear upgrades for X minutes
- **Arena-style rating:** Separate PvP leaderboard with ELO-like scoring
- **Flagged zones:** Certain zones have different PvP death rules

### Item Unlock System
- Score milestones unlock access to gear tiers
- "You must earn X points before equipping Epic items"
- Addon enforces by monitoring equip events and warning/unequipping
- Creates progression within the HC experience

### Desktop/Browser Setup
- Web dashboard for configuration (modes, rules, guild settings)
- Leaderboard viewer accessible from browser
- No need to be in-game to manage addon settings
- Settings sync via companion app → SavedVariables

### Discord Integration
- Bot sends death notifications to guild Discord
- Leaderboard updates posted periodically
- Event scheduling / tournament management
- /commands for checking player stats

## Testing Environment
- **Private TBC Server**: AzerothCore + TBC module or CMaNGOS-TBC
- **Setup:** Docker container on Pi, connect via WoW 2.4.3 client
- **Purpose:** Safe testing without risking real account/character
- **Status:** Not yet set up — planned for Phase 6

## External Resources
- **Podcast:** "Punching Down episode 32 podcast discussion about tbc hc" (Valuable context regarding community sentiment and TBC HC rulesets)
