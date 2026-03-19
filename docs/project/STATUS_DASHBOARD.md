# Project Status Dashboard

At-a-glance project health for TBC Hybrid Hardcore.

_Last updated: 2026-03-17_

---

## Timeline

```
Mar 17          Mar 23    Mar 30         Apr 20    Apr 30
  |── Phase 0 ──|── 0.5 ──|── Phase 1 ───|── P2 ──|
  Pre-Alpha PoC   Clean     Semi-Private    Public
  2-3 players     Rebuild   Alpha 10-20     Alpha
                            testers         CurseForge
  ◄── HERE
```

**Days until Public Alpha:** 44 (April 30, 2026)
**Current Phase:** 0 — Pre-Alpha PoC
**Phase Gate:** Compat.lua validation on CMaNGOS

---

## Phase Status

| Phase | Window | Status | Gate Check |
|-------|--------|--------|------------|
| **0 — Pre-Alpha** | Mar 17–23 | **ACTIVE** | All 6 Compat polyfills validated on CMaNGOS |
| 0.5 — Clean Rebuild | Mar 24–30 | PENDING | 9 tracker modules wired + memory <2 MB |
| 1 — Semi-Private Alpha | Mar 31 – Apr 20 | PENDING | 10-20 testers, full bug-fix cycle |
| 2 — Public Alpha | Apr 21–30 | PENDING | CurseForge listing, hotfix pipeline |
| 3+ — Post-Alpha | May+ | DEFERRED | Web dashboard, houses, scoring |

---

## System Health

### Core Systems (Phase 0 scope)

| System | Implementation | Tested | Compat | Notes |
|--------|:-:|:-:|:-:|-------|
| Death tracking | DONE | NO | WARN | CLEU polyfill untested on CMaNGOS |
| Status state machine | DONE | NO | OK | Pure Lua, no API dependencies |
| Setup wizard | DONE | NO | WARN | BackdropTemplate polyfilled |
| Checkpoint system | DONE | NO | OK | Cross-char token flow |
| Instance lives | DONE | NO | WARN | GetInstanceInfo polyfilled |
| Soft reset | DONE | NO | OK | Inventory/profession checks |
| Uptime/gap detection | DONE | NO | OK | /played based |
| Verification tracking | DONE | NO | OK | SoI buff scan + hash snapshots |
| Instance tracking | DONE | NO | WARN | GetInstanceInfo polyfilled |

### Network (Experimental)

| System | Implementation | Tested | Notes |
|--------|:-:|:-:|-------|
| Heartbeat broadcast | DONE | NO | 60s interval, GUILD/PARTY channels |
| Peer registry | DONE | NO | 5 min timeout, dedup |
| Death verification | DONE | NO | Experimental, toggleable |
| Hash comparison | DONE | NO | Peer mismatch flagging |

### Plugin Trackers (Phase 0.5 scope)

| Tracker | Module Exists | Wired | Data Cap | Toggle Key |
|---------|:-:|:-:|:-:|------------|
| Gold | YES | NO | 500 | goldTracking |
| Kills | YES | NO | — | killTracking |
| Trades | YES | NO | 200 | tradeTracking |
| Mail | YES | NO | 200 | mailTracking |
| AH | YES | NO | 200 | ahTracking |
| Distance | YES | NO | — | distanceTracking |
| Professions | YES | NO | 100 | professionTracking |
| Equipment | YES | NO | 500 | equipmentTracking |
| Loot | YES | NO | 300 | lootTracking |

### UI Panels

| Panel | Implementation | Compat | Notes |
|-------|:-:|:-:|-------|
| Main panel (5 tabs) | DONE | WARN | BackdropTemplate polyfilled |
| Minimap button | DONE | OK | LDB + LibDBIcon standard |
| Settings (AceConfig) | DONE | OK | No compat issues |
| Death monitor widget | DONE | WARN | BackdropTemplate polyfilled |
| Lives panel | DONE | WARN | BackdropTemplate polyfilled |
| Checkpoint panel | DONE | WARN | BackdropTemplate polyfilled |
| Soft reset wizard | DONE | WARN | BackdropTemplate polyfilled |
| Debug panel (17 toggles) | DONE | WARN | BackdropTemplate polyfilled |

---

## Codebase Metrics

| Metric | Value |
|--------|-------|
| Addon Lua files | 34 |
| Total lines of code | ~8,200 |
| Library files | 17 (Ace3 + LDB + LibDBIcon) |
| Documentation files | 20 |
| Repeating timers (max) | 12 |
| Event chain depth (max) | 3 hops |
| Data table caps | 100–500 per tracker |
| Debug toggles | 17 (8 core + 9 tracker) |
| Compat polyfills | 6 |

---

## Open Blockers

| ID | Description | Impact | Owner |
|----|-------------|--------|-------|
| B-001 | CLEU polyfill untested on CMaNGOS | Death tracking may silently fail | Rick |
| B-002 | BackdropTemplate polyfill untested | All UI frames may fail to create | Rick |
| B-003 | IsInGroup polyfill untested | Network messaging broken for party | Rick |
| B-004 | GetInstanceInfo polyfill untested | Instance tracking + lives broken | Rick |
| B-005 | SetColorTexture polyfill untested | UI rendering + AceGUI broken | Rick |
| B-006 | Death detection E2E untested | Core feature unvalidated | Rick |

---

## Open Bugs (HIGH+)

| ID | Severity | Description | File |
|----|----------|-------------|------|
| BUG-001 | HIGH | sessions[] unbounded growth | Core.lua:192 |
| BUG-002 | HIGH | suspiciousFlags[] unbounded growth | UptimeTracker/VerificationTracker |

See [BACKLOG.md](BACKLOG.md) for full bug list.

---

## Pending Decisions

| ID | Topic | Deadline | Impact |
|----|-------|----------|--------|
| DEC-P01 | Database tech (Mongo vs Postgres) | Mar 31 | Backend architecture |
| DEC-P04 | Instance lives model (+1 vs tiered) | Mar 30 | Addon + website + docs |
| DEC-P03 | Companion app tech (Electron vs Tauri) | Mar 31 | Development velocity |

See [DECISION_LOG.md](DECISION_LOG.md) for full details.

---

## Risk Summary

| Risk | Severity | Likelihood | Status |
|------|----------|------------|--------|
| TBC 2.4.3 API compat failures | CRITICAL | MEDIUM | Polyfills written, testing pending |
| Feature creep delays April 30 | HIGH | HIGH | Strict MVP in place |
| Single developer (bus factor = 1) | HIGH | MEDIUM | Comprehensive docs mitigate |
| Community rejects premium model | HIGH | MEDIUM | Tier design emphasizes "never P2W" |

See [../risks.md](../risks.md) for full analysis.

---

_This dashboard is a snapshot. Consult BACKLOG.md for current task status and CHANGELOG.md for recent changes._
