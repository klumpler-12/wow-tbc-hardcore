# Backlog

Prioritized task list for TBC Hybrid Hardcore. Updated as work progresses.
Priority: P0 (blocker) → P1 (must-have) → P2 (should-have) → P3 (nice-to-have) → P4 (deferred).

_Last updated: 2026-03-17_

---

## Phase 0 — Pre-Alpha PoC (Mar 17–23)

### P0 — Blockers

| ID | Task | Owner | Status | Notes |
|----|------|-------|--------|-------|
| B-001 | Validate Compat.lua CLEU polyfill on CMaNGOS | Rick | TODO | CombatLogGetCurrentEventInfo() may not exist; StoreCLEUArgs() is the fallback |
| B-002 | Validate BackdropTemplate polyfill on CMaNGOS | Rick | TODO | CreateBackdropFrame() replaces all 18 occurrences |
| B-003 | Validate IsInGroup()/IsInRaid() polyfill on CMaNGOS | Rick | TODO | Network messaging depends on this |
| B-004 | Validate GetInstanceInfo() polyfill on CMaNGOS | Rick | TODO | Instance tracking + lives depend on this |
| B-005 | Validate SetColorTexture() polyfill on CMaNGOS | Rick | TODO | UI rendering + AceGUI depend on this |
| B-006 | Test death detection end-to-end (die → record → UI update) | Rick | TODO | Core feature gate |

### P1 — Must-Have for Phase 0 Sign-Off

| ID | Task | Owner | Status | Notes |
|----|------|-------|--------|-------|
| P0-001 | Run full TESTING_CHECKLIST.md sections 1–5 (install, minimap, UI, wizard, death) | Rick | TODO | 287-item checklist, sections 1-5 = ~80 items |
| P0-002 | Test checkpoint flow (die at 58+ → token → new char claims) | Rick | TODO | Cross-character interaction |
| P0-003 | Test instance lives flow (enter heroic → lives widget → die → life consumed) | Rick | TODO | Needs target server heroic access |
| P0-004 | Test 2-player network flow (heartbeats, peer detection, death verification) | Rick | TODO | Requires 2 clients |
| P0-005 | Test soft reset full cycle (die → strip → verify → re-register) | Rick | TODO | Complex multi-step flow |
| P0-006 | Fix sessions table unbounded growth in Core.lua:192 | — | TODO | Add cap (e.g. 200 sessions) |
| P0-007 | Fix suspiciousFlags unbounded growth in UptimeTracker + VerificationTracker | — | TODO | Add cap (e.g. 500 flags) |

### P2 — Should-Have

| ID | Task | Owner | Status | Notes |
|----|------|-------|--------|-------|
| P0-008 | Test gap detection (logout 20 min → login → violation flagged) | Rick | TODO | UptimeTracker validation |
| P0-009 | Test Soul of Iron detection (buff applied → status VERIFIED) | Rick | TODO | Needs SoI buff on server |
| P0-010 | Verify SavedVariables persistence across /reload and relog | Rick | TODO | AceDB reliability check |
| P0-011 | Test debug panel toggle isolation (disable system → verify no processing) | Rick | TODO | All 17 toggles |

---

## Phase 0.5 — Clean Rebuild (Mar 24–30)

### P1 — Must-Have

| ID | Task | Owner | Status | Notes |
|----|------|-------|--------|-------|
| P05-001 | Wire GoldTracker (PLAYER_MONEY event → snapshots → data cap) | — | TODO | Module exists, needs implementation |
| P05-002 | Wire KillTracker (PARTY_KILL via hidden frame → kill log → data cap) | — | TODO | Rewritten, needs validation |
| P05-003 | Wire TradeTracker (TRADE events → log trades → data cap) | — | TODO | Module exists |
| P05-004 | Wire MailTracker (MAIL events → log sends/receives → data cap) | — | TODO | Module exists |
| P05-005 | Wire AHTracker (AH events → visit duration → data cap) | — | TODO | Module exists |
| P05-006 | Wire DistanceTracker (ZONE_CHANGED → zone set tracking) | — | TODO | Module exists |
| P05-007 | Wire ProfessionTracker (SKILL_LINES_CHANGED → snapshots → data cap) | — | TODO | Module exists |
| P05-008 | Wire EquipmentTracker (PLAYER_EQUIPMENT_CHANGED → change log → data cap) | — | TODO | Module exists |
| P05-009 | Wire LootTracker (LOOT events → item log → data cap) | — | TODO | Module exists |
| P05-010 | Memory benchmark: measure addon memory under normal play (<2 MB target) | — | TODO | Use /run UpdateAddOnMemoryUsage() |
| P05-011 | FPS benchmark: verify no measurable drop with all systems enabled | — | TODO | Use /run GetFramerate() in combat |
| P05-012 | Validate all 9 tracker data caps actually fire under load | — | TODO | Generate test data |

### P2 — Should-Have

| ID | Task | Owner | Status | Notes |
|----|------|-------|--------|-------|
| P05-013 | UI visual pass: consistent colors, spacing, font sizes | — | TODO | Match HCP.Colors palette |
| P05-014 | Review AceGUI-3.0 TBC compatibility (SetColorTexture in library) | — | TODO | 3 internal occurrences |
| P05-015 | Add TTL-based peer registry cleanup (age out after 30 days) | — | TODO | Heartbeat.lua |
| P05-016 | Decide instance lives model: +1 bonus vs. tiered (Easy/Hard/Brutal) | — | TODO | Website/addon mismatch |

---

## Phase 1 — Semi-Private Alpha (Mar 31 – Apr 20)

### P1 — Must-Have

| ID | Task | Owner | Status | Notes |
|----|------|-------|--------|-------|
| P1-001 | Recruit 10–20 testers from target guild/community | Rick | TODO | — |
| P1-002 | Full bug-fix cycle from Phase 0/0.5 testing | — | TODO | — |
| P1-003 | Run TESTING_CHECKLIST.md sections 6–15 (all remaining) | — | TODO | ~207 items |
| P1-004 | Cross-guild network sync (basic peer discovery beyond party/guild) | — | TODO | May need WHISPER channel |
| P1-005 | Scoring engine skeleton (record scores, no display yet) | — | TODO | Phase 3 displays |

### P2 — Should-Have

| ID | Task | Owner | Status | Notes |
|----|------|-------|--------|-------|
| P1-006 | Companion app prototype (Electron, SavedVariables file watcher) | — | TODO | Node.js backend dependency |
| P1-007 | Backend skeleton (Node.js/Express, basic API endpoints) | — | TODO | Database choice pending |
| P1-008 | Addon error reporting (structured error log for tester feedback) | — | TODO | — |
| P1-009 | Localization framework (English strings extracted, German translation stub) | — | TODO | — |

---

## Phase 2 — Public Alpha (Apr 21–30)

### P0 — Blockers

| ID | Task | Owner | Status | Notes |
|----|------|-------|--------|-------|
| P2-001 | CurseForge account setup and addon listing | Rick | TODO | Requires packaging |
| P2-002 | Release packaging (.zip with correct folder structure) | — | TODO | Exclude dev files |
| P2-003 | Hotfix pipeline (git tag → build → upload) | — | TODO | — |
| P2-004 | All P0/P1 bugs from Phase 1 testing resolved | — | TODO | Gate check |

### P1 — Must-Have

| ID | Task | Owner | Status | Notes |
|----|------|-------|--------|-------|
| P2-005 | Public-facing website updated to match addon state | — | TODO | Fix WEBSITE_LOGIC_ERRORS.md items |
| P2-006 | SETUP.txt and README updated for public audience | — | TODO | — |
| P2-007 | Basic leaderboard (addon-only, no web yet) | — | TODO | — |

---

## Phase 3+ — Post-Alpha (Deferred)

All items below are **not scheduled** and will be prioritized after public alpha launch.

| ID | Feature | Priority | Notes |
|----|---------|----------|-------|
| P3-001 | Scoring system (complex multipliers + simple fixed) | P3 | Needs community input |
| P3-002 | Web dashboard (React 18) | P3 | Full stack deployment |
| P3-003 | Fractions & houses system | P3 | Premium feature |
| P3-004 | Draft system (snake/auction) | P3 | Depends on fractions |
| P3-005 | Mini-games framework | P4 | Premium feature |
| P3-006 | Custom achievements designer | P4 | Web dashboard dependency |
| P3-007 | Custom punishments & rewards | P4 | Web dashboard dependency |
| P3-008 | Guild web profiles | P3 | Premium feature |
| P3-009 | Advanced analytics | P4 | Backend dependency |
| P3-010 | Monetization activation (Patreon/premium unlock) | P3 | Distribution method pending |
| P3-011 | Challenge modes (Onlyfists, Flex Raiding, Fishing Frenzy) | P4 | Premium feature |

---

## Bug Tracker

Active bugs and issues. Resolved bugs moved to CHANGELOG.md.

| ID | Severity | Description | File | Status |
|----|----------|-------------|------|--------|
| BUG-001 | HIGH | sessions[] table grows unbounded | Core.lua:192 | OPEN |
| BUG-002 | HIGH | suspiciousFlags[] table grows unbounded | UptimeTracker.lua, VerificationTracker.lua | OPEN |
| BUG-003 | MEDIUM | checkpointTokens[] relies on expiry for cleanup, no hard cap | Checkpoint.lua | OPEN |
| BUG-004 | MEDIUM | Per-instance death lists grow without cap | InstanceTracker.lua | OPEN |
| BUG-005 | MEDIUM | peerFlags[] per player grows unbounded | Network/Verification.lua:224 | OPEN |
| BUG-006 | LOW | Weekly pool reset uses local time, not server reset | InstanceTracker.lua:30-35 | OPEN |
| BUG-007 | INFO | Checkpoint sourceChar check is dead code | Checkpoint.lua:116 | OPEN |
| BUG-008 | WARN | SETUP.txt file structure section lists 34 files but only names 24 | SETUP.txt:140-150 | OPEN |

---

_Next review: End of Phase 0 (Mar 23)_
