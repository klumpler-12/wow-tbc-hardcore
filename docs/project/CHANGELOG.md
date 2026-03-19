# Changelog

All notable changes to TBC Hybrid Hardcore are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Version scheme: MAJOR.MINOR.PATCH-tag (e.g. 0.1.0-alpha).

---

## [Unreleased] — Phase 0.5 Queue

### Planned
- Wire all 9 plugin tracker modules (kills, gold, trades, mail, AH, distance, professions, equipment, loot)
- Performance benchmark pass (target: <2 MB memory, no measurable FPS drop)
- Validate Compat.lua polyfills on target CMaNGOS server
- UI visual refinement (color matching, spacing consistency)

---

## [0.1.0-alpha] — 2026-03-17

Initial pre-alpha release. All core systems functional for 2–3 player testing.

### Added
- **Core framework:** AceAddon-3.0, AceDB-3.0, AceEvent-3.0, AceTimer-3.0, AceComm-3.0, AceSerializer-3.0, AceConsole-3.0
- **Death tracking:** CLEU-based death detection with 5s debounce, open world vs instance discrimination, recent damage log (last 5 hits), death monitor widget
- **Status state machine:** PENDING → UNVERIFIED → VERIFIED → TARNISHED → DEAD → SOFT_RESET / LATE_REG
- **Setup wizard:** 4-step registration (freshness check, trade mode, instance lives, confirmation), late registration path for progressed characters
- **Checkpoint system:** Token generation on permadeath (level 58+), 24h expiry, cross-character claim via wizard
- **Instance lives:** +1 bonus life per qualifying heroic/raid, 14 heroics + 7 raids in bonus list, weekly pool (default 10), permadeath on 0 lifes
- **Soft reset:** Eligibility check (SSF/GF, 58+, checkpoint enabled), inventory strip verification (bags, bank, gold, professions, talents, quests), 2h /played completion window
- **Uptime/gap detection:** Silent /played polling every 2 min, gap analysis (15 min grace), minor/major violation classification, weekly violation limit (5/week)
- **Verification tracking:** Soul of Iron buff scan every 30s, inventory hash snapshots, gold/equipment/profession change detection
- **Instance tracking:** Zone change detection, instance entry/exit events, bonus life calculation per instance
- **Network (experimental):** Heartbeat broadcast every 60s via GUILD/PARTY, peer registry with 5 min timeout, death event broadcast, hash comparison, message dedup
- **UI:** Main panel with 5 tabs (Overview, Deaths, Lifes, Network, Flags), minimap skull button (LDB + LibDBIcon), settings panel (AceConfig), death monitor widget, lives panel, network panel, checkpoint panel, soft reset wizard, debug panel with 17 system toggles
- **Slash commands:** /hcp show, status, deaths, lives, monitor, config, debug, checkpoint, reset
- **Compat layer (Compat.lua):** 6 polyfills for TBC 2.4.3 — CLEU arg normalization, BackdropTemplate helper, group API (IsInGroup/IsInRaid/GetNumGroupMembers), C_Map stub, GetInstanceInfo() via GetRealZoneText()+GetInstanceDifficulty(), SetColorTexture() via Texture metatable patch
- **9 plugin tracker module stubs:** GoldTracker, KillTracker, TradeTracker, MailTracker, AHTracker, DistanceTracker, ProfessionTracker, EquipmentTracker, LootTracker — all toggleable via debug panel, all with data caps
- **Debug panel:** 17 system toggles (8 core + 9 tracker plugins), enable/disable all buttons, verbose logging toggle, network stats display

### Fixed
- Interface version corrected from 20504 (Classic Era) to 20400 (TBC 2.4.3)
- CLEU arg format normalized from TBC 8-field to modern 11-field via StoreCLEUArgs()
- BackdropTemplate replaced with CreateBackdropFrame() across all 7 UI files (18 occurrences)
- KillTracker rewritten: proper CLEU arg passing via hidden frame, simplified notable kill detection
- GetInstanceInfo() polyfilled for TBC 2.4.3 (added in WotLK 3.2.0, not available in original TBC)
- SetColorTexture() polyfilled via Texture metatable (added in Legion 7.0.3)
- Protocol stat tracking made consistent across all send functions
- All tracker data tables capped (100–500 entries) to prevent unbounded SavedVariables growth

### Known Issues
- Compat.lua polyfills untested on target CMaNGOS server
- AceGUI-3.0 library files use SetColorTexture internally (3 occurrences) — metatable polyfill should cover but untested
- Instance lives model mismatch between addon (+1 bonus) and website (tiered Easy/Hard/Brutal)
- Peer registry can grow unbounded over months (cleanup planned for Phase 1)
- Weekly pool reset uses local system time, not WoW server reset time

---

## [0.0.1-concept] — 2026-03-12

### Added
- Project concept documentation (TESTAMENT.md, PROJECT_PLAN_REVISED.md)
- Presentation website (static HTML/CSS/JS)
- Competitor analysis
- OnlyFangs 3 requirements mapping
- Monetization model design
- Feature specification documents (10 files covering all planned systems)

---

_Database version: HCP.DB_VERSION = 1_
_Target client: WoW TBC 2.4.3 (Interface 20400)_
