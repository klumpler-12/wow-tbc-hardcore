# TBC Hybrid Hardcore — Pre-Testing Audit Report

> **Date:** 2026-03-17
> **Auditor:** Automated code review
> **Scope:** All addon source files — readiness for Phase 0 testing
> **Verdict:** ⚠️ READY WITH CAVEATS — 2 issues fixed, 6 warnings, 4 notes

---

## FIXED (applied during audit)

### FIX-1: Interface version wrong — CRITICAL ✅ FIXED
- **File:** `HardcorePlus.toc` line 1
- **Was:** `## Interface: 20504` (WoW Classic Era / SoM)
- **Now:** `## Interface: 20400` (TBC 2.4.3)
- **Impact:** Addon would not load on TBC 2.4.3 clients without "Load out of date addons" checked. Users wouldn't find it in the addon list by default.

### FIX-2: Protocol stat tracking inconsistent ✅ FIXED
- **File:** `Network/Protocol.lua`
- **Was:** `SendGuild()` and `SendGroup()` didn't call `TrackSent()`, while `SendWhisper()` and `SendAll()` did.
- **Now:** All four send functions track stats consistently.
- **Impact:** Debug panel network stats would undercount sent messages when using guild-only or group-only sends.

### FIX-3: .toc phase comments mismatched revised plan ✅ FIXED
- **Was:** Phase labels from original plan (Phase 1.5, 2-3, 4, 5)
- **Now:** Cleaned up to match revised structure. InstanceTracker no longer segregated.

---

## WARNINGS (should fix before Phase 1 testers)

### WARN-1: `CombatLogGetCurrentEventInfo()` called twice per CLEU
- **File:** `Tracking/DeathTracker.lua` lines 28, 36-37, 48-49, 59-60
- **Issue:** `CombatLogGetCurrentEventInfo()` returns values from the C stack. The first call at line 28 gets the base fields. Then for SWING_DAMAGE/SPELL_DAMAGE/ENVIRONMENTAL_DAMAGE, the function is called *again* to get extended fields. In TBC 2.4.3, `CombatLogGetCurrentEventInfo()` may not exist — CLEU passes args directly to the event handler. This is a **Classic Era 1.14+ / Wrath+ API pattern**.
- **Risk:** HIGH — on TBC 2.4.3 private servers (CMaNGOS), CLEU fires with arguments directly: `function(timestamp, subevent, ...)`. The `CombatLogGetCurrentEventInfo()` global may not exist.
- **Fix:** Change to receive args directly from the event function: `function(...) local timestamp, subevent, ... = ... end`, or check if `CombatLogGetCurrentEventInfo` exists and fall back to event args.
- **Workaround:** Most TBC private server cores (CMaNGOS, TrinityCore) do provide `CombatLogGetCurrentEventInfo()` for addon compat, but it's not guaranteed. Test on target server.

### WARN-2: `GetInstanceInfo()` may have different TBC 2.4.3 signature
- **File:** `Utils.lua` line 105
- **Issue:** `GetInstanceInfo()` in retail/Wrath returns `(name, type, difficultyID, difficultyName, maxPlayers, ...)`. In TBC 2.4.3, the function may only return `(name, type, difficulty, maxPlayers)` with `difficulty` as a number (1=Normal, 2=Heroic) without a string name.
- **Risk:** MEDIUM — `difficultyName` could be nil. Code handles this with fallback (`difficultyName or ""`), so no crash, but logging may show empty strings.
- **Fix:** Test on target server and verify return values.

### WARN-3: `C_Map.GetBestMapForUnit` may not exist in TBC 2.4.3
- **File:** `Utils.lua` line 143
- **Issue:** `C_Map` namespace was added in WoW 8.0 (BFA). TBC 2.4.3 does not have it.
- **Risk:** LOW — code already guards with `(C_Map and C_Map.GetBestMapForUnit and ...)` so it falls back to 0. No crash, but `mapID` will always be 0.
- **Note:** This is fine; mapID is informational only. No action needed unless future features need it.

### WARN-4: `BackdropTemplate` mixin may not exist in TBC 2.4.3
- **Files:** `UI/SetupWizard.lua` line 42, `UI/DeathMonitor.lua` line 30
- **Issue:** `BackdropTemplate` was introduced in WoW 9.0 (Shadowlands) when `SetBackdrop` was removed from base Frame. In TBC 2.4.3, frames have `SetBackdrop` natively and `BackdropTemplate` doesn't exist as a mixin.
- **Risk:** HIGH — `CreateFrame("Button", nil, parent, "BackdropTemplate")` will error if the template isn't registered.
- **Fix:** Remove `"BackdropTemplate"` from CreateFrame calls. In TBC 2.4.3, just use `CreateFrame("Frame", nil, parent)` and call `SetBackdrop()` directly (it's a native Frame method).

### WARN-5: `IsInGroup()` may not exist in TBC 2.4.3
- **File:** `Network/Protocol.lua` lines 166, 188
- **Issue:** `IsInGroup()` was added in WoW 5.0 (MoP). TBC 2.4.3 uses `GetNumPartyMembers() > 0` to check if in a party.
- **Risk:** HIGH on original TBC client, LOW on most private server cores (which backport it for addon compat). Test on target server.
- **Fix:** Add a compat wrapper: `local function IsInGroup() return (GetNumPartyMembers and GetNumPartyMembers() or 0) > 0 end`

### WARN-6: `IsInRaid()` return type may differ
- **File:** `Network/Protocol.lua` lines 166, 188
- **Issue:** Similar to WARN-5. TBC 2.4.3 has `IsInRaid()` but private server implementations may return 1/nil instead of true/false.
- **Risk:** LOW — Lua truthy/falsy handles both, but best to verify.

---

## NOTES (informational, no action needed now)

### NOTE-1: Data directory is empty
- **Path:** `Data/` — contains no files.
- **Status:** Harmless (not referenced in .toc). Can be used later for static data files.

### NOTE-2: No `SavedVariablesPerCharacter` in .toc
- **Current:** Uses `## SavedVariables: HardcorePlusDB` (global).
- **Why it's fine:** AceDB-3.0 handles per-char data internally via the `char` profile. The global SV file contains all data (global + per-char). This is the standard Ace3 pattern.

### NOTE-3: Checkpoint token self-claim check uses character key
- **File:** `Systems/Checkpoint.lua` line 116
- **Code:** `if token.sourceChar == HCP.Utils.GetPlayerKey() then` — prevents claiming your own token on the same character.
- **Question:** Is this intentional? The user said checkpoint is for "boosted, bought in store and always after lvl 58". If a player dies at 60 and rolls a new level 58, the *new* character has a different player key. This check only blocks the SAME character from claiming, which can't happen anyway (you'd need to be alive to claim). The check is harmless but effectively dead code.

### NOTE-4: Weekly pool reset timezone
- **File:** `Tracking/InstanceTracker.lua` lines 30-35
- **Issue:** Weekly reset calculation uses `time()` (local system time) offset by 4 days. Real WoW reset is region-specific (NA = Tuesday 10am PT, EU = Wednesday 8am CET). Private servers may vary.
- **Status:** Acceptable for alpha. Can be refined in Phase 1 once target server reset time is known.

---

## ARCHITECTURE ASSESSMENT

### Strengths
- **Clean separation of concerns:** Tracking, Systems, Network, UI are independent modules communicating via AceEvent messages. Textbook event bus pattern.
- **Debug toggles per-system:** Every module checks `HCP.Utils.IsSystemEnabled()` before processing. This is essential for testing — can isolate any system.
- **Defensive coding:** Null checks, fallbacks, debouncing (5s death debounce), grace periods (15 min gap threshold), and safety caps (`_suppressPlayedCountMax`).
- **Event-driven death flow:** `CLEU → DeathTracker → HCP_PLAYER_DEATH → InstanceTracker → HCP_INSTANCE_DEATH_RESOLVED → VerificationTracker`. Clean chain, easy to debug.
- **Network deduplication:** Multi-channel broadcasts (GUILD + PARTY/RAID) are deduped via `IsDuplicate()` with a 5s window.

### Potential Issues Under Load
- **Peer registry grows unbounded:** `HCP.db.global.peerRegistry` never expires old entries. After months of play, could grow large. Add TTL-based cleanup in Phase 1.
- **Kill tracking not implemented yet:** `COMBAT_LOG_EVENT_UNFILTERED` only watches for damage-to-player and UNIT_DIED. No mob kill counter, no XP tracking. Listed in revised plan as Phase 0.5 work.
- **Trade/Mail/AH tracking not implemented yet:** Event hooks exist in the plan but no module code yet. Phase 0.5 work.
- **Distance tracking not implemented:** No polling for player position. Phase 0.5 work.

---

## TESTING READINESS VERDICT

| Area | Ready? | Blockers |
|------|--------|----------|
| Installation & load | ⚠️ | WARN-4 (BackdropTemplate) may crash UI creation on some TBC cores |
| Death tracking | ⚠️ | WARN-1 (CLEU API) — test on target server immediately |
| Instance lifes | ✅ | Logic complete, all 14 instances defined, GetBonusLives works |
| Checkpoint system | ✅ | Token generation, claiming, expiry, cleanup all implemented |
| Soft reset | ✅ | Full strip verification, time window, item restoration detection |
| Network/heartbeat | ⚠️ | WARN-5 (IsInGroup compat) — test on target server |
| Setup wizard | ⚠️ | WARN-4 (BackdropTemplate) |
| Status state machine | ✅ | All transitions validated, invalid ones blocked |
| Uptime/gap detection | ✅ | /played suppression, gap analysis, violation tiers |
| SavedVariables | ✅ | AceDB defaults comprehensive, corruption recovery natural via AceDB |
| Comprehensive tracking | ❌ | Only deaths/sessions/inventory tracked. Kills, gold, trades, distance, professions, AH, mail modules not yet written (Phase 0.5 scope) |

### Immediate Actions Before First Test Session
1. **Test `CombatLogGetCurrentEventInfo()` on target CMaNGOS server** — if it doesn't exist, the addon will silently fail to track deaths (no error, just empty recentDamage).
2. **Test `BackdropTemplate` on target server** — if it errors, UI frames won't create. Fix: remove the template string from CreateFrame calls.
3. **Test `IsInGroup()` on target server** — if it errors, network messaging will fail for party groups.

---

*This audit covers code quality and API compatibility. Functional testing should follow the TESTING_CHECKLIST.md (287 items).*
