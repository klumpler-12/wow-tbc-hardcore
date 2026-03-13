# WoW TBC Addon Development Environment Research
**Date:** 2026-03-04

## Goal
Set up a safe, local development environment to build and test a TBC Hardcore addon (Lua) without risking any Blizzard ToS violations or account bans.

## Key Findings

### 1. Server Emulator Options (TBC 2.4.3)
| Emulator | TBC Support | Docker? | macOS? | Community |
|---|---|---|---|---|
| **CMaNGOS TBC** | ✅ Native (best accuracy) | ✅ Docker Compose | ✅ | Active, stable |
| TrinityCore TBC | ⚠️ Via fork (TrinityTBC) | ✅ | ✅ | Moderate |
| AzerothCore | ⚠️ Primarily WotLK | ✅ | ✅ | Very active but wrong expansion |

**Winner: CMaNGOS TBC via Docker** — best TBC accuracy, easy Docker setup, works on macOS.

### 2. ToS & Safety Analysis
- **Private servers are legally gray for operators**, not addon devs
- **Key rules to stay safe:**
  - NEVER connect a retail WoW client to a private server
  - Use a completely separate TBC 2.4.3 client (not your retail install)
  - NEVER run retail WoW and private server client simultaneously
  - Use a burner email for any server registration
  - All development happens locally on your machine — no public server hosting
  - The addon code itself (Lua) is not a ToS violation; it uses public Blizzard API
- **Blizzard primarily targets server hosts, not individual devs or players**
- When the addon is ready for production, it targets the official Classic TBC servers, using only sanctioned Blizzard addon APIs

### 3. What You Need
- **TBC 2.4.3 Client** — download from archive sources (not from Blizzard)
- **CMaNGOS TBC Docker** — runs the server locally
- **macOS** — fully supported via Docker Desktop
- **VS Code + Lua extension** — for addon development
- **GM commands** — for quickly testing scenarios (teleport, spawn, level up, kill, etc.)

### 4. Addon Structure (WoW TBC)
```
Interface/AddOns/TBCHardcore/
├── TBCHardcore.toc          # Addon manifest
├── Core.lua                 # Main logic (event hooks)
├── UI.lua                   # Frame definitions
├── Config.lua               # SavedVariables defaults
└── Locales/
    ├── enUS.lua
    └── deDE.lua
```

### 5. Key Blizzard API Events for HC Addon
- `COMBAT_LOG_EVENT_UNFILTERED` — death tracking
- `UNIT_DIED` — unit death detection
- `PLAYER_DEAD` — player death
- `PLAYER_LEVEL_UP` — level tracking
- `GROUP_ROSTER_UPDATE` — party/group changes (anti-boost)
- `CHAT_MSG_ADDON` — cross-addon communication

### 6. Testing Workflow
1. Start CMaNGOS TBC Docker containers
2. Launch separate TBC 2.4.3 client, realmlist → 127.0.0.1
3. Log in with GM account
4. Place addon in client's `Interface/AddOns/`
5. Use `/reload` to hot-reload after code changes
6. Use GM commands for test scenarios (`.die`, `.levelup`, `.additem`, `.teleport`)

### Status
- [x] Research completed (2026-03-04)
- [ ] CMaNGOS TBC Docker setup on Raspi or local Mac
- [ ] TBC 2.4.3 client acquisition
- [ ] First POC addon with functional button
