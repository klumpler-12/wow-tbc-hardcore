# Dependency Map

Technical and module dependencies for TBC Hybrid Hardcore.

_Last updated: 2026-03-17_

---

## Load Order (Critical — .toc file)

Files load top-to-bottom. Any file can reference anything loaded before it, but NOT after it.

```
1. LibStub                          ─── Foundation
2. CallbackHandler-1.0              ─── Event infrastructure
3. AceAddon-3.0                     ─── Addon registration
4. AceDB-3.0                        ─── Database persistence
5. AceEvent-3.0                     ─── Event bus
6. AceTimer-3.0                     ─── Timer scheduling
7. ChatThrottleLib                   ─── Network rate limiting
8. AceComm-3.0                      ─── Network messaging
9. AceSerializer-3.0                ─── Data serialization
10. AceGUI-3.0 (.xml → all widgets) ─── UI framework
11. AceConfigRegistry-3.0           ─── Settings registry
12. AceConfigCmd-3.0                ─── Slash command settings
13. AceConfigDialog-3.0             ─── Settings dialog
14. AceConfig-3.0                   ─── Settings master
15. AceConsole-3.0                  ─── Console commands
16. LibDataBroker-1.1               ─── Minimap data
17. LibDBIcon-1.0                   ─── Minimap button
───────────────────────────────────────────────────
18. Constants.lua                   ─── Enums, defaults, colors
19. Compat.lua                      ─── TBC 2.4.3 API polyfills
20. Utils.lua                       ─── Utility functions
21. Core.lua                        ─── Main addon, event registration
───────────────────────────────────────────────────
22. Systems/Registration.lua        ─── Character registration
23. Systems/Checkpoint.lua          ─── Checkpoint tokens
24. Systems/SoftReset.lua           ─── Soft reset wizard
───────────────────────────────────────────────────
25. Tracking/DeathTracker.lua       ─── Death detection (core)
26. Tracking/UptimeTracker.lua      ─── /played gap detection (core)
27. Tracking/VerificationTracker.lua ── SoI + hash verification (core)
28. Tracking/InstanceTracker.lua    ─── Instance lives (core)
29-37. Tracking/*Tracker.lua        ─── Plugin trackers (9 modules)
───────────────────────────────────────────────────
38. Network/Protocol.lua            ─── Message routing
39. Network/Heartbeat.lua           ─── Peer heartbeats
40. Network/Verification.lua        ─── Peer verification
───────────────────────────────────────────────────
41. UI/MinimapButton.lua            ─── Minimap icon
42-51. UI/*.lua                     ─── All UI panels (10 modules)
```

---

## Module Dependency Graph

```
Constants.lua ◄──── Everything reads constants
     │
     ▼
Compat.lua ◄─────── Everything uses polyfills
     │
     ▼
Utils.lua ◄──────── GetPlayerKey(), IsSystemEnabled(), FormatTimestamp()
     │                 Used by: Core, all Systems, all Tracking, all Network, all UI
     ▼
Core.lua ◄────────── Central hub
     │                 Provides: HardcorePlus addon object, db access, event bus
     │                 Used by: Everything
     │
     ├──► Registration.lua ─── Depends on: Core, Utils
     │         │
     │         └──► SetupWizard.lua (UI) ─── Depends on: Registration, Compat
     │
     ├──► DeathTracker.lua ─── Depends on: Core, Utils, Compat (CLEU)
     │         │
     │         ├──► InstanceTracker.lua ─── Depends on: DeathTracker events, Compat (GetInstanceInfo)
     │         │         │
     │         │         └──► LivesPanel.lua (UI) ─── Depends on: InstanceTracker
     │         │
     │         ├──► Checkpoint.lua ─── Depends on: DeathTracker events
     │         │
     │         ├──► VerificationTracker.lua ─── Depends on: DeathTracker events
     │         │
     │         └──► DeathMonitor.lua (UI) ─── Depends on: DeathTracker events
     │
     ├──► UptimeTracker.lua ─── Depends on: Core (ChatFrame_DisplayTimePlayed hook)
     │
     ├──► SoftReset.lua ─── Depends on: Core, Utils, Registration
     │         │
     │         └──► SoftResetPanel.lua (UI) ─── Depends on: SoftReset
     │
     ├──► Network/Protocol.lua ─── Depends on: Core, AceComm, AceSerializer, Compat (IsInGroup)
     │         │
     │         ├──► Heartbeat.lua ─── Depends on: Protocol
     │         │
     │         └──► Verification.lua (Net) ─── Depends on: Protocol
     │
     └──► All Plugin Trackers ─── Depend on: Core, Utils (IsSystemEnabled)
           (GoldTracker, KillTracker, TradeTracker, MailTracker,
            AHTracker, DistanceTracker, ProfessionTracker,
            EquipmentTracker, LootTracker)
```

---

## Event Bus (AceEvent Messages)

Internal addon events and their producers/consumers:

| Event | Producer | Consumer(s) |
|-------|----------|-------------|
| HCP_PLAYER_DEATH | DeathTracker | VerificationTracker, InstanceTracker, Checkpoint, DeathMonitor, Network/Verification |
| HCP_INSTANCE_ENTERED | InstanceTracker | LivesPanel |
| HCP_INSTANCE_LEFT | InstanceTracker | LivesPanel |
| HCP_INSTANCE_DEATH_RESOLVED | InstanceTracker | VerificationTracker, LivesPanel |
| HCP_STATUS_CHANGED | VerificationTracker, Registration | MainPanel, StatusDisplay, all UI |
| HCP_ADDON_GAP_DETECTED | UptimeTracker | VerificationTracker, StatusDisplay |
| HCP_PEER_UPDATED | Heartbeat | NetworkPanel |
| HCP_PEER_OFFLINE | Heartbeat | NetworkPanel |
| HCP_REGISTRATION_COMPLETE | Registration | Core, SetupWizard |
| HCP_SOFT_RESET_STARTED | SoftReset | SoftResetPanel, UptimeTracker |
| HCP_SOFT_RESET_COMPLETE | SoftReset | Registration, VerificationTracker |
| HCP_CHECKPOINT_CLAIMED | Checkpoint | SetupWizard |

---

## WoW API Dependencies (via Compat.lua)

| API Function | Used By | TBC 2.4.3 Status | Polyfill |
|-------------|---------|-------------------|----------|
| CombatLogGetCurrentEventInfo() | DeathTracker, KillTracker | NOT AVAILABLE (BFA 8.0+) | StoreCLEUArgs() normalizes TBC→modern format |
| BackdropTemplate (mixin) | All UI files (18 occurrences) | NOT AVAILABLE (SL 9.0+) | CreateBackdropFrame() with SetBackdrop() |
| IsInGroup() | Protocol.lua | NOT AVAILABLE (MoP 5.0+) | Maps to GetNumPartyMembers()>0 or GetNumRaidMembers()>0 |
| IsInRaid() | Protocol.lua | NOT AVAILABLE (MoP 5.0+) | Maps to GetNumRaidMembers()>0 |
| GetNumGroupMembers() | Protocol.lua | NOT AVAILABLE (MoP 5.0+) | Sums party+raid members |
| C_Map.GetBestMapForUnit() | Utils.lua | NOT AVAILABLE (modern) | Returns 0 (stub) |
| GetInstanceInfo() | Utils.lua, InstanceTracker | NOT AVAILABLE (WotLK 3.2.0+) | Uses GetRealZoneText()+GetInstanceDifficulty() |
| SetColorTexture() | SetupWizard, MainPanel, AceGUI | NOT AVAILABLE (Legion 7.0.3+) | Texture metatable patch → SetTexture(r,g,b,a) |

---

## External Dependencies

| Component | Version | Purpose | Source |
|-----------|---------|---------|--------|
| WoW TBC Client | 2.4.3 (Interface 20400) | Runtime environment | Private server |
| Ace3 Framework | Latest TBC-compatible | Addon infrastructure | wowace.com |
| LibStub | 1.0 | Library versioning | Bundled |
| LibDataBroker | 1.1 | Minimap data provider | Bundled |
| LibDBIcon | 1.0 | Minimap button renderer | Bundled |
| ChatThrottleLib | — | Network rate limiting | Bundled with AceComm |

### Future Dependencies (Phase 1+)

| Component | Version | Purpose | Status |
|-----------|---------|---------|--------|
| Node.js | 18+ LTS | Backend server | PENDING (DEC-P01) |
| Express | 4.x | HTTP framework | PENDING |
| MongoDB or PostgreSQL | Latest | Database | PENDING (DEC-P01) |
| Electron or Tauri | Latest | Companion app | PENDING (DEC-P03) |
| React | 18 | Web dashboard | DEFERRED (Phase 3+) |
| Socket.io | 4.x | Real-time updates | DEFERRED (Phase 3+) |

---

## Data Flow Summary

```
WoW Client (TBC 2.4.3)
  │
  ├──► Addon (Lua 5.1)
  │      ├── SavedVariables (WTF/Account/.../HardcorePlusDB.lua)
  │      └── AceComm (GUILD/PARTY/WHISPER channels)
  │
  ├──► [Future] Companion App (Electron/Tauri)
  │      ├── File watcher (SavedVariables → JSON diff)
  │      ├── HMAC-SHA256 signing per payload
  │      └── REST API sync (rate limited: 1/min)
  │
  └──► [Future] Backend (Node.js/Express)
         ├── REST API (JWT auth)
         ├── Database (MongoDB/PostgreSQL)
         └── [Future] Web Dashboard (React 18 + Socket.io)
```

---

_Cross-reference: See TESTAMENT.md for data structure definitions, architecture.md for tech stack details._
