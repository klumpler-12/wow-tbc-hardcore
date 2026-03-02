# WoW TBC Hardcore Addon - Research Notes
**Created:** 2026-03-03
**Last Updated:** 2026-03-03

## OnlyFangs 3 Event
- **Game:** WoW TBC (Burning Crusade)
- **Led by:** Sodapoppin; Tyler1 possibly involved
- **Timeline:** TBC Pre-Patch Jan 13 2026, Full Launch Feb 5 2026; OF3 starts LATER in TBC lifecycle (multiple raids available)
- **Death Rules Under Discussion:** Permadeath, restart from 58, gear-loss options
- **58 Boost:** Possibly allowed for alts
- **Goal:** Avoid "stale gaps" that plagued previous Classic progression

## Competitive Landscape (Existing Addons)
### Guild Death Log (CurseForge)
- Auto-tracks guild member deaths (name, level, class, zone, timestamp, killer)
- Guild-wide sync (auto + manual)
- TBC compatible
- Memorial book-style UI
- Stats by zone/level/class/cause
- Milestones/titles/achievements/Hall of Fame
- Compatible with "Deathlog" addon

### Deathlog (CurseForge)
- Death log UI + statistics
- Classic Era HC + TBC Anniversary Soul of Iron compatible
- Faction-wide death notifications (configurable guild-only)

### Key Gap in Market
- **No addon offers multi-mode HC** (hardcore/softcore/scoring)
- **No community voting system** for rule-sets
- **No scoring/leaderboard system** for events
- **No gear deletion or SSF enforcement** as penalty tiers

## WoW Addon Development (Lua API)
- **Language:** Lua 5.1 subset
- **Key API Events for Death Tracking:**
  - `COMBAT_LOG_EVENT_UNFILTERED` — all combat events
  - `PLAYER_DEAD` — player death event
  - `PLAYER_UNGHOST` — resurrection
  - `GUILD_ROSTER_UPDATE` — guild roster changes
- **Key Functions:**
  - `UnitIsDead("player")` — check if player is dead
  - `DeleteCursorItem()` — delete item on cursor (for gear deletion)
  - `PickupInventoryItem(slot)` — pick up equipped item
  - `GuildRemove(name)` / `GuildUninvite(name)` — remove from guild
  - `SendAddonMessage(prefix, msg, type, target)` — addon-to-addon comms
  - `C_ChatInfo.RegisterAddonMessagePrefix(prefix)` — register prefix
- **Cannot Programmatically:**
  - Delete a character (no API for this, Blizzard-only)
  - Force char transfer
  - Access other players' inventory directly
- **Can Do:**
  - Track deaths via combat log
  - Delete player's own items (with user interaction / cursor)
  - Send/receive messages between addon users
  - Manage guild kicks
  - Store data in SavedVariables
  - Display custom UI frames

## Design Reference (wowclassic.plus)
- **BG Color:** #0e1115 (deep midnight blue/black)
- **Primary Accent:** #FFCC00 (WoW gold)
- **CTA:** #CC3333 (Horde red gradient) + gold text
- **Text:** Pure white headings, muted white body (rgba 255,255,255,0.7)
- **Heading Font:** Friz Quadrata (WoW brand font) — use LifeCraft or similar free alternative
- **Body Font:** Montserrat or similar modern sans-serif
- **Layout:** Hero + video embed → Card pillars → Survey progress cards → Community results charts
- **Effects:** High negative space, parchment textures, stone/gear corner assets, glassmorphism on cards

## Technical Constraints
- TBC client API is a subset of modern WoW API
- No server-side code possible — all addon logic is client-side
- Inter-player communication via addon messages (guild/raid/party channels)
- Data persistence via SavedVariables (per-character or per-account)
- Character deletion NOT possible via addon — must use alternative penalties
