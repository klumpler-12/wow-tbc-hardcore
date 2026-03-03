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
2. **Gear Battle** duels — completely novel mechanic
3. **Scoring/leaderboard system** — no competitor has competitive scoring
4. **Community voting on rules** — democratic rule-setting
5. **Configurable penalties** — not one-size-fits-all

## WoW Addon Development (Lua API)
- **Language:** Lua 5.1 subset
- **Key API Events for Death Tracking:**
  - `COMBAT_LOG_EVENT_UNFILTERED` — all combat events
  - `PLAYER_DEAD` — player death event
  - `PLAYER_UNGHOST` — resurrection
  - `GUILD_ROSTER_UPDATE` — guild roster changes
  - `DUEL_REQUESTED` / `DUEL_FINISHED` — duel events (for Gear Battle)
- **Key Functions:**
  - `UnitIsDead("player")` — check if player is dead
  - `DeleteCursorItem()` — delete item on cursor (for gear deletion / Gear Battle)
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
  - Track duel outcomes
  - Send/receive messages between addon users
  - Manage guild kicks
  - Store data in SavedVariables
  - Display custom UI frames

## Testing Environment (Future)
- **Private TBC Server**: Use AzerothCore + TBC module or CMaNGOS-TBC for local testing
- **Setup:** Docker container on Pi with TBC server, connect via WoW 2.4.3 client
- **Purpose:** Test addon without risking real account/character
- **Note:** For development/testing ONLY, never for public use

## Design Reference
- Using unique Outland-inspired theme (NOT copying wowclassic.plus)
- Deep void blacks (#08070d), portal purples (#9b59f0), fel-greens (#39ff14), ember-oranges (#ff6b2b)
- Cinzel (display) + Inter (body) fonts
- Glassmorphism cards, particle effects, scroll reveal animations
