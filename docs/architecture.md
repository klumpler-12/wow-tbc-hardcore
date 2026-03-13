# Technical Architecture

---

## WoW Addon (Lua 5.1 / TBC 2.4.3 API)

### Directory Structure

```
HardcorePlus/
├── HardcorePlus.toc
├── Core.lua                      -- Initialization, event bus, slash commands, module loader
├── Constants.lua                 -- Static data (zone IDs, boss names, achievement defs)
├── Utils.lua                     -- Shared utilities
│
├── Tracking/
│   ├── DeathTracker.lua
│   ├── MobTracker.lua
│   ├── MoveTracker.lua
│   ├── TradeTracker.lua
│   ├── DungeonTracker.lua
│   ├── GearTracker.lua
│   └── FishingTracker.lua
│
├── Rules/
│   ├── RuleEngine.lua
│   ├── Rulesets.lua
│   ├── Enforcement.lua
│   └── Violations.lua
│
├── Scoring/
│   ├── ScoreEngine.lua
│   ├── Achievements.lua
│   ├── Leaderboard.lua
│   └── Normalization.lua
│
├── Social/
│   ├── Communication.lua
│   ├── Protocol.lua
│   ├── Houses.lua
│   ├── GuildSync.lua
│   └── Draft.lua
│
├── Gameplay/
│   ├── Punishments.lua
│   ├── Rewards.lua
│   └── MiniGames.lua
│
├── UI/
│   ├── MainPanel.lua
│   ├── ScorePanel.lua
│   ├── DeathLog.lua
│   ├── LeaderboardPanel.lua
│   ├── HousePanel.lua
│   ├── DraftPanel.lua
│   ├── MiniGamePanel.lua
│   ├── Alerts.lua
│   └── Widgets.lua
│
├── Libs/                         -- Ace3 + community libraries
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
    ├── BossData.lua
    ├── AchievementData.lua
    ├── DungeonData.lua
    └── ZoneData.lua
```

### Key Technical Decisions

- **Event Bus Pattern:** All modules communicate through AceEvent. Decouples modules and eases testing.
- **Module Lifecycle:** Each module has `OnInitialize()` and `OnEnable()`. Modules can be individually disabled.
- **SavedVariables:** AceDB-3.0 with per-character profiles for tracking, global profile for settings/rulesets.
- **Memory Management:** Table recycling and object pools for frequently created/destroyed structures.
- **Combat Log Parsing:** Single `COMBAT_LOG_EVENT_UNFILTERED` registration in Core.lua, subevent routing to tracker modules.

---

## Companion App (Electron)

Bridges WoW addon (no HTTP) and web backend.

### Data Flow

1. Addon writes to `SavedVariables/HardcorePlus.lua` on logout/zone change/timer
2. Companion app detects file change via `fs.watch`
3. DataParser converts Lua tables to JSON
4. SyncManager calculates diff against last sync
5. ApiClient sends diff to backend with HMAC-SHA256 signature
6. Backend validates, processes, updates leaderboards

### Security

- HMAC-SHA256 per-user signing on every payload
- Rate-limited to 1 sync/minute minimum
- Backend validates data consistency (e.g., level 20 cannot have killed Gruul)

---

## Backend (Node.js / Express)

### Database Schema (Key Collections)

- **players**: name, server, class, race, level, score, fraction, guild, status, timestamps
- **deaths**: player ref, timestamp, zone, level, killer, cause, overkill, verified
- **scores**: player ref, timestamp, source, points, metadata
- **guilds**: name, server, ruleset, fractions, members, settings, premium status
- **houses**: name, guild ref, team, leader, officers, members, scores
- **votes**: poll ref, voter, choice, timestamp
- **achievements**: player ref, achievement ID, timestamp, verified

---

## Web Dashboard (React 18 + TypeScript)

### Stack

- React 18 + TypeScript
- TanStack Query for server state
- Tailwind CSS
- React Router
- Chart.js/Recharts for visualizations
- Socket.io for real-time updates

### Key Routes

| Route | Page |
|-------|------|
| `/` | Landing / feature overview |
| `/dashboard` | Guild overview + GM actions |
| `/leaderboard` | Player/fraction rankings |
| `/player/:id` | Player profile |
| `/rules` | Ruleset editor |
| `/houses` | Fraction management |
| `/draft` | Draft interface |
| `/punishments` | Punishment designer |
| `/rewards` | Reward designer |
| `/voting` | Active polls |
| `/analytics` | Deep-dive statistics |

---

## Technology Stack Summary

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| WoW Addon | Lua 5.1 (TBC 2.4.3 API) | Required by WoW client |
| Addon Libs | Ace3 suite | Industry standard |
| Companion App | Electron | Cross-platform, mature |
| Backend | Node.js / Express | Async I/O, JS across stack |
| Database | MongoDB (initial) → PostgreSQL | Flexible schema for iteration |
| Dashboard | React 18 + TS + Tailwind | Modern, performant |
| Real-time | Socket.io | Bidirectional live updates |
| Auth | JWT + HMAC-SHA256 | Stateless auth + integrity |
| CI/CD | GitHub Actions | Free for open-source |
| Hosting | VPS (initial) → AWS/GCP | Cost-effective, scalable |
