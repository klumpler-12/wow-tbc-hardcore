# Decision Log

Architectural and design decisions for TBC Hybrid Hardcore. Each entry is immutable once recorded — new decisions supersede old ones rather than editing them.

_Last updated: 2026-03-17_

---

## Format

Each decision follows this template:
- **ID:** DEC-NNN
- **Date:** When decided
- **Status:** ACCEPTED / PENDING / SUPERSEDED
- **Context:** Why we needed to decide
- **Decision:** What we chose
- **Alternatives considered:** What else was on the table
- **Consequences:** What follows from this choice

---

## Accepted Decisions

### DEC-001 — Single Hybrid HC Mode
- **Date:** 2026-03-12
- **Status:** ACCEPTED
- **Context:** TBC is too punishing for pure permadeath at endgame (one-shot mechanics in Shattered Halls, raid-wide damage). Multiple mode variants (Pure HC, Softcore HC, etc.) fragment the community and complicate development.
- **Decision:** Single "Hybrid HC" mode with three configurable layers: base ruleset (always active), free customization (SSF toggle, PvP rules), premium customization (guild rulesets, extra lives, fractions).
- **Alternatives:** Multiple separate modes (rejected: fragmenting), pure permadeath only (rejected: endgame unviable), no HC mode and just tracking (rejected: no engagement hook).
- **Consequences:** Every player shares the same base experience. Complexity comes from optional layers, not mode selection. Simpler to test and balance.

### DEC-002 — Instance Lives Model (+1 Bonus)
- **Date:** 2026-03-12
- **Status:** ACCEPTED (implementation) / PENDING (final values)
- **Context:** Permadeath in TBC instances makes endgame impossible. Players need a way to progress through heroics and raids without permanent loss on every death.
- **Decision:** +1 bonus life per qualifying heroic/raid entry. Base = 1 life (die once = permadeath). Bonus = +1 for qualifying instances (die once = life consumed, die twice = permadeath). Weekly pool of 10 as safety net.
- **Alternatives:** Tiered model (Easy 2 / Hard 3 / Brutal 5) shown on website — still under consideration. Fixed lives per instance (rejected: no progression feel).
- **Consequences:** Website currently shows tiered model which does NOT match addon implementation. Decision needed before Phase 2 publicity. See BACKLOG P05-016.

### DEC-003 — Checkpoint at Level 58
- **Date:** 2026-03-12
- **Status:** ACCEPTED
- **Context:** Losing a level 60+ character to permadeath is devastating. Blizzard provides 58 boosts in TBC. Players need a recovery path that doesn't trivialize death.
- **Decision:** Class-wide checkpoint at level 58 (default). On death at 58+: choose Blizzard boost (new 58) or soft reset (strip everything, re-register as HC). Checkpoint must be enabled at registration (immutable).
- **Alternatives:** No checkpoint (rejected: too punishing for TBC endgame), checkpoint at 70 (rejected: too late), multiple checkpoints (deferred to premium).
- **Consequences:** Players commit at registration. Checkpoint + soft reset together create a meaningful "second chance" that preserves the HC spirit. Reputation/flight paths/spells cannot be removed in TBC — accepted as trade-off.

### DEC-004 — Trade Modes (SSF / Guildfound / Open)
- **Date:** 2026-03-12
- **Status:** ACCEPTED
- **Context:** Self-found is a core HC identity marker. Different players want different levels of restriction. Trade mode affects soft reset eligibility and scoring.
- **Decision:** Three trade modes set at registration, immutable forever: SSF (no trading/AH/mail), Guildfound (guild members only), Open (no restrictions).
- **Alternatives:** Single mode with toggle (rejected: abuse potential), no enforcement (rejected: defeats purpose).
- **Consequences:** SSF and GF players eligible for soft reset. Open players are not. Scoring will weight SSF higher (Phase 3+).

### DEC-005 — AceAddon-3.0 Framework
- **Date:** 2026-03-12
- **Status:** ACCEPTED
- **Context:** Need a mature, well-tested addon framework for TBC 2.4.3 private servers. Must handle events, timers, database, networking, settings UI.
- **Decision:** Full Ace3 stack: AceAddon, AceDB, AceEvent, AceTimer, AceComm (+ChatThrottleLib), AceSerializer, AceConsole, AceGUI, AceConfig, LibDataBroker, LibDBIcon.
- **Alternatives:** Custom framework (rejected: reinventing the wheel), lightweight single-lib (rejected: insufficient for project scope).
- **Consequences:** 17 library files in Libs/. Well-documented APIs. Risk: AceGUI-3.0 uses SetColorTexture internally (polyfilled via Compat.lua metatable patch — untested).

### DEC-006 — Compat.lua Polyfill Layer
- **Date:** 2026-03-17
- **Status:** ACCEPTED
- **Context:** TBC 2.4.3 (Interface 20400) is the ORIGINAL TBC client, not TBC Classic. Many modern WoW APIs don't exist. Previous code assumed Classic API availability.
- **Decision:** Centralized Compat.lua loaded between Constants.lua and Utils.lua. Provides 6 polyfills: CLEU arg normalization (TBC 8→modern 11 fields), BackdropTemplate helper, group API (IsInGroup/IsInRaid/GetNumGroupMembers), C_Map stub, GetInstanceInfo() via GetRealZoneText()+GetInstanceDifficulty(), SetColorTexture() via Texture metatable.
- **Alternatives:** Inline checks in every file (rejected: maintenance nightmare), require TBC Classic client (rejected: target is private servers on 2.4.3).
- **Consequences:** All downstream code uses modern field positions unchanged. Single point of maintenance. Must validate every polyfill on target CMaNGOS server (Phase 0 blocker).

### DEC-007 — Modular Plugin Tracker Architecture
- **Date:** 2026-03-17
- **Status:** ACCEPTED
- **Context:** 9 new tracking modules (kills, gold, trades, mail, AH, distance, professions, equipment, loot) risk bloating the addon and making bugs harder to isolate.
- **Decision:** Each tracker is independently toggleable via debug panel. Each checks `HCP.Utils.IsSystemEnabled(key)` before processing. Each has its own data cap (100–500 entries). All store data under `db.char.trackerData.*`.
- **Alternatives:** Monolithic tracker (rejected: impossible to debug), runtime module loading (rejected: TBC Lua limitations).
- **Consequences:** 17 toggle keys in debug panel (8 core + 9 trackers). Any tracker can be disabled without affecting others. Phase labels in debug panel: Core/Net/Trk.

### DEC-008 — "Record Everything, Score Nothing Yet"
- **Date:** 2026-03-12
- **Status:** ACCEPTED
- **Context:** Scoring system is complex and deferred to Phase 3+. But tracking data is needed NOW to have historical records when scoring is implemented.
- **Decision:** All trackers record raw data immediately. No scoring calculations, no point displays, no leaderboard logic until Phase 3+. Data is retrospectively scoreable.
- **Alternatives:** Implement scoring now (rejected: scope creep, blocks April 30 deadline), don't track until scoring is ready (rejected: loses historical data).
- **Consequences:** SavedVariables will grow with tracking data. Data caps prevent unbounded growth. When scoring ships, all existing data can be scored retroactively.

### DEC-009 — Network as Experimental Toggle
- **Date:** 2026-03-17
- **Status:** ACCEPTED
- **Context:** Peer-based verification via AceComm is powerful but complex. Solo play must be fully functional. Network bugs shouldn't block core features.
- **Decision:** Entire network subsystem (Protocol, Heartbeat, Verification) is toggleable via debug panel. Solo play is 100% functional without peers. Network is "experimental" in Phase 0.
- **Alternatives:** Network required (rejected: solo players locked out), no network (rejected: no peer verification possible).
- **Consequences:** Solo auto-promote to UNVERIFIED after 5 min. All network features are additive. Can be disabled entirely for testing isolation.

### DEC-010 — Freemium Monetization Model
- **Date:** 2026-03-12
- **Status:** ACCEPTED
- **Context:** Need sustainable revenue. Must not fragment community or create pay-to-win perception.
- **Decision:** Three tiers: $5/month individual, $15/month guild, $25/month event. Free tier is fully functional (base ruleset, death tracking, scoring, SSF enforcement). Premium adds management tools (custom rulesets, extra lives, fractions, web dashboard, mini-games).
- **Alternatives:** Fully free (rejected: unsustainable), one-time purchase (rejected: no recurring revenue), donations only (rejected: unreliable).
- **Consequences:** Free players always participate fully in base gameplay. Premium is never competitive advantage. Distribution method still PENDING (DEC-P02).

---

## Pending Decisions

### DEC-P01 — Database Technology
- **Date:** —
- **Status:** PENDING
- **Context:** Backend needs persistent storage for player profiles, guild data, leaderboards, scoring.
- **Options:** MongoDB (flexible schema, fast prototyping, JS-native) vs. PostgreSQL (relational integrity, complex queries, proven at scale).
- **Deadline:** Before Phase 1 (Mar 31)
- **Impact:** Backend architecture, query patterns, migration complexity.

### DEC-P02 — Premium Distribution Method
- **Date:** —
- **Status:** PENDING
- **Context:** How do paying users unlock premium features in the addon?
- **Options:** Patreon download + license key, OAuth-gated web login, encrypted unlock file in addon directory, server-side feature flag via companion app.
- **Deadline:** Before Phase 3 (May+)
- **Impact:** Companion app architecture, piracy risk, user experience.

### DEC-P03 — Companion App Technology
- **Date:** —
- **Status:** PENDING
- **Context:** Bridge between addon (no HTTP capability) and backend server.
- **Options:** Electron (proven, larger binary, JS ecosystem) vs. Tauri (smaller, Rust backend, newer).
- **Deadline:** Before Phase 1 (Mar 31)
- **Impact:** Development velocity, binary size, cross-platform support.

### DEC-P04 — Instance Lives Final Model
- **Date:** —
- **Status:** PENDING
- **Context:** Addon implements +1 bonus model. Website shows tiered model (Easy 2, Hard 3, Brutal 5). Must align before public visibility.
- **Options:** Keep +1 bonus (simpler), switch to tiered (more granular), hybrid (base +1, premium configurable tiers).
- **Deadline:** Before Phase 0.5 ends (Mar 30)
- **Impact:** Constants.lua, InstanceTracker.lua, website content, all documentation.

### DEC-P05 — Difficulty Rating Scale
- **Date:** —
- **Status:** PENDING
- **Context:** Heroic dungeons and raids need difficulty ratings for scoring multipliers.
- **Options:** 1–5 scale, 1–10 scale, direct point values.
- **Deadline:** Before Phase 3 (scoring implementation)
- **Impact:** Scoring system, community voting mechanism, Constants.lua values.

---

_Decision IDs are permanent. Superseded decisions reference the replacing decision._
